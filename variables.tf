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
  description = "Connectivity for VPC.  Must be 'public', 'vpn', 'private' ('public' only supported for now.)"
  type        = string
  default     = "public"
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
