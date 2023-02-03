resource "aws_route_table" "public" {
  count = var.vpc_connectivity == "public" ? 1 : 0

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
  count = var.vpc_connectivity == "public" ? var.subnet_count : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

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
