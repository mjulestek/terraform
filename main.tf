provider "aws" {
  region = "eu-central-1"
}


variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip_address" {}
variable "instance_type" {}
variable "public_key_path" {}
variable "key_name" {}



resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-myapp-vpc"
  }
}


resource "aws_subnet" "myapp_subnet-1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-myapp-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_internet_gateway" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.env_prefix}-myapp-internet-gateway"
  }
}

resource "aws_default_route_table" "myapp_default_route_table" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_internet_gateway.id
  }
  tags = {
    Name = "${var.env_prefix}-myapp-default-route-table"
  }
}

resource "aws_route_table_association" "myapp_route_table_association" {
  subnet_id      = aws_subnet.myapp_subnet-1.id
  route_table_id = aws_default_route_table.myapp_default_route_table.id
}


resource "aws_default_security_group" "default_myapp_security_group" {
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-default-myapp-security-group"
  }
}


data "aws_ami" "latest_ubuntu_image" {
  most_recent = true
  owners      = ["099720109477"] # amazon owner ID for Ubuntu images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-**"]
  }

}

output "aws_ami_id" {
  value = data.aws_ami.latest_ubuntu_image.id
}

resource "aws_key_pair" "myapp_ssh_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}


resource "aws_instance" "myapp_instance" {
  ami                         = data.aws_ami.latest_ubuntu_image.id
  instance_type               = var.instance_type
  availability_zone           = var.avail_zone
  subnet_id                   = aws_subnet.myapp_subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default_myapp_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.myapp_ssh_key_pair.key_name

  user_data = file("user_data_script.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "${var.env_prefix}-myapp-instance"
  }

  }

output "myapp_instance_public_ip" {
  value = aws_instance.myapp_instance.public_ip
}
