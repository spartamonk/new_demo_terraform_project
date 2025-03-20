variable "db_subnet_group" {
  description = "The name of the RDS subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets for the RDS subnet group"
  type        = list(string)
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "mysql"
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  # default     = "db.t4g.large"
  default = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydb"
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = "default.mysql8.0"
}

variable "bastion_sg_id" {
  description = "The ID of the security group for the bastion host"
  type        = string
}
variable "db_engine_version" {
  description = "The database engine version"
  type        = string
  default     = "8.0"
}

variable "vpc_id" {
  description = "The VPC ID for the RDS instance"
  type        = string
}

variable "parameter_name" {
  description = "The name of the SSM parameter"
  type        = string
}
variable "lambda_sg_id" {
  description = "Lambda security group ID"
  type        = string
}












