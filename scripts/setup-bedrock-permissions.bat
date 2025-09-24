@echo off
echo 🔐 AWS Bedrock Permissions Setup
echo ================================
echo.

echo This script will add the required Bedrock permissions to your AWS user.
echo.

echo Checking prerequisites...

where aws >nul 2>nul
if %errorlevel%==0 (
    echo ✓ AWS CLI is available
) else (
    echo ✗ AWS CLI is not available
    echo Please install AWS CLI first
    pause
    exit /b 1
)

echo.
echo Testing AWS credentials...
aws sts get-caller-identity >nul 2>nul
if %errorlevel%==0 (
    echo ✓ AWS credentials verified
) else (
    echo ✗ AWS credentials not configured
    echo Please run: scripts\setup-aws-credentials.bat
    pause
    exit /b 1
)

echo.
echo 🔧 Adding Bedrock permissions to user: a-sanjeevc
echo.

echo Attaching AWS managed policies...
echo.

echo 1. Attaching AmazonBedrockFullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
if %errorlevel%==0 (
    echo ✓ AmazonBedrockFullAccess attached
) else (
    echo ✗ Failed to attach AmazonBedrockFullAccess
)

echo.
echo 2. Attaching AmazonS3FullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
if %errorlevel%==0 (
    echo ✓ AmazonS3FullAccess attached
) else (
    echo ✗ Failed to attach AmazonS3FullAccess
)

echo.
echo 3. Attaching AmazonOpenSearchServerlessFullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonOpenSearchServerlessFullAccess
if %errorlevel%==0 (
    echo ✓ AmazonOpenSearchServerlessFullAccess attached
) else (
    echo ✗ Failed to attach AmazonOpenSearchServerlessFullAccess
)

echo.
echo 4. Attaching AWSLambda_FullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess
if %errorlevel%==0 (
    echo ✓ AWSLambda_FullAccess attached
) else (
    echo ✗ Failed to attach AWSLambda_FullAccess
)

echo.
echo 5. Attaching AmazonSNSFullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
if %errorlevel%==0 (
    echo ✓ AmazonSNSFullAccess attached
) else (
    echo ✗ Failed to attach AmazonSNSFullAccess
)

echo.
echo 6. Attaching IAMFullAccess...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
if %errorlevel%==0 (
    echo ✓ IAMFullAccess attached
) else (
    echo ✗ Failed to attach IAMFullAccess
)

echo.
echo ⏳ Waiting for policy propagation (30 seconds)...
timeout /t 30 /nobreak >nul

echo.
echo 🧪 Testing Bedrock permissions...
echo.

echo Testing Bedrock model access...
aws bedrock list-foundation-models --region us-east-1 >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Can access Bedrock models
) else (
    echo ✗ Cannot access Bedrock models
)

echo.
echo Testing Knowledge Base access...
aws bedrockagent list-knowledge-bases --region us-east-1 >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Can access Knowledge Bases
) else (
    echo ✗ Cannot access Knowledge Bases
)

echo.
echo Testing Agent access...
aws bedrockagent list-agents --region us-east-1 >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Can access Agents
) else (
    echo ✗ Cannot access Agents
)

echo.
echo 📋 Current attached policies:
aws iam list-attached-user-policies --user-name a-sanjeevc --output table

echo.
echo 🎉 Bedrock permissions setup completed!
echo =====================================
echo.
echo ✅ Your user 'a-sanjeevc' now has Bedrock permissions
echo.
echo 🚀 Next steps:
echo 1. Deploy Bedrock flow: cd bedrock ^&^& node scripts\create-bedrock-flow.js setup
echo 2. Test security analysis: node scripts\create-bedrock-flow.js test
echo 3. Deploy infrastructure: powershell -ExecutionPolicy Bypass -File scripts\setup-bedrock-environment.ps1
echo.
echo 📖 For detailed instructions, see: docs\AWS-BEDROCK-PERMISSIONS-GUIDE.md
echo.
pause
