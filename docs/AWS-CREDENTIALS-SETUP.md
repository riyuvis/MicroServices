# AWS Credentials Setup Guide

This guide explains how to set up AWS credentials for the DevSecOps AWS Flow with Bedrock integration.

## 🔐 Required AWS Permissions

Your AWS credentials need the following permissions:

### Core Services
- **Amazon Bedrock** - For AI-powered security scanning
- **Amazon EKS** - For Kubernetes cluster management
- **Amazon RDS** - For database management
- **Amazon Secrets Manager** - For secrets management

### Security & Compliance
- **AWS Config** - For compliance monitoring
- **AWS Security Hub** - For centralized security findings
- **AWS CloudWatch** - For monitoring and logging
- **AWS CloudTrail** - For audit logging

### Infrastructure
- **Amazon VPC** - For network management
- **Amazon EC2** - For compute resources
- **Amazon S3** - For storage and Terraform state
- **AWS IAM** - For access management

## 📋 Setup Methods

### Method 1: AWS CLI Configuration (Recommended)

If you have AWS CLI installed:

```bash
aws configure
```

You'll be prompted for:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region**: `us-east-1` (recommended)
- **Default output format**: `json`

### Method 2: Environment Variables

Set these environment variables in your system:

```bash
# Windows PowerShell
$env:AWS_ACCESS_KEY_ID="your-access-key-id"
$env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
$env:AWS_DEFAULT_REGION="us-east-1"
$env:AWS_REGION="us-east-1"

# Windows Command Prompt
set AWS_ACCESS_KEY_ID=your-access-key-id
set AWS_SECRET_ACCESS_KEY=your-secret-access-key
set AWS_DEFAULT_REGION=us-east-1
set AWS_REGION=us-east-1

# Linux/Mac
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="us-east-1"
```

### Method 3: AWS Credentials File

Create the credentials file at `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
```

Create the config file at `~/.aws/config`:

```ini
[default]
region = us-east-1
output = json
```

### Method 4: IAM Roles (For EC2 Instances)

If running on EC2, you can use IAM roles instead of credentials:

1. Create an IAM role with these policies:
   - `AmazonBedrockFullAccess`
   - `AmazonEKSClusterPolicy`
   - `AmazonRDSFullAccess`
   - `AmazonSecretsManagerFullAccess`
   - `AWSConfigRole`
   - `SecurityHubFullAccess`
   - `AmazonEC2FullAccess`

2. Attach the role to your EC2 instance

## 🔍 Testing Your Setup

### Test Basic Access
```bash
aws sts get-caller-identity
```

### Test Bedrock Access
```bash
aws bedrock list-foundation-models --region us-east-1
```

### Test EKS Access
```bash
aws eks list-clusters --region us-east-1
```

## 🛡️ Security Best Practices

### 1. Use Least Privilege
- Only grant the minimum permissions needed
- Regularly review and rotate credentials
- Use IAM roles when possible instead of access keys

### 2. Rotate Credentials
- Rotate access keys every 90 days
- Use AWS Secrets Manager for automatic rotation
- Monitor credential usage with CloudTrail

### 3. Secure Storage
- Never commit credentials to version control
- Use environment variables or secure credential stores
- Enable MFA for AWS console access

### 4. Monitor Access
- Enable CloudTrail for audit logging
- Set up alerts for unusual access patterns
- Use AWS Config for compliance monitoring

## 🚨 Troubleshooting

### Common Issues

#### "Unable to locate credentials"
- Check if credentials are properly configured
- Verify environment variables are set
- Ensure credentials file exists and has correct permissions

#### "Access Denied" errors
- Verify your IAM permissions
- Check if the service is available in your region
- Ensure you have the correct policy attached

#### "Bedrock access denied"
- Request access to Bedrock models in AWS console
- Verify your region supports Bedrock
- Check if you have the required permissions

### Getting Help

1. Check AWS documentation for the specific service
2. Review CloudTrail logs for detailed error information
3. Contact AWS support for account-specific issues

## 📞 Support

For issues with this DevSecOps setup:
- Check the troubleshooting section above
- Review AWS CloudWatch logs
- Contact the DevSecOps team

## 🔗 Useful Links

- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Amazon Bedrock Getting Started](https://docs.aws.amazon.com/bedrock/latest/userguide/getting-started.html)
- [AWS EKS Getting Started](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
