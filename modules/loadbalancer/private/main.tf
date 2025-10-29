resource "aws_alb" "internal_lb" {
  name                       = "${var.name_prefix}-private-alb"
  internal                   = "true"
  load_balancer_type         = "application"
  enable_deletion_protection = "false"
  idle_timeout               = "300"
  ip_address_type            = "ipv4"
  subnets                    = var.private_subnet_ids
  security_groups            = [aws_security_group.internal_lb_sg.id]
  tags                       = merge(tomap({ "Name" = "${var.name_prefix}-private-lb" }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}


resource "aws_security_group" "internal_lb_sg" {
  name        = "${var.name_prefix}-sg-private-lb"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.name_prefix}-sg-private-lb" }), tomap(var.tags))
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags["created_by"], tags["created_by_arn"],
    ]
  }
}


resource "aws_lb_listener" "internal_lb_https_listner" {
  load_balancer_arn = aws_alb.internal_lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "internal_lb_http_listner" {
  load_balancer_arn = aws_alb.internal_lb.arn
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

