@echo off
echo 🔧 AWS CLI Quick Setup
echo ======================
echo.

echo ✅ AWS CLI has been installed successfully!
echo.
echo ⚠️  IMPORTANT: The PATH environment variable needs to be refreshed
echo.
echo 🔄 SOLUTION: Restart your terminal/command prompt
echo.
echo 📋 After restarting, run these commands to verify:
echo.
echo    1. aws --version
echo    2. aws configure set aws_access_key_id YOUR_AWS_ACCESS_KEY_ID
echo    3. aws configure set aws_secret_access_key YOUR_AWS_SECRET_ACCESS_KEY
echo    4. aws configure set default.region us-east-1
echo    5. aws sts get-caller-identity
echo.
echo 🚀 Then you can run:
echo    cd bedrock
echo    node scripts\create-bedrock-flow.js setup
echo.
echo 📖 For detailed instructions, see: docs\AWS-CLI-SETUP-GUIDE.md
echo.
echo 🔄 Please close this terminal and open a new one to continue.
echo.
pause

