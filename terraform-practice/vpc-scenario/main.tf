#provider
provider "aws" {
region = "us-east-1"
}
#VPC
resource "aws_vpc" "webserver" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support = true

tags = {
Name = "Practice-vpc"
}
}
#public subnet
resource "aws_subnet" "subnet" {
vpc_id = aws_vpc.webserver.id
cidr_block = "10.0.0.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true

tags = {
Name = "Public-subnet"
}
}
#Internet_gateway
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.webserver.id

tags = {
Name = "webserver-igw"
}
}
#route table
resource "aws_route_table" "Route-table" {
vpc_id = aws_vpc.webserver.id

route{
cidr_block = "0.0.0.0/0"
gateway_id=aws_internet_gateway.igw.id
}
tags = {
Name = "public-routetable"
}
}
#route table association
resource "aws_route_table_association" "RTA" {
subnet_id = aws_subnet.subnet.id
route_table_id = aws_route_table.Route-table.id
}
#output 
output "vpc_id" {
value = aws_vpc.webserver.id
}
#output
output "subnet_id" {
value = aws_subnet.subnet.id
}

