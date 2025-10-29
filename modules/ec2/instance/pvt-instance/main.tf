locals {
  name = var.name
}


##############
#pvt-instance#
##############
#data
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-${var.architecture}-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


#locals
locals {
  ami_id = var.pvt_use_explicit_ami ? var.pvt_explicit_ami_id : data.aws_ami.ubuntu.id
}

resource "aws_instance" "pvt_instance" {
  ami                         = local.ami_id
  instance_type               = var.pvt_instance_type
  key_name                    = var.ssh_key_name
  volume_tags                 = merge(tomap({ "Name" = "${var.name}-root-volume" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  subnet_id                   = var.pvt_subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name
  root_block_device {
    volume_size           = var.pvt_root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    #tags = var.root_block_device_tags
  }
  private_ip = var.private_ip

  tags = merge(tomap({ "Name" = "${var.name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      root_block_device,
      instance_type,
      tags,
      volume_tags
    ]
  }
}