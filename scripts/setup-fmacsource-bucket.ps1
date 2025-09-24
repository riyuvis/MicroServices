# Setup script for fmacsource bucket with Bedrock integration
# This script prepares your existing S3 bucket for Bedrock knowledge base

param(
    [string]$BucketName = "fmacsource",
    [string]$Region = "us-east-1",
    [switch]$Help
)

if ($Help) {
    Write-Host "Fmacsource Bucket Setup for Bedrock" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\setup-fmacsource-bucket.ps1 [-BucketName fmacsource] [-Region us-east-1]"
    Write-Host ""
    Write-Host "This script will:"
    Write-Host "1. Create security documentation folders in your S3 bucket"
    Write-Host "2. Upload sample security documents"
    Write-Host "3. Configure bucket for Bedrock knowledge base"
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "🪣 Setting up fmacsource bucket for Bedrock Knowledge Base" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bucket: $BucketName" -ForegroundColor Yellow
Write-Host "Region: $Region" -ForegroundColor Yellow
Write-Host ""

# Function to check AWS credentials
function Test-AWSCredentials {
    try {
        $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Host "✅ AWS credentials verified" -ForegroundColor Green
        Write-Host "   Account: $($identity.Account)" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "❌ AWS credentials not configured" -ForegroundColor Red
        return $false
    }
}

# Function to check if bucket exists and is accessible
function Test-S3Bucket {
    Write-Host "🔍 Checking S3 bucket access..." -ForegroundColor Yellow
    
    try {
        $bucketInfo = aws s3api head-bucket --bucket $BucketName --region $Region 2>$null
        Write-Host "✅ Bucket '$BucketName' is accessible" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Cannot access bucket '$BucketName'" -ForegroundColor Red
        Write-Host "   Please check bucket name and permissions" -ForegroundColor Yellow
        return $false
    }
}

# Function to create folder structure
function New-SecurityFolders {
    Write-Host "📁 Creating security documentation folder structure..." -ForegroundColor Yellow
    
    $folders = @(
        "security-docs/",
        "security-docs/owasp/",
        "security-docs/compliance/",
        "security-docs/remediation/",
        "security-docs/vulnerabilities/"
    )
    
    foreach ($folder in $folders) {
        try {
            # Create a placeholder file to create the folder structure
            $placeholder = "placeholder.txt"
            echo "This folder contains security documentation for Bedrock knowledge base" | Out-File -FilePath $placeholder -Encoding UTF8
            
            # Upload to S3
            aws s3 cp $placeholder "s3://$BucketName/$folder" --region $Region >$null 2>&1
            Remove-Item $placeholder -Force
            
            Write-Host "   ✅ Created folder: $folder" -ForegroundColor Green
        }
        catch {
            Write-Host "   ❌ Failed to create folder: $folder" -ForegroundColor Red
        }
    }
}

# Function to upload sample security documents
function Upload-SampleDocuments {
    Write-Host "📄 Uploading sample security documents..." -ForegroundColor Yellow
    
    # Create OWASP Top 10 document
    $owaspContent = @"
# OWASP Top 10 Security Vulnerabilities

## A01:2021 – Broken Access Control
Access control enforces policy such that users cannot act outside of their intended permissions.

### Common Vulnerabilities:
- Bypassing access control checks by modifying the URL
- Privilege escalation by acting as a user without being logged in
- Metadata manipulation, such as replaying or tampering with a JWT access control token

### Prevention:
- Implement proper access controls
- Use principle of least privilege
- Deny access by default

## A02:2021 – Cryptographic Failures
Cryptographic failures lead to sensitive data exposure or system compromise.

### Common Vulnerabilities:
- Weak encryption algorithms
- Hardcoded encryption keys
- Insufficient entropy in random number generation

### Prevention:
- Use strong encryption algorithms (AES-256, RSA-2048)
- Store encryption keys securely
- Use cryptographically secure random number generators
"@

    try {
        $owaspContent | Out-File -FilePath "owasp-top10.md" -Encoding UTF8
        aws s3 cp "owasp-top10.md" "s3://$BucketName/security-docs/owasp/owasp-top10.md" --region $Region
        Remove-Item "owasp-top10.md" -Force
        Write-Host "   ✅ Uploaded OWASP Top 10 document" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Failed to upload OWASP document" -ForegroundColor Red
    }
    
    # Create compliance document
    $complianceContent = @"
# Security Compliance Frameworks

## SOC 2 Type II
System and Organization Controls for security, availability, and processing integrity.

### Key Requirements:
- Access controls and user management
- System monitoring and logging
- Data encryption and backup procedures
- Incident response procedures

## PCI DSS
Payment Card Industry Data Security Standard for handling credit card data.

### Key Requirements:
- Secure network and systems
- Protect cardholder data
- Vulnerability management program
- Strong access control measures

## HIPAA
Health Insurance Portability and Accountability Act for healthcare data.

### Key Requirements:
- Administrative safeguards
- Physical safeguards
- Technical safeguards
- Breach notification procedures
"@

    try {
        $complianceContent | Out-File -FilePath "compliance-frameworks.md" -Encoding UTF8
        aws s3 cp "compliance-frameworks.md" "s3://$BucketName/security-docs/compliance/frameworks.md" --region $Region
        Remove-Item "compliance-frameworks.md" -Force
        Write-Host "   ✅ Uploaded compliance frameworks document" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Failed to upload compliance document" -ForegroundColor Red
    }
}

# Function to create bucket policy for Bedrock access
function Set-BucketPolicy {
    Write-Host "🔐 Setting up bucket policy for Bedrock access..." -ForegroundColor Yellow
    
    $bucketPolicy = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BedrockKnowledgeBaseAccess",
            "Effect": "Allow",
            "Principal": {
                "Service": "bedrock.amazonaws.com"
            },
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$BucketName",
                "arn:aws:s3:::$BucketName/*"
            ]
        }
    ]
}
"@

    try {
        $bucketPolicy | Out-File -FilePath "bucket-policy.json" -Encoding UTF8
        aws s3api put-bucket-policy --bucket $BucketName --policy file://bucket-policy.json --region $Region
        Remove-Item "bucket-policy.json" -Force
        Write-Host "   ✅ Bucket policy updated for Bedrock access" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Failed to update bucket policy" -ForegroundColor Red
        if (Test-Path "bucket-policy.json") {
            Remove-Item "bucket-policy.json" -Force
        }
    }
}

