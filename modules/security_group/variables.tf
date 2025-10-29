variable "name_prefix" {}
variable "tags" {}

variable "vpc_id" {}

variable "description" {}

variable "sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = []
}
variable "component" {}


variable "ingress_rules_source_sg" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default = []
}