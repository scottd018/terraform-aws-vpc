resource "aws_vpc" "managed" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = local.vpc_tags
}
