# AWS Bedrock Permissions Setup Guide

## 🔐 **Required Permissions for Bedrock DevSecOps Flow**

Your AWS user needs specific permissions to create and manage Bedrock resources. Here's how to add them:

## 📋 **Required Permissions**

### **Bedrock Permissions:**
- `bedrock:CreateKnowledgeBase`
- `bedrock:GetKnowledgeBase`
- `bedrock:UpdateKnowledgeBase`
- `bedrock:DeleteKnowledgeBase`
- `bedrock:CreateAgent`
- `bedrock:GetAgent`
- `bedrock:UpdateAgent`
- `bedrock:DeleteAgent`
- `bedrock:CreateAgentActionGroup`
- `bedrock:GetAgentActionGroup`
- `bedrock:UpdateAgentActionGroup`
- `bedrock:DeleteAgentActionGroup`
- `bedrock:CreateAgentAlias`
- `bedrock:GetAgentAlias`
- `bedrock:UpdateAgentAlias`
- `bedrock:DeleteAgentAlias`
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListFoundationModels`
- `bedrock:GetFoundationModel`

### **Supporting Service Permissions:**
- `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`
- `opensearchserverless:CreateCollection`
- `opensearchserverless:GetCollection`
- `opensearchserverless:UpdateCollection`
- `opensearchserverless:DeleteCollection`
- `opensearchserverless:CreateSecurityPolicy`
- `opensearchserverless:UpdateSecurityPolicy`
- `opensearchserverless:CreateAccessPolicy`
- `opensearchserverless:UpdateAccessPolicy`
- `lambda:CreateFunction`, `lambda:GetFunction`, `lambda:UpdateFunction`
- `sns:CreateTopic`, `sns:GetTopic`, `sns:Publish`
- `iam:CreateRole`, `iam:GetRole`, `iam:AttachRolePolicy`

## 🚀 **Option 1: AWS Managed Policy (Recommended)**

### **Step 1: Attach AWS Managed Policy**
```bash
# Attach the AWS managed Bedrock policy
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
```

### **Step 2: Attach Additional Required Policies**
```bash
# Attach S3 policy for document storage
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Attach OpenSearch policy for vector storage
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonOpenSearchServerlessFullAccess

# Attach Lambda policy for action groups
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess

# Attach SNS policy for notifications
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess

