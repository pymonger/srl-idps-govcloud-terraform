# Complete EKS Infrastructure with KEDA, Karpenter, and Airflow

This Terraform configuration creates a complete EKS cluster infrastructure in AWS GovCloud with KEDA, Karpenter, and Airflow deployment, including all necessary dependencies and custom Airflow Docker image support.

## 🏗️ Architecture

This Terraform configuration is specifically designed for **AWS GovCloud** environments and fully complies with GovCloud's internet access restrictions. All container images are sourced from ECR repositories within your AWS account, ensuring no external registry dependencies.

The infrastructure is organized into modular components:

### Core Infrastructure Modules

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **VPC** (`./modules/vpc`) | Network foundation | Public/private subnets, NAT Gateway, Karpenter discovery tags |
| **IAM** (`./modules/iam`) | Identity & access | EKS roles, Karpenter policies, service account permissions |
| **EKS** (`./modules/eks`) | Kubernetes cluster | EKS cluster, node groups, OIDC provider via JPL IAM as Code |
| **EFS** (`./modules/efs`) | Persistent storage | File system, access points for Airflow DAGs/logs |
| **SQS** (`./modules/sqs`) | Message queuing | Karpenter interruption handling with dead letter queue |
| **ECR** (`./modules/ecr`) | Container registry | Image repositories with lifecycle policies |
| **Kubernetes** (`./modules/kubernetes`) | Application deployment | KEDA, Karpenter, Airflow via Helm charts |

## 📋 Prerequisites

### Required Tools
- **Terraform** >= 1.0
- **AWS CLI** configured for GovCloud
- **Docker** for building custom Airflow image
- **kubectl** for cluster interaction
- **helm** for chart management
- **pre-commit** (optional, for development workflow)

### Required AWS Permissions
- EKS cluster management
- VPC and networking resources
- IAM roles and policies
- EFS file systems
- SQS queues
- ECR repositories

### Administrative Requirements ⚠️

**CRITICAL**: Before running this Terraform configuration, your AWS GovCloud administrators must deploy the JPL IAM as Code CloudFormation stack:

**Required CloudFormation Stack:**
- **Stack Name Pattern**: `StackSet-jpl-roles-as-code-*` (dynamically generated)
- **Purpose**: Provides `Custom::JplEksFederation` resource for OIDC provider creation
- **Deployment**: Must be deployed by administrators with elevated permissions
- **Status**: Human-in-the-loop process that cannot be automated

**Verification Commands:**
```bash
# Check if the CloudFormation stack exists
aws cloudformation list-stacks --region us-gov-west-1 \
  --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`) && StackStatus==`CREATE_COMPLETE`]'

# Check if custom resource exports are available
aws cloudformation list-exports --region us-gov-west-1 \
  --query 'Exports[?Name==`Custom::JplEksFed::ServiceToken`]'
```

## 🔒 GovCloud Compliance

This configuration addresses AWS GovCloud's internet access restrictions by sourcing all container images from ECR repositories within your AWS account.

### Image Mirroring Process

Before deployment, mirror all required images to ECR:

```bash
# Mirror all required images to ECR
./scripts/mirror-images.sh
```

**Required Images:**
- **KEDA**: `kedacore/keda`, `kedacore/keda-metrics-apiserver`, `kedacore/keda-admission-webhooks`
- **Karpenter**: `karpenter/controller`, `karpenter/webhook`
- **Supporting**: `statsd-exporter`, `redis`, `git-sync/git-sync`, `postgresql`
- **Base Images**: `unity/alpine`, `unity/busybox`, `unity/nginx` (for sidecars)

## 🛠️ Development Setup

### Pre-commit Hooks (Recommended)
```bash
# Setup pre-commit hooks and tools
./scripts/setup-pre-commit.sh
```

**Available Checks:**
- **Terraform**: Formatting, validation, security scanning
- **Security**: Credential detection, private key detection
- **Documentation**: Markdown linting, YAML validation
- **Code Quality**: JSON validation, trailing whitespace

## 🚀 Quick Start

### 1. Verify Administrative Setup
```bash
# Ensure CloudFormation stack is deployed
aws cloudformation list-stacks --region us-gov-west-1 \
  --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`) && StackStatus==`CREATE_COMPLETE`]'
```

