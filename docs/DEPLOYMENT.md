# DevSecOps AWS Deployment Guide

This guide provides step-by-step instructions for deploying the DevSecOps AWS flow with Bedrock integration for microservices.

## Prerequisites

### Required Tools
- AWS CLI v2.0+
- Terraform v1.0+
- kubectl v1.28+
- Docker v20.0+
- Node.js v18.0+
- npm v8.0+

### AWS Account Setup
1. Create an AWS account with appropriate permissions
2. Configure AWS CLI with your credentials:
   ```bash
   aws configure
   ```
3. Create an S3 bucket for Terraform state:
   ```bash
   aws s3 mb s3://devsecops-terraform-state
   ```

### Required AWS Services
- Amazon Bedrock (with Claude 3 Sonnet model access)
- Amazon EKS
- Amazon RDS (PostgreSQL)
- Amazon Secrets Manager
- Amazon Config
- AWS Security Hub
- Amazon CloudWatch

## Deployment Steps

### 1. Infrastructure Deployment

#### Configure Terraform Variables
```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

#### Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

#### Verify Infrastructure
```bash
# Check EKS cluster
aws eks describe-cluster --name devsecops-dev-eks

# Check RDS instance
aws rds describe-db-instances --db-instance-identifier devsecops-dev-db

# Check Bedrock model access
aws bedrock list-foundation-models --region us-east-1
```

### 2. Kubernetes Configuration

#### Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name devsecops-dev-eks
```

#### Verify Cluster Access
```bash
kubectl get nodes
kubectl get namespaces
```

### 3. Application Deployment

#### Deploy Namespaces and Configurations
```bash
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/configmaps/
```

#### Configure Secrets
```bash
# Update secrets with actual values
kubectl create secret generic app-secrets \
  --from-literal=database-url="postgresql://user:password@rds-endpoint:5432/db" \
  --from-literal=jwt-secret="your-jwt-secret" \
  --from-literal=encryption-key="your-encryption-key" \
  --namespace=microservices
```

#### Deploy Applications
```bash
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/ingress/
```

#### Verify Deployment
```bash
kubectl get pods -n microservices
kubectl get services -n microservices
kubectl get ingress -n microservices
```

### 4. Monitoring Setup

#### Deploy Prometheus
```bash
kubectl apply -f monitoring/k8s/prometheus-deployment.yaml
```

#### Deploy Grafana
```bash
# Create Grafana deployment
kubectl apply -f monitoring/k8s/grafana-deployment.yaml

# Access Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

#### Deploy AlertManager
```bash
kubectl apply -f monitoring/k8s/alertmanager-deployment.yaml
```

### 5. Security Configuration

#### Configure AWS Security Hub
```bash
# Enable Security Hub
aws securityhub enable-security-hub --region us-east-1

# Enable AWS Config
aws configservice put-configuration-recorder --configuration-recorder file://config-recorder.json
```

#### Run Security Scans
```bash
# Install dependencies
npm install
cd security && npm install

# Run security scan
npm run security:scan
```

## Environment-Specific Configurations

### Development Environment
```bash
# Use development configuration
export ENVIRONMENT=dev
export AWS_REGION=us-east-1
export CLUSTER_NAME=devsecops-dev-eks
```

### Production Environment
```bash
# Use production configuration
export ENVIRONMENT=prod
export AWS_REGION=us-east-1
export CLUSTER_NAME=devsecops-prod-eks
```

## Verification Checklist

### Infrastructure
- [ ] EKS cluster is running
- [ ] RDS instance is accessible
- [ ] VPC and subnets are configured
- [ ] Security groups are properly configured
- [ ] Load balancer is working

### Applications
- [ ] All microservices are running
- [ ] Health checks are passing
- [ ] API endpoints are responding
- [ ] Database connections are working
- [ ] Bedrock integration is functional

### Security
- [ ] Security scans are running
- [ ] Secrets are properly configured
- [ ] Network policies are enforced
- [ ] Monitoring is active
- [ ] Alerts are configured

### Monitoring
- [ ] Prometheus is collecting metrics
- [ ] Grafana dashboards are accessible
- [ ] AlertManager is configured
- [ ] Logs are being collected
- [ ] Performance metrics are visible

## Troubleshooting

### Common Issues

#### EKS Cluster Issues
```bash
# Check cluster status
aws eks describe-cluster --name devsecops-dev-eks

# Check node group status
aws eks describe-nodegroup --cluster-name devsecops-dev-eks --nodegroup-name devsecops-dev-node-group
```

#### Application Issues
```bash
# Check pod logs
kubectl logs -f deployment/api -n microservices

# Check service endpoints
kubectl get endpoints -n microservices

# Check ingress status
kubectl describe ingress microservices-ingress -n microservices
```

#### Security Issues
```bash
# Check security scan logs
kubectl logs -f deployment/security-scanner -n security

# Verify Bedrock access
aws bedrock list-foundation-models --region us-east-1
```

#### Monitoring Issues
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
# Open http://localhost:9090/targets

# Check Grafana connectivity
kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Open http://localhost:3000
```

## Cleanup

### Remove Applications
```bash
kubectl delete -f k8s/
```

### Remove Infrastructure
```bash
cd infrastructure
terraform destroy
```

### Remove S3 Bucket
```bash
aws s3 rb s3://devsecops-terraform-state --force
```

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review AWS CloudWatch logs
3. Check Kubernetes events: `kubectl get events -n microservices`
4. Contact the DevSecOps team

## Security Considerations

- Always use HTTPS in production
- Rotate secrets regularly
- Enable AWS CloudTrail for audit logging
- Use least privilege IAM policies
- Regularly update dependencies
- Monitor for security vulnerabilities
- Enable AWS GuardDuty for threat detection
