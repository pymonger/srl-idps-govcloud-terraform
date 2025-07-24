# ecr

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.alpine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.busybox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.eks_pause](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.git_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.karpenter_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_admission_webhooks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_metrics_apiserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_operator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.nginx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.postgresql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.statsd_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_airflow_repository_url"></a> [airflow\_repository\_url](#output\_airflow\_repository\_url) | Airflow ECR repository URL |
| <a name="output_alpine_repository_url"></a> [alpine\_repository\_url](#output\_alpine\_repository\_url) | Alpine base image ECR repository URL |
| <a name="output_busybox_repository_url"></a> [busybox\_repository\_url](#output\_busybox\_repository\_url) | Busybox base image ECR repository URL |
| <a name="output_git_sync_repository_url"></a> [git\_sync\_repository\_url](#output\_git\_sync\_repository\_url) | Git sync ECR repository URL |
| <a name="output_karpenter_controller_repository_url"></a> [karpenter\_controller\_repository\_url](#output\_karpenter\_controller\_repository\_url) | Karpenter controller ECR repository URL |
| <a name="output_karpenter_webhook_repository_url"></a> [karpenter\_webhook\_repository\_url](#output\_karpenter\_webhook\_repository\_url) | Karpenter webhook ECR repository URL |
| <a name="output_keda_admission_webhooks_repository_url"></a> [keda\_admission\_webhooks\_repository\_url](#output\_keda\_admission\_webhooks\_repository\_url) | KEDA admission webhooks ECR repository URL |
| <a name="output_keda_metrics_apiserver_repository_url"></a> [keda\_metrics\_apiserver\_repository\_url](#output\_keda\_metrics\_apiserver\_repository\_url) | KEDA metrics apiserver ECR repository URL |
| <a name="output_keda_operator_repository_url"></a> [keda\_operator\_repository\_url](#output\_keda\_operator\_repository\_url) | KEDA operator ECR repository URL |
| <a name="output_nginx_repository_url"></a> [nginx\_repository\_url](#output\_nginx\_repository\_url) | Nginx base image ECR repository URL |
| <a name="output_postgresql_repository_url"></a> [postgresql\_repository\_url](#output\_postgresql\_repository\_url) | PostgreSQL ECR repository URL |
| <a name="output_redis_repository_url"></a> [redis\_repository\_url](#output\_redis\_repository\_url) | Redis ECR repository URL |
| <a name="output_statsd_exporter_repository_url"></a> [statsd\_exporter\_repository\_url](#output\_statsd\_exporter\_repository\_url) | Statsd exporter ECR repository URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