### 2. Mirror Images (GovCloud Requirement)
```bash
./scripts/mirror-images.sh
```

### 3. Build Custom Airflow Image
```bash
./scripts/build-airflow-image.sh
```

### 4. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 5. Verify Deployment
```bash
# Check cluster status
kubectl get nodes

# Check application deployments
kubectl get pods -n keda
kubectl get pods -n karpenter
kubectl get pods -n sps

# Check Karpenter resources
kubectl get nodepools
kubectl get nodeclasses
```

### 6. Access Airflow
```bash
kubectl port-forward -n sps svc/airflow-webserver 8080:8080
```
Then open http://localhost:8080 in your browser.

## ⚙️ Configuration

Customize the deployment by modifying `terraform.tfvars`:

### EKS Configuration
```hcl
cluster_name = "your-cluster-name"
kubernetes_version = "1.32"
vpc_cidr = "10.0.0.0/16"
node_group_instance_types = ["t3.medium"]
node_group_desired_size = 4
```

### Application Configuration
- **KEDA**: Autoscaling for Airflow workers (1-10 replicas)
- **Karpenter**: Node provisioning with c6i.large instances
  - Uses subnets and security groups tagged with `karpenter.sh/discovery`
  - Supports both Spot and On-Demand instances
  - Automatic node lifecycle management
- **Airflow**: Custom image with Unity SPS plugins
- **EFS**: Persistent storage for DAGs, logs, and shared data
- **SQS**: Interruption handling for Karpenter

## 📊 Outputs

The configuration provides comprehensive outputs for integration with other systems:

### EKS Outputs
- `cluster_id`, `cluster_endpoint`, `cluster_certificate_authority_data`
- `vpc_id`, `private_subnet_ids`, `public_subnet_ids`

### Storage Outputs
- `efs_file_system_id`, `efs_security_group_id`
- `karpenter_queue_url`, `karpenter_queue_arn`

### ECR Outputs
- `airflow_repository_url`, `karpenter_controller_repository_url`
- `keda_operator_repository_url`

### IAM Outputs
- `karpenter_controller_role_arn`
- `karpenter_node_instance_profile_name`

## 🔐 Security Features

- Private subnets for worker nodes
- Security groups with minimal required access
- IAM roles with least privilege policies
- OIDC provider for secure service account integration
- Public access restricted to specified CIDR blocks
- Encrypted EFS file system
- SQS queue policies for secure message handling
- ECR image scanning enabled

## 💰 Cost Considerations

- NAT Gateway: ~$0.045/hour
- EKS cluster: ~$0.10/hour
- Worker nodes: Based on instance type and usage
- EFS: Storage and throughput costs
- SQS: Per-message charges
- ECR: Storage costs
- **Cost Optimization**: Karpenter can provision Spot instances

## 🔧 Maintenance

- **Kubernetes Updates**: Plan carefully for version upgrades
- **Node Groups**: Zero-downtime updates supported
- **Security Groups**: Can be modified without cluster downtime
- **IAM Policies**: Can be updated without affecting workloads
- **ECR Lifecycle**: Automatic cleanup of old images
- **Karpenter**: Automatic node lifecycle management
- **KEDA**: Automatic scaling based on workload demand

## 🐛 Troubleshooting

### OIDC Provider Issues

**Common Error Messages:**
- `No exports found for Custom::JplEksFed::ServiceToken`: CloudFormation stack not deployed
- `error creating CloudFormation stack`: Insufficient permissions
- `No IAM OpenID Connect Provider found`: OIDC provider doesn't exist
- `Access Denied`: Insufficient permissions

