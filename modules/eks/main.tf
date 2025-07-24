# Security Groups
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.cluster_name}-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

resource "aws_security_group" "eks_nodes_sg" {
  name_prefix = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name                     = "${var.cluster_name}-nodes-sg"
    "karpenter.sh/discovery" = var.cluster_name
  })
}

# Security Group Rules
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow unmanaged nodes to communicate with control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow control plane to communicate with unmanaged nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 65535
  type                     = "egress"
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow unmanaged nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 0
  type                     = "ingress"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = var.public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
    ip_family         = "ipv4"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    var.cluster_policy_attachments
  ]

  tags = var.tags
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-ng-1"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  labels = {
    "alpha.eksctl.io/cluster-name"   = var.cluster_name
    "alpha.eksctl.io/nodegroup-name" = "${var.cluster_name}-ng-1"
  }

  depends_on = [
    var.node_policy_attachments
  ]

  tags = merge(var.tags, {
    "alpha.eksctl.io/cluster-name"   = var.cluster_name
    "alpha.eksctl.io/nodegroup-name" = "${var.cluster_name}-ng-1"
    "alpha.eksctl.io/nodegroup-type" = "managed"
  })
}

# OIDC Provider - Use JPL EKS Federation CloudFormation stack
# This creates the OIDC provider using the custom CloudFormation resource
# that allows advanced users to create OIDC providers in GovCloud
resource "aws_cloudformation_stack" "eks_oidc_provider" {
  name = "${var.cluster_name}-irsa"

  timeout_in_minutes = 4

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-irsa"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })

  template_body = <<EOF
AWSTemplateFormatVersion: 2010-09-09
Resources:
  EksFederation:
    Type: Custom::JplEksFederation
    Properties:
      ServiceToken: !ImportValue Custom::JplEksFed::ServiceToken
      EksClusterName: ${var.cluster_name}
Outputs:
  EksFederationArn:
    Value: !Sub $${EksFederation.OpenIDConnectProviderArn}
EOF
}

# Data source to reference the created OIDC provider
data "aws_iam_openid_connect_provider" "eks" {
  url        = aws_eks_cluster.main.identity[0].oidc[0].issuer
  depends_on = [aws_cloudformation_stack.eks_oidc_provider]
}
