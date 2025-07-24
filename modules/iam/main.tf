# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "am-${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "am-${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_node" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_role.name
}

# Karpenter Controller IAM Role
resource "aws_iam_role" "karpenter_controller_role" {
  name = "am-${var.cluster_name}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^https:///", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Karpenter Controller Policy
resource "aws_iam_policy" "karpenter_controller_policy" {
  name = "am-${var.cluster_name}-karpenter-controller-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws-us-gov:ec2:*::snapshot/*",
          "arn:aws-us-gov:ec2:*::image/*",
          "arn:aws-us-gov:ec2:*:*:subnet/*",
          "arn:aws-us-gov:ec2:*:*:spot-instances-request/*",
          "arn:aws-us-gov:ec2:*:*:security-group/*",
          "arn:aws-us-gov:ec2:*:*:launch-template/*"
        ]
        Sid = "AllowScopedEC2InstanceActions"
      },
      {
        Action = [
          "ec2:RunInstances",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" = "owned"
          }
          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
        Effect = "Allow"
        Resource = [
          "arn:aws-us-gov:ec2:*:*:volume/*",
          "arn:aws-us-gov:ec2:*:*:spot-instances-request/*",
          "arn:aws-us-gov:ec2:*:*:network-interface/*",
          "arn:aws-us-gov:ec2:*:*:launch-template/*",
          "arn:aws-us-gov:ec2:*:*:instance/*",
          "arn:aws-us-gov:ec2:*:*:fleet/*"
        ]
        Sid = "AllowScopedEC2InstanceActionsWithTags"
      },
      {
        Action = "ec2:TerminateInstances"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" = "owned"
          }
          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
        Effect   = "Allow"
        Resource = "arn:aws-us-gov:ec2:*:*:instance/*"
        Sid      = "AllowScopedEC2InstanceTermination"
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeImages",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "AllowScopedEC2InstanceDescribeActions"
      },
      {
        Action = [
          "ec2:CreateTags"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" = "owned"
          }
          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
        Effect = "Allow"
        Resource = [
          "arn:aws-us-gov:ec2:*:*:volume/*",
          "arn:aws-us-gov:ec2:*:*:spot-instances-request/*",
          "arn:aws-us-gov:ec2:*:*:network-interface/*",
          "arn:aws-us-gov:ec2:*:*:launch-template/*",
          "arn:aws-us-gov:ec2:*:*:instance/*",
          "arn:aws-us-gov:ec2:*:*:fleet/*"
        ]
        Sid = "AllowScopedResourceCreationTagging"
      },
      {
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:ListQueues",
          "sqs:ReceiveMessage"
        ]
        Effect   = "Allow"
        Resource = var.karpenter_queue_arn
        Sid      = "AllowSQSReadAccess"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node_role.arn
        Sid      = "AllowPassNodeIAMRole"
      }
    ]
  })

  tags = var.tags
}

# Attach Karpenter Controller Policy
resource "aws_iam_role_policy_attachment" "karpenter_controller_policy" {
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
  role       = aws_iam_role.karpenter_controller_role.name
}

# Karpenter Node IAM Role
resource "aws_iam_role" "karpenter_node_role" {
  name = "am-${var.cluster_name}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to Karpenter Node Role
resource "aws_iam_role_policy_attachment" "karpenter_worker_node_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node_role.name
}

resource "aws_iam_role_policy_attachment" "karpenter_cni_policy" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node_role.name
}

resource "aws_iam_role_policy_attachment" "karpenter_container_registry_readonly" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node_role.name
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_managed_instance_core" {
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_node_role.name
}

# Karpenter Node Instance Profile
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "am-${var.cluster_name}-karpenter-node-instance-profile"
  role = aws_iam_role.karpenter_node_role.name

  tags = var.tags
}
