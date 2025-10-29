
locals {
  name = var.name
}


######################
#Internal Loadbalancer 
######################

resource "aws_alb" "internal_lb" {
  name                       = "${local.name}-internal-lb"
  internal                   = "true"
  load_balancer_type         = "application"
  enable_deletion_protection = "false"
  idle_timeout               = "300"
  ip_address_type            = "ipv4"
  subnets                    = var.private_subnet_ids
  security_groups            = [aws_security_group.internal_lb_sg.id]
}


resource "aws_security_group" "internal_lb_sg" {
  name        = "${local.name}-internal-loadbalancer-sg"
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

  tags = {
    Name = "${local.name}-internal-loadbalancer-sg"
  }
}

/*
resource "aws_lb_listener" "internal_lb_https_listner" {
  load_balancer_arn = aws_alb.internal_lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.id

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}
*/

resource "aws_lb_listener" "internal_lb_http_listner" {
  load_balancer_arn = aws_alb.internal_lb.arn
  port              = "80"
  protocol          = "HTTP"

  #  default_action {
  #    type = "redirect"
  #
  #    redirect {
  #      port        = "443"
  #      protocol    = "HTTPS"
  #      status_code = "HTTP_301"
  #    }
  #  }

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

/*
resource "aws_lb_listener_rule" "internal_listner_rule" {
  for_each     = var.internal_lb_listener_rules
  listener_arn = aws_lb_listener.internal_lb_https_listner.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }

  dynamic "condition" {
    for_each = each.value.conditions
    content {
        type   = condition.value.type 
        values = condition.value.values
    }
  }
}
*/


######################
#Public Loadbalancer 
######################

resource "aws_alb" "public_lb" {
  name                       = "${local.name}-public-lb"
  internal                   = "false"
  load_balancer_type         = "application"
  enable_deletion_protection = "false"
  idle_timeout               = "300"
  ip_address_type            = "ipv4"
  subnets                    = var.public_subnet_ids
  security_groups            = [aws_security_group.public_lb_sg.id]
}


resource "aws_security_group" "public_lb_sg" {
  name        = "${local.name}-public-loadbalancer-sg"
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

  tags = {
    Name = "${local.name}-public-loadbalancer-sg"
  }
}

/*
resource "aws_lb_listener" "public_lb_https_listner" {
  load_balancer_arn = aws_alb.public_lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.id

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}
*/

resource "aws_lb_listener" "public_lb_http_listner" {
  load_balancer_arn = aws_alb.public_lb.arn
  port              = "80"
  protocol          = "HTTP"

  #default_action {
  #  type = "redirect"
  #  redirect {
  #    port        = "443"
  #    protocol    = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  #}
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

/*
resource "aws_lb_listener_rule" "public_listner_rule" {
  for_each     = var.public_lb_listener_rules
  listener_arn = aws_lb_listener.public_lb_https_listner.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      "${condition.value.type}" {
        values = condition.value.values
      }
    }
  }
}
*/