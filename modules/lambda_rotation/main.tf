data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "rds_rotation_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  
  filename         = "${path.module}/lambda-deploy.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda-deploy.zip")

  environment {
    variables = {
      ENVIRONMENT = var.environment
      SSM_PARAMETER_NAME = var.ssm_parameter_name
      RDS_INSTANCE_ID = var.db_instance_identifier
      # SLACK_WEBHOOK_URL = var.slack_webhook_url
      CA_BUNDLE_PATH    = var.ca_bundle_path
    }
  }


  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_to_rds.id]
  }
  depends_on = [ aws_security_group.lambda_to_rds ]
  timeout = 300
}


# EventBridge Rule to trigger the Lambda function every 10 minutes
resource "aws_cloudwatch_event_rule" "password_rotation_schedule" {
  name        = "${var.lambda_function_name}-rotation-schedule"
  description = "Triggers the Lambda function to rotate the RDS password every 10 minutes"
  schedule_expression = "rate(10 minutes)"
}

# EventBridge Target to invoke the Lambda function
resource "aws_cloudwatch_event_target" "password_rotation_target" {
  rule      = aws_cloudwatch_event_rule.password_rotation_schedule.name
  target_id = "${var.lambda_function_name}-target"
  arn       = aws_lambda_function.rds_rotation_lambda.arn
}

# Grant EventBridge permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_rotation_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.password_rotation_schedule.arn
}

resource "aws_security_group" "lambda_to_rds" {
  name = "lambda-to-rds"
  description = "Allows Lambda to connect to RDS"
  vpc_id = var.vpc_id
  egress {
    from_port = var.db_port
    to_port = var.db_port
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
    egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound to AWS services via NAT or VPC Endpoints"
  }

}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.lambda_function_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_role_policy" "lambda_combined_policy" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ],
        Resource = "${var.ssm_parameter_arn}"
      }
    ]
  })
}