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
echo    2. aws configure set aws_access_key_id AKIA2UZBV7QXNP2PQ2ZI
echo    3. aws configure set aws_secret_access_key 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
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