**Resolution Steps:**
1. Verify CloudFormation stack deployment
2. Check custom resource exports availability
3. Ensure AWS credentials have necessary permissions
4. Re-run `terraform plan` and `terraform apply`

**Getting Stack Name:**
```bash
aws cloudformation list-stacks --region us-gov-west-1 \
  --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`)].{StackName:StackName,Status:StackStatus}' \
  --output table
```

### Karpenter Issues

**Check Discovery Tags:**
```bash
# Verify subnets have karpenter.sh/discovery tags
aws ec2 describe-subnets --region us-gov-west-1 \
  --filters "Name=tag:karpenter.sh/discovery,Values=your-cluster-name"

# Verify security groups have karpenter.sh/discovery tags
aws ec2 describe-security-groups --region us-gov-west-1 \
  --filters "Name=tag:karpenter.sh/discovery,Values=your-cluster-name"
```

**AWS Auth Configuration:**
```bash
# Check if Karpenter node role is in aws-auth
kubectl get configmap aws-auth -n kube-system -o yaml

# The aws-auth ConfigMap is automatically managed by Terraform
# If Karpenter nodes can't authenticate, verify the role ARN is correct
# and the role has the necessary permissions
```

**Common Karpenter Node Issues:**
- **Authentication failures**: Check aws-auth ConfigMap configuration
- **API server connectivity**: Verify security groups and subnet routing
- **Node not joining**: Check IAM role permissions and instance profile

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [KEDA Documentation](https://keda.sh/)
- [Karpenter Documentation](https://karpenter.sh/)
- [Apache Airflow Documentation](https://airflow.apache.org/)
- [AWS GovCloud Documentation](https://aws.amazon.com/govcloud-us/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run pre-commit hooks: `pre-commit run --all-files`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.25 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/ecr | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | ./modules/efs | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ./modules/eks | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | ./modules/kubernetes | n/a |
| <a name="module_sqs"></a> [sqs](#module\_sqs) | ./modules/sqs | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones for subnets | `list(string)` | <pre>[<br/>  "us-gov-west-1a",<br/>  "us-gov-west-1b",<br/>  "us-gov-west-1c"<br/>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `"gman-test"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the EKS cluster | `string` | `"1.32"` | no |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | Desired number of nodes in the node group | `number` | `4` | no |
| <a name="input_node_group_instance_types"></a> [node\_group\_instance\_types](#input\_node\_group\_instance\_types) | Instance types for the node group | `list(string)` | <pre>[<br/>  "t3.medium"<br/>]</pre> | no |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | Maximum number of nodes in the node group | `number` | `4` | no |
| <a name="input_node_group_min_size"></a> [node\_group\_min\_size](#input\_node\_group\_min\_size) | Minimum number of nodes in the node group | `number` | `0` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets | `list(string)` | <pre>[<br/>  "10.0.11.0/24",<br/>  "10.0.12.0/24",<br/>  "10.0.13.0/24"<br/>]</pre> | no |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | CIDR blocks for public access to EKS cluster | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | CIDR block for Kubernetes services | `string` | `"10.100.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "gman-test",<br/>  "ManagedBy": "terraform",<br/>  "Owner": "account-managed"<br/>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_airflow_release_name"></a> [airflow\_release\_name](#output\_airflow\_release\_name) | Airflow Helm release name |
| <a name="output_airflow_repository_url"></a> [airflow\_repository\_url](#output\_airflow\_repository\_url) | Airflow ECR repository URL |
| <a name="output_alpine_repository_url"></a> [alpine\_repository\_url](#output\_alpine\_repository\_url) | Alpine base image ECR repository URL |
| <a name="output_aws_ebs_csi_driver_repository_url"></a> [aws\_ebs\_csi\_driver\_repository\_url](#output\_aws\_ebs\_csi\_driver\_repository\_url) | AWS EBS CSI Driver ECR repository URL |
| <a name="output_busybox_repository_url"></a> [busybox\_repository\_url](#output\_busybox\_repository\_url) | Busybox base image ECR repository URL |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | EKS cluster ARN |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | EKS cluster certificate authority data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | EKS cluster OIDC issuer URL |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS cluster security group ID |
| <a name="output_edrgen_repository_url"></a> [edrgen\_repository\_url](#output\_edrgen\_repository\_url) | Unity EDRGEN ECR repository URL |
| <a name="output_efs_file_system_id"></a> [efs\_file\_system\_id](#output\_efs\_file\_system\_id) | EFS file system ID |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | EFS security group ID |
| <a name="output_eks_pause_repository_url"></a> [eks\_pause\_repository\_url](#output\_eks\_pause\_repository\_url) | EKS pause image ECR repository URL |
| <a name="output_external_attacher_repository_url"></a> [external\_attacher\_repository\_url](#output\_external\_attacher\_repository\_url) | External Attacher ECR repository URL |
| <a name="output_external_provisioner_repository_url"></a> [external\_provisioner\_repository\_url](#output\_external\_provisioner\_repository\_url) | External Provisioner ECR repository URL |
| <a name="output_external_resizer_repository_url"></a> [external\_resizer\_repository\_url](#output\_external\_resizer\_repository\_url) | External Resizer ECR repository URL |
| <a name="output_karpenter_controller_repository_url"></a> [karpenter\_controller\_repository\_url](#output\_karpenter\_controller\_repository\_url) | Karpenter controller ECR repository URL |
| <a name="output_karpenter_controller_role_arn"></a> [karpenter\_controller\_role\_arn](#output\_karpenter\_controller\_role\_arn) | Karpenter controller IAM role ARN |
| <a name="output_karpenter_node_instance_profile_name"></a> [karpenter\_node\_instance\_profile\_name](#output\_karpenter\_node\_instance\_profile\_name) | Karpenter node instance profile name |
| <a name="output_karpenter_queue_arn"></a> [karpenter\_queue\_arn](#output\_karpenter\_queue\_arn) | Karpenter interruption queue ARN |
| <a name="output_karpenter_queue_url"></a> [karpenter\_queue\_url](#output\_karpenter\_queue\_url) | Karpenter interruption queue URL |
| <a name="output_karpenter_release_name"></a> [karpenter\_release\_name](#output\_karpenter\_release\_name) | Karpenter Helm release name |
| <a name="output_keda_operator_repository_url"></a> [keda\_operator\_repository\_url](#output\_keda\_operator\_repository\_url) | KEDA operator ECR repository URL |
| <a name="output_keda_release_name"></a> [keda\_release\_name](#output\_keda\_release\_name) | KEDA Helm release name |
| <a name="output_livenessprobe_repository_url"></a> [livenessprobe\_repository\_url](#output\_livenessprobe\_repository\_url) | Liveness Probe ECR repository URL |
| <a name="output_nginx_repository_url"></a> [nginx\_repository\_url](#output\_nginx\_repository\_url) | Nginx base image ECR repository URL |
| <a name="output_node_driver_registrar_repository_url"></a> [node\_driver\_registrar\_repository\_url](#output\_node\_driver\_registrar\_repository\_url) | Node Driver Registrar ECR repository URL |
| <a name="output_node_group_arn"></a> [node\_group\_arn](#output\_node\_group\_arn) | EKS node group ARN |
| <a name="output_node_group_id"></a> [node\_group\_id](#output\_node\_group\_id) | EKS node group ID |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | EKS node security group ID |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | EKS OIDC provider ARN |
| <a name="output_oidc_provider_stack_arn"></a> [oidc\_provider\_stack\_arn](#output\_oidc\_provider\_stack\_arn) | CloudFormation stack ARN for OIDC provider |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_rdrgen_repository_url"></a> [rdrgen\_repository\_url](#output\_rdrgen\_repository\_url) | Unity RDRGEN ECR repository URL |
| <a name="output_vic2png_repository_url"></a> [vic2png\_repository\_url](#output\_vic2png\_repository\_url) | Unity VIC2PNG ECR repository URL |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
