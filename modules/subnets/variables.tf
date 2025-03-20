variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "subnets" {
  description = "The CIDR block for the subnet"
  type = map(object({
    type = string
    az   = number
  }))
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

