variable "aws_region" {
  description = "Region where Cloud Formation is created"
  default     = "eu-central-1"
}

variable "name" {
  description = "Name of the AWS Minikube cluster - will be used to name all created resources"
}

variable "instance_type" {
  description = "Type of instance"
  default     = "t2.medium"
}


variable "ssh_public_key" {
  description = "Path to the pulic part of SSH key which should be used for the instance"
  default     = "~/.ssh/id_rsa.pub"
}

variable "aws_zones" {
  type = list
  description = "AWS AZs (Availability zones) where subnets should be created"
}


variable "vpc_cidr" {
  type = string
  description = "CIDR of the VPC"
}

