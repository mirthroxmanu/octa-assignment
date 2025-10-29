output "ecr_dkr_endpoint_id" {
  description = "ECR Docker VPC endpoint ID"
  value       = var.vpc_endpoints && var.enable_ecr_dkr_endpoint ? aws_vpc_endpoint.vpc_ecr_dkr[0].id : null
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = var.vpc_endpoints && var.enable_s3_gateway_endpoint ? aws_vpc_endpoint.vpc_s3_gateway[0].id : null
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPC endpoint ID"
  value       = var.vpc_endpoints && var.enable_ecr_api_endpoint ? aws_vpc_endpoint.vpc_ecr_api[0].id : null
}

output "endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = var.vpc_endpoints && (var.enable_ecr_dkr_endpoint || var.enable_ecr_api_endpoint) ? aws_security_group.endpoint_sg[0].id : null
}