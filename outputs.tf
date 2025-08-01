output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.node_group_id
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks.node_group_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.existing.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = data.aws_subnets.private.ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = data.aws_subnets.private.ids
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

# EFS Outputs
output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = module.efs.efs_file_system_id
}

output "efs_security_group_id" {
  description = "EFS security group ID"
  value       = module.efs.efs_security_group_id
}

# SQS Outputs
output "karpenter_queue_url" {
  description = "Karpenter interruption queue URL"
  value       = module.sqs.karpenter_queue_url
}

output "karpenter_queue_arn" {
  description = "Karpenter interruption queue ARN"
  value       = module.sqs.karpenter_queue_arn
}

# ECR Outputs
output "airflow_repository_url" {
  description = "Airflow ECR repository URL"
  value       = module.ecr.airflow_repository_url
}

output "karpenter_controller_repository_url" {
  description = "Karpenter controller ECR repository URL"
  value       = module.ecr.karpenter_controller_repository_url
}

output "keda_operator_repository_url" {
  description = "KEDA operator ECR repository URL"
  value       = module.ecr.keda_operator_repository_url
}

output "alpine_repository_url" {
  description = "Alpine base image ECR repository URL"
  value       = module.ecr.alpine_repository_url
}

output "busybox_repository_url" {
  description = "Busybox base image ECR repository URL"
  value       = module.ecr.busybox_repository_url
}

output "nginx_repository_url" {
  description = "Nginx base image ECR repository URL"
  value       = module.ecr.nginx_repository_url
}

output "rdrgen_repository_url" {
  description = "Unity RDRGEN ECR repository URL"
  value       = module.ecr.rdrgen_repository_url
}

output "edrgen_repository_url" {
  description = "Unity EDRGEN ECR repository URL"
  value       = module.ecr.edrgen_repository_url
}

output "vic2png_repository_url" {
  description = "Unity VIC2PNG ECR repository URL"
  value       = module.ecr.vic2png_repository_url
}

output "eks_pause_repository_url" {
  description = "EKS pause image ECR repository URL"
  value       = module.ecr.eks_pause_repository_url
}

output "aws_ebs_csi_driver_repository_url" {
  description = "AWS EBS CSI Driver ECR repository URL"
  value       = module.ecr.aws_ebs_csi_driver_repository_url
}

output "external_provisioner_repository_url" {
  description = "External Provisioner ECR repository URL"
  value       = module.ecr.external_provisioner_repository_url
}

output "external_resizer_repository_url" {
  description = "External Resizer ECR repository URL"
  value       = module.ecr.external_resizer_repository_url
}

output "external_attacher_repository_url" {
  description = "External Attacher ECR repository URL"
  value       = module.ecr.external_attacher_repository_url
}

output "livenessprobe_repository_url" {
  description = "Liveness Probe ECR repository URL"
  value       = module.ecr.livenessprobe_repository_url
}

output "node_driver_registrar_repository_url" {
  description = "Node Driver Registrar ECR repository URL"
  value       = module.ecr.node_driver_registrar_repository_url
}

# IAM Outputs
output "karpenter_controller_role_arn" {
  description = "Karpenter controller IAM role ARN"
  value       = module.iam.karpenter_controller_role_arn
}

output "karpenter_node_instance_profile_name" {
  description = "Karpenter node instance profile name"
  value       = module.iam.karpenter_node_instance_profile_name
}

# Kubernetes Application Outputs
output "keda_release_name" {
  description = "KEDA Helm release name"
  value       = module.kubernetes.keda_release_name
}

output "karpenter_release_name" {
  description = "Karpenter Helm release name"
  value       = module.kubernetes.karpenter_release_name
}

output "airflow_release_name" {
  description = "Airflow Helm release name"
  value       = module.kubernetes.airflow_release_name
}

# OIDC Provider Outputs
output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_stack_arn" {
  description = "CloudFormation stack ARN for OIDC provider"
  value       = module.eks.oidc_provider_stack_arn
}
