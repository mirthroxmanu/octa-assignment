variable "component" {
  description = "Component name instance charecter EG: Marklogic, EKS, Etc.."
  type        = string
}

variable "name_prefix" {
  description = "A common Name prefix"
  type        = string
}
variable "service" {
  description = "Aws Service Eg: instance "
  type        = string    
}
variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policies to create. Key is policy name, value is policy document JSON"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
