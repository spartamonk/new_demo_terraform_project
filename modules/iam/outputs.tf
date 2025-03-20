output "lambda_role_arn" {
  description = "The ARN of the IAM role for the Lambda function"
  value = aws_iam_role.lambda_rotation_role.arn
}