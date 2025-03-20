variable "region" {
  description = "The AWS region to deploy resources"
  type        = string 
}
variable "ssm_parameter_name" {
  description = "The username for the RDS instance"
  type        = string
}
variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  
}
variable "subnet_ids" {
  description = "The subnet IDs for the RDS instance"
  type        = list(string)
  
}
variable "vpc_id" {
  description = "The VPC ID for the RDS instance"
  type        = string  
  
}
variable "db_port" {
  description = "The port for the RDS instance"
  type        = number
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  
}

# variable "rds_role_arn" {
#   description = "The ARN of the IAM role for the RDS instance"
#   type        = string
# }

# variable "ssm_role_arn" {
#   description = "The ARN of the IAM role for the RDS instance"
#   type        = string
# }

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}
variable "environment" {
  description = "The environment for the resources"
  type        = string
}

# variable "slack_webhook_url" {
#   description = "The username for the RDS instance"
#   type        = string
# }

variable "ca_bundle_path" {
  description = "The username for the RDS instance"
  type        = string
}
variable "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter"
  type        = string
  
}