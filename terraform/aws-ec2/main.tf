terraform{
 required_providers{
  aws = {
    source = "hashicorp/aws"
    version = "~>5.0"
  }
 }
}

provider "aws" {
region = "us-east-1"
}
resource "aws_instance" "devops_ec2" {	
  ami = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t3.micro"
  key_name = "forawspractice"

tags = {
  Name = "terraform-devops-ec2"
  Enviroment = "practice"
 }
}  
