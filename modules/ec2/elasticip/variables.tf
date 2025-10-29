variable "name" {
  description = "Name for the elastic ip"
}
variable "name_prefix" {}

variable "instance_id" {
  description = "The instance id which attach the eip"
}

variable "tags" {}