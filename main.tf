terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the account's default VPC so we don't have to build networking for this lab.
data "aws_vpc" "default" {
  default = true
}

# Latest Ubuntu 22.04 LTS (Jammy) AMI in the selected region.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Optional: compute your custom HTML once, then inject via cloud-init.
locals {
  index_html = templatefile("${path.module}/index.html.tftpl", {
    page_title   = var.page_title
    project_name = var.project_name
  })

  index_html_indented   = indent(6, local.index_html)
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP${var.enable_ssh ? " and SSH" : ""}"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #  ipv6_cidr_blocks = ["::/0"]
  }

  # Optionally allow SSH from your IP when enable_ssh=true
  dynamic "ingress" {
    for_each = var.enable_ssh && var.my_ip_cidr != "" ? [1] : []
    content {
      description = "SSH from my IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #  ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_key_pair" "ec2" {
  count      = var.enable_ssh ? 1 : 0
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.enable_ssh ? aws_key_pair.ec2[0].key_name : null

  vpc_security_group_ids = [aws_security_group.web.id]

  # Cloud-init user data: installs nginx and writes your HTML
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    html         = local.index_html_indented
    project_name = var.project_name
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-web"
    Project = var.project_name
  }
}
