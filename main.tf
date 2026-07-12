provider "aws" {
  region = "eu-central-1"
}


resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-myapp-vpc"
  }
}

module "subnets" {
  source                 = "./modules/subnets"
  vpc_id                 = aws_vpc.myapp_vpc.id
  subnet_cidr_block      = var.subnet_cidr_block
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
}


module "instances" {
  source        = "./modules/instances"
  avail_zone    = var.avail_zone
  image_name    = var.image_name
  instance_type = var.instance_type
  vpc_id        = aws_vpc.myapp_vpc.id
  subnet_id     = module.subnets.subnet_output.id

  env_prefix      = var.env_prefix
  my_ip_address   = var.my_ip_address
  public_key_path = var.public_key_path
  key_name        = var.key_name


}


