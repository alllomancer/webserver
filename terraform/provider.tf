terraform {
  backend "s3" {
    bucket = "YOUR-BUCKET"
    key    = "YOUR-KEY"
    region = "AWS_REGION"
  }
}

provider "aws" {
  region = var.region
  #  shared_credentials_file = "$HOME/.aws/credentials"
  #  profile = "default"
}



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster_id.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_id.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", data.aws_eks_cluster.cluster_id.name,
      "--region", var.region
    ]
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
