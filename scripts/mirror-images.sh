#!/bin/bash

# Mirror images from public registries to ECR for GovCloud compliance
set -e

# Configuration
CLUSTER_NAME="gman-test"
AWS_REGION="us-gov-west-1"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

# Function to mirror an image
mirror_image() {
    local source_image=$1
    local target_repo=$2
    local target_tag=$3

    echo "Mirroring ${source_image} to ${ECR_URL}/${target_repo}:${target_tag}"

    # Pull the source image
    docker pull ${source_image}

    # Tag for ECR
    docker tag ${source_image} ${ECR_URL}/${target_repo}:${target_tag}

    # Push to ECR
    docker push ${ECR_URL}/${target_repo}:${target_tag}

    # Clean up local images
    docker rmi ${source_image} ${ECR_URL}/${target_repo}:${target_tag}
}

echo "Starting image mirroring process..."

# KEDA Images
mirror_image "ghcr.io/kedacore/keda:2.17.2" "kedacore/keda" "2.17.2"
mirror_image "ghcr.io/kedacore/keda-metrics-apiserver:2.17.2" "kedacore/keda-metrics-apiserver" "2.17.2"
mirror_image "ghcr.io/kedacore/keda-admission-webhooks:2.17.2" "kedacore/keda-admission-webhooks" "2.17.2"

# Karpenter Images
mirror_image "public.ecr.aws/karpenter/controller:v0.16.3" "karpenter/controller" "v0.16.3"
mirror_image "public.ecr.aws/karpenter/webhook:v0.16.3" "karpenter/webhook" "v0.16.3"

# Supporting Images
mirror_image "prom/statsd-exporter:v0.28.0" "statsd-exporter" "v0.28.0"
mirror_image "redis:7.2-bookworm" "redis" "7.2-bookworm"
mirror_image "k8s.gcr.io/git-sync/git-sync:v4.3.0" "git-sync/git-sync" "v4.3.0"
mirror_image "bitnami/postgresql:16.1.0-debian-11-r15" "postgresql" "16.1.0-debian-11-r15"

# Base Images (for sidecars and init containers)
mirror_image "alpine:3.19" "unity/alpine" "3.19"
mirror_image "alpine:latest" "unity/alpine" "latest"

# Additional base images commonly used in Kubernetes
mirror_image "busybox:1.36" "unity/busybox" "1.36"
mirror_image "busybox:latest" "unity/busybox" "latest"
mirror_image "nginx:1.25-alpine" "unity/nginx" "1.25-alpine"
mirror_image "nginx:alpine" "unity/nginx" "alpine"

echo "All images mirrored successfully!"
echo "You can now build and push your custom Airflow image using: ./scripts/build-airflow-image.sh"
