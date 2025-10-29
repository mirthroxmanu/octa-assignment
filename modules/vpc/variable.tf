#VPC variables
variable "vpc_cidr_block" {}
variable "name_prefix" {}
variable "enable_dns_hostnames" {
  default = true
}
variable "enable_dns_support" {
  default = true
}

variable "enable_nat_gateway" {
  default = true
}

variable "public_subnets" {
  description = "List of public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets."
  type        = list(string)
}

variable "availability_zones" {}
variable "single_nat_gateway" {}
variable "tags" {}
variable "private_subnet_additional_tags" {}