

resource "aws_subnet" "myapp_subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-myapp-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-myapp-internet-gateway"
  }
}



resource "aws_default_route_table" "myapp_default_route_table" {
  default_route_table_id = var.default_route_table_id
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
