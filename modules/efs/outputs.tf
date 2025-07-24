output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.airflow.id
}

output "efs_file_system_arn" {
  description = "EFS file system ARN"
  value       = aws_efs_file_system.airflow.arn
}

output "efs_security_group_id" {
  description = "EFS security group ID"
  value       = aws_security_group.efs.id
}

output "airflow_dags_access_point_id" {
  description = "Airflow DAGs access point ID"
  value       = aws_efs_access_point.airflow_dags.id
}

output "airflow_logs_access_point_id" {
  description = "Airflow logs access point ID"
  value       = aws_efs_access_point.airflow_logs.id
}

output "shared_task_data_access_point_id" {
  description = "Shared task data access point ID"
  value       = aws_efs_access_point.shared_task_data.id
}
