# kubernetes

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.4.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.airflow](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.airflow_dags](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [kubernetes_manifest.karpenter_nodeclass](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.karpenter_nodepool](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubernetes_config_map_v1.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/config_map_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_deploy_dags"></a> [deploy\_dags](#input\_deploy\_dags) | Whether to deploy the default DAGs (rdrgen, edrgen, vic2png) | `bool` | `true` | no |
| <a name="input_karpenter_controller_role_arn"></a> [karpenter\_controller\_role\_arn](#input\_karpenter\_controller\_role\_arn) | Karpenter controller IAM role ARN | `string` | n/a | yes |
| <a name="input_karpenter_node_instance_profile_name"></a> [karpenter\_node\_instance\_profile\_name](#input\_karpenter\_node\_instance\_profile\_name) | Karpenter node instance profile name | `string` | n/a | yes |
| <a name="input_karpenter_node_role_arn"></a> [karpenter\_node\_role\_arn](#input\_karpenter\_node\_role\_arn) | Karpenter node IAM role ARN | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_airflow_namespace"></a> [airflow\_namespace](#output\_airflow\_namespace) | Airflow namespace |
| <a name="output_airflow_release_name"></a> [airflow\_release\_name](#output\_airflow\_release\_name) | Airflow Helm release name |
| <a name="output_karpenter_namespace"></a> [karpenter\_namespace](#output\_karpenter\_namespace) | Karpenter namespace |
| <a name="output_karpenter_release_name"></a> [karpenter\_release\_name](#output\_karpenter\_release\_name) | Karpenter Helm release name |
| <a name="output_keda_namespace"></a> [keda\_namespace](#output\_keda\_namespace) | KEDA namespace |
| <a name="output_keda_release_name"></a> [keda\_release\_name](#output\_keda\_release\_name) | KEDA Helm release name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
