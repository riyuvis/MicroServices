# AWS Bedrock Permissions Setup Script
# Adds required permissions to your AWS user for Bedrock DevSecOps flow

param(
    [string]$UserName = "a-sanjeevc",
    [string]$Region = "us-east-1",
    [switch]$UseManagedPolicies = $true,
    [switch]$CreateCustomPolicy = $false,
    [switch]$Help
)

if ($Help) {
    Write-Host "AWS Bedrock Permissions Setup Script" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\setup-bedrock-permissions.ps1 [-UserName a-sanjeevc] [-Region us-east-1] [-UseManagedPolicies] [-CreateCustomPolicy]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -UserName           AWS IAM username - Default: a-sanjeevc"
    Write-Host "  -Region             AWS region - Default: us-east-1"
    Write-Host "  -UseManagedPolicies Use AWS managed policies (recommended) - Default: true"
    Write-Host "  -CreateCustomPolicy Create custom policy with minimal permissions"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup-bedrock-permissions.ps1"
    Write-Host "  .\setup-bedrock-permissions.ps1 -CreateCustomPolicy"
    Write-Host "  .\setup-bedrock-permissions.ps1 -UserName myuser -Region us-west-2"
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "🔐 AWS Bedrock Permissions Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  User Name: $UserName" -ForegroundColor White
Write-Host "  Region: $Region" -ForegroundColor White
Write-Host "  Use Managed Policies: $UseManagedPolicies" -ForegroundColor White
Write-Host "  Create Custom Policy: $CreateCustomPolicy" -ForegroundColor White
Write-Host ""

# Function to check AWS CLI
function Test-AWSCLI {
    try {
        $version = aws --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ AWS CLI is available: $version" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "❌ AWS CLI is not available" -ForegroundColor Red
        return $false
    }
}

# Function to check AWS credentials
function Test-AWSCredentials {
    Write-Host "🔐 Testing AWS credentials..." -ForegroundColor Yellow
    
    try {
        $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Host "✅ AWS credentials verified" -ForegroundColor Green
        Write-Host "   Account ID: $($identity.Account)" -ForegroundColor Gray
        Write-Host "   User/Role: $($identity.Arn)" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "❌ AWS credentials not configured or invalid" -ForegroundColor Red
        Write-Host "   Please run: scripts\setup-aws-credentials.bat" -ForegroundColor Yellow
        return $false
    }
}

# Function to check if user exists
function Test-AWSUser {
    Write-Host "👤 Checking if user '$UserName' exists..." -ForegroundColor Yellow
    
    try {
        $user = aws iam get-user --user-name $UserName --output json | ConvertFrom-Json
        Write-Host "✅ User '$UserName' found" -ForegroundColor Green
        Write-Host "   User ARN: $($user.User.Arn)" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "❌ User '$UserName' not found" -ForegroundColor Red
        Write-Host "   Please check the username or create the user first" -ForegroundColor Yellow
        return $false
    }
}

# Function to attach managed policies
function Add-ManagedPolicies {
    Write-Host "📋 Attaching AWS managed policies..." -ForegroundColor Yellow
    
    $policies = @(
        @{ Name = "AmazonBedrockFullAccess"; ARN = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess" },
        @{ Name = "AmazonS3FullAccess"; ARN = "arn:aws:iam::aws:policy/AmazonS3FullAccess" },
        @{ Name = "AmazonOpenSearchServerlessFullAccess"; ARN = "arn:aws:iam::aws:policy/AmazonOpenSearchServerlessFullAccess" },
        @{ Name = "AWSLambda_FullAccess"; ARN = "arn:aws:iam::aws:policy/AWSLambda_FullAccess" },
        @{ Name = "AmazonSNSFullAccess"; ARN = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" },
        @{ Name = "IAMFullAccess"; ARN = "arn:aws:iam::aws:policy/IAMFullAccess" }
    )
    
    foreach ($policy in $policies) {
        try {
            Write-Host "   Attaching $($policy.Name)..." -ForegroundColor Gray
            aws iam attach-user-policy --user-name $UserName --policy-arn $policy.ARN --output json | Out-Null
            Write-Host "   ✅ $($policy.Name) attached successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Failed to attach $($policy.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Function to create custom policy
function New-CustomPolicy {
    Write-Host "📝 Creating custom Bedrock DevSecOps policy..." -ForegroundColor Yellow
    
    $policyDocument = @"
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
                "s3:GetBucketLocation"
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
                "opensearchserverless:ListAccessPolicies"
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
                "lambda:InvokeFunction"
            ],
            "Resource": "arn:aws:lambda:$Region:*:function:devsecops-*"
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
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:$Region:*:devsecops-*"
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
                "arn:aws:iam::*:role/devsecops-*",
                "arn:aws:iam::*:policy/devsecops-*"
            ]
        }
    ]
}
"@

    try {
        # Save policy document to temporary file
        $tempFile = [System.IO.Path]::GetTempFileName()
        $policyDocument | Out-File -FilePath $tempFile -Encoding UTF8
        
        # Create the policy
        Write-Host "   Creating custom policy..." -ForegroundColor Gray
        $policyResult = aws iam create-policy --policy-name BedrockDevSecOpsPolicy --policy-document file://$tempFile --output json | ConvertFrom-Json
        
        Write-Host "   ✅ Custom policy created: $($policyResult.Policy.Arn)" -ForegroundColor Green
        
        # Attach policy to user
        Write-Host "   Attaching policy to user..." -ForegroundColor Gray
        aws iam attach-user-policy --user-name $UserName --policy-arn $policyResult.Policy.Arn --output json | Out-Null
        
        Write-Host "   ✅ Custom policy attached to user" -ForegroundColor Green
        
        # Clean up temporary file
        Remove-Item $tempFile -Force
        
        return $true
    }
    catch {
        Write-Host "   ❌ Failed to create custom policy: $($_.Exception.Message)" -ForegroundColor Red
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
        return $false
    }
}

# Function to verify permissions
function Test-BedrockPermissions {
    Write-Host "🧪 Testing Bedrock permissions..." -ForegroundColor Yellow
    
    try {
        # Test Bedrock model access
        Write-Host "   Testing Bedrock model access..." -ForegroundColor Gray
        $models = aws bedrock list-foundation-models --region $Region --output json | ConvertFrom-Json
        Write-Host "   ✅ Can list Bedrock models ($($models.modelSummaries.Count) models found)" -ForegroundColor Green
        
        # Test Knowledge Base access
        Write-Host "   Testing Knowledge Base access..." -ForegroundColor Gray
        $kbs = aws bedrockagent list-knowledge-bases --region $Region --output json | ConvertFrom-Json
        Write-Host "   ✅ Can access Knowledge Bases ($($kbs.knowledgeBaseSummaries.Count) KBs found)" -ForegroundColor Green
        
        # Test Agent access
        Write-Host "   Testing Agent access..." -ForegroundColor Gray
        $agents = aws bedrockagent list-agents --region $Region --output json | ConvertFrom-Json
        Write-Host "   ✅ Can access Agents ($($agents.agentSummaries.Count) agents found)" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "   ❌ Bedrock permissions test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to list attached policies
function Show-AttachedPolicies {
    Write-Host "📋 Current attached policies for user '$UserName':" -ForegroundColor Yellow
    
    try {
        $attachedPolicies = aws iam list-attached-user-policies --user-name $UserName --output json | ConvertFrom-Json
        
        if ($attachedPolicies.AttachedPolicies.Count -eq 0) {
            Write-Host "   No policies attached" -ForegroundColor Gray
        }
        else {
            foreach ($policy in $attachedPolicies.AttachedPolicies) {
                Write-Host "   ✅ $($policy.PolicyName)" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "   ❌ Failed to list attached policies: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
try {
    Write-Host "Starting Bedrock permissions setup..." -ForegroundColor Green
    Write-Host ""
    
    # Check prerequisites
    if (-not (Test-AWSCLI)) {
        throw "AWS CLI is not available"
    }
    
    if (-not (Test-AWSCredentials)) {
        throw "AWS credentials not configured"
    }
    
    if (-not (Test-AWSUser)) {
        throw "AWS user not found"
    }
    
    Write-Host ""
    
    # Show current policies
    Show-AttachedPolicies
    Write-Host ""
    
    # Add permissions
    if ($UseManagedPolicies) {
        Add-ManagedPolicies
        Write-Host ""
    }
    
    if ($CreateCustomPolicy) {
        New-CustomPolicy
        Write-Host ""
    }
    
    # Wait for policy propagation
    Write-Host "⏳ Waiting for policy propagation (30 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # Test permissions
    if (Test-BedrockPermissions) {
        Write-Host ""
        Write-Host "🎉 Bedrock permissions setup completed successfully!" -ForegroundColor Green
        Write-Host "=================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "✅ Your user '$UserName' now has Bedrock permissions" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Next steps:" -ForegroundColor Yellow
        Write-Host "1. Deploy Bedrock flow: cd bedrock && node scripts\create-bedrock-flow.js setup" -ForegroundColor White
        Write-Host "2. Test security analysis: node scripts\create-bedrock-flow.js test" -ForegroundColor White
        Write-Host "3. Deploy infrastructure: powershell -ExecutionPolicy Bypass -File scripts\setup-bedrock-environment.ps1" -ForegroundColor White
    }
    else {
        throw "Permission verification failed"
    }
    
}
catch {
    Write-Host ""
    Write-Host "❌ Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify AWS credentials are configured correctly" -ForegroundColor White
    Write-Host "2. Check if the username '$UserName' is correct" -ForegroundColor White
    Write-Host "3. Ensure you have IAM permissions to attach policies" -ForegroundColor White
    Write-Host "4. Contact your AWS administrator if needed" -ForegroundColor White
    exit 1
}
