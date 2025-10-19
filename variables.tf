variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project tag/name"
  type        = string
  default     = "auto-provision-ec2"
}

variable "page_title" {
  description = "Title used in the demo HTML page"
  type        = string
  default     = "Hello from Cloud-Init on EC2"
}

variable "enable_ssh" {
  description = "If true, open SSH from your IP (set my_ip_cidr)"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "otto-ec2"
}

variable "public_key" {
  description = "SSH public key text"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR format (e.g., 203.0.113.5/32)"
  type        = string
  default     = ""
}
