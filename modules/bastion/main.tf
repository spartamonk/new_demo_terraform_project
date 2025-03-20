data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"] # Specify the owner ID or "self" for your own AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"] # Adjust the filter to match your desired AMI
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.latest.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  security_groups = [aws_security_group.bastion_sg.id]
  lifecycle {
    ignore_changes = [ami, user_data, security_groups]
  }
  tags = {
    Name = var.name
  }
}

# resource "aws_instance" "bastion2" {
#   ami           = data.aws_ami.latest.id
#   instance_type = var.instance_type
#   subnet_id     = var.private_subnet_id
#   key_name      = var.key_name

#   security_groups = [aws_security_group.bastion_sg.id]
#   lifecycle {
#     ignore_changes = [ami, user_data, security_groups]
#   }
#   tags = {
#     Name = var.name
#   }
# }
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# resource "aws_security_group" "bastion2_sg" {
#   name        = "bastion-sg"
#   description = "Security group for bastion host"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     security_groups = [aws_security_group.bastion_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "bastion2-sg"
#   }
# }