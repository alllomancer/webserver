# AWS PARAMETERS
region      = "eu-central-1"
# --------------

# VPC PARAMETERS
create_vpc              = true
vpc_name                = "demo"
iac_environment_tag     = "demo"
main_network_block      = "10.1.0.0/16"
number_of_azs           = 3
subnet_prefix_extension = "4"
zone_offset             = "8"
# --------------

# EKS PARAMETERS
create_eks                     = true
aws_region                     = "eu-central-1"
cluster_name                   = "demo-eks"
kubernetes_version             = "1.21"
instance_type                  = "t3a.small"
disk_size                      = 200
wg_autoscaling_minimum_size    = "1"
wg_autoscaling_maximum_size    = "1"
autoscaling_maximum_size_by_az = "0"
autoscaling_minimum_size_by_az = "0"
install_metrics_server         = true
install_cluster_autoscaler     = true
wg_instance_types              = ["t3.small", "t3.micro", "t3.nano"]
    
# --------------
