# variables.tf - Add these variables
variable "vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
  default     = false
}

variable "enable_ecr_dkr_endpoint" {
  description = "Enable ECR Docker VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_s3_gateway_endpoint" {
  description = "Enable S3 Gateway VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_api_endpoint" {
  description = "Enable ECR API VPC endpoint"
  type        = bool
  default     = false
}

# Existing variables
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "pvt_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route table IDs for gateway endpoints"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}