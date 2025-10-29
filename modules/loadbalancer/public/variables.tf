variable "name_prefix" {}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {}

variable "certificate_arn" {}

variable "tags" {}