#EKS Variables.
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "name_prefix" {}
variable "eks_version" {}
variable "node_groups" {
  type = map(object({
    node_group_name            = string
    ami_type                   = string
    subnet_ids                 = list(string)
    capacity_type              = string
    labels                     = map(string)
    instance_types             = list(string)
    desired_size               = number
    disk_size                  = number
    # launch_template_version    = string
    # launch_template_id         = string
    max_size                   = number
    min_size                   = number
    max_unavailable_percentage = number
  }))
}
variable "tags" {}
variable "security_group_ids" {}
#Addons
variable "vpc_cni_addon_version" {}
variable "ebs_csi_driver_addon_version" {}
variable "coredns_addon_version" {}
variable "kube_proxy_addon_version" {}

