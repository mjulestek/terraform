resource "aws_default_security_group" "default_myapp_security_group" {
  vpc_id = var.vpc_id

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
    values = [var.image_name]
  }

}

resource "aws_key_pair" "myapp_ssh_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}


resource "aws_instance" "myapp_instance" {
  ami                         = data.aws_ami.latest_ubuntu_image.id
  instance_type               = var.instance_type
  availability_zone           = var.avail_zone

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_default_security_group.default_myapp_security_group.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.myapp_ssh_key_pair.key_name

 user_data = file("${path.module}/user_data_script.sh")

  user_data_replace_on_change = true


  tags = {
    Name = "${var.env_prefix}-myapp-instance"
  }

  }
  


