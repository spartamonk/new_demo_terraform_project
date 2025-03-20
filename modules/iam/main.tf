data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_rotation_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_secretsmanager_policy" {
  name = "${var.lambda_role_name}-secretsmanager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      Resource = var.secret_arn
    }]
  })
}

resource "aws_iam_policy" "lambda_rds_policy" {
  name = "${var.lambda_role_name}-rds"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "rds-db:connect"
      ],
      Resource = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_instance_resource_id}/${var.db_username}"
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_logging_policy" {
  name = "${var.lambda_role_name}-s3-logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject"
      ],
      Resource = "${var.s3_bucket_arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secretsmanager_attach" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.lambda_secretsmanager_policy.arn
}

resource "aws_iam_role_policy_attachment" "rds_attach" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_logging_attach" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.lambda_s3_logging_policy.arn
}

resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "SecretsManagerRDSMySQLRotationSingleUser"
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = var.secret_arn
}