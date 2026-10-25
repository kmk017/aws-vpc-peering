resource "aws_vpc" "vpc_a" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "ewb-vpc-a" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_az = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "subnet_a_public" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = { Name = "ewb-a-public" }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = { Name = "ewb-a-private" }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "ewb-igw-a" }
}

resource "aws_route_table" "rt_a_public" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }

  tags = { Name = "ewb-rt-a-public" }
}

resource "aws_route_table_association" "rta_public" {
  subnet_id      = aws_subnet.subnet_a_public.id
  route_table_id = aws_route_table.rt_a_public.id
}

resource "aws_route_table" "rt_a_private" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "ewb-rt-a-private" }
}

resource "aws_route_table_association" "rta_private" {
  subnet_id      = aws_subnet.subnet_a_private.id
  route_table_id = aws_route_table.rt_a_private.id
}
