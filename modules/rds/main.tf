data "aws_ssm_parameter" "db_credentials" {
  name = var.parameter_name
}

locals {
  secret_json = jsondecode(data.aws_ssm_parameter.db_credentials.value)
  db_password = local.secret_json.db_password
  db_username = local.secret_json.db_user
}
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group
  subnet_ids = var.subnet_ids
  tags = {
    Name = var.db_subnet_group
  }
}
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
  # Allow traffic from the bastion host
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }
  # Allow Lambda to connect to the RDS instance
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.lambda_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}





resource "aws_db_instance" "main" {
  identifier             = var.db_name
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.db_engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = local.db_username
  password               = local.db_password
  parameter_group_name   = var.parameter_group_name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  storage_type           = "gp2"  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# data "aws_iam_policy_document" "rds_trust" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "rds_rotation_role" {
#   name = "rds-rotation-role"

#   assume_role_policy = data.aws_iam_policy_document.rds_trust.json
# }


# resource "aws_iam_role_policy" "rds_rotation_policy" {
#   role = aws_iam_role.rds_rotation_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "rds:ModifyDBInstance",
#           "rds:DescribeDBInstances",
#           "rds-db:connect"
#         ],
#         Resource = aws_db_instance.main.arn 
#       }
#     ]
#   })
# }