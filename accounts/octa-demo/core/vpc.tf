module "vpc" {
  source             = "../../../modules/vpc"
  single_nat_gateway = false
  name_prefix        = local.name_prefix
  vpc_cidr_block     = local.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  tags               = merge(local.common_tags)
  private_subnet_additional_tags = {} #This is for karpenter
}