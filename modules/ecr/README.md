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
| [aws_ecr_repository.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.busybox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.edrgen](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.eks_pause](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.external_attacher](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.external_provisioner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.external_resizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.git_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.karpenter_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_admission_webhooks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_metrics_apiserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.keda_operator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.livenessprobe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.nginx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.node_driver_registrar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.postgresql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.rdrgen](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.statsd_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.vic2png](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

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
| <a name="output_aws_ebs_csi_driver_repository_url"></a> [aws\_ebs\_csi\_driver\_repository\_url](#output\_aws\_ebs\_csi\_driver\_repository\_url) | AWS EBS CSI Driver ECR repository URL |
| <a name="output_busybox_repository_url"></a> [busybox\_repository\_url](#output\_busybox\_repository\_url) | Busybox base image ECR repository URL |
| <a name="output_edrgen_repository_url"></a> [edrgen\_repository\_url](#output\_edrgen\_repository\_url) | Unity EDRGEN ECR repository URL |
| <a name="output_eks_pause_repository_url"></a> [eks\_pause\_repository\_url](#output\_eks\_pause\_repository\_url) | EKS pause image ECR repository URL |
| <a name="output_external_attacher_repository_url"></a> [external\_attacher\_repository\_url](#output\_external\_attacher\_repository\_url) | External Attacher ECR repository URL |
| <a name="output_external_provisioner_repository_url"></a> [external\_provisioner\_repository\_url](#output\_external\_provisioner\_repository\_url) | External Provisioner ECR repository URL |
| <a name="output_external_resizer_repository_url"></a> [external\_resizer\_repository\_url](#output\_external\_resizer\_repository\_url) | External Resizer ECR repository URL |
| <a name="output_git_sync_repository_url"></a> [git\_sync\_repository\_url](#output\_git\_sync\_repository\_url) | Git sync ECR repository URL |
| <a name="output_karpenter_controller_repository_url"></a> [karpenter\_controller\_repository\_url](#output\_karpenter\_controller\_repository\_url) | Karpenter controller ECR repository URL |
| <a name="output_karpenter_webhook_repository_url"></a> [karpenter\_webhook\_repository\_url](#output\_karpenter\_webhook\_repository\_url) | Karpenter webhook ECR repository URL |
| <a name="output_keda_admission_webhooks_repository_url"></a> [keda\_admission\_webhooks\_repository\_url](#output\_keda\_admission\_webhooks\_repository\_url) | KEDA admission webhooks ECR repository URL |
| <a name="output_keda_metrics_apiserver_repository_url"></a> [keda\_metrics\_apiserver\_repository\_url](#output\_keda\_metrics\_apiserver\_repository\_url) | KEDA metrics apiserver ECR repository URL |
| <a name="output_keda_operator_repository_url"></a> [keda\_operator\_repository\_url](#output\_keda\_operator\_repository\_url) | KEDA operator ECR repository URL |
| <a name="output_livenessprobe_repository_url"></a> [livenessprobe\_repository\_url](#output\_livenessprobe\_repository\_url) | Liveness Probe ECR repository URL |
| <a name="output_nginx_repository_url"></a> [nginx\_repository\_url](#output\_nginx\_repository\_url) | Nginx base image ECR repository URL |
| <a name="output_node_driver_registrar_repository_url"></a> [node\_driver\_registrar\_repository\_url](#output\_node\_driver\_registrar\_repository\_url) | Node Driver Registrar ECR repository URL |
| <a name="output_postgresql_repository_url"></a> [postgresql\_repository\_url](#output\_postgresql\_repository\_url) | PostgreSQL ECR repository URL |
| <a name="output_rdrgen_repository_url"></a> [rdrgen\_repository\_url](#output\_rdrgen\_repository\_url) | Unity RDRGEN ECR repository URL |
| <a name="output_redis_repository_url"></a> [redis\_repository\_url](#output\_redis\_repository\_url) | Redis ECR repository URL |
| <a name="output_statsd_exporter_repository_url"></a> [statsd\_exporter\_repository\_url](#output\_statsd\_exporter\_repository\_url) | Statsd exporter ECR repository URL |
| <a name="output_vic2png_repository_url"></a> [vic2png\_repository\_url](#output\_vic2png\_repository\_url) | Unity VIC2PNG ECR repository URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
