resource "aws_iam_role" "this" {
  name = var.identifier
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_access_execution_role" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "custom_policy" {
  name = var.identifier

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
        ]
        Effect = "Allow"
        Resource = [
          var.application_master_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
