variable "name_prefix" {}
variable "instance_name" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "vpc_id" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "storage_type" {}
variable "db_subnet_group_name" {}
variable "rds_master_user" {}
variable "rds_master_password" {}
variable "availability_zone" {}
variable "deletion_protection" {}
variable "copy_tags_to_snapshot" {}
variable "performance_insights_enabled" {}
variable "vpc_security_group_ids" {}
variable "tags" {}

variable "parameters" {
  description = "List of DB parameters"
  type = list(object({
    name  = string
    value = string
  }))
}
variable "apply_immediately" {}
variable "parameter_gp_name" {}
variable "parameter_group_family" {}
variable "allow_major_version_upgrade" {}
variable "backup_retention_period" {}
variable "publicly_accessible" {}
variable "auto_minor_version_upgrade" {}
variable "skip_final_snapshot" {}
variable "backup_window" {}


variable "final_snapshot_identifier" {}