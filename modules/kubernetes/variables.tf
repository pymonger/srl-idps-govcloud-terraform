variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "karpenter_controller_role_arn" {
  description = "Karpenter controller IAM role ARN"
  type        = string
}

variable "karpenter_node_instance_profile_name" {
  description = "Karpenter node instance profile name"
  type        = string
}

variable "karpenter_node_role_arn" {
  description = "Karpenter node IAM role ARN"
  type        = string
}

variable "deploy_dags" {
  description = "Whether to deploy the default DAGs (rdrgen, edrgen, vic2png)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
