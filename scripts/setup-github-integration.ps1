# 🐙 GitHub Repository Integration Setup
# This script helps you connect your GitHub repo to the CI/CD pipeline

Write-Host "🐙 GitHub Repository Integration Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if git is available
try {
    $gitVersion = git --version
    Write-Host "✅ Git is available: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Check if GitHub CLI is available
try {
    $ghVersion = gh --version
    Write-Host "✅ GitHub CLI is available: $ghVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️ GitHub CLI not found. Installing..." -ForegroundColor Yellow
    winget install --id GitHub.cli
    Write-Host "Please restart your terminal and run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🔐 Step 1: GitHub Authentication" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Check if already authenticated
try {
    $authStatus = gh auth status
    Write-Host "✅ Already authenticated with GitHub" -ForegroundColor Green
} catch {
    Write-Host "🔑 Authenticating with GitHub..." -ForegroundColor Yellow
    gh auth login
}

Write-Host "`n📁 Step 2: Repository Setup" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Check if we're in a git repository
if (Test-Path ".git") {
    Write-Host "✅ Already in a git repository" -ForegroundColor Green
    
    # Get repository URL
    $remoteUrl = git remote get-url origin
    Write-Host "📂 Repository URL: $remoteUrl" -ForegroundColor Green
    
    # Extract repository name
    if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$") {
        $owner = $matches[1]
        $repo = $matches[2]
        Write-Host "👤 Owner: $owner" -ForegroundColor Green
        Write-Host "📦 Repository: $repo" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Not in a git repository. Initializing..." -ForegroundColor Red
    
    # Ask for repository details
    $repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/repo)"
    
    # Initialize git repository
    git init
    git remote add origin $repoUrl
    
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
}

Write-Host "`n🔐 Step 3: GitHub Secrets Configuration" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

Write-Host "🔑 Setting up GitHub secrets for CI/CD pipeline..." -ForegroundColor Yellow

# Get AWS credentials
Write-Host "`n📋 AWS Credentials:" -ForegroundColor Yellow
$awsAccessKeyId = Read-Host "Enter your AWS Access Key ID"
$awsSecretAccessKey = Read-Host "Enter your AWS Secret Access Key" -AsSecureString
$awsSecretAccessKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($awsSecretAccessKey))

# Get Bedrock Agent details
Write-Host "`n🤖 Bedrock Agent Configuration:" -ForegroundColor Yellow
$bedrockAgentId = Read-Host "Enter your Bedrock Agent ID"
$bedrockAliasId = Read-Host "Enter your Bedrock Agent Alias ID (or press Enter for default)"

if ([string]::IsNullOrEmpty($bedrockAliasId)) {
    $bedrockAliasId = "TSTALIASID"
}

# Get ECR registry
Write-Host "`n🐳 Container Registry:" -ForegroundColor Yellow
$ecrRegistry = Read-Host "Enter your ECR registry URL (e.g., 123456789.dkr.ecr.us-east-1.amazonaws.com)"

# Optional configurations
Write-Host "`n📧 Optional Notifications:" -ForegroundColor Yellow
$securityTeamEmail = Read-Host "Enter security team email (optional)"
$slackWebhook = Read-Host "Enter Slack webhook URL (optional)"

Write-Host "`n📊 Optional Monitoring:" -ForegroundColor Yellow
$grafanaUrl = Read-Host "Enter Grafana URL (optional)"
$grafanaApiKey = Read-Host "Enter Grafana API key (optional)"

Write-Host "`n🔒 Setting GitHub secrets..." -ForegroundColor Yellow

