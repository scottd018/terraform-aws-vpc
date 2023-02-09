locals {
  vpc_tags = merge(var.all_tags, var.vpc_tags, { "Name" = var.vpc_name })

  _all_cidrs = [
    for index in range(var.subnet_count * 2) : cidrsubnet(var.vpc_cidr, (var.subnet_cidr - tonumber(split("/", var.vpc_cidr)[1])), index)
  ]
  subnets_public       = slice(local._all_cidrs, 0, var.subnet_count)
  subnets_private      = slice(local._all_cidrs, var.subnet_count, (length(local._all_cidrs)))
  subnets_public_tags  = merge(var.all_tags, merge(var.subnet_public_tags, { "Visibility" = "public" }))
  subnets_private_tags = merge(var.all_tags, merge(var.subnet_private_tags, { "Visibility" = "private" }))

  nat_gateway_tags = var.all_tags

  internet_gateway_tags = local.vpc_tags
  vpn_gateway_tags      = local.vpc_tags

  route_table_tags = var.all_tags

  #egress_gw_enabled = (var.vpc_connectivity == "vpn" && var.vpn_internet_connectivity == "egress-gw")
}
