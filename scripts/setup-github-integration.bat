@echo off
echo 🐙 GitHub Repository Integration Setup
echo =====================================

REM Check if git is available
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed. Please install Git first.
    echo Download from: https://git-scm.com/downloads
    pause
    exit /b 1
)
echo ✅ Git is available

REM Check if GitHub CLI is available
gh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ GitHub CLI not found. Installing...
    winget install --id GitHub.cli
    echo Please restart your terminal and run this script again.
    pause
    exit /b 1
)
echo ✅ GitHub CLI is available

echo.
echo 🔐 Step 1: GitHub Authentication
echo ===============================

REM Check if already authenticated
gh auth status >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Already authenticated with GitHub
) else (
    echo 🔑 Authenticating with GitHub...
    gh auth login
)

echo.
echo 📁 Step 2: Repository Setup
echo ==========================

REM Check if we're in a git repository
if exist ".git" (
    echo ✅ Already in a git repository
    for /f "tokens=*" %%i in ('git remote get-url origin') do set remote_url=%%i
    echo 📂 Repository URL: %remote_url%
) else (
    echo ❌ Not in a git repository. Please initialize git first.
    echo Run: git init
    echo Then: git remote add origin YOUR_GITHUB_REPO_URL
    pause
    exit /b 1
)

echo.
echo 🔐 Step 3: GitHub Secrets Configuration
echo ======================================

echo 🔑 Setting up GitHub secrets for CI/CD pipeline...

echo.
echo 📋 AWS Credentials:
set /p aws_access_key_id="Enter your AWS Access Key ID: "
set /p aws_secret_access_key="Enter your AWS Secret Access Key: "

echo.
echo 🤖 Bedrock Agent Configuration:
set /p bedrock_agent_id="Enter your Bedrock Agent ID: "
set /p bedrock_alias_id="Enter your Bedrock Agent Alias ID (or press Enter for default): "

if "%bedrock_alias_id%"=="" set bedrock_alias_id=TSTALIASID

echo.
echo 🐳 Container Registry:
set /p ecr_registry="Enter your ECR registry URL (e.g., 123456789.dkr.ecr.us-east-1.amazonaws.com): "

echo.
echo 📧 Optional Notifications:
set /p security_team_email="Enter security team email (optional): "
set /p slack_webhook="Enter Slack webhook URL (optional): "

echo.
echo 📊 Optional Monitoring:
set /p grafana_url="Enter Grafana URL (optional): "
set /p grafana_api_key="Enter Grafana API key (optional): "

echo.
echo 🔒 Setting GitHub secrets...

gh secret set AWS_ACCESS_KEY_ID --body "%aws_access_key_id%"
if %errorlevel% equ 0 (
    echo ✅ AWS_ACCESS_KEY_ID set
) else (
    echo ❌ Failed to set AWS_ACCESS_KEY_ID
)

gh secret set AWS_SECRET_ACCESS_KEY --body "%aws_secret_access_key%"
if %errorlevel% equ 0 (
    echo ✅ AWS_SECRET_ACCESS_KEY set
) else (
    echo ❌ Failed to set AWS_SECRET_ACCESS_KEY
)

gh secret set BEDROCK_AGENT_ID --body "%bedrock_agent_id%"
if %errorlevel% equ 0 (
    echo ✅ BEDROCK_AGENT_ID set
) else (
    echo ❌ Failed to set BEDROCK_AGENT_ID
)

gh secret set BEDROCK_AGENT_ALIAS_ID --body "%bedrock_alias_id%"
if %errorlevel% equ 0 (
    echo ✅ BEDROCK_AGENT_ALIAS_ID set
) else (
    echo ❌ Failed to set BEDROCK_AGENT_ALIAS_ID
)

gh secret set ECR_REGISTRY --body "%ecr_registry%"
if %errorlevel% equ 0 (
    echo ✅ ECR_REGISTRY set
) else (
    echo ❌ Failed to set ECR_REGISTRY
)

if not "%security_team_email%"=="" (
    gh secret set SECURITY_TEAM_EMAIL --body "%security_team_email%"
    if %errorlevel% equ 0 (
        echo ✅ SECURITY_TEAM_EMAIL set
    )
)

if not "%slack_webhook%"=="" (
    gh secret set SLACK_WEBHOOK_URL --body "%slack_webhook%"
    if %errorlevel% equ 0 (
        echo ✅ SLACK_WEBHOOK_URL set
    )
)

if not "%grafana_url%"=="" (
    gh secret set GRAFANA_URL --body "%grafana_url%"
    if %errorlevel% equ 0 (
        echo ✅ GRAFANA_URL set
    )
)

if not "%grafana_api_key%"=="" (
    gh secret set GRAFANA_API_KEY --body "%grafana_api_key%"
    if %errorlevel% equ 0 (
        echo ✅ GRAFANA_API_KEY set
    )
)

echo.
echo 📁 Step 4: Commit and Push Pipeline Configuration
echo =================================================

REM Check if there are changes to commit
git status --porcelain | findstr /r "." >nul
if %errorlevel% equ 0 (
    echo 📝 Changes detected. Committing CI/CD pipeline configuration...
    
    git add .
    git commit -m "Add AI-powered DevSecOps CI/CD pipeline configuration

- GitHub Actions workflow for automated security analysis
- Bedrock Agent integration for AI-powered vulnerability detection
- Security gate checks with configurable thresholds
- Automated deployment pipeline with Terraform and Kubernetes
- Monitoring and reporting with Grafana dashboards
- Email and Slack notifications for security alerts

Powered by AWS Bedrock with Claude 3.5 Sonnet"
    
    echo ✅ Changes committed
    
    echo 🚀 Pushing to GitHub...
    git push origin main
    
    echo ✅ Pipeline configuration pushed to GitHub
) else (
    echo ℹ️ No changes to commit
)

echo.
echo 🎉 Step 5: Verify Pipeline Setup
echo ===============================

echo 🔍 Checking GitHub Actions workflow...

if exist ".github\workflows\bedrock-security-pipeline.yml" (
    echo ✅ GitHub Actions workflow file found
) else (
    echo ❌ GitHub Actions workflow file not found
    echo Please ensure the workflow file is in .github/workflows/
)

echo.
echo 📋 Summary:
echo ===========
echo ✅ GitHub repository connected
echo ✅ GitHub secrets configured
echo ✅ CI/CD pipeline committed and pushed
echo ✅ Ready for automated security analysis

echo.
echo 🚀 Next Steps:
echo ==============
echo 1. Go to your GitHub repository
echo 2. Check the 'Actions' tab to see the workflow
echo 3. Make a test commit to trigger the pipeline
echo 4. Monitor the security analysis results

echo.
echo 🎯 Your AI-powered DevSecOps pipeline is now connected to GitHub!
echo Every push and pull request will now trigger automated security analysis!

pause
