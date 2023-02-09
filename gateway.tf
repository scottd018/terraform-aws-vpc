#
# public connectivity
#
resource "aws_internet_gateway" "internet_gateway" {
  count = var.vpc_connectivity != "private" ? 1 : 0

  vpc_id = aws_vpc.managed.id

  tags = local.internet_gateway_tags
}

resource "aws_eip" "nat_gateway" {
  count = var.vpc_connectivity != "private" ? var.subnet_count : 0

  tags = merge(
    local.nat_gateway_tags,
    { "Name" = "${var.vpc_name}-natgw-${aws_subnet.public[count.index].availability_zone}" }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "public" {
  count = var.vpc_connectivity != "private" ? var.subnet_count : 0

  subnet_id         = aws_subnet.public[count.index].id
  allocation_id     = aws_eip.nat_gateway[count.index].id
  connectivity_type = "public"

  tags = merge(
    local.nat_gateway_tags,
    { "Name" = "${var.vpc_name}-natgw-${aws_subnet.public[count.index].availability_zone}" }
  )
}

#
# vpn connectivity
#
/* resource "random_integer" "vpn_bgp_asn" {
  count = var.vpn_bgp_asn == null && var.vpc_connectivity == "vpn" ? 1 : 0

  min = 65000
  max = 2147483647
} */

resource "aws_vpn_gateway" "vpn" {
  count = var.vpc_connectivity == "vpn" ? 1 : 0

  vpc_id = aws_vpc.managed.id
  #amazon_side_asn = var.vpn_bgp_asn == null ? random_integer.vpn_bgp_asn[0].result : var.vpn_bgp_asn

  tags = local.vpn_gateway_tags
}

resource "aws_customer_gateway" "vpn" {
  count = var.vpc_connectivity == "vpn" ? 1 : 0

  device_name = var.vpn_connection_name
  #bgp_asn     = var.vpn_bgp_asn == null ? random_integer.vpn_bgp_asn[0].result : var.vpn_bgp_asn
  bgp_asn    = 65000
  type       = "ipsec.1"
  ip_address = var.vpn_ip_address

  tags = local.vpn_gateway_tags

  lifecycle {
    precondition {
      condition     = var.vpn_ip_address != null
      error_message = "var.vpn_ip_address must not be null when requesting vpn connection"
    }
  }
}

resource "aws_vpn_connection" "vpn" {
  count = var.vpc_connectivity == "vpn" ? 1 : 0

  vpn_gateway_id      = aws_vpn_gateway.vpn[0].id
  customer_gateway_id = aws_customer_gateway.vpn[0].id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_ike_versions            = ["ikev1"]
  tunnel2_ike_versions            = ["ikev1"]
  tunnel1_phase1_dh_group_numbers = [2]
  tunnel2_phase1_dh_group_numbers = [2]

  tunnel1_phase1_integrity_algorithms = [var.vpn_integrity_alogrithm]
  tunnel1_phase2_integrity_algorithms = [var.vpn_integrity_alogrithm]
  tunnel2_phase1_integrity_algorithms = [var.vpn_integrity_alogrithm]
  tunnel2_phase2_integrity_algorithms = [var.vpn_integrity_alogrithm]

  tunnel1_phase1_encryption_algorithms = [var.vpn_encryption_alogrithm]
  tunnel1_phase2_encryption_algorithms = [var.vpn_encryption_alogrithm]
  tunnel2_phase1_encryption_algorithms = [var.vpn_encryption_alogrithm]
  tunnel2_phase2_encryption_algorithms = [var.vpn_encryption_alogrithm]

  tags = local.vpn_gateway_tags
}

/* resource "aws_egress_only_internet_gateway" "vpn" {
  count = local.egress_gw_enabled ? 1 : 0

  vpc_id = aws_vpc.managed.id

  tags = local.internet_gateway_tags
} */
