resource "aws_lb_target_group" "public" {
  count       = var.public_route53_zone != null ? 1 : 0
  name        = substr(var.identifier, 0, 32)
  target_type = "lambda"
}

resource "aws_lb_listener_rule" "public" {
  count    = var.public_route53_zone != null ? 1 : 0
  priority = var.app_environment == "production" ? 11 : 111

  listener_arn = var.region.public_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public[0].id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.public[0].fqdn
      ]
    }
  }
}

resource "aws_lb_target_group_attachment" "public" {
  count            = var.public_route53_zone != null ? 1 : 0
  target_group_arn = aws_lb_target_group.public[0].arn
  target_id        = aws_lambda_function.this.arn
  depends_on       = [aws_lambda_permission.this]
}

resource "aws_lb_target_group" "internal" {
  name        = substr("${var.identifier}-internal", 0, 32)
  target_type = "lambda"
}

resource "aws_lb_listener_rule" "internal" {
  priority = var.app_environment == "production" ? 11 : 111

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.internal.fqdn
      ]
    }
  }
}

resource "aws_lb_target_group_attachment" "internal" {
  target_group_arn = aws_lb_target_group.internal.arn
  target_id        = aws_lambda_function.this.arn
  depends_on       = [aws_lambda_permission.this]
}
