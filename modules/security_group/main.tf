locals {
  name   = "${var.name_prefix}-sg-${var.component}"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "aws_sg" {
  name        = "${var.name_prefix}-sg-${var.component}"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.name_prefix}-sg-${var.component}" }), tomap(var.tags))


  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}


locals {
  ingress_rules           = var.sg_ingress_rules
  ingress_rules_source_sg = var.ingress_rules_source_sg
}


# For ingress and egress from IP CIDR Blocks or IPs
resource "aws_security_group_rule" "aws_ingress_rules" {
  count             = length(local.ingress_rules)
  type              = "ingress"
  from_port         = local.ingress_rules[count.index].from_port
  to_port           = local.ingress_rules[count.index].to_port
  protocol          = local.ingress_rules[count.index].protocol
  cidr_blocks       = [local.ingress_rules[count.index].cidr_block]
  description       = local.ingress_rules[count.index].description
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_security_group_rule" "aws_egress_source_sg" {
  count                    = length(local.ingress_rules_source_sg)
  type                     = "ingress"
  from_port                = local.ingress_rules_source_sg[count.index].from_port
  to_port                  = local.ingress_rules_source_sg[count.index].to_port
  protocol                 = local.ingress_rules_source_sg[count.index].protocol
  source_security_group_id = local.ingress_rules_source_sg[count.index].source_security_group_id
  description              = local.ingress_rules_source_sg[count.index].description
  security_group_id        = aws_security_group.aws_sg.id
}
