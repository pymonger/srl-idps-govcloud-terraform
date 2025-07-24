output "keda_release_name" {
  description = "KEDA Helm release name"
  value       = helm_release.keda.name
}

output "karpenter_release_name" {
  description = "Karpenter Helm release name"
  value       = helm_release.karpenter.name
}

output "airflow_release_name" {
  description = "Airflow Helm release name"
  value       = helm_release.airflow.name
}

output "keda_namespace" {
  description = "KEDA namespace"
  value       = helm_release.keda.namespace
}

output "karpenter_namespace" {
  description = "Karpenter namespace"
  value       = helm_release.karpenter.namespace
}

output "airflow_namespace" {
  description = "Airflow namespace"
  value       = helm_release.airflow.namespace
}
