data "aws_kms_secrets" "creds" {
  secret {
    name    = "rdscreds"
    payload = file("../../creds-encrypted/rds_db_creds.yml.encrypted")
  }
}

locals {
  db_creds         = yamldecode(data.aws_kms_secrets.creds.plaintext["rdscreds"])
}

module "octabyte_common_rds" {
  source = "../../../modules/rds/psql"

  # Basic Configuration
  name_prefix     = "octabyte"
  instance_name   = "common"
  engine          = "postgres"
  engine_version  = "17.2"
  instance_class  = "db.t4g.micro" 

  # Storage Configuration
  allocated_storage     = 50
  max_allocated_storage = 100
  storage_type          = "gp3"

  # Network Configuration
  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.private_subnet_group.db_subnet_group_id
  vpc_security_group_ids = [module.octabyte_common_rds_sg.security_group_id]
  availability_zone      = "ap-south-1a"
  publicly_accessible    = false

  # Master Credentials
  rds_master_user              = local.db_creds.rds_master_user
  rds_master_password          = local.db_creds.rds_master_password

  # Parameter Group
  parameter_gp_name      = "octabyte-common"
  parameter_group_family = "postgres17"
  
  parameters = []

  # Backup & Maintenance
  backup_retention_period      = 7
  backup_window                = "03:00-04:00"
  auto_minor_version_upgrade   = true
  allow_major_version_upgrade  = false
  apply_immediately            = false

  # Snapshot Configuration
  skip_final_snapshot       = false
  final_snapshot_identifier = "octabyte-common-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  copy_tags_to_snapshot     = true

  # Security & Monitoring
  deletion_protection          = true
  performance_insights_enabled = true

  # Tags
  tags = merge(local.common_tags)
}

# Output the DB endpoint for Grafana configuration
output "octabyte_common_db_endpoint" {
  value       = module.octabyte_common_rds.db_identifier
  description = "octabyte Common RDS database identifier"
}

module "private_subnet_group" {
  source = "../../../modules/rds/db_subnet_group"

  create = true
  name_prefix = local.name_prefix
  name = "pvt-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids
  description = "octabyte common, app"
  tags =  merge(local.common_tags)

}