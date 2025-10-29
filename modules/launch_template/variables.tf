# variables.tf - Launch Template Module Variables

variable "name" {
  description = "Name of the launch template"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

# AMI Configuration
variable "image_id" {
  description = "AMI ID to use for the launch template. If not provided, will use data source"
  type        = string
  default     = ""
}

variable "ami_owners" {
  description = "List of AMI owners for data source lookup"
  type        = list(string)
  default     = ["amazon"]
}

variable "ami_filters" {
  description = "List of filters for AMI data source"
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = [
    {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  ]
}

variable "key_name" {
  description = "Key pair name to use for instances"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to associate"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile" {
  description = "IAM instance profile configuration"
  type = object({
    arn  = optional(string)
    name = optional(string)
  })
  default = null
}

# User Data Configuration
variable "custom_userdata" {
  description = "Custom user data script. Takes precedence over EKS userdata"
  type        = string
  default     = ""
}

variable "encode_userdata" {
  description = "Whether to base64 encode the user data"
  type        = bool
  default     = true
}

# EKS Specific Configuration
variable "eks_cluster_config" {
  description = "EKS cluster configuration for generating node userdata"
  type = object({
    endpoint              = string
    certificate_authority = string
    cidr                  = string
    name                  = string
  })
  default = null
}

variable "kubelet_max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 17
}

variable "cluster_dns_ip" {
  description = "Cluster DNS IP address"
  type        = string
  default     = "172.20.0.10"
}

# Block Device Configuration
variable "block_device_mappings" {
  description = "Block device mappings for the launch template"
  type = list(object({
    device_name  = string
    no_device    = optional(string)
    virtual_name = optional(string)
    ebs = optional(object({
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      volume_size           = optional(number)
      volume_type           = optional(string)
      iops                  = optional(number)
      throughput            = optional(number)
    }))
  }))
  default = [
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_type           = "gp3"
        volume_size           = 50
        iops                  = 3000
        throughput            = 125
      }
    }
  ]
}

# Metadata Options
variable "metadata_options" {
  description = "Instance metadata options"
  type = object({
    http_endpoint               = optional(string)
    http_tokens                 = optional(string)
    http_put_response_hop_limit = optional(number)
    http_protocol_ipv6          = optional(string)
    instance_metadata_tags      = optional(string)
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

# Tag Configuration
variable "tag_specifications" {
  description = "Tag specifications for resources created by the launch template"
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the launch template itself"
  type        = map(string)
  default     = {}
}


variable "ignore_tag_changes" {
  description = "Ignore changes to tags and tag_specifications"
  type        = bool
  default     = true
}