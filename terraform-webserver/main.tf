provider "aws" {
  region = "us-east-1"
  }

resource "aws_vpc" "Webserver_VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

tags = {
  Name = "Webserver_VPC"
}
}
# Internet Gateway
resource "aws_internet_gateway" "webserver_igw" {
  vpc_id = aws_vpc.Webserver_VPC.id

  tags = {
    Name = "webserver-igw"
  }
}
# Subnet (Public)
resource "aws_subnet" "webserver_subnet" {
  vpc_id                  = aws_vpc.Webserver_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "webserver-public-subnet"
  }
}
# Route Table
resource "aws_route_table" "webserver_rt" {
  vpc_id = aws_vpc.Webserver_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webserver_igw.id
  }

  tags = {
    Name = "webserver-route-table"
  }
}

# Route Table Association (Connect route table to subnet)
resource "aws_route_table_association" "webserver_rta" {
  subnet_id      = aws_subnet.webserver_subnet.id
  route_table_id = aws_route_table.webserver_rt.id
}
# Security Group
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-security-group"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.Webserver_VPC.id

  # Inbound rule - Allow HTTP (port 80) from anywhere
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule - Allow SSH (port 22) from anywhere
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule - Allow all traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver-sg"
  }
}
# EC2 Instance (Web Server)
resource "aws_instance" "webserver" {
  ami                    = "ami-026992d753d5622bc"  # Amazon Linux 2 AMI (us-east-1)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.webserver_subnet.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform Web Server!</h1>" > /var/www/html/index.html
              echo "<p>Server IP: $(hostname -I)</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-webserver"
  }
}
