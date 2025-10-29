locals {
  name = var.name
}

#########
#Bastion#
#########
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

#EIP
resource "aws_eip" "instance_eip" {
  instance = aws_instance.bastion_instance.id
  tags     = merge(tomap({ "Name" = "${var.name}-eip" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))

  lifecycle {
    ignore_changes = [ tags, tags_all ]
  }
}


#locals
locals {
  ami_id = var.bastion_use_explicit_ami ? var.bastion_explicit_ami_id : data.aws_ami.ubuntu.id
}

resource "aws_instance" "bastion_instance" {
  ami                         = local.ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = var.public_subnet_id
  volume_tags                 = merge(tomap({ "Name" = "${var.name}-root-volume" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  associate_public_ip_address = "true"
  vpc_security_group_ids      = var.security_group_ids

  root_block_device {
    volume_size           = var.bastion_root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    #tags = var.root_block_device_tags
  }

  private_ip = var.private_ip

  #user_data = var.user_data

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
# resource "aws_security_group" "bastion_sg" {
#   name        = "${local.name}-bastion-server-sg"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = var.vpc_id

#   dynamic "ingress" {
#     for_each = var.bastion_sg_ingress_rules
#     content {
#       description = ingress.value.description
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(tomap({ "Name" = "${var.name}-sg" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
# }