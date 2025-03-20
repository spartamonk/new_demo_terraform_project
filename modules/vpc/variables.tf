variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "name" {
  description = "The name of the VPC"
  type        = string
  default     = "rds-vpc"

}
variable "db_subnet_group" {
  description = "The name of the VPC"
  type        = string
  default     = "db-subnet-group"

}
variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
  
}