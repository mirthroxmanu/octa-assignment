variable "name_prefix" {}
variable "target_group_name" {
  description = " Name of the target group. If omitted, Terraform will assign a random, unique name. This name must be unique per region per account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen"
}
variable "create_public" {
  default = false
}

variable "create_private" {
  default = false
}
variable "target_group_port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
}

variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group."
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip, or alb. Does not apply when target_type is lambda."
}

variable "vpc_id" {
  description = "vpc id in which tg can created"
}

variable "status_code" {}
variable "health_check_path" {}

variable "instance_ids" {}

variable "target_attachment_port" {}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}