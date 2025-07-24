#!/bin/bash

# Build and push custom Airflow Docker image to ECR
set -e

# Configuration
CLUSTER_NAME="gman-test"
AWS_REGION="us-gov-west-1"
AIRFLOW_VERSION="2.10.5-python3.10"
ECR_REPO="airflow"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECR repository URL
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

# Build the custom Airflow image
echo "Building custom Airflow image..."
cd ../srl-idps-airflow-deployment
docker build -t ${ECR_URL}/${ECR_REPO}:${AIRFLOW_VERSION} .

# Push the image to ECR
echo "Pushing image to ECR..."
docker push ${ECR_URL}/${ECR_REPO}:${AIRFLOW_VERSION}

echo "Custom Airflow image built and pushed successfully!"
echo "Image: ${ECR_URL}/${ECR_REPO}:${AIRFLOW_VERSION}"
