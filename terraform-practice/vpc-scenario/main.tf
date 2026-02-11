#provider
provider "aws" {
region = "us-east-1"
}

#VPC
resource "aws_vpc" "public" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support = true 

tags = {
Name = "Practice-module"
}
}
#subnet
resource "aws_subnet" "subnet" {
vpc_id = aws_vpc.public.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true

tags = {
Name = "public-subnet"
}
}
#Internet Gateway
resource "aws_internet_gateway" "IGW" {
vpc_id = aws_vpc.public.id

tags = {
Name = "Internet-gateway"
}
}
#route table
resource "aws_route_table" "ART" {
vpc_id = aws_vpc.public.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW.id
}

tags = {
Name = "IGW route table"
}
}
#route table association
resource "aws_route_table_association" "RTA" {
subnet_id = aws_subnet.subnet.id
route_table_id = aws_route_table.ART.id 
}
#output
output "vpc_id" {
value = aws_vpc.public.id
}
#output
output "subnet_id" {
value = aws_subnet.subnet.id
}


