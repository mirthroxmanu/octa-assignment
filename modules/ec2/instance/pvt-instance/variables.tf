#Instances
#pvt
variable "name" {}
variable "vpc_id" {}
variable "architecture" {}
variable "pvt_explicit_ami_id" {}
variable "pvt_root_volume_size" {}
variable "pvt_use_explicit_ami" {}
variable "pvt_instance_type" {}
variable "ssh_key_name" {}
variable "pvt_subnet_id" {}
variable "security_group_ids" {
  type = list(string)
}

# variable "sg_tags" {
#   description = "A map of tags to assign to the resource."
#   type        = map(string)
# }

# variable "instance_tags" {
#   description = "A map of tags to assign to the resource."
#   type        = map(string)
# }

# #variable "root_block_device_tags" {
# #  description = "A map of tags to assign to the resource."
# #  type        = map(string)
# #}

# variable "volume_tags" {}


variable "tags" {
  
}

variable "iam_instance_profile_name" {
  type = string
  default = null
}

variable "private_ip" {
  type = string
  default = null
}