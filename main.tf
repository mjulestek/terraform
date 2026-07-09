provider "aws" {
  region = "eu-central-1"
}

 variable "subnet_cidr-block" {
  description = "The CIDR block for the subnet"
}

variable "avail_zone" {}


resource "aws_vpc" "development_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "development_vpc"
  }
}


resource "aws_subnet" "development_subnet-1" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = var.subnet_cidr-block
  availability_zone = var.avail_zone
  tags = {
    Name = "development_subnet-1"
  }
}

output "vpc_id" {
  value = aws_vpc.development_vpc.id
}

output "subnet_id" {
  value = aws_subnet.development_subnet-1.id
}
