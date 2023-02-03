#
# public connectivity
#
resource "aws_internet_gateway" "internet_gateway" {
  count = var.vpc_connectivity == "public" ? 1 : 0

  vpc_id = aws_vpc.managed.id

  tags = local.internet_gateway_tags
}

/* locals {
  internet_subnets = var.vpc_connectivity == "public" ? {
    for subnet in aws_subnet.public : subnet.id => subnet
  } : {}
} */

/* resource "aws_network_interface" "nat_gateway" {
  for_each = local.internet_subnets

  subnet_id = each.value.id

  tags = merge(
    local.nat_gateway_tags,
    { "Name" = "${var.vpc_name}-natgw-${each.value.availability_zone}" }
  )
} */

/* locals {
  internet_interfaces = var.vpc_connectivity == "public" ? {
    for interface in aws_network_interface.nat_gateway : interface.id => interface
  } : {}
} */

resource "aws_eip" "nat_gateway" {
  count = var.vpc_connectivity == "public" ? var.subnet_count : 0

  # network_interface = each.value.id

  tags = merge(
    local.nat_gateway_tags,
    { "Name" = "${var.vpc_name}-natgw-${aws_subnet.public[count.index].tags["Name"]}" }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "public" {
  count = var.vpc_connectivity == "public" ? var.subnet_count : 0

  subnet_id         = aws_subnet.public[count.index].id
  allocation_id     = aws_eip.nat_gateway[count.index].id
  connectivity_type = "public"

  tags = merge(
    local.nat_gateway_tags,
    { "Name" = "${var.vpc_name}-natgw-${aws_subnet.public[count.index].tags["Name"]}" }
  )
}
