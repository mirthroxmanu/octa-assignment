#common#
locals {
  name_prefix    = "octa-byte"
  vpc_cidr_block = var.vpc_cidr_block
}

#Tags
data "aws_caller_identity" "current" {}

data "aws_kms_key" "default_ebs_key_by_alias" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "default_rds_key_by_alias" {
  key_id = "alias/aws/rds"
}


locals {
  common_tags = {
    account        = var.account
    env            = var.env
    project        = "${local.name_prefix}-project"
    created_by     = data.aws_caller_identity.current.user_id
    created_by_arn = data.aws_caller_identity.current.arn
  }
  specific_tags = {
    account = local.common_tags.account
    env     = local.common_tags.env
  }
}
