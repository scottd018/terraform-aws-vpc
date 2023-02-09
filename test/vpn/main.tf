module "test" {
  source = "../../"

  vpc_name                 = "dscott-pl"
  vpc_connectivity         = "vpn"
  # use export TF_VAR_vpn_ip_address due to sensitive nature of this.
  #vpn_ip_address           = "1.1.1.1"
  vpn_integrity_alogrithm  = "SHA1"
  vpn_encryption_alogrithm = "AES128"
  vpn_local_networks       = ["172.50.0.0/16"]
}
