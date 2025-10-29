resource "aws_security_group_rule" "aws_ingress_source_sg" {
  count                    = length(var.ingress_rules_source_sg)
  type                     = "ingress"
  from_port                = var.ingress_rules_source_sg[count.index].from_port
  to_port                  = var.ingress_rules_source_sg[count.index].to_port
  protocol                 = var.ingress_rules_source_sg[count.index].protocol
  source_security_group_id = var.ingress_rules_source_sg[count.index].source_security_group_id
  description              = var.ingress_rules_source_sg[count.index].description
  security_group_id        = var.security_group_id
}
