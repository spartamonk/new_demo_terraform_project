output "db_instance_identifier" {
  value = aws_db_instance.main.identifier
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}
output "db_name" {
  value = aws_db_instance.main.db_name
} 
output "db_instance_id" {
  value = aws_db_instance.main.id
}
output "db_username" {
  value = aws_db_instance.main.username
}

# output "rds_rotation_arn" {
#   value = aws_iam_role.rds_rotation_role.arn
# }
output "ssm_parameter_arn" {
  value = data.aws_ssm_parameter.db_credentials.arn
}