resource "aws_lambda_function" "this" {
  function_name = var.identifier
  role          = aws_iam_role.this.arn
  package_type  = "Image"
  architectures = ["arm64"]
  image_uri     = docker_registry_image.this.name
  timeout       = 300
  memory_size   = 512

  vpc_config {
    security_group_ids = [aws_security_group.this.id]
    subnet_ids         = var.region.vpc.private_subnets
  }

  environment {
    variables = {
      APP_MASTER_KEY_SSM_PARAMETER_NAME = var.application_master_key.name
      AUDIO_BUCKET                      = aws_s3_bucket.audio.id
      APP_ENV                           = var.app_environment
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.this
  ]

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}
