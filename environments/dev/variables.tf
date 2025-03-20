variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"

}
variable "name" {
  description = "The name of the VPC"
  type        = string
  default     = "main"
}
variable "subnets" {
  description = "The CIDR block for the subnet"
  type = map(object({
    type = string
    az   = number
  }))
  default = {
    "public_subnet_1" = {
      type = "public"
      az   = 0
    },
    "public_subnet_2" = {
      type = "public"
      az   = 1
    },
    "private_subnet_1" = {
      type = "private"
      az   = 0
    },
    "private_subnet_2" = {
      type = "private"
      az   = 1
    }

  }
}


variable "db_subnet_group" {
  description = "The name of the RDS subnet group"
  type        = string
  default     = "my-rds-subnet-group"
}
variable "parameter_name" {
  description = "The name of the SSM parameter"
  type        = string
  default     = "/prod/database/credentials"

}


variable "key_name" {
  description = "The key name for SSH access"
  type        = string
  default     = "new_jenkins"

}
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "rotate_password"

}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing logs"
  type        = string
  default     = "cloud-for-developers-source-code-cma"

}

variable "db_port" {
  description = "The port for the RDS instance"
  type        = number
  default = 3306
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
  
}

variable "ca_bundle_path" {
  description = "The path to the CA bundle"
  type        = string
  default     = "/var/task/certs/global-bundle.pem"
}

# variable "slack_webhook_url" {
#   description = "value of the slack webhook url"
#   type        = string
# }

