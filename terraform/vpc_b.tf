resource "aws_vpc" "vpc_b" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "ewb-vpc-b" }
}

resource "aws_subnet" "subnet_b_private" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = { Name = "ewb-b-private" }
}

resource "aws_route_table" "rt_b_private" {
  vpc_id = aws_vpc.vpc_b.id
  tags   = { Name = "ewb-rt-b-private" }
}

resource "aws_route_table_association" "rtb_private" {
  subnet_id      = aws_subnet.subnet_b_private.id
  route_table_id = aws_route_table.rt_b_private.id
}
