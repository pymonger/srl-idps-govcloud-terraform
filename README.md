# Complete EKS Infrastructure with KEDA, Karpenter, and Airflow

This Terraform configuration creates a complete EKS cluster infrastructure in AWS GovCloud with KEDA, Karpenter, and Airflow deployment, including all necessary dependencies and the custom Airflow Docker image.

## Architecture

This Terraform configuration is specifically designed for **AWS GovCloud** environments and fully complies with GovCloud's internet access restrictions. All container images are sourced from ECR repositories within your AWS account, ensuring no external registry dependencies.

The infrastructure is organized into multiple modules:

### 1. VPC Module (`./modules/vpc`)
- VPC with DNS support enabled
- Public and private subnets across multiple availability zones
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route tables and associations
- Proper tagging for EKS integration and Karpenter discovery

### 2. IAM Module (`./modules/iam`)
- EKS cluster IAM role with necessary policies
- EKS node group IAM role with worker node policies
- Karpenter controller and node IAM roles
- Additional policies for EBS/EFS CSI drivers, SSM, and ECR access

### 3. EKS Module (`./modules/eks`)
- EKS cluster with security groups
- Managed node group with t3.medium instances
- OIDC provider for service account integration
- Security group rules for cluster-node communication

### 4. EFS Module (`./modules/efs`)
- EFS file system for persistent storage
- EFS access points for Airflow DAGs, logs, and shared data
- Security groups for EFS mount targets

### 5. SQS Module (`./modules/sqs`)
- SQS queue for Karpenter interruption handling
- Dead letter queue for failed messages
- Queue policies for EventBridge integration

### 6. ECR Module (`./modules/ecr`)
- ECR repositories for all required container images
- Lifecycle policies for image cleanup
- Support for custom Airflow image

### 7. Kubernetes Module (`./modules/kubernetes`)
- KEDA deployment for autoscaling
- Karpenter deployment for node provisioning
- Airflow deployment with custom image
- Helm chart management for all applications

## Prerequisites

### Required Tools
- Terraform >= 1.0
- AWS CLI configured for GovCloud
- Docker for building custom Airflow image
- kubectl for cluster interaction
- helm for chart management
- pre-commit (optional, for development workflow)

### Required AWS Permissions
- Appropriate AWS permissions for EKS, VPC, IAM, EFS, SQS, and ECR resources

### Administrative Requirements
**IMPORTANT**: Before running this Terraform configuration, your AWS GovCloud administrators must deploy the JPL IAM as Code CloudFormation stack that provides custom resource creation capabilities:

**Required CloudFormation Stack:**
- **Stack Name**: `StackSet-jpl-roles-as-code-*` (dynamically generated when deployed)
- **Purpose**: Provides custom CloudFormation resources including `Custom::JplEksFederation` for OIDC provider creation
- **Deployment**: Must be deployed by administrators with elevated permissions
- **Status**: This is a human-in-the-loop process that cannot be automated
- **Repository**: The stack resources are defined in `/Users/gmanipon/dev/roles-as-code`

**How It Works:**
The Terraform configuration uses a CloudFormation stack with the `Custom::JplEksFederation` resource type to create the OIDC provider. This custom resource is provided by the JPL IAM as Code system and allows advanced users to create OIDC providers without requiring elevated IAM permissions.

**Verification:**
After the CloudFormation stack is deployed, you can verify it's working by checking if the custom resources are available:
```bash
# Check if the CloudFormation stack exists (replace with actual stack name)
aws cloudformation list-stacks --region us-gov-west-1 --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`) && StackStatus==`CREATE_COMPLETE`]'

# Check if the custom resource exports are available
aws cloudformation list-exports --region us-gov-west-1 --query 'Exports[?Name==`Custom::JplEksFed::ServiceToken`]'
```

**Note**: The CloudFormation stack name is dynamically generated when administrators deploy the JPL IAM as Code stack. The verification commands above will help you identify the actual stack name in your environment.

## GovCloud Compliance

This configuration is designed for AWS GovCloud environments where resources don't have direct internet access to public container registries (Docker Hub, GitHub Container Registry, etc.). All container images are sourced from ECR repositories within your AWS account.

### Image Mirroring Process

Before deploying the infrastructure, you must mirror all required images from public registries to your ECR repositories:

```bash
# Mirror all required images to ECR
./scripts/mirror-images.sh
```

This script will:
- Pull images from public registries (ghcr.io, docker.io, etc.)
- Tag them for your ECR repositories
- Push them to your ECR repositories
- Clean up local images

**Required Images:**
- KEDA: `kedacore/keda`, `kedacore/keda-metrics-apiserver`, `kedacore/keda-admission-webhooks`
- Karpenter: `karpenter/controller`, `karpenter/webhook`
- Supporting: `statsd-exporter`, `redis`, `git-sync/git-sync`, `postgresql`
- Base Images: `unity/alpine`, `unity/busybox`, `unity/nginx` (for sidecars and init containers)

## Development Setup

### Pre-commit Hooks (Recommended)
This project includes comprehensive pre-commit hooks for code quality, security, and compliance:

```bash
# Setup pre-commit hooks and tools
./scripts/setup-pre-commit.sh
```

**Available Checks:**
- **Terraform**: Formatting, validation, linting, security scanning
- **Security**: Checkov, tfsec, detect-secrets, credential detection
- **Documentation**: Markdown linting, YAML validation, README generation
- **Code Quality**: Shell script linting, JSON validation, trailing whitespace
- **Cost Analysis**: Infracost integration for cost estimation
- **Compliance**: Custom rules for GovCloud compliance

**Usage:**
```bash
pre-commit run --all-files    # Run all hooks on all files
pre-commit run                # Run hooks on staged files
pre-commit run <hook-name>    # Run specific hook
pre-commit autoupdate         # Update hook versions
```

## Usage

### 1. Verify Administrative Setup
**CRITICAL**: Ensure the required CloudFormation stack has been deployed by your administrators:
```bash
# Check if the CloudFormation stack exists (replace with actual stack name)
aws cloudformation list-stacks --region us-gov-west-1 --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`) && StackStatus==`CREATE_COMPLETE`]'

# Check if the custom resource exports are available
aws cloudformation list-exports --region us-gov-west-1 --query 'Exports[?Name==`Custom::JplEksFed::ServiceToken`]'
```

