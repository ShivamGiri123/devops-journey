# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.Webserver_VPC.id
}

# Subnet ID
output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.webserver_subnet.id
}

# Security Group ID
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.webserver_sg.id
}

# EC2 Instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.webserver.id
}

# EC2 Public IP
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.webserver.public_ip
}

# Website URL
output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.webserver.public_ip}"
}
