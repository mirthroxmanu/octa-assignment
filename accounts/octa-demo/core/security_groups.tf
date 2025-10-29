#EKS Security groups
module "eks_cluster_secondary_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "eks"
 tags = merge(
   local.common_tags,
 )
 vpc_id = module.vpc.vpc_id
 description =  "eks secondary security group"
 sg_ingress_rules = [
    { description = "https from self vpc", from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "10.10.0.0/16" },
    
 ]
 ingress_rules_source_sg = []
}


module "eks_managed_cluster_sg_rule" {
  source            = "../../../modules/security_group/source_sg_ingress_rule"
  security_group_id = module.eks_cluster.cluster_primary_securitygroup_id
  ingress_rules_source_sg = [
    { description = "Allow all traffic form public lb sg", from_port = 0, to_port = 0, protocol = "-1", source_security_group_id = module.eks_internal_loadbalancer_sg.security_group_id },
    { description = "Allow all traffic from pvt lb sg", from_port = 0, to_port = 0, protocol = "-1", source_security_group_id = module.eks_public_loadbalancer_sg.security_group_id },
    { description = "Allow all traffic from eks user managed secondary security group", from_port = 0, to_port = 0, protocol = "-1", source_security_group_id = module.eks_cluster_secondary_sg.security_group_id },
  ]
}

#Public Network Security groups and rules.
module "app_public_nw_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "app-public"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "app public security group"
 sg_ingress_rules = [
    { description = "pritunl web http", from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0" },
    { description = "pritunl web https", from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0" },
    { description = "For VPN udp port", from_port = 11024, to_port = 11024, protocol = "udp", cidr_block = "0.0.0.0/0" },    
 ]
 ingress_rules_source_sg = []
}

module "ssh_public_nw_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "ssh-public"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "ssh public security group"
 sg_ingress_rules = [
    { description = "ssh access", from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "10.10.0.4/32" },
 ]
 ingress_rules_source_sg = []
}


#Private Network Security Groups and rules
module "app_private_nw_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "app-private"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "app private security group"
 sg_ingress_rules = []
 ingress_rules_source_sg = []
}

module "ssh_private_nw_sg" {    
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "ssh-private"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "ssh private security group"
 sg_ingress_rules = [
    { description = "ssh access", from_port = 22, to_port = 22, protocol = "tcp", cidr_block = "10.10.0.4/32" },
 ]
 ingress_rules_source_sg = []
}


# Loadbalancer Security groups
module "eks_internal_loadbalancer_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "eks-lb-private"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "eks loadbalancer private security group"
 sg_ingress_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0", description = "Allow alll" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0", description = "Allow all" }   
 ]
 ingress_rules_source_sg = []
}


module "eks_public_loadbalancer_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "eks-lb-public"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "eks loadbalancer public security group"
 sg_ingress_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_block = "0.0.0.0/0", description = "Allow alll" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_block = "0.0.0.0/0", description = "Allow all" }   
 ]
 ingress_rules_source_sg = []
}


#RDS  Securrity group
module "octabyte_common_rds_sg" {
 source = "../../../modules/security_group"

 name_prefix =  local.name_prefix
 component = "octabyte-common"
 tags = merge(local.common_tags)
 vpc_id = module.vpc.vpc_id
 description =  "octabyte common rds private security group"
 sg_ingress_rules = [
   { description = "rds 5432 access", from_port = 5432, to_port = 5432, protocol = "tcp", cidr_block = "10.10.0.0/16" },
 ]
 ingress_rules_source_sg = []
}