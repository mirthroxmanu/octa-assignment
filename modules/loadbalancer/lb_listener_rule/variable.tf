# variable "host_header" {}
# variable "lb_target_group_arn" {}
# variable "lb_listener_arn" {}
# variable "priority" {}

variable "listener_arn" {
  description = "The ARN of the listener to attach the rule to."
  type        = string
}

# variable "rules" {
#   description = "List of rules to create, including conditions and actions."
#   type = list(object({
#     priority = number
#     conditions = list(object({
#       type   = string
#       values = optional(list(string)) # For most conditions
#       http_header = optional(object({
#         name   = string
#         values = list(string)
#       }))
#       query_string = optional(object({
#         key   = string
#         value = string
#       }))
#       http_request_method = optional(object({
#         value = string
#       }))
#       path_pattern = optional(object({
#         values = string
#       }))
#       host_header = optional(object({
#         key   = string
#         value = string
#       }))
#       http_header = optional(object({
#         name   = string
#         values = string
#       }))
#     }))
#     actions = list(object({
#       type             = string
#       target_group_arn = optional(string)
#       fixed_response = optional(object({
#         content_type = string
#         message_body = string
#         status_code  = string
#       }))
#       redirect = optional(object({
#         host        = optional(string)
#         path        = optional(string)
#         port        = optional(string)
#         protocol    = optional(string)
#         query       = optional(string)
#         status_code = string
#       }))
#     }))
#   }))
# }

variable "rules" {
  description = "List of rules to create, including conditions and actions."
  type = list(object({
    priority = number
    conditions = list(object({
      type   = string
      values = optional(list(string)) # For most conditions
      http_header = optional(object({
        name   = string
        values = list(string)
      }))
      query_string = optional(list(object({
        key   = string
        value = string
      })))
      http_request_method = optional(object({
        value = string
      }))
      path_pattern = optional(object({
        values = list(string) # Corrected this as well to ensure consistency
      }))
      host_header = optional(object({
        values = list(string) # Updated for consistency with AWS documentation
      }))
    }))
    actions = list(object({
      type             = string
      target_group_arn = optional(string)
      fixed_response = optional(object({
        content_type = string
        message_body = string
        status_code  = string
      }))
      redirect = optional(object({
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
        status_code = string
      }))
    }))
  }))
}
