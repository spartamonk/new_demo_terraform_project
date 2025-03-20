# # Get the current AWS region
# data "aws_region" "current" {}
# data "aws_caller_identity" "current" {}

# # Get the latest version
# data "aws_ssm_parameter" "db_credentials" {
#   name = var.parameter_name
# }

# data "aws_iam_policy_document" "ssm_trust" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }
# # IAM Role for Lambda to access Parameter Store
# resource "aws_iam_role" "ssm_access_role" {
#   name = "${var.lambda_function_name}-parameter-store"

#   assume_role_policy = data.aws_iam_policy_document.ssm_trust.json

# }

# # IAM Policy for accessing Parameter Store secrets
# resource "aws_iam_role_policy" "ssm_access_policy" {
#   name = "${var.lambda_function_name}-parameter-store-policy"
#   role = aws_iam_role.ssm_access_role.id  

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssm:GetParameter",
#           "ssm:PutParameter",
#           "ssm:DescribeParameter"
#         ],
#         Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.parameter_name}"
#       }
#     ]
#   })
# }

