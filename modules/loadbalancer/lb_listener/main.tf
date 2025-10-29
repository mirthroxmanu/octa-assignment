resource "aws_lb_listener" "https" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}