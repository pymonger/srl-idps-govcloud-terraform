output "airflow_repository_url" {
  description = "Airflow ECR repository URL"
  value       = aws_ecr_repository.airflow.repository_url
}

output "karpenter_controller_repository_url" {
  description = "Karpenter controller ECR repository URL"
  value       = aws_ecr_repository.karpenter_controller.repository_url
}

output "karpenter_webhook_repository_url" {
  description = "Karpenter webhook ECR repository URL"
  value       = aws_ecr_repository.karpenter_webhook.repository_url
}

output "keda_operator_repository_url" {
  description = "KEDA operator ECR repository URL"
  value       = aws_ecr_repository.keda_operator.repository_url
}

output "keda_metrics_apiserver_repository_url" {
  description = "KEDA metrics apiserver ECR repository URL"
  value       = aws_ecr_repository.keda_metrics_apiserver.repository_url
}

output "keda_admission_webhooks_repository_url" {
  description = "KEDA admission webhooks ECR repository URL"
  value       = aws_ecr_repository.keda_admission_webhooks.repository_url
}

output "statsd_exporter_repository_url" {
  description = "Statsd exporter ECR repository URL"
  value       = aws_ecr_repository.statsd_exporter.repository_url
}

output "redis_repository_url" {
  description = "Redis ECR repository URL"
  value       = aws_ecr_repository.redis.repository_url
}

output "git_sync_repository_url" {
  description = "Git sync ECR repository URL"
  value       = aws_ecr_repository.git_sync.repository_url
}

output "postgresql_repository_url" {
  description = "PostgreSQL ECR repository URL"
  value       = aws_ecr_repository.postgresql.repository_url
}

output "alpine_repository_url" {
  description = "Alpine base image ECR repository URL"
  value       = aws_ecr_repository.alpine.repository_url
}

output "busybox_repository_url" {
  description = "Busybox base image ECR repository URL"
  value       = aws_ecr_repository.busybox.repository_url
}

output "nginx_repository_url" {
  description = "Nginx base image ECR repository URL"
  value       = aws_ecr_repository.nginx.repository_url
}

output "rdrgen_repository_url" {
  description = "Unity RDRGEN ECR repository URL"
  value       = aws_ecr_repository.rdrgen.repository_url
}

output "edrgen_repository_url" {
  description = "Unity EDRGEN ECR repository URL"
  value       = aws_ecr_repository.edrgen.repository_url
}

output "vic2png_repository_url" {
  description = "Unity VIC2PNG ECR repository URL"
  value       = aws_ecr_repository.vic2png.repository_url
}

output "eks_pause_repository_url" {
  description = "EKS pause image ECR repository URL"
  value       = aws_ecr_repository.eks_pause.repository_url
}