# Attach IAM policy for role creation
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
```

## 🛠️ **Option 2: Custom Policy (More Secure)**

### **Step 1: Create Custom Policy**
```bash
# Create a custom policy with minimal required permissions
aws iam create-policy --policy-name BedrockDevSecOpsPolicy --policy-document file://bedrock-custom-policy.json
```

### **Step 2: Attach Custom Policy**
```bash
# Attach the custom policy to your user
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::731825699886:policy/BedrockDevSecOpsPolicy
```

## 📄 **Custom Policy JSON**

Create a file called `bedrock-custom-policy.json` with this content:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BedrockKnowledgeBaseAccess",
            "Effect": "Allow",
            "Action": [
                "bedrock:CreateKnowledgeBase",
                "bedrock:GetKnowledgeBase",
                "bedrock:UpdateKnowledgeBase",
                "bedrock:DeleteKnowledgeBase",
                "bedrock:ListKnowledgeBases",
                "bedrock:CreateDataSource",
                "bedrock:GetDataSource",
                "bedrock:UpdateDataSource",
                "bedrock:DeleteDataSource",
                "bedrock:ListDataSources",
                "bedrock:StartIngestionJob",
                "bedrock:GetIngestionJob",
                "bedrock:ListIngestionJobs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "BedrockAgentAccess",
            "Effect": "Allow",
            "Action": [
                "bedrock:CreateAgent",
                "bedrock:GetAgent",
                "bedrock:UpdateAgent",
                "bedrock:DeleteAgent",
                "bedrock:ListAgents",
                "bedrock:CreateAgentActionGroup",
                "bedrock:GetAgentActionGroup",
                "bedrock:UpdateAgentActionGroup",
                "bedrock:DeleteAgentActionGroup",
                "bedrock:ListAgentActionGroups",
                "bedrock:CreateAgentAlias",
                "bedrock:GetAgentAlias",
                "bedrock:UpdateAgentAlias",
                "bedrock:DeleteAgentAlias",
                "bedrock:ListAgentAliases"
            ],
            "Resource": "*"
        },
        {
            "Sid": "BedrockModelAccess",
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel",
                "bedrock:InvokeModelWithResponseStream",
                "bedrock:ListFoundationModels",
                "bedrock:GetFoundationModel"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:CreateBucket",
                "s3:GetBucketLocation",
                "s3:GetBucketPolicy",
                "s3:PutBucketPolicy",
                "s3:DeleteBucketPolicy"
            ],
            "Resource": [
                "arn:aws:s3:::devsecops-*-bedrock-documents",
                "arn:aws:s3:::devsecops-*-bedrock-documents/*"
            ]
        },
        {
            "Sid": "OpenSearchServerlessAccess",
            "Effect": "Allow",
            "Action": [
                "opensearchserverless:CreateCollection",
                "opensearchserverless:GetCollection",
                "opensearchserverless:UpdateCollection",
                "opensearchserverless:DeleteCollection",
                "opensearchserverless:ListCollections",
                "opensearchserverless:CreateSecurityPolicy",
                "opensearchserverless:GetSecurityPolicy",
                "opensearchserverless:UpdateSecurityPolicy",
                "opensearchserverless:DeleteSecurityPolicy",
                "opensearchserverless:ListSecurityPolicies",
                "opensearchserverless:CreateAccessPolicy",
                "opensearchserverless:GetAccessPolicy",
                "opensearchserverless:UpdateAccessPolicy",
                "opensearchserverless:DeleteAccessPolicy",
                "opensearchserverless:ListAccessPolicies",
                "opensearchserverless:BatchGetCollection",
                "opensearchserverless:GetAccountSettings",
                "opensearchserverless:UpdateAccountSettings"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LambdaAccess",
            "Effect": "Allow",
            "Action": [
                "lambda:CreateFunction",
                "lambda:GetFunction",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration",
                "lambda:DeleteFunction",
                "lambda:ListFunctions",
                "lambda:InvokeFunction",
                "lambda:AddPermission",
                "lambda:RemovePermission",
                "lambda:GetPolicy"
            ],
            "Resource": [
                "arn:aws:lambda:us-east-1:731825699886:function:devsecops-*"
            ]
        },
        {
            "Sid": "SNSAccess",
            "Effect": "Allow",
            "Action": [
                "sns:CreateTopic",
                "sns:GetTopicAttributes",
                "sns:SetTopicAttributes",
                "sns:DeleteTopic",
                "sns:ListTopics",
                "sns:Publish",
                "sns:Subscribe",
                "sns:Unsubscribe",
                "sns:ListSubscriptionsByTopic"
            ],
            "Resource": [
                "arn:aws:sns:us-east-1:731825699886:devsecops-*"
            ]
        },
        {
            "Sid": "IAMAccess",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:GetRole",
                "iam:UpdateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:CreatePolicy",
                "iam:GetPolicy",
                "iam:ListPolicies",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::731825699886:role/devsecops-*",
                "arn:aws:iam::731825699886:policy/devsecops-*"
            ]
        },
        {
            "Sid": "CloudWatchLogsAccess",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:731825699886:log-group:/aws/bedrock/*",
                "arn:aws:logs:us-east-1:731825699886:log-group:/aws/lambda/devsecops-*"
            ]
        }
    ]
}
```

## 🔧 **Quick Setup Script**

### **Automated Permission Setup:**
```bash
# Run this script to add all required permissions
./scripts/setup-bedrock-permissions.sh
```

## ✅ **Verification Steps**

### **Step 1: Test Bedrock Access**
```bash
# Test if you can list Bedrock models
aws bedrock list-foundation-models --region us-east-1
```

### **Step 2: Test Knowledge Base Creation**
```bash
# Test knowledge base permissions
aws bedrockagent list-knowledge-bases --region us-east-1
```

### **Step 3: Test Agent Creation**
```bash
# Test agent permissions
aws bedrockagent list-agents --region us-east-1
```

## 🚨 **Troubleshooting**

### **If Permissions Still Don't Work:**

1. **Check IAM Policy Attachment:**
   ```bash
   aws iam list-attached-user-policies --user-name a-sanjeevc
   ```

2. **Verify Policy ARN:**
   ```bash
   aws iam get-policy --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
   ```

3. **Check for Policy Conflicts:**
   ```bash
   aws iam list-user-policies --user-name a-sanjeevc
   ```

### **Common Issues:**
- **Policy propagation delay**: Wait 5-10 minutes after attaching policies
- **Region mismatch**: Ensure you're using the correct AWS region
- **Policy conflicts**: Check for explicit deny policies

## 📞 **Support**

If you continue to have permission issues:
1. **Contact your AWS administrator**
2. **Check AWS IAM documentation**
3. **Review AWS Bedrock service limits**
4. **Contact AWS Support** for service-specific issues

---

**🚀 Once permissions are set up, you can deploy your Bedrock DevSecOps flow!**