If the stack doesn't exist or the exports are not available, contact your AWS GovCloud administrators to deploy the JPL IAM as Code stack before proceeding.

### 2. Mirror Images (GovCloud Requirement)
Mirror all required images to ECR:
```bash
./scripts/mirror-images.sh
```

### 3. Build Custom Airflow Image
Build and push the custom Airflow Docker image:
```bash
./scripts/build-airflow-image.sh
```

### 4. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Verify Deployment
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

### 4. Access Airflow
```bash
# Port forward to access Airflow UI
kubectl port-forward -n sps svc/airflow-webserver 8080:8080
```
Then open http://localhost:8080 in your browser.

### 5. Destroy Infrastructure
```bash
terraform destroy
```

## Configuration

The configuration can be customized by modifying `terraform.tfvars`:

### EKS Configuration
- `cluster_name`: Name of the EKS cluster
- `kubernetes_version`: Kubernetes version for the cluster
- `vpc_cidr`: CIDR block for the VPC
- `public_subnet_cidrs`: CIDR blocks for public subnets
- `private_subnet_cidrs`: CIDR blocks for private subnets
- `availability_zones`: AWS availability zones
- `node_group_instance_types`: EC2 instance types for worker nodes
- `node_group_desired_size`: Desired number of worker nodes
- `service_ipv4_cidr`: CIDR block for Kubernetes services

### Application Configuration
- **KEDA**: Autoscaling for Airflow workers (1-10 replicas)
- **Karpenter**: Node provisioning with c6i.large instances
  - Configured to use subnets and security groups tagged with `karpenter.sh/discovery`
  - Supports both Spot and On-Demand instances
  - Automatic node lifecycle management
- **Airflow**: Custom image with Unity SPS plugins
- **EFS**: Persistent storage for DAGs, logs, and shared data
- **SQS**: Interruption handling for Karpenter

### Custom Airflow Image
The deployment uses a custom Airflow Docker image that includes:
- Unity SPS utilities plugin
- Additional Python packages (Flask-Session, msgspec, statsd-client)
- FAB authentication configuration
- Custom webserver configuration

## Outputs

The configuration provides comprehensive outputs:

### EKS Outputs
- `cluster_id`: EKS cluster ID
- `cluster_endpoint`: EKS cluster endpoint
- `cluster_certificate_authority_data`: Cluster CA certificate
- `vpc_id`: VPC ID
- `private_subnet_ids`: Private subnet IDs
- `public_subnet_ids`: Public subnet IDs

### Storage Outputs
- `efs_file_system_id`: EFS file system ID
- `efs_security_group_id`: EFS security group ID
- `karpenter_queue_url`: Karpenter SQS queue URL
- `karpenter_queue_arn`: Karpenter SQS queue ARN

### ECR Outputs
- `airflow_repository_url`: Custom Airflow ECR repository
- `karpenter_controller_repository_url`: Karpenter controller ECR repository
- `keda_operator_repository_url`: KEDA operator ECR repository

### IAM Outputs
- `karpenter_controller_role_arn`: Karpenter controller IAM role
- `karpenter_node_instance_profile_name`: Karpenter node instance profile

### Application Outputs
- `keda_release_name`: KEDA Helm release name
- `karpenter_release_name`: Karpenter Helm release name
- `airflow_release_name`: Airflow Helm release name

## Security Features

- Private subnets for worker nodes
- Security groups with minimal required access
- IAM roles with least privilege policies
- OIDC provider for secure service account integration
- Public access restricted to specified CIDR blocks
- Encrypted EFS file system
- SQS queue policies for secure message handling
- ECR image scanning enabled
- Custom Airflow image with security hardening

## Cost Considerations

- NAT Gateway incurs hourly charges
- EKS cluster has a base cost per hour
- Worker nodes are charged based on instance type and usage
- EFS file system has storage and throughput costs
- SQS queues have per-message charges
- ECR repositories have storage costs
- Karpenter can provision Spot instances for cost optimization
- Consider using Spot instances for non-production workloads

