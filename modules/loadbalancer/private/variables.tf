variable "name_prefix" {}
variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {}

variable "certificate_arn" {}

#variable "create_internal_lb_listener_rules" {}

variable "tags" {}