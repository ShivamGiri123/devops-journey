#provider
provider "aws" {
region = var.aws_region
}

#data source for linux machine in linux 2 amin
data "aws_ami" "amazon_linux" {
most_recent = true
owners = ["amazon"]

filter {
name = "name"
ami_id = ["amzn2-ami-*-x86_64-gp2"]
}
}

#VPC
resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr
enable_dns_hostnames = true
enable_dns_support = true

tags = {
Name = "${var.project_name}-vpc"
}
}

#Internetgateway
resource "aws_internet_gateway" "IGW" {
vpc_id = aws_vpc.main.id

tags = {
Name = "$(var.project_name)-IGW"
}
}

#Public Subnet
resource "aws_subnet" "public" {
count = length(var.public_subnet_cidr)
vpc_id = aws_vpc.main.id
cidr_block = var.public_subnet_cidrs[count.index]
availablity_zone = var.public_availablity_zones[count.index]
map_public_ip_on_launch = true

tags = {
Name = "${var.project_name}-public-subnet-${count.index+1}"
}
}

#Private Subnet
resource "aws_subnet" "private" {
count = length(var.private_subnet_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.private_subnet_cidrs[count.index]
availability_zone = var.availability_zones[count.index]
map_public_ip_on_launch = true

tags = {
Name = "${var.project_name}-private-subnet-${count.index+1}"
}
}
#public Route table 
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id

route{
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW.id
}
}
#public Route table association
resource "aws_route_table_association" "public" {
count = length(aws_subnet.public)
subnet_id = var.aws_subnet.public[count.index].id
route_table_id = aws_route_table.public.id
}
#security group for ALB
resource "aws_securtiy_group" "alb" {
name = "${var.project_name}-alb-sg"
description = "security group for Application LB"
vpc_id = aws_vpc.main.id

ingress{
description = "HTTP from anywhere"
from_port = 80
to_port = 80 
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
#security group for web servers
resource "aws_security_group" "web" {
name = "${var.project_name}-web-sg"
description = "security group for web servers"
vpc_id = aws_vpc.main.id

ingress {
description = "HTTP from ALB"
from_port = 80
to_port = 80
protocol = "tcp"
security_groups = [aws_security_group.alb.id]
}
ingress {
description = "SSH from Bastion"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"]
}
egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = [0.0.0.0/0]
}
}
#security group for RDS
resource "aws_security_group" "rds" {
vpc_id =aws_vpc.main.id

ingress{
description = "MySQL from web server"
from_port = 3306
to_port = 3306
protocol = "tcp"
security_groups = [aws_security_group.web.id]
}
egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
#launch templete for web servers
resource "aws_launch_template" "web" {
name_prefix = "${var.project_name}-web-"
image_id = data.aws_ami.amazon_linux.id
instance_type = var.instance_type
vpc_security_group_ids = [aws_security_group.web.id]

user_data = base64encode(<<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
            EOF
)
tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-server"
    }
  }
}
#application load balancer
resource "aws_lb" "main" {
name = "${var.project_name}-alb"
internal = false
load_balancer_type = "application"
security_groups = [aws_security_group.alb.id]
subnets = aws_subnet.public[*].id
}

#target group
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}
# Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  health_check_type   = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  
  db_name  = "webapp"
  username = var.db_username
  password = var.db_password
  
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  tags = {
    Name = "${var.project_name}-db"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-static-files-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}



