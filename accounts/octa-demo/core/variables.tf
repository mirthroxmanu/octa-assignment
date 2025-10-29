#Common locals configuration
variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}
variable "account" {
  default = "octabyte"
}
variable "env" {
  default = "octabyte"
}
#VPC Configurations
variable "public_subnets" {
  description = "List of public subnets."
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.16.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets."
  type        = list(string)
  default     = ["10.10.32.0/24", "10.10.48.0/24"]
}
variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "octabyte_common_rds_master_user" {}
variable "octabyte_common_rds_master_password" {}
variable "sshkey_master_pub" {}