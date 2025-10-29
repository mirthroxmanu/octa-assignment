variable "name" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}
#Loadbalancer
/*
#private
variable "internal_lb_listener_rules" {
  type = map(object({
    priority    = number
    target_group_arn = string
    conditions  = list(object({
      type  = string
      values = list(string)
    }))
  }))
}

#public
variable "public_lb_listener_rules" {
  type = map(object({
    priority    = number
    target_group_arn = string
    conditions  = list(object({
      type  = string
      values = list(string)
    }))
  }))
}
*/