locals {
  public_subnet_count = var.vpc_connectivity != "private" ? var.subnet_count : 0
}

resource "aws_subnet" "public" {
  count = local.public_subnet_count

  vpc_id                  = aws_vpc.managed.id
  cidr_block              = local.subnets_public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.subnets_public_tags,
    { "Name" = "${var.vpc_name}-public-${data.aws_availability_zones.available.names[count.index]}" }
  )
}

resource "aws_subnet" "private" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.managed.id
  cidr_block              = local.subnets_private[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    local.subnets_private_tags,
    { "Name" = "${var.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}" }
  )
}

locals {
  public_subnet_ids  = [for subnet in aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}
