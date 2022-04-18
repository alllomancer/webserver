module "minikube" {
  source = "scholzj/minikube/aws"

  aws_region          = var.aws_region
  cluster_name        = var.name
  aws_instance_type   = var.instance_type
  ssh_public_key      = var.ssh_public_key
  aws_subnet_id       = module.vpc.private_subnet_ids[0]
  hosted_zone         = aws_route53_zone.main.zone_id
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

resource "helm_release" "webserver" {
  depends_on = [
    module.minikube
  ]

  name             = var.name
  namespace        = "default"
  chart            = "../../webserver-helm"
  version          = "latest"
  create_namespace = false

}

resource "aws_route53_zone" "main" {
  name = "webserver.com"
}