
resource "aws_key_pair" "octabyte_aws_master" {
  key_name   = "octabyte-aws-master"
  public_key = var.sshkey_master_pub
}


module "pritunl_main" {
  source = "../../../modules/ec2/instance/bastion"

  # Required variables
  name             = "${local.name_prefix}-pritunl-vpn"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id =  module.vpc.public_subnet_ids[0]
  ssh_key_name     = aws_key_pair.octabyte_aws_master.key_name
  # Instance configuration
  bastion_instance_type    = "t3a.medium"
  bastion_root_volume_size = 20
  architecture              = "amd64"
  bastion_use_explicit_ami = false
  bastion_explicit_ami_id  = ""
  private_ip  = "10.10.0.4"
  security_group_ids =  [module.app_public_nw_sg.security_group_id, module.ssh_public_nw_sg.security_group_id]
  # Tags
  tags =  merge(local.common_tags)
}