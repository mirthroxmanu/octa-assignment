output "db_identifier" {
  value = aws_db_instance.this.identifier
}

output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_arn" {
  value = aws_db_instance.this.arn
}
variable "rds0_mysql_rds_snapshot_identifier" {
  description = "Snapshot ID to restore RDS from. Leave null to create a new RDS instance."
  type        = string
  default     = null
}
