locals {
  description = coalesce(var.description, format("%s subnet group", var.name))
}

resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-rds-db-${var.name}"
  description = local.description
  subnet_ids  = var.subnet_ids

  tags = merge(tomap({ "Name" = "${var.name_prefix}-rds-db-${var.name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      tags["created_by"],
      tags["created_by_arn"],
      tags["Launch_Month_Year"],
    ]
  }
}