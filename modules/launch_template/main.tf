# main.tf - Launch Template Module

# Data source for AMI - conditional based on architecture
data "aws_ami" "eks_ami" {
  count       = var.image_id == "" ? 1 : 0
  most_recent = true
  owners      = var.ami_owners

  dynamic "filter" {
    for_each = var.ami_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}


locals {
  # EKS userdata template - define as a separate local first
  eks_userdata_template = <<-USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: ${var.eks_cluster_config != null ? var.eks_cluster_config.endpoint : ""}
    certificateAuthority: ${var.eks_cluster_config != null ? var.eks_cluster_config.certificate_authority : ""}
    cidr: ${var.eks_cluster_config != null ? var.eks_cluster_config.cidr : ""}
    name: ${var.eks_cluster_config != null ? var.eks_cluster_config.name : ""}
  kubelet:
    config:
      maxPods: ${var.kubelet_max_pods}
      clusterDNS:
      - ${var.cluster_dns_ip}
--//--
USERDATA

  # Conditionally use EKS userdata or empty string
  eks_userdata = var.eks_cluster_config != null ? local.eks_userdata_template : ""

  # Determine final userdata
  final_userdata = var.custom_userdata != "" ? var.custom_userdata : local.eks_userdata

  # Determine the AMI ID to use
  #ami_id = var.image_id != "" ? var.image_id : (length(data.aws_ami.eks_ami) > 0 ? data.aws_ami.eks_ami[0].id : "")
}


# Launch Template Resource
resource "aws_launch_template" "this" {
  name        = var.name
  name_prefix = var.name_prefix
  description = var.description

  # Use provided AMI ID or data source
  image_id = var.image_id != "" ? var.image_id : data.aws_ami.eks_ami[0].id

  # User data
  user_data = var.encode_userdata ? base64encode(local.final_userdata) : local.final_userdata

  # Instance configuration
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids

  # IAM instance profile
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [1] : []
    content {
      arn  = lookup(var.iam_instance_profile, "arn", null)
      name = lookup(var.iam_instance_profile, "name", null)
    }
  }

  # EBS block device mappings
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) != null ? [block_device_mappings.value.ebs] : []
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", true)
          encrypted             = lookup(ebs.value, "encrypted", true)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
          iops                  = lookup(ebs.value, "iops", null)
          throughput            = lookup(ebs.value, "throughput", null)
        }
      }
    }
  }

  # Metadata options
  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", 2)
      http_protocol_ipv6          = lookup(metadata_options.value, "http_protocol_ipv6", null)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  # Tag specifications for created resources
  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  # Tags for the launch template itself
  tags = merge(tomap({ "Component" = "eks" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))

  lifecycle {
    ignore_changes = []
  }
}