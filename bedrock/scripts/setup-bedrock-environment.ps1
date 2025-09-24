# AWS Bedrock DevSecOps Environment Setup Script
# Creates and configures Bedrock flows, agents, and knowledge bases

param(
    [string]$Environment = "dev",
    [string]$ProjectName = "devsecops",
    [string]$AlertEmail = "",
    [switch]$SkipTerraform = $false,
    [switch]$SkipKnowledgeBase = $false,
    [switch]$Help
)

if ($Help) {
    Write-Host "AWS Bedrock DevSecOps Environment Setup" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\setup-bedrock-environment.ps1 [-Environment dev] [-ProjectName devsecops] [-AlertEmail email@domain.com]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Environment    Environment name (dev, staging, prod) - Default: dev"
    Write-Host "  -ProjectName    Project name - Default: devsecops"
    Write-Host "  -AlertEmail     Email for security alerts - Optional"
    Write-Host "  -SkipTerraform  Skip Terraform infrastructure deployment"
    Write-Host "  -SkipKnowledgeBase  Skip knowledge base setup"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup-bedrock-environment.ps1"
    Write-Host "  .\setup-bedrock-environment.ps1 -Environment prod -AlertEmail security@company.com"
    Write-Host "  .\setup-bedrock-environment.ps1 -SkipTerraform -SkipKnowledgeBase"
    exit 0
}

# Configuration
$ErrorActionPreference = "Stop"
$StartTime = Get-Date

Write-Host "🚀 AWS Bedrock DevSecOps Environment Setup" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Environment: $Environment" -ForegroundColor White
Write-Host "  Project Name: $ProjectName" -ForegroundColor White
Write-Host "  Alert Email: $AlertEmail" -ForegroundColor White
Write-Host "  Skip Terraform: $SkipTerraform" -ForegroundColor White
Write-Host "  Skip Knowledge Base: $SkipKnowledgeBase" -ForegroundColor White
Write-Host ""

# Function to check AWS credentials
function Test-AWSCredentials {
    Write-Host "🔐 Checking AWS credentials..." -ForegroundColor Yellow
    
    try {
        $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Host "✅ AWS credentials verified" -ForegroundColor Green
        Write-Host "   Account ID: $($identity.Account)" -ForegroundColor Gray
        Write-Host "   User/Role: $($identity.Arn)" -ForegroundColor Gray
        Write-Host "   Region: $($env:AWS_DEFAULT_REGION)" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "❌ AWS credentials not configured or invalid" -ForegroundColor Red
        Write-Host "   Please run: scripts\setup-aws-credentials.bat" -ForegroundColor Yellow
        return $false
    }
}

# Function to check required tools
function Test-RequiredTools {
    Write-Host "🔧 Checking required tools..." -ForegroundColor Yellow
    
    $tools = @(
        @{ Name = "aws"; Command = "aws --version" },
        @{ Name = "node"; Command = "node --version" },
        @{ Name = "npm"; Command = "npm --version" }
    )
    
    $allToolsAvailable = $true
    
    foreach ($tool in $tools) {
        try {
            $null = Invoke-Expression $tool.Command 2>$null
            Write-Host "✅ $($tool.Name) is installed" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $($tool.Name) is not installed" -ForegroundColor Red
            $allToolsAvailable = $false
        }
    }
    
    if (-not $SkipTerraform) {
        try {
            $null = terraform --version 2>$null
            Write-Host "✅ Terraform is installed" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Terraform is not installed" -ForegroundColor Red
            Write-Host "   Install with: winget install HashiCorp.Terraform" -ForegroundColor Yellow
            $allToolsAvailable = $false
        }
    }
    
    return $allToolsAvailable
}

