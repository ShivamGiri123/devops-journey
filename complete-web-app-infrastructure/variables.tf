variable "aws_region" {
description = "AWS-Region"
type = string
default = "us-east-1"

variable "project_name" {
description = "Project name for tagging" 
type = string
default = "webapp"

variable "vpc_cidr" {
description = "VPC CIDR Block"
type = string
default = "10.0.0.0/16"

variable "public_subnet_cidrs" {
description = "public subnet cidrs blocks"
type = list(string)
default = ["10.0.1.0/24" , "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
description = "private subnet cidrs blocks"
type = list(string)
default = ["10.0.10.0/24" , "10.0.11.0/24"]
}

variable "availablity_zones" {
description = "availability zone"
type = list(string)
default = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
description = "ec2 instance type"
type = sring
default = "t2.micro"
}

variable "db_username" {
description = "DB username"
type = string
default = "admin"

variable "db_password" {
description = "DB Password"
type = string
default = "MySecurePassword123!"
sensitive = true
}
  
