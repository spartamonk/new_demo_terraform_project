variable "lambda_role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
}

variable "secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  type        = string
}

variable "db_instance_resource_id" {
  description = "The resource ID of the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for logging"
  type        = string
}