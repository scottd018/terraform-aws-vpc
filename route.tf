#
# public subnet routes
#
resource "aws_route_table" "public" {
  count = var.vpc_connectivity != "private" ? 1 : 0

  vpc_id = aws_vpc.managed.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway[0].id
  }

  tags = merge(
    local.route_table_tags,
    { "Name" = "${var.vpc_name}-public" }
  )
}

resource "aws_route_table_association" "public" {
  count = var.vpc_connectivity != "private" ? var.subnet_count : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

#
# private subnet routes
#
resource "aws_route_table" "private" {
  count = var.subnet_count

  vpc_id = aws_vpc.managed.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[count.index].id
  }

  tags = merge(
    local.route_table_tags,
    { "Name" = "${var.vpc_name}-private-${aws_subnet.private[count.index].availability_zone}" }
  )
}

resource "aws_route_table_association" "private" {
  count = var.subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#
# vpn subnet routes
#
resource "aws_vpn_connection_route" "local" {
  count = var.vpc_connectivity == "vpn" ? length(var.vpn_local_networks) : 0

  destination_cidr_block = var.vpn_local_networks[count.index]
  vpn_connection_id      = aws_vpn_connection.vpn[0].id
}

resource "aws_route" "vpn_public" {
  count = var.vpc_connectivity == "vpn" ? length(var.vpn_local_networks) : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = var.vpn_local_networks[count.index]
  gateway_id             = aws_vpn_gateway.vpn[0].id
}

resource "aws_route" "vpn_private" {
  count = var.vpc_connectivity == "vpn" ? length(var.vpn_local_networks) : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = var.vpn_local_networks[count.index]
  gateway_id             = aws_vpn_gateway.vpn[0].id
}

/* resource "aws_route_table" "vpn" {
  count = var.vpc_connectivity == "vpn" ? var.subnet_count : 0

  vpc_id = aws_vpc.managed.id

  dynamic "route" {
    for_each = tolist(var.vpn_local_networks)

    content {
      cidr_block = route.value
      gateway_id = aws_vpn_gateway.vpn[0].id
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpn_gateway.vpn[0].id
  }

  tags = merge(
    local.route_table_tags,
    { "Name" = "${var.vpc_name}-vpn-${aws_subnet.private[count.index].availability_zone}" }
  )
}

resource "aws_route_table_association" "vpn" {
  count = var.vpc_connectivity == "vpn" ? var.subnet_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.vpn[count.index].id
} 

*/
