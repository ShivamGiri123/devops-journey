#provider
provider "aws" {
region = "us-east-1"
}
#Data source Ami for linux machine
data "aws_ami" "web" {
most_recent = true
owners = ["amazon"]

filter{
name = "name"
values = ["amzn2-ami-hvm-*-x86_64-gp2"]
}
}

#security group
resource "aws_security_group" "web-sg" {
vpc_id = aws_vpc.public.id

#inbound ssh
ingress {
description = "ssh"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
#inbound http
ingress {
description = "http"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
#Outbound all
egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
#vpc
resource "aws_vpc" "public" {
cidr_block = "0.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support = true

tags = {
Name = "Public-VPC"
}
}
#Subnet
resource "aws_subnet" "subnet" {
vpc_id = aws_vpc.public.id
cidr_block = "0.0.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true

tags = {
Name = "vpc-subnet"
}
}
#Internet Gateway
resource "aws_internet_gateway" "IGW" {
vpc_id = aws_vpc.public.id

tags = {
Name = "IGW"
}
}
#Ec2 instance
resource "aws_instance" "web-server" {
ami = data.aws_ami.web.id
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet.id
vpc_security_group_ids = aws_security_group.web-sg.id
}
#Route table
resource "aws_route_table" "ART" {
vpc_id = aws_vpc.public.id
route{
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW.id
}
}
#Route table association
resource "aws_route_table_association" "RTA" {
subnet_id = aws_subnet.subnet.id
route_table_id = aws_route_table.ART.id
}

#Output
output "VPC_ID" {
value = aws_vpc.public.id
}
output "Subnet_ID" {
value = aws_subnet.subnet.id
}
output "aws_instance_id" {
value = aws_instance.web-server.id
}
output "aws_instance_public_ip" {
value = aws_instance.web-server.public_ip 
}
