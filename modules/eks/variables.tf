variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "CIDR blocks for public access to EKS cluster"
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
}

variable "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  type        = string
}

variable "node_role_arn" {
  description = "EKS node IAM role ARN"
  type        = string
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "node_group_instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
}

variable "cluster_policy_attachments" {
  description = "List of cluster policy attachments for depends_on"
  type        = list(any)
  default     = []
}

variable "node_policy_attachments" {
  description = "List of node policy attachments for depends_on"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
