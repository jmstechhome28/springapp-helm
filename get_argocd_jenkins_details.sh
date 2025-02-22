#!/bin/bash

# Function to get public IP of a node
get_public_ip() {
    local NODE_NAME=$1
    aws ec2 describe-instances --filters "Name=private-ip-address,Values=$(kubectl get node $NODE_NAME -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text
}

# Get ArgoCD Server Node IP and Service Port
ARGOCD_NODE_NAME=$(kubectl get pods -n argocd -o wide | grep argocd-server | awk '{print $9}')
ARGOCD_PUBLIC_IP=$(get_public_ip $ARGOCD_NODE_NAME)
ARGOCD_SVC_PORT=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.spec.ports[0].nodePort}')

# Get ArgoCD Login Token
ARGOCD_TOKEN=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode)

# Get Jenkins Node IP and Service Port
JENKINS_NODE_NAME=$(kubectl get pods -n jenkins -o wide | grep jenkins | awk '{print $9}')
JENKINS_PUBLIC_IP=$(get_public_ip $JENKINS_NODE_NAME)
JENKINS_SVC_PORT=$(kubectl get svc -n jenkins jenkins -o jsonpath='{.spec.ports[0].nodePort}')

# Get Jenkins Admin Credentials
JENKINS_ADMIN_USER=$(kubectl -n jenkins get secret jenkins-admin-secret -o jsonpath='{.data.username}' | base64 --decode)
JENKINS_ADMIN_PASSWORD=$(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)

# Build URLs
ARGOCD_URL="http://$ARGOCD_PUBLIC_IP:$ARGOCD_SVC_PORT"
JENKINS_URL="http://$JENKINS_PUBLIC_IP:$JENKINS_SVC_PORT"

# Output the results
echo "ArgoCD Public IP: $ARGOCD_PUBLIC_IP"
echo "ArgoCD Service Port: $ARGOCD_SVC_PORT"
echo "ArgoCD Admin Token: $ARGOCD_TOKEN"
echo "ArgoCD URL: $ARGOCD_URL"
echo "Jenkins Public IP: $JENKINS_PUBLIC_IP"
echo "Jenkins Service Port: $JENKINS_SVC_PORT"
echo "Jenkins Admin Username: $JENKINS_ADMIN_USER"
echo "Jenkins Admin Password: $JENKINS_ADMIN_PASSWORD"
echo "Jenkins URL: $JENKINS_URL"

