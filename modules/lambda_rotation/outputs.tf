output "lambda_function_name" {
  value = aws_lambda_function.rds_rotation_lambda.function_name
}
output "lambda_function_arn" {
  value = aws_lambda_function.rds_rotation_lambda.arn
}
output "lambda_sg_id" {
  value = aws_security_group.lambda_to_rds.id
  
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}