# Main execution
try {
    Write-Host "Starting fmacsource bucket setup for Bedrock..." -ForegroundColor Green
    Write-Host ""
    
    # Check prerequisites
    if (-not (Test-AWSCredentials)) {
        throw "AWS credentials not configured"
    }
    
    if (-not (Test-S3Bucket)) {
        throw "S3 bucket not accessible"
    }
    
    Write-Host ""
    
    # Setup bucket for Bedrock
    New-SecurityFolders
    Write-Host ""
    
    Upload-SampleDocuments
    Write-Host ""
    
    Set-BucketPolicy
    Write-Host ""
    
    Write-Host "🎉 Fmacsource bucket setup completed successfully!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Bucket '$BucketName' is ready for Bedrock knowledge base" -ForegroundColor White
    Write-Host ""
    Write-Host "📁 Created folder structure:" -ForegroundColor Yellow
    Write-Host "   - security-docs/owasp/" -ForegroundColor White
    Write-Host "   - security-docs/compliance/" -ForegroundColor White
    Write-Host "   - security-docs/remediation/" -ForegroundColor White
    Write-Host "   - security-docs/vulnerabilities/" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: node scripts/create-bedrock-flow.js setup" -ForegroundColor White
    Write-Host "2. Test: node scripts/create-bedrock-flow.js test" -ForegroundColor White
    
}
catch {
    Write-Host ""
    Write-Host "❌ Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify bucket '$BucketName' exists and is accessible" -ForegroundColor White
    Write-Host "2. Check AWS credentials have S3 permissions" -ForegroundColor White
    Write-Host "3. Ensure bucket is in the correct region ($Region)" -ForegroundColor White
    exit 1
}
