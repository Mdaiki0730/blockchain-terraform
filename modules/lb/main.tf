// route 53 setting
resource "aws_route53_record" "wallet" {
  zone_id = var.zone_id
  name    = var.wallet_domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.wallet.dns_name]
}

resource "aws_route53_record" "blockchain" {
  zone_id = var.zone_id
  name    = var.blockchain_domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.blockchain.dns_name]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.zone_id
}

// acm setting
resource "aws_acm_certificate" "cert" {
  domain_name               = "*.${var.domain}"
  subject_alternative_names = ["${var.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.prefix}-acm"
  }
}

// lb-wallet setting
resource "aws_lb" "wallet" {
  name               = "${var.prefix}-wallet-alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  security_groups = [
    "${aws_security_group.alb.id}"
  ]
  subnets = [
    "${var.subnet_public_2a_id}",
    "${var.subnet_public_2c_id}"
  ]
}

resource "aws_lb_target_group" "wallet" {
  name        = "${var.prefix}-wallet-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 10
    path                = "/health"
    port                = 8080
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "wallet_https" {
  depends_on = [
    aws_route53_record.cert_validation
  ]
  load_balancer_arn = aws_lb.wallet.arn

  certificate_arn = aws_acm_certificate.cert.arn

  port     = "443"
  protocol = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wallet.id
  }
}

resource "aws_lb_listener_rule" "wallet_in_maintenance" {
  listener_arn = aws_lb_listener.wallet_https.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = "503"
      message_body = <<MESSAGE
      {"msg": "in maintenance"}
MESSAGE
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener_rule" "wallet_default_action" {
  listener_arn = aws_lb_listener.wallet_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wallet.id
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener" "wallet_http" {
  port     = "80"
  protocol = "HTTP"

  load_balancer_arn = aws_lb.wallet.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

resource "aws_lb_listener_rule" "wallet_http_to_https" {
  listener_arn = aws_lb_listener.wallet_http.arn

  priority = 99

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
}

// lb-blockchain-node1 setting
resource "aws_lb" "blockchain" {
  name               = "${var.prefix}-blockchain-alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  security_groups = [
    "${aws_security_group.alb.id}"
  ]
  subnets = [
    "${var.subnet_public_2a_id}",
    "${var.subnet_public_2c_id}"
  ]
}

resource "aws_lb_target_group" "blockchain" {
  name        = "${var.prefix}-blockchain-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 10
    path                = "/health"
    port                = 8080
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "blockchain_https" {
  depends_on = [
    aws_route53_record.cert_validation
  ]
  load_balancer_arn = aws_lb.blockchain.arn

  certificate_arn = aws_acm_certificate.cert.arn

  port     = "443"
  protocol = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blockchain.id
  }
}

resource "aws_lb_listener_rule" "blockchain_in_maintenance" {
  listener_arn = aws_lb_listener.blockchain_https.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = "503"
      message_body = <<MESSAGE
      {"msg": "in maintenance"}
MESSAGE
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener_rule" "blockchain_default_action" {
  listener_arn = aws_lb_listener.blockchain_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blockchain.id
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener" "blockchain_http" {
  port     = "80"
  protocol = "HTTP"

  load_balancer_arn = aws_lb.blockchain.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

resource "aws_lb_listener_rule" "blockchain_http_to_https" {
  listener_arn = aws_lb_listener.blockchain_http.arn

  priority = 99

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
}

// security group
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb"
  description = "${var.prefix} alb"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-alb"
  }
}
