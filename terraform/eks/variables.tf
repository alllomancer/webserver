
variable "region" {
  default = "us-east-1"
  //    default = "eu-central-1"
}
variable "environment" {
  default = "uat-us-east-1"
}
# ---------------------------------------------------------------------------------------------------------------------
# VPC PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "create_vpc" {
  type        = bool
  description = "Indication of whether to create a VPC."
}

variable "vpc_name" {
  type        = string
  description = "Name to be used on all the resources as identifier."
}

variable "iac_environment_tag" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}

variable "main_network_block" {
  type        = string
  description = "Base CIDR block to be used in our VPC."
}

variable "number_of_azs" {
  type        = number
  description = "Number of Availability Zones to subnets in."
  default     = 3
}

variable "subnet_prefix_extension" {
  type        = number
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
}

variable "zone_offset" {
  type        = number
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "create_eks" {
  type        = bool
  description = "Indication of whether to create an EKS cluster."
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes."
}

variable "instance_type" {
  type        = string
  description = "The type of the instances."
}

variable "disk_size" {
    type        = number
    default     = 100
}

variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
  default     = 0
}

variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
  default     = 0
}

variable "wg_autoscaling_minimum_size" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
  default     = 0
}

variable "wg_autoscaling_maximum_size" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
  default     = 0
}

variable "install_metrics_server" {
  type        = bool
  description = "Indication of whether to install metrics-server on the cluster."
}

variable "install_cluster_autoscaler" {
  type        = bool
  description = "Indication of whether to install cluster-autoscaler on the cluster."
}

variable "install_efs_provisioner" {
  description = "Indication of whether to install EFS-Provisioner on the cluster."
  type        = bool
  default     = false
}

variable "cluster_enabled_log_types" {
  default     = ["api","audit"]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "wg_instance_types" {
  default     = ["t3.small", "t3.large"]
  description = "A list of the instance types to put in the work group"
  type        = list(string)
}

variable "ami_id" {
  type        = string
  description = "the ami id for the nodes"
  default     = null
}

