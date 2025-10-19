output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IPv4 of the EC2 instance"
}

output "public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS name of the EC2 instance"
}

output "http_url" {
  value       = "http://${aws_instance.web.public_ip}"
  description = "Convenience URL for the demo site"
}
