module "minikube" {
  source = "scholzj/minikube/aws"

  aws_region          = "eu-central-1"
  cluster_name        = "my-minikube"
  aws_instance_type   = "t2.medium"
  ssh_public_key      = "~/.ssh/id_rsa.pub"
  aws_subnet_id       = module.vpc.private_subnet_ids[0]
  hosted_zone         = "webserver.com"
  hosted_zone_private = trye
  ami_image_id        = data.aws_ami.ami.id

  tags = {
    Application = "Minikube"
  }
  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/metrics-server.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/ingressyaml",
  ]
}

# This autoscaler works from-the-box with Intel core
# When using Graviton or AMD core, AMI type need to be set explicitly in eks.node_groups
resource "helm_release" "webserver" {
  depends_on = [
    module.minikube
  ]

  name             = "webserver"
  namespace        = "default"
  chart            = "./webserver-helm"
  version          = "0.1.0"
  create_namespace = false

}