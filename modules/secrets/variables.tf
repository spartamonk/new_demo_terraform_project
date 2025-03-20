variable "parameter_name" {
  description = "The name of the SSM parameter"
  type        = string 
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  type        = string
}
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  
}
