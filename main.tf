terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source for existing VPC (using tags to find the appropriate VPC)
data "aws_vpc" "existing" {
  tags = {
    "JplVpcType" = "TGW-Internal"
  }
}

# Data sources for existing private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:karpenter.sh/discovery"
    values = ["gman-test"]
  }
}

# Validation to ensure subnets with karpenter.sh/discovery tag are found
locals {
  subnet_count = length(data.aws_subnets.private.ids)
}

resource "null_resource" "validate_subnets" {
  count = local.subnet_count == 0 ? 1 : 0

  lifecycle {
    precondition {
      condition     = local.subnet_count > 0
      error_message = "No subnets found with tag karpenter.sh/discovery = gman-test in VPC ${data.aws_vpc.existing.id}"
    }
  }
}

# SQS Module
module "sqs" {
  source = "./modules/sqs"

  cluster_name = var.cluster_name
  tags         = var.tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  cluster_name = var.cluster_name
  tags         = var.tags
}

# EFS Module
module "efs" {
  source = "./modules/efs"

  cluster_name               = var.cluster_name
  vpc_id                     = data.aws_vpc.existing.id
  private_subnet_ids         = data.aws_subnets.private.ids
  eks_node_security_group_id = module.eks.node_security_group_id
  tags                       = var.tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name        = var.cluster_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  karpenter_queue_arn = module.sqs.karpenter_queue_arn
  tags                = var.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  vpc_id                    = data.aws_vpc.existing.id
  private_subnet_ids        = data.aws_subnets.private.ids
  public_access_cidrs       = var.public_access_cidrs
  service_ipv4_cidr         = var.service_ipv4_cidr
  cluster_role_arn          = module.iam.cluster_role_arn
  node_role_arn             = module.iam.node_role_arn
  node_group_desired_size   = var.node_group_desired_size
  node_group_max_size       = var.node_group_max_size
  node_group_min_size       = var.node_group_min_size
  node_group_instance_types = var.node_group_instance_types
  cluster_policy_attachments = [
    module.iam.cluster_role_arn
  ]
  node_policy_attachments = [
    module.iam.node_role_arn
  ]
  tags = var.tags
}

# Kubernetes Applications Module
module "kubernetes" {
  source = "./modules/kubernetes"

  cluster_name                         = var.cluster_name
  cluster_endpoint                     = module.eks.cluster_endpoint
  karpenter_controller_role_arn        = module.iam.karpenter_controller_role_arn
  karpenter_node_instance_profile_name = module.iam.karpenter_node_instance_profile_name
  karpenter_node_role_arn              = module.iam.karpenter_node_role_arn
  tags                                 = var.tags
}
