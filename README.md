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
