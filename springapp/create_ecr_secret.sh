#!/bin/bash

# Set AWS region and ECR registry
export AWS_REGION="ap-south-1"
export ECR_REGISTRY="060795946012.dkr.ecr.ap-south-1.amazonaws.com"
NAMESPACE="springapp"
SECRET_NAME="ecr-secret"

# Check if the secret exists and delete it if found
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Secret '$SECRET_NAME' exists in namespace '$NAMESPACE'. Deleting..."
    kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE"
else
    echo "Secret '$SECRET_NAME' does not exist in namespace '$NAMESPACE'. Skipping delete..."
fi

# Create a new ECR secret
echo "Creating new ECR secret..."
kubectl create secret docker-registry "$SECRET_NAME" \
    --docker-server="$ECR_REGISTRY" \
    --docker-username=AWS \
    --docker-password="$(aws ecr get-login-password --region "$AWS_REGION")" \
    -n "$NAMESPACE"

echo "Secret '$SECRET_NAME' created successfully!"

