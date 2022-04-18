# reserve Elastic IP to be used in our NAT gateway
# Every NAT gateway must have EIP allocated to
# Amount of NAT gateways depends on network scenario you use
resource "aws_eip" "nat_gw_elastic_ip" {
  count = var.create_vpc ? 3 : 0
//  count = var.create_vpc ? 1 : 0

  vpc   = true

  tags = {
    Name            = "${var.cluster_name}-nat-eip"
    iac_environment = var.iac_environment_tag
    owner = "devops"
    environment = var.environment
  }
}

locals {
  number_of_azs = var.number_of_azs > length(data.aws_availability_zones.azs.names) ? length(data.aws_availability_zones.azs.names) : var.number_of_azs
  ami_id = try(var.ami_id, data.aws_ami.ami.id)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  count   = var.create_vpc ? 1 : 0
  version = "3.0.0"

  name = var.vpc_name
  cidr = var.main_network_block
  azs  = slice(data.aws_availability_zones.azs.names, 0, local.number_of_azs)
  private_subnets = [
  # this loop will create a one-line list as ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", ...]
  # with a length depending on how many Zones are available
  for zone_id in slice(data.aws_availability_zones.azs.zone_ids, 0, local.number_of_azs) :
  cidrsubnet(var.main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
  # this loop will create a one-line list as ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", ...]
  # with a length depending on how many Zones are available
  # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
  for zone_id in slice(data.aws_availability_zones.azs.zone_ids, 0, local.number_of_azs) :
  cidrsubnet(var.main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  # reference: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.44.0#nat-gateway-scenarios
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  reuse_nat_ips          = true
  external_nat_ip_ids    = [aws_eip.nat_gw_elastic_ip[0].id, aws_eip.nat_gw_elastic_ip[1].id, aws_eip.nat_gw_elastic_ip[2].id]
//  external_nat_ip_ids    = [aws_eip.nat_gw_elastic_ip[0].id]
  # add VPC/Subnet tags required by EKS
  tags                = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    iac_environment                             = var.iac_environment_tag
    owner = "devops"
    environment = var.environment
  }
  public_subnet_tags  = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    iac_environment                             = var.iac_environment_tag
    owner = "devops"
    environment = var.environment
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    iac_environment                             = var.iac_environment_tag
    owner = "devops"
    environment = var.environment
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  count  = var.create_vpc ? 1 : 0

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [
    module.vpc[0].default_security_group_id,
    module.vpc[0].default_vpc_default_security_group_id,
    module.eks[0].cluster_security_group_id,
    module.eks[0].worker_security_group_id,
    module.eks[0].cluster_primary_security_group_id
  ]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc[0].private_route_table_ids
      tags            = {
        name        = "S3 VPC endpoint gateway - ${var.environment}"
        environment = var.environment
        owner       = "devops"
      }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].private_subnets
      tags = {
        name = "ECR VPC endpoint Interface - ${var.environment}"
        environment = var.environment
        owner = "devops"
      }
    },
    rds = {
      service             = "rds"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].private_subnets
      tags = {
        name         = "RDS VPC endpoint Interface - ${var.environment}"
        environment  = var.environment
        owner        = "devops"
      }
    }
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  count           = var.create_eks ? 1 : 0
  depends_on      = [module.vpc]
  version         = "17.23.0"
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  cluster_enabled_log_types = var.cluster_enabled_log_types 

  vpc_id  = module.vpc[0].vpc_id
  subnets = module.vpc[0].private_subnets

  enable_irsa = true

  manage_aws_auth = true

  map_roles = [
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
      username = "admin"
      groups    = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/oncall-developer"
      username = "oncall-developer"
      groups    = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/developer"
      username = "developer"
      groups    = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/readonly"
      username = "readonly"
      groups    = ["system:authenticated"]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  workers_additional_policies =[aws_iam_policy.cluster_autoscaler.id]

  worker_groups_launch_template = [
    {
      name                    = "cpu-spot"
      override_instance_types = var.wg_instance_types
      spot_instance_pools     = length(var.wg_instance_types)
      asg_max_size            = var.wg_autoscaling_maximum_size
      asg_desired_capacity    = var.wg_autoscaling_minimum_size
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = false
      ami_id                  = local.ami_id
      root_encrypted          = true
      root_volume_size        = var.disk_size
    },
  // mixed spot fleet with on demand instances
    # {
    #   name                                     = "gpu-spot"
    #   override_instance_types                  = ["p2.xlarge", "p3.2xlarge"]
    #   spot_instance_pools                      = 4
    #   asg_max_size                             = 10
    #   asg_desired_capacity                     = 1
    #   root_encrypted                           = true
    #   on_demand_base_capacity                  = 1
    #   on_demand_percentage_above_base_capacity = 25
    #   kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`"
    #   public_ip                                = false
    #   ami_id                                   = data.aws_ami.eks_gpu.id
    # }, 
  ]

  # node_groups = {
  #   general = {
  #     desired_capacity = var.autoscaling_minimum_size_by_az * length(module.vpc[0].azs)
  #     max_capacity     = var.autoscaling_maximum_size_by_az * length(module.vpc[0].azs)
  #     min_capacity     = var.autoscaling_minimum_size_by_az * length(module.vpc[0].azs)
  #     instance_types   = [var.instance_type]
  #     disk_size        = var.disk_size
  #   }
  # }


  write_kubeconfig = false
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc[0].vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.main_network_block,
    ]
  }
}

# This autoscaler works from-the-box with Intel core
# When using Graviton or AMD core, AMI type need to be set explicitly in eks.node_groups
resource "helm_release" "cluster-autoscaler" {
  depends_on = [
    module.eks
  ]

  name             = "cluster-autoscaler"
  namespace        = local.k8s_service_account_namespace
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.10.7"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = local.k8s_service_account_name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks[0].cluster_id
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
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