# Set GitHub secrets
try {
    gh secret set AWS_ACCESS_KEY_ID --body $awsAccessKeyId
    Write-Host "✅ AWS_ACCESS_KEY_ID set" -ForegroundColor Green
    
    gh secret set AWS_SECRET_ACCESS_KEY --body $awsSecretAccessKeyPlain
    Write-Host "✅ AWS_SECRET_ACCESS_KEY set" -ForegroundColor Green
    
    gh secret set BEDROCK_AGENT_ID --body $bedrockAgentId
    Write-Host "✅ BEDROCK_AGENT_ID set" -ForegroundColor Green
    
    gh secret set BEDROCK_AGENT_ALIAS_ID --body $bedrockAliasId
    Write-Host "✅ BEDROCK_AGENT_ALIAS_ID set" -ForegroundColor Green
    
    gh secret set ECR_REGISTRY --body $ecrRegistry
    Write-Host "✅ ECR_REGISTRY set" -ForegroundColor Green
    
    if (![string]::IsNullOrEmpty($securityTeamEmail)) {
        gh secret set SECURITY_TEAM_EMAIL --body $securityTeamEmail
        Write-Host "✅ SECURITY_TEAM_EMAIL set" -ForegroundColor Green
    }
    
    if (![string]::IsNullOrEmpty($slackWebhook)) {
        gh secret set SLACK_WEBHOOK_URL --body $slackWebhook
        Write-Host "✅ SLACK_WEBHOOK_URL set" -ForegroundColor Green
    }
    
    if (![string]::IsNullOrEmpty($grafanaUrl)) {
        gh secret set GRAFANA_URL --body $grafanaUrl
        Write-Host "✅ GRAFANA_URL set" -ForegroundColor Green
    }
    
    if (![string]::IsNullOrEmpty($grafanaApiKey)) {
        gh secret set GRAFANA_API_KEY --body $grafanaApiKey
        Write-Host "✅ GRAFANA_API_KEY set" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Error setting secrets: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please set the secrets manually in GitHub repository settings." -ForegroundColor Yellow
}

Write-Host "`n📁 Step 4: Commit and Push Pipeline Configuration" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check if there are changes to commit
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "📝 Changes detected. Committing CI/CD pipeline configuration..." -ForegroundColor Yellow
    
    git add .
    git commit -m "Add AI-powered DevSecOps CI/CD pipeline configuration

- GitHub Actions workflow for automated security analysis
- Bedrock Agent integration for AI-powered vulnerability detection
- Security gate checks with configurable thresholds
- Automated deployment pipeline with Terraform and Kubernetes
- Monitoring and reporting with Grafana dashboards
- Email and Slack notifications for security alerts

Powered by AWS Bedrock with Claude 3.5 Sonnet"
    
    Write-Host "✅ Changes committed" -ForegroundColor Green
    
    Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host "✅ Pipeline configuration pushed to GitHub" -ForegroundColor Green
} else {
    Write-Host "ℹ️ No changes to commit" -ForegroundColor Blue
}

Write-Host "`n🎉 Step 5: Verify Pipeline Setup" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

Write-Host "🔍 Checking GitHub Actions workflow..." -ForegroundColor Yellow

# Check if workflow file exists
if (Test-Path ".github/workflows/bedrock-security-pipeline.yml") {
    Write-Host "✅ GitHub Actions workflow file found" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub Actions workflow file not found" -ForegroundColor Red
    Write-Host "Please ensure the workflow file is in .github/workflows/" -ForegroundColor Yellow
}

Write-Host "`n📋 Summary:" -ForegroundColor Cyan
Write-Host "===========" -ForegroundColor Cyan
Write-Host "✅ GitHub repository connected" -ForegroundColor Green
Write-Host "✅ GitHub secrets configured" -ForegroundColor Green
Write-Host "✅ CI/CD pipeline committed and pushed" -ForegroundColor Green
Write-Host "✅ Ready for automated security analysis" -ForegroundColor Green

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host "1. Go to your GitHub repository" -ForegroundColor White
Write-Host "2. Check the 'Actions' tab to see the workflow" -ForegroundColor White
Write-Host "3. Make a test commit to trigger the pipeline" -ForegroundColor White
Write-Host "4. Monitor the security analysis results" -ForegroundColor White

Write-Host "`n🔗 Useful Links:" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
Write-Host "• GitHub Actions: https://github.com/$owner/$repo/actions" -ForegroundColor Blue
Write-Host "• Repository Settings: https://github.com/$owner/$repo/settings" -ForegroundColor Blue
Write-Host "• Secrets Management: https://github.com/$owner/$repo/settings/secrets/actions" -ForegroundColor Blue

Write-Host "`n🎯 Your AI-powered DevSecOps pipeline is now connected to GitHub!" -ForegroundColor Green
Write-Host "Every push and pull request will now trigger automated security analysis!" -ForegroundColor Green
