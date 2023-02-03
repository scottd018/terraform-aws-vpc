module "test" {
  source = "../../"

  vpc_name = "dscott-poc-vpc"
}

output "subnets_public" {
  value = module.test.subnets_public
}

output "subnets_private" {
  value = module.test.subnets_private
}
