locals {
  tg_type = var.create_public ? "pub" : "pvt"
}

resource "aws_lb_target_group" "public_target_group" {
  name        = "${var.name_prefix}-tg-${local.tg_type}-${var.target_group_name}"
  port        = var.target_group_port
  target_type = var.target_type
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = var.status_code
    path                = var.health_check_path
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}


# resource "aws_lb_target_group" "private_target_group" {
#   count       = var.create_private ? 1 : 0
#   name        = "${var.name_prefix}-tg-pvt-${var.target_group_name}"
#   port        = var.target_group_port
#   target_type = var.target_type
#   protocol    = var.target_group_protocol
#   vpc_id      = var.vpc_id

#   health_check {
#     enabled             = true
#     interval            = 30
#     protocol            = "HTTP"
#     timeout             = 5
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#     matcher             = var.status_code
#     path                = var.health_check_path
#   }
#   tags = var.tags
#   lifecycle {
#     ignore_changes = [
#       tags,
#       tags_all
#     ]
#   }
# }

resource "aws_lb_target_group_attachment" "public" {
  #count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.public_target_group.arn
  target_id        = var.instance_ids #element(var.instance_ids, count.index)
  port             = var.target_attachment_port
}

# resource "aws_lb_target_group_attachment" "private" {
#   count            = var.create_private ? length(var.instance_ids) : 0
#   target_group_arn = aws_lb_target_group.private_target_group[0].arn
#   target_id        = element(var.instance_ids, count.index)
#   port             = var.target_attachment_port
# }