resource "aws_lb_target_group" "this" {
  name        = substr("${var.identifier}-internal", 0, 32)
  target_type = "lambda"
}

resource "aws_lb_listener_rule" "this" {
  priority = var.app_environment == "production" ? 42 : 142

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.this.fqdn
      ]
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_lambda_function.this.arn
  depends_on       = [aws_lambda_permission.this]
}