# Function to install Bedrock dependencies
function Install-BedrockDependencies {
    Write-Host "📦 Installing Bedrock dependencies..." -ForegroundColor Yellow
    
    try {
        Push-Location "bedrock"
        npm install
        Pop-Location
        Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

# Function to deploy Terraform infrastructure
function Deploy-TerraformInfrastructure {
    if ($SkipTerraform) {
        Write-Host "⏭️ Skipping Terraform deployment" -ForegroundColor Yellow
        return $true
    }
    
    Write-Host "🏗️ Deploying Bedrock infrastructure with Terraform..." -ForegroundColor Yellow
    
    try {
        Push-Location "bedrock\terraform"
        
        # Initialize Terraform
        Write-Host "   Initializing Terraform..." -ForegroundColor Gray
        terraform init
        
        # Create terraform.tfvars
        $tfvarsContent = @"
project_name = "$ProjectName"
environment = "$Environment"
alert_email = "$AlertEmail"
region = "$env:AWS_DEFAULT_REGION"
"@
        $tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
        
        # Plan deployment
        Write-Host "   Planning deployment..." -ForegroundColor Gray
        terraform plan -out=tfplan
        
        # Apply deployment
        Write-Host "   Applying deployment..." -ForegroundColor Gray
        terraform apply tfplan
        
        Pop-Location
        Write-Host "✅ Terraform infrastructure deployed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Terraform deployment failed" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

# Function to setup knowledge base
function Setup-KnowledgeBase {
    if ($SkipKnowledgeBase) {
        Write-Host "⏭️ Skipping knowledge base setup" -ForegroundColor Yellow
        return $true
    }
    
    Write-Host "📚 Setting up knowledge base..." -ForegroundColor Yellow
    
    try {
        # Create sample security documents
        $securityDocsPath = "bedrock\documents\security-docs"
        if (-not (Test-Path $securityDocsPath)) {
            New-Item -ItemType Directory -Path $securityDocsPath -Force | Out-Null
        }
        
        # Create OWASP Top 10 document
        $owaspContent = @"
# OWASP Top 10 Security Vulnerabilities

## A01:2021 – Broken Access Control
Access control enforces policy such that users cannot act outside of their intended permissions.

### Common Vulnerabilities:
- Bypassing access control checks by modifying the URL, internal application state, or the HTML page
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
        $owaspContent | Out-File -FilePath "$securityDocsPath\owasp-top10.md" -Encoding UTF8
        
        Write-Host "✅ Knowledge base documents created" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Knowledge base setup failed" -ForegroundColor Red
        return $false
    }
}

# Function to create Bedrock flow
function Create-BedrockFlow {
    Write-Host "🔄 Creating Bedrock flow..." -ForegroundColor Yellow
    
    try {
        Push-Location "bedrock"
        node scripts/create-bedrock-flow.js setup
        Pop-Location
        Write-Host "✅ Bedrock flow created successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Bedrock flow creation failed" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

# Function to test Bedrock flow
function Test-BedrockFlow {
    Write-Host "🧪 Testing Bedrock flow..." -ForegroundColor Yellow
    
    try {
        Push-Location "bedrock"
        node scripts/create-bedrock-flow.js test "https://github.com/example/test-repo"
        Pop-Location
        Write-Host "✅ Bedrock flow test completed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Bedrock flow test failed" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

# Main execution
try {
    Write-Host "Starting Bedrock environment setup..." -ForegroundColor Green
    Write-Host ""
    
    # Check prerequisites
    if (-not (Test-AWSCredentials)) {
        throw "AWS credentials not configured"
    }
    
    if (-not (Test-RequiredTools)) {
        throw "Required tools not available"
    }
    
    # Install dependencies
    if (-not (Install-BedrockDependencies)) {
        throw "Failed to install dependencies"
    }
    
    # Deploy infrastructure
    if (-not (Deploy-TerraformInfrastructure)) {
        throw "Failed to deploy infrastructure"
    }
    
    # Setup knowledge base
    if (-not (Setup-KnowledgeBase)) {
        throw "Failed to setup knowledge base"
    }
    
    # Create Bedrock flow
    if (-not (Create-BedrockFlow)) {
        throw "Failed to create Bedrock flow"
    }
    
    # Test flow
    if (-not (Test-BedrockFlow)) {
        throw "Failed to test Bedrock flow"
    }
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host ""
    Write-Host "🎉 Bedrock DevSecOps Environment Setup Complete!" -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Setup completed in $($Duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Upload security documentation to S3 bucket" -ForegroundColor White
    Write-Host "2. Sync knowledge base with data sources" -ForegroundColor White
    Write-Host "3. Test the security flow with sample code" -ForegroundColor White
    Write-Host "4. Integrate with CI/CD pipeline" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Resources Created:" -ForegroundColor Yellow
    Write-Host "✅ Bedrock Knowledge Base" -ForegroundColor Green
    Write-Host "✅ Security Analysis Agent" -ForegroundColor Green
    Write-Host "✅ DevSecOps Security Flow" -ForegroundColor Green
    Write-Host "✅ OpenSearch Serverless Collection" -ForegroundColor Green
    Write-Host "✅ S3 Bucket for Documents" -ForegroundColor Green
    Write-Host "✅ Security Alerts SNS Topic" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Management Commands:" -ForegroundColor Yellow
    Write-Host "  Test Flow: node bedrock\scripts\create-bedrock-flow.js test" -ForegroundColor Gray
    Write-Host "  View Logs: aws logs tail /aws/bedrock --follow" -ForegroundColor Gray
    Write-Host "  Monitor Alerts: Check SNS topic for security notifications" -ForegroundColor Gray
    
}
catch {
    Write-Host ""
    Write-Host "❌ Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify AWS credentials are configured" -ForegroundColor White
    Write-Host "2. Check AWS service limits and permissions" -ForegroundColor White
    Write-Host "3. Ensure required tools are installed" -ForegroundColor White
    Write-Host "4. Review Terraform state for any partial deployments" -ForegroundColor White
    exit 1
}
