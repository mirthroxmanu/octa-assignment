resource "aws_db_instance" "this" {

  identifier                            = "${var.name_prefix}-rds-instance-${var.instance_name}"
  engine                                = var.snapshot_identifier != null ? null : var.engine
  engine_version                        = var.snapshot_identifier != null ? null : var.engine_version
  instance_class                        = var.instance_class
  allocated_storage                     = var.snapshot_identifier != null ? null : var.allocated_storage
  max_allocated_storage                 = var.max_allocated_storage != null ? var.max_allocated_storage : null
  storage_type                          = var.storage_type
  storage_encrypted                     = true
  kms_key_id                            = aws_kms_key.rds.arn
  license_model                         = var.snapshot_identifier != null ? null : "general-public-license"
  db_name                               = var.snapshot_identifier != null ? null : "admin"
  username                              = var.snapshot_identifier != null ? null : var.rds_master_user
  password                              = var.snapshot_identifier != null ? null : var.rds_master_password
  snapshot_identifier                   = var.snapshot_identifier
  vpc_security_group_ids                = var.vpc_security_group_ids
  db_subnet_group_name                  = var.db_subnet_group_name
  network_type                          = "IPV4"
  availability_zone                     = var.availability_zone
  publicly_accessible                   = var.publicly_accessible #false
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  parameter_group_name                  = aws_db_parameter_group.db_parameter_group.id
  allow_major_version_upgrade           = var.allow_major_version_upgrade #false
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade  #false
  skip_final_snapshot                   = var.skip_final_snapshot         #false
  backup_retention_period               = var.backup_retention_period     #7 
  backup_window                         = var.backup_window
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = 7
  apply_immediately                     = var.apply_immediately
  performance_insights_kms_key_id       = aws_kms_key.performance_insights.arn
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  depends_on                            = [aws_db_parameter_group.db_parameter_group]
  deletion_protection                   = var.deletion_protection
  tags                                  = merge(tomap({ "Name" = "${var.name_prefix}-rds-instance-${var.instance_name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"],
      tags["created_by_arn"],
      tags["Launch_Month_Year"],
      engine_version,
      snapshot_identifier,
      max_allocated_storage,
      allocated_storage
    ]
  }

}

resource "aws_kms_key" "rds" {
  description = "For the DB instance is to be encrypted"
}

resource "aws_kms_key" "performance_insights" {
  description = "For performance insights"
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.name_prefix}-rds-pg-postgres-${var.parameter_gp_name}"
  description = "RDS DB Instance parameter group from terraform"
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(tomap({ "Name" = "${var.name_prefix}-rds-pg-postgres-${var.parameter_gp_name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"],
      tags["created_by_arn"],
      tags["Launch_Month_Year"],
      parameter
    ]
  }
}