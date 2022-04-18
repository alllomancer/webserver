module "vpc" {
  source  = "scholzj/vpc/aws"
  version = "3.0.0"

  aws_region = var.aws_region
  aws_zones = var.aws_zones
  vpc_name = var.name
  vpc_cidr = var.vpc_cidr
  private_subnets = "true"

  ## Tags
  tags = {
    app = var.name
  }

}