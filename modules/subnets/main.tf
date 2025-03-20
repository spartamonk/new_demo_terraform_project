data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id
  for_each                = var.subnets
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, index(keys(var.subnets), each.key))
  availability_zone       = data.aws_availability_zones.available.names[each.value.az]
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  tags = {
    Name = each.key
  }
}

