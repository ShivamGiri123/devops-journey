#provider
provider "aws" {
region = "us-east-1"
}

#data source from amazon to create amazon linux machine
data "aws_ami" "linux-machine" {
most_recent = true
owners = ["amazon"]

filter{
	name = "name"
	values = ["amzn2-ami-hvm-*-x86_64-gp2"]
}
}
#security group
resource "aws_security_group" "web-sg" {
#name = "aws-security-group"
#description = "Allow SSH and HTTP"
vpc_id = aws_vpc.public.id

#ingress ssh
ingress{
description = "SSH"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

#ingress http
ingress{
description = "HTTP"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
#egress all
egress{
description = "All"
from_port = 0
to_port = 0
protocol = -1
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "web-sg"
}
}
#Ec2 Server
resource "aws_instance" "web" {
ami_id = data.aws_ami.linux-machine.id
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet.id
vpc_security_group_id = [aws_security_group.web-sg.id]

tags = {
Name = "web-sg"
}
}
#output
output "aws_instance_id" {
value = aws_instance.web.id
}
#output
output "aws_public_ip"{
value = "aws_instance.web.ip"
}
