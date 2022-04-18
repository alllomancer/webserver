data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  #owners      = [data.aws_caller_identity.current.account_id] # should use private images
  owners      = ["amazon"] 

# should use encrypted images
/*   filter {
    name   = "tag:encrypted"
    values = ["true"]
  } */

  filter {
    name   = "name"
    values = ["amazon-*"]
  }
}