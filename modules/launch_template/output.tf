# outputs.tf - Launch Template Module Outputs

output "id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.this.arn
}

output "name" {
  description = "The name of the launch template"
  value       = aws_launch_template.this.name
}

output "latest_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "default_version" {
  description = "The default version of the launch template"
  value       = aws_launch_template.this.default_version
}

output "image_id" {
  description = "The AMI ID used in the launch template"
  value       = aws_launch_template.this.image_id
}

output "tags_all" {
  description = "All tags applied to the launch template"
  value       = aws_launch_template.this.tags_all
}

# output "ami_info" {
#   description = "Information about the AMI from data source"
#   value = var.image_id == "" ? {
#     id               = data.aws_ami.eks_ami.id
#     name             = data.aws_ami.eks_ami.name
#     description      = data.aws_ami.eks_ami.description
#     architecture     = data.aws_ami.eks_ami.architecture
#     creation_date    = data.aws_ami.eks_ami.creation_date
#     owner_id         = data.aws_ami.eks_ami.owner_id
#     platform_details = data.aws_ami.eks_ami.platform_details
#   } : null
# }