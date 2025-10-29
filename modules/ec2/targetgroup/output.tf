output "tg_arn" {
  value = aws_lb_target_group.public_target_group.arn
}

# output "private_tg_arn" {
#   value = aws_lb_target_group.private_target_group[0].arn
# }

# output "tg_arn" {
#   value = var.create_public && length(aws_lb_target_group.public_target_group) > 0 ? aws_lb_target_group.public_target_group[0].arn : null
# }

# output "private_tg_arn" {
#   value = var.create_private && length(aws_lb_target_group.private_target_group) > 0 ? aws_lb_target_group.private_target_group[0].arn : null
# }