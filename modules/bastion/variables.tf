variable "instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The subnet ID for the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for the bastion host"
  type        = string
}

variable "key_name" {
  description = "The key name for SSH access"
  type        = string
}

variable "name" {
  description = "The name of the bastion host"
  type        = string
  default     = "bastion_host"
}
variable "rds_cidr_blocks" {
  description = "The CIDR blocks for the RDS database"
  type        = list(string)
}
