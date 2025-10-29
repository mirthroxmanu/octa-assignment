data "aws_partition" "current" {}
data "aws_region" "current" {}

# data "aws_vpc_endpoint_service" "ecr_dkr" {
#   service_type = "Interface"
#   filter {
#     name   = "service-name"
#     values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.ecr.dkr"]
#   }
# }

# data "aws_vpc_endpoint_service" "s3" {
#   service_type = "Interface"
#   filter {
#     name   = "service-name"
#     values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.s3"]
#   }
# }

# data "aws_vpc_endpoint_service" "ecr_api" {
#   service_type = "Interface"
#   filter {
#     name   = "service-name"
#     values = ["${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.name}.ecr.api"]
#   }
# }