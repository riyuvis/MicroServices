# Manual Infrastructure Deployment Guide

Since Terraform was just installed and needs PATH refresh, here's how to deploy the infrastructure manually:

## 🔧 Step 1: Refresh Environment and Verify Terraform

```bash
# Close and reopen your terminal/command prompt
# Then verify Terraform installation:
terraform --version
```

## 🚀 Step 2: Deploy Infrastructure

### Option A: Using PowerShell Script (Recommended)
```powershell
# Set AWS credentials
$env:AWS_ACCESS_KEY_ID='YOUR_AWS_ACCESS_KEY_ID'
$env:AWS_SECRET_ACCESS_KEY='YOUR_AWS_SECRET_ACCESS_KEY'
$env:AWS_DEFAULT_REGION='us-east-1'

# Deploy infrastructure
.\scripts\deploy-infrastructure.ps1
```

### Option B: Manual Terraform Commands
```bash
# Navigate to infrastructure directory
cd infrastructure

# Initialize Terraform
terraform init

# Create terraform.tfvars from example
copy terraform.tfvars.example terraform.tfvars

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

## 🏗️ Infrastructure Components to be Deployed

### Core Infrastructure:
- ✅ **VPC** with public/private subnets across 3 AZs
- ✅ **EKS Cluster** with managed node groups
- ✅ **RDS PostgreSQL** database
- ✅ **Application Load Balancer** (ALB)
- ✅ **Security Groups** with least privilege access

### Security & Compliance:
- ✅ **AWS Secrets Manager** for application secrets
- ✅ **AWS Config** for compliance monitoring
- ✅ **AWS Security Hub** for centralized security findings
- ✅ **AWS CloudWatch** for monitoring and logging
- ✅ **S3 Buckets** for Terraform state and Bedrock logs

### Networking:
- ✅ **Internet Gateway** for public access
- ✅ **NAT Gateways** for private subnet internet access
- ✅ **Route Tables** for proper traffic routing
- ✅ **Network ACLs** for additional security

### Estimated Costs:
- EKS Cluster: ~$73/month
- RDS Database: ~$25/month
- NAT Gateways: ~$45/month
- Load Balancer: ~$16/month
- **Total**: ~$159/month

## 🔍 Pre-Deployment Checklist

- [ ] AWS credentials configured and tested
- [ ] Terraform installed and accessible
- [ ] AWS account has sufficient permissions
- [ ] Desired AWS region selected (us-east-1)
- [ ] S3 bucket for Terraform state (will be created)

## 📋 Required AWS Permissions

Your AWS user/role needs these permissions:
- `AmazonVPCFullAccess`
- `AmazonEKSClusterPolicy`
- `AmazonRDSFullAccess`
- `AmazonElasticLoadBalancingFullAccess`
- `AmazonS3FullAccess`
- `AmazonSecretsManagerFullAccess`
- `AWSConfigRole`
- `SecurityHubFullAccess`
- `AmazonCloudWatchFullAccess`
- `IAMFullAccess`

## 🚨 Important Notes

1. **State Management**: Terraform state will be stored in S3
2. **Resource Naming**: All resources prefixed with "devsecops-dev-"
3. **Region**: Infrastructure deploys to us-east-1
4. **Cleanup**: Use `terraform destroy` to remove all resources

## 🎯 Post-Deployment Steps

After successful deployment:

1. **Update kubectl config**:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name devsecops-dev-eks
   ```

2. **Verify cluster access**:
   ```bash
   kubectl get nodes
   ```

3. **Deploy applications**:
   ```bash
   .\scripts\deploy-applications.ps1
   ```

4. **Start monitoring**:
   ```bash
   .\scripts\start-monitoring.ps1
   ```

## 🔧 Troubleshooting

### Common Issues:
- **Permission denied**: Check AWS IAM permissions
- **Resource limit exceeded**: Check AWS service limits
- **Terraform not found**: Restart terminal after installation
- **State lock**: Wait for previous operation to complete

### Getting Help:
- Check AWS CloudTrail for detailed error logs
- Review Terraform plan output for resource conflicts
- Verify AWS service availability in your region

