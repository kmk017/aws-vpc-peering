resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  auto_accept = true

  tags = { Name = "ewb-a-b-peer" }
}

resource "aws_route" "route_a_public_to_b" {
  count                     = var.enable_peering_routes ? 1 : 0
  route_table_id            = aws_route_table.rt_a_public.id
  destination_cidr_block    = aws_vpc.vpc_b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_a_private_to_b" {
  count                     = var.enable_peering_routes ? 1 : 0
  route_table_id            = aws_route_table.rt_a_private.id
  destination_cidr_block    = aws_vpc.vpc_b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_b_private_to_a" {
  count                     = var.enable_peering_routes ? 1 : 0
  route_table_id            = aws_route_table.rt_b_private.id
  destination_cidr_block    = aws_vpc.vpc_a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
