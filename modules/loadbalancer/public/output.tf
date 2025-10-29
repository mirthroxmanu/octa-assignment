output "public_lb_sg_id" {
  value = aws_security_group.public_lb_sg.id
}

output "aws_lb_https_listener_arn" {
  value = aws_lb_listener.public_lb_https_listner.arn
}

output "aws_lb_http_listener_arn" {
  value = aws_lb_listener.public_lb_http_listner.arn
}
