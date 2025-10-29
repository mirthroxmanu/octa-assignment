# resource "aws_lb_listener_rule" "listner_rule" {
#   listener_arn = var.lb_listener_arn
#   priority     = var.priority

#   action {
#     type = "forward"
#     forward {
#       target_group {
#         arn    = var.lb_target_group_arn
#         weight = 80
#       }
#     }
#   }

#   condition {
#     host_header {
#       values = var.host_header
#     }
#   }

# }



# resource "aws_lb_listener_rule" "this" {
#   for_each = { for idx, rule in var.rules : idx => rule }

#   listener_arn = var.listener_arn
#   priority     = each.value.priority

#   dynamic "condition" {
#     for_each = each.value.conditions
#     content {
#       field = condition.value.type
#       dynamic "host_header" {
#         for_each = condition.value.type == "host-header" ? [condition.value.values] : []
#         content {
#           values = host_header.value
#         }
#       }

#       dynamic "http_header" {
#         for_each = condition.value.type == "http-header" ? [condition.value.http_header] : []
#         content {
#           http_header_name = http_header.value.name
#           values           = http_header.value.values
#         }
#       }

#       dynamic "http_request_method" {
#         for_each = condition.value.type == "http-request-method" ? [condition.value.values] : []
#         content {
#           values = http_request_method.value
#         }
#       }

#       dynamic "path_pattern" {
#         for_each = condition.value.type == "path-pattern" ? [condition.value.values] : []
#         content {
#           values = path_pattern.value
#         }
#       }

#       dynamic "query_string" {
#         for_each = condition.value.type == "query-string" ? [condition.value.query_string] : []
#         content {
#           key   = query_string.value.key
#           value = query_string.value.value
#         }
#       }

#       dynamic "source_ip" {
#         for_each = condition.value.type == "source-ip" ? [condition.value.values] : []
#         content {
#           values = source_ip.value
#         }
#       }
#     }
#   }
#   dynamic "action" {
#     for_each = each.value.actions
#     content {
#       type = action.value.type

#       dynamic "target_group_arn" {
#         for_each = action.value.target_group_arn != null ? [action.value.target_group_arn] : []
#         content {
#           target_group_arn = action.value.target_group_arn
#         }
#       }

#       dynamic "fixed_response" {
#         for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []
#         content {
#           content_type = action.value.fixed_response.content_type
#           message_body = action.value.fixed_response.message_body
#           status_code  = action.value.fixed_response.status_code
#         }
#       }

#       dynamic "redirect" {
#         for_each = action.value.redirect != null ? [action.value.redirect] : []
#         content {
#           host        = action.value.redirect.host
#           path        = action.value.redirect.path
#           port        = action.value.redirect.port
#           protocol    = action.value.redirect.protocol
#           query       = action.value.redirect.query
#           status_code = action.value.redirect.status_code
#         }
#       }
#     }
#   }
# }
resource "aws_lb_listener_rule" "this" {
  for_each = { for idx, rule in var.rules : idx => rule }

  listener_arn = var.listener_arn
  priority     = each.value.priority

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "host_header" {
        for_each = condition.value.type == "host-header" ? [condition.value.values] : []
        content {
          values = host_header.value
        }
      }

      dynamic "http_header" {
        for_each = condition.value.type == "http-header" ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.type == "http-request-method" ? [condition.value.values] : []
        content {
          values = http_request_method.value
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.type == "path-pattern" ? [condition.value.values] : []
        content {
          values = path_pattern.value
        }
      }

      dynamic "query_string" {
        for_each = condition.value.type == "query-string" ? condition.value.query_string : []
        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.type == "source-ip" ? [condition.value.values] : []
        content {
          values = source_ip.value
        }
      }
    }
  }

  dynamic "action" {
    for_each = each.value.actions
    content {
      type = action.value.type

      target_group_arn = action.value.target_group_arn

      dynamic "fixed_response" {
        for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []
        content {
          content_type = action.value.fixed_response.content_type
          message_body = action.value.fixed_response.message_body
          status_code  = action.value.fixed_response.status_code
        }
      }

      dynamic "redirect" {
        for_each = action.value.redirect != null ? [action.value.redirect] : []
        content {
          host        = action.value.redirect.host
          path        = action.value.redirect.path
          port        = action.value.redirect.port
          protocol    = action.value.redirect.protocol
          query       = action.value.redirect.query
          status_code = action.value.redirect.status_code
        }
      }
    }
  }
}
