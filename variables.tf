#
# vpc
#
variable "vpc_name" {
  description = "Name of the VPC to manage"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the VPC to manage"
  type        = string
  default     = "10.50.0.0/16"
}

variable "vpc_tags" {
  description = "Tags to apply to only VPC object"
  type        = map(string)
  default     = {}
}

variable "vpc_connectivity" {
  description = "Connectivity for VPC.  Must be 'public', 'vpn', 'private' ('public' only supported for now)"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "vpn"], var.vpc_connectivity)
    error_message = "vpc_connectivity must be one of: ['public']."
  }
}

#
# vpn
#
variable "vpn_connection_name" {
  description = "The name used for the VPN connection"
  type        = string
  default     = "remote-site"
}

variable "vpn_ip_address" {
  description = "The IP address on the local site where the VPN is running"
  type        = string
  default     = null
}

variable "vpn_local_networks" {
  description = "Network CIDRs on the local site used for routing through the VPN"
  type        = list(string)
  default     = []
}

variable "vpn_integrity_alogrithm" {
  description = "The VPN integrity algorithm to use when setting up the site-to-site VPN"
  type        = string
  default     = "SHA2-512"

  validation {
    condition     = contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], var.vpn_integrity_alogrithm)
    error_message = "vpn_integrity_alogrithm must be one of: ['SHA1', 'SHA2-256', 'SHA2-384', 'SHA2-512']."
  }
}

variable "vpn_encryption_alogrithm" {
  description = "The VPN encryption algorithm to use when setting up the site-to-site VPN"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], var.vpn_encryption_alogrithm)
    error_message = "vpn_encryption_alogrithm must be one of: ['AES128', 'AES256', 'AES128-GCM-16', 'AES256-GCM-16']."
  }
}

variable "vpn_bgp_asn" {
  description = "BGP ASN used for the VPN connection.  Randomized if empty (must be between 65000 and 2147483647)"
  type        = number
  default     = 65000

  validation {
    condition = (
      var.vpn_bgp_asn == null || (
        var.vpn_bgp_asn >= 65000 &&
        var.vpn_bgp_asn <= 2147483647
      )
    )
    error_message = "vpn_bgp_asn must be between 65000 and 2147483647, or null for a random number."
  }
}

#
# subnet
#
variable "subnet_count" {
  description = "Number of public/private subnets to provision/manage"
  type        = number
  default     = 3
}

variable "subnet_cidr" {
  description = "CIDR for each of the public/private subnets"
  type        = number
  default     = 20
}

variable "subnet_public_tags" {
  description = "Tags to apply to public subnets"
  type        = map(string)
  default     = {}
}

variable "subnet_private_tags" {
  description = "Tags to apply to private subnets"
  type        = map(string)
  default     = {}
}

variable "all_tags" {
  description = "Tags to apply to all objects"
  type        = map(string)
  default     = {}
}
