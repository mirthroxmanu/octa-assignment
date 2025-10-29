terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
  }
}

variable "acm_domain_name" {
  description = "The domain name for the cert"
}

variable "another_names" {
  description = "another names for the cert"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}
variable "name_prefix" {}
variable "name" {}