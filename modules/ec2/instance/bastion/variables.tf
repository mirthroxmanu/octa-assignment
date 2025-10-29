#Instances
#Bastion
variable "name" {}
variable "vpc_id" {}
#variable "user_data" {}
variable "architecture" {}
variable "bastion_explicit_ami_id" {}
variable "bastion_root_volume_size" {}
variable "bastion_use_explicit_ami" {}
variable "ssh_key_name" {}
variable "bastion_instance_type" {}
variable "public_subnet_id" {}
# variable "bastion_sg_ingress_rules" {
#   description = "List of ingress rules"
#   type = list(object({
#     description = string
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
# }

variable "tags" {}
variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile_name" {
  type = string
  default = null
}

variable "private_ip" {
  type = string
  default = null
}
