#provider
provider "aws" {
region = "us-east-1"
}
#VPC
resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support =true

tags = { 
Name = "AWS_VPC"
}
}
#subnet
resource "aws_subnet" "subnet" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.0.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true

tags = {
Name = "AWS-Subnet"
}
}
#Internet_connectivity
resource "aws_internet_gateway" "IGW" {
vpc_id = aws_vpc.main.id
}

#route table 
resource "aws_route_table" "ART" {
vpc_id = aws_vpc.main.id

route{
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW.id
}
}
#route table assoication 
resource "aws_route_table_association" "RTA" {
subnet_id = aws_subnet.subnet.id
route_table_id = aws_route_table.ART.id
}
#amazon ami for linux machine
data "aws_ami" "linux" {
most_recent = true
owners = ["amazon"]

filter{
	name = "name"
	values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }
}
#security group
resource "aws_security_group" "web-sg" {
vpc_id = aws_vpc.main.id 

ingress {
description = "HTTP"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "SSH"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
#EC2 instance
resource "aws_instance" "web" {
ami = data.aws_ami.linux.id
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet.id
vpc_security_group_ids = ["aws_security_group.web-sg.id"]

tags = {
Name = "EC2-Instance"
}
}
#output
output "aws_public_ip" {
value = aws_instance.web.public_ip
}

