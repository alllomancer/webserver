data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = [data.aws_caller_identity.current.account_id] #

  filter {
    name   = "tag:encrypted"
    values = ["true"]
  }

  filter {
    name   = "name"
    values = ["amazon-eks-*"]
  }
}

data "aws_eks_cluster" "cluster_id" {
  name = module.eks[0].cluster_id
}

data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