## Maintenance

- Kubernetes version updates should be planned carefully
- Node group updates can be performed with zero downtime
- Security group rules can be modified without cluster downtime
- IAM policies can be updated without affecting running workloads
- ECR image lifecycle policies automatically clean up old images
- Karpenter automatically handles node lifecycle management
- KEDA provides automatic scaling based on workload demand
- Airflow database migrations are handled automatically by Helm

## Troubleshooting

### OIDC Provider Issues

If you encounter errors related to OIDC provider creation, ensure:

1. **CloudFormation Stack is Deployed:**
   ```bash
   # Check if the CloudFormation stack exists (replace with actual stack name)
   aws cloudformation list-stacks --region us-gov-west-1 --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`) && StackStatus==`CREATE_COMPLETE`]'
   ```

2. **Check Custom Resource Exports:**
   ```bash
   # Check if the custom resource exports are available
   aws cloudformation list-exports --region us-gov-west-1 --query 'Exports[?Name==`Custom::JplEksFed::ServiceToken`]'
   ```

3. **Check OIDC Provider Exists:**
   ```bash
   # Get the OIDC issuer URL from your EKS cluster
   aws eks describe-cluster --name gman-test --region us-gov-west-1 --query 'cluster.identity.oidc.issuer' --output text

   # Check if the OIDC provider exists
   aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `oidc-provider`)]' --output table
   ```

4. **Common Error Messages:**
   - `Error: No exports found for Custom::JplEksFed::ServiceToken`: CloudFormation stack not deployed or exports not available
   - `Error: error creating CloudFormation stack`: Insufficient permissions or custom resource not available
   - `Error: No IAM OpenID Connect Provider found`: OIDC provider doesn't exist for your cluster
   - `Error: Access Denied`: Insufficient permissions to create OIDC providers

5. **Resolution Steps:**
   - Contact your AWS GovCloud administrators to deploy the JPL IAM as Code CloudFormation stack
   - Verify the stack deployment was successful and exports are available
   - Ensure your AWS credentials have the necessary permissions
   - Re-run `terraform plan` and `terraform apply`

**Getting the Actual Stack Name:**
If you need the exact stack name for detailed troubleshooting, you can find it using:
```bash
# List all CloudFormation stacks and filter for JPL roles-as-code
aws cloudformation list-stacks --region us-gov-west-1 --query 'StackSummaries[?contains(StackName, `StackSet-jpl-roles-as-code`)].{StackName:StackName,Status:StackStatus}' --output table
``` <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="output_busybox_repository_url"></a> [busybox\_repository\_url](#output\_busybox\_repository\_url) | Busybox base image ECR repository URL |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | EKS cluster ARN |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | EKS cluster certificate authority data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | EKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | EKS cluster OIDC issuer URL |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS cluster security group ID |
| <a name="output_efs_file_system_id"></a> [efs\_file\_system\_id](#output\_efs\_file\_system\_id) | EFS file system ID |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | EFS security group ID |
| <a name="output_karpenter_controller_repository_url"></a> [karpenter\_controller\_repository\_url](#output\_karpenter\_controller\_repository\_url) | Karpenter controller ECR repository URL |
| <a name="output_karpenter_controller_role_arn"></a> [karpenter\_controller\_role\_arn](#output\_karpenter\_controller\_role\_arn) | Karpenter controller IAM role ARN |
| <a name="output_karpenter_node_instance_profile_name"></a> [karpenter\_node\_instance\_profile\_name](#output\_karpenter\_node\_instance\_profile\_name) | Karpenter node instance profile name |
| <a name="output_karpenter_queue_arn"></a> [karpenter\_queue\_arn](#output\_karpenter\_queue\_arn) | Karpenter interruption queue ARN |
| <a name="output_karpenter_queue_url"></a> [karpenter\_queue\_url](#output\_karpenter\_queue\_url) | Karpenter interruption queue URL |
| <a name="output_karpenter_release_name"></a> [karpenter\_release\_name](#output\_karpenter\_release\_name) | Karpenter Helm release name |
| <a name="output_keda_operator_repository_url"></a> [keda\_operator\_repository\_url](#output\_keda\_operator\_repository\_url) | KEDA operator ECR repository URL |
| <a name="output_keda_release_name"></a> [keda\_release\_name](#output\_keda\_release\_name) | KEDA Helm release name |
| <a name="output_nginx_repository_url"></a> [nginx\_repository\_url](#output\_nginx\_repository\_url) | Nginx base image ECR repository URL |
| <a name="output_node_group_arn"></a> [node\_group\_arn](#output\_node\_group\_arn) | EKS node group ARN |
| <a name="output_node_group_id"></a> [node\_group\_id](#output\_node\_group\_id) | EKS node group ID |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | EKS node security group ID |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | EKS OIDC provider ARN |
| <a name="output_oidc_provider_stack_arn"></a> [oidc\_provider\_stack\_arn](#output\_oidc\_provider\_stack\_arn) | CloudFormation stack ARN for OIDC provider |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
