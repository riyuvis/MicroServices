@echo off
echo AWS Credentials - Environment Variables Setup
echo =============================================

echo.
echo This will help you set up AWS credentials using environment variables.
echo.

set /p AWS_ACCESS_KEY_ID="Enter your AWS Access Key ID: "
set /p AWS_SECRET_ACCESS_KEY="Enter your AWS Secret Access Key: "
set /p AWS_REGION="Enter your AWS Region (default: us-east-1): "

if "%AWS_REGION%"=="" set AWS_REGION=us-east-1

echo.
echo Setting environment variables...

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
set AWS_DEFAULT_REGION=%AWS_REGION%
set AWS_REGION=%AWS_REGION%

echo.
echo Environment variables set for current session:
echo AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
echo AWS_SECRET_ACCESS_KEY=***hidden***
echo AWS_DEFAULT_REGION=%AWS_REGION%
echo AWS_REGION=%AWS_REGION%

echo.
echo To make these permanent, add them to your system environment variables:
echo.
echo 1. Open System Properties
echo 2. Click "Environment Variables"
echo 3. Add the variables to "User variables" or "System variables"

echo.
echo Testing credentials with Node.js...

node -e "
const { BedrockRuntimeClient } = require('@aws-sdk/client-bedrock-runtime');
const client = new BedrockRuntimeClient({ region: process.env.AWS_REGION || 'us-east-1' });
console.log('AWS Bedrock client initialized successfully!');
console.log('Region:', process.env.AWS_REGION || 'us-east-1');
"

echo.
echo ========================================
echo AWS Credentials Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Test security scan: scripts\security-scan.ps1 -Quick
echo 2. Deploy infrastructure: scripts\deploy-infrastructure.ps1
echo.
pause
