#provider
provider "aws" {
region = "us-east-1"
}
#data used for creating linux machine
data "aws_ami" "web" {
most_recent = true
owners = ["amazon"]

filter {
name = "name"
values = ["amzn2-ami-hvm-*-x86_84-gp2"]
}
}
#vpc
resource "aws_vpc" "public" {
cidr_block = "0.0.0.0/16"
enable_dns_support = true
enable_dns_hostnames = true

tags = {
name = "AWS-VPC"
}
}

#security group
resource "aws_security_group" "web-sg" {
vpc_id = aws_vpc.public.id
#inbound ssh trafic
ingress{
description = "ssh"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
#inbound http traffic
ingress{
description = "HTTP"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
#outbound all
egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
#subnet
resource "aws_subnet" "subnet" {
cidr_block = "0.0.1.0/24"
availability_zone = "us-east-1a"
vpc_id = aws_vpc.public.id
map_public_ip_on_launch = true
tags = {
Name = "AWS_Subnet"
}
}
#ec2 instance
resource "aws_instance" "web" {
ami = data.aws_ami.web.id
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet.id
vpc_security_group_ids = aws_security_group.web-sg.id
}
#output
output "instance_id" {
value = aws_instance.web.id
}
output "public_ip" {
value = aws_instance.web.public_ip
}
