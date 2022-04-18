# state files should be saved in s3 for collabration 
/* terraform {
  backend "s3" {
    bucket = "YOUR-BUCKET"
    key    = "YOUR-KEY"
    region = "AWS_REGION"
  }
}
 */
 
provider "aws" {
  region = var.aws_region
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
