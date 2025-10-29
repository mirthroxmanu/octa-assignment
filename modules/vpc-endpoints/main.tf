
data "aws_vpc_endpoint_service" "ecr_dkr" {
  count        = var.vpc_endpoints && var.enable_ecr_dkr_endpoint ? 1 : 0
  service_type = "Interface"
  filter {
    name   = "service-name"
    values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.ecr.dkr"]
  }
}

data "aws_vpc_endpoint_service" "ecr_api" {
  count        = var.vpc_endpoints && var.enable_ecr_api_endpoint ? 1 : 0
  service      = "ecr.api"
  service_type = "Interface"
  filter {
    name   = "service-name"
    values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.ecr.api"]
  }
}

data "aws_vpc_endpoint_service" "s3" {
  count        = var.vpc_endpoints && var.enable_s3_gateway_endpoint ? 1 : 0
  service      = "s3"
  service_type = "Interface"
  filter {
    name   = "service-name"
    values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.s3"]
  }
}

# Security Group - Only create if any VPC endpoint is enabled
resource "aws_security_group" "endpoint_sg" {
  count = var.vpc_endpoints && (var.enable_ecr_dkr_endpoint || var.enable_ecr_api_endpoint) ? 1 : 0

  name        = "${var.name_prefix}-sg-vpc-endpoint"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${var.name_prefix}-sg-vpc-endpoint" },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
    ]
  }
}

# ECR Docker VPC Endpoint
resource "aws_vpc_endpoint" "vpc_ecr_dkr" {
  count = var.vpc_endpoints && var.enable_ecr_dkr_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_dkr[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint_sg[0].id]
  subnet_ids         = var.pvt_subnet_ids

  dns_options {
    private_dns_only_for_inbound_resolver_endpoint = true
  }

  private_dns_enabled = true

  tags = merge(
    { "Name" = "${var.name_prefix}-docker-vpc-endpoint" },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      dns_options[0].private_dns_only_for_inbound_resolver_endpoint
    ]
  }
}

# S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "vpc_s3_gateway" {
  count = var.vpc_endpoints && var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = data.aws_vpc_endpoint_service.s3[0].service_name
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = var.route_table_ids
  private_dns_enabled = false

  tags = merge(
    { "Name" = "${var.name_prefix}-s3-gw-vpc-endpoint" },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      dns_options[0].private_dns_only_for_inbound_resolver_endpoint
    ]
  }
}

# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "vpc_ecr_api" {
  count = var.vpc_endpoints && var.enable_ecr_api_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_api[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.endpoint_sg[0].id]
  subnet_ids          = var.pvt_subnet_ids
  private_dns_enabled = true

  dns_options {
    private_dns_only_for_inbound_resolver_endpoint = true
  }

  tags = merge(
    { "Name" = "${var.name_prefix}-ecr-vpc-endpoint" },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      dns_options[0].private_dns_only_for_inbound_resolver_endpoint
    ]
  }
}