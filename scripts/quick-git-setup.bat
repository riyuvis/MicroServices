@echo off
echo 🐙 Quick GitHub Repository Setup
echo ================================

echo.
echo 📋 This script will help you set up your GitHub repository for CI/CD
echo.

REM Check if we're in a git repository
if exist ".git" (
    echo ✅ Already in a git repository
    git remote get-url origin 2>nul
    if %errorlevel% equ 0 (
        echo ✅ Remote origin is configured
    ) else (
        echo ❌ No remote origin configured
        set /p repo_url="Enter your GitHub repository URL: "
        git remote add origin %repo_url%
        echo ✅ Remote origin added
    )
) else (
    echo ❌ Not in a git repository
    git init
    echo ✅ Git repository initialized
    
    set /p repo_url="Enter your GitHub repository URL: "
    git remote add origin %repo_url%
    echo ✅ Remote origin added
)

echo.
echo 📝 Committing CI/CD pipeline configuration...

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

echo.
echo 🚀 Pushing to GitHub...
git push origin main

echo.
echo ✅ Pipeline configuration pushed to GitHub!
echo.
echo 🔗 Next Steps:
echo 1. Go to your GitHub repository
echo 2. Go to Settings → Secrets and variables → Actions
echo 3. Add the required secrets (see manual-github-setup.md)
echo 4. Check the Actions tab to see your workflow
echo 5. Make a test commit to trigger the pipeline
echo.
echo 📚 For detailed setup instructions, see:
echo    scripts/manual-github-setup.md
echo.
pause
