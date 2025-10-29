module "eks_cluster" {

  source             = "../../../modules/eks"
  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr_block     = local.vpc_cidr_block
  eks_version        = "1.33"
  security_group_ids = [module.eks_cluster_secondary_sg.security_group_id]
  #EKS Addon Versions    
  vpc_cni_addon_version        = "v1.20.2-eksbuild.1"
  ebs_csi_driver_addon_version = "v1.48.0-eksbuild.2"
  coredns_addon_version        = "v1.12.4-eksbuild.1"
  kube_proxy_addon_version     = "v1.33.3-eksbuild.10"
  #Tags
  tags = merge(local.common_tags)
  node_groups = {
    pool-0 = {
      node_group_name = "common-ng"
      ami_type        = "AL2023_ARM_64_STANDARD"
      capacity_type   = "ON_DEMAND"
      instance_types = ["m6g.xlarge"]
      desired_size               = 1
      max_size                   = 6
      min_size                   = 2
      disk_size                  = 60
      max_unavailable_percentage = 25
      labels                     = { "app" = "common" }
      subnet_ids                 = [module.vpc.private_subnet_ids[0]]
    },  
    #additional pool can be added by separated by coma
  }
}