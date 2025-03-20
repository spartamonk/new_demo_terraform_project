provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "dev"
      terraform   = "true"
    }
  }
}
data "aws_caller_identity" "current" {}
resource "random_string" "suffix" {
  length  = 4
  special = false
}


module "vpc" {
  source            = "../../modules/vpc"
  name              = var.name
  public_subnet_ids = module.subnet.public_subnet_ids
  private_subnet_ids = module.subnet.private_subnet_ids
}
# output "cidr_block" {
#   value = module.subnet.first_private_subnet_id
# }
module "subnet" {
  source         = "../../modules/subnets"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnets        = var.subnets

}
# module "bastion" {
#   source          = "../../modules/bastion"
#   subnet_id       = module.subnet.first_public_subnet_id
#   vpc_id          = module.vpc.vpc_id
#   key_name        = var.key_name
#   rds_cidr_blocks = [module.vpc.vpc_cidr_block]
# }

# module "rds" {
#   source          = "../../modules/rds"
#   db_subnet_group = var.db_subnet_group
#   subnet_ids      = module.subnet.private_subnet_ids
#   bastion_sg_id   = module.bastion.bastion_sg_id
#   vpc_id          = module.vpc.vpc_id
#   parameter_name  = var.parameter_name
#   lambda_sg_id = module.lambda_rotation.lambda_sg_id
# }

# module "lambda_rotation" {
#   source = "../../modules/lambda_rotation"
#   region = var.region
#   vpc_id = module.vpc.vpc_id
#   subnet_ids = [module.subnet.first_private_subnet_id]
#   db_port = var.db_port
#   vpc_cidr_block = module.vpc.vpc_cidr_block
#   # ssm_role_arn = module.secrets.ssm_access_role_arn
#   # rds_role_arn = module.rds.rds_rotation_arn
#   lambda_function_name = var.lambda_function_name
#   ssm_parameter_name = var.parameter_name
#   db_instance_identifier = module.rds.db_instance_id
#   ca_bundle_path = var.ca_bundle_path
#   environment = var.environment
#   ssm_parameter_arn = module.rds.ssm_parameter_arn
#   # slack_webhook_url = var.slack_webhook_url
# }













# module "secrets" {
#   source = "../../modules/secrets"
#   parameter_name = var.parameter_name
#   lambda_function_name = module.lambda_rotation.lambda_function_name
#   lambda_function_arn = module.lambda_rotation.lambda_function_arn
# }

































# # module "iam" {
# #   source                = "../../modules/iam"
# #   lambda_role_name      = "lambda_rotation_role"
# #   secret_arn            = module.secrets.secrets_arn
# #   db_instance_resource_id = module.rds.db_instance_id
# #   db_username           = module.rds.db_username
# #   s3_bucket_arn         = "arn:aws:s3:::cloud-for-developers-source-code-cma"
# # }
