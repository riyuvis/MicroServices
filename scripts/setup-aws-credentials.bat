@echo off
echo AWS Credentials Setup
echo =====================

echo.
echo This script will help you configure AWS credentials for the DevSecOps environment.
echo.

echo Available methods:
echo 1. AWS CLI configure (if AWS CLI is installed)
echo 2. Environment variables
echo 3. AWS credentials file
echo 4. IAM roles (for EC2 instances)
echo.

set /p method="Choose setup method (1-4): "

if "%method%"=="1" goto aws_cli
if "%method%"=="2" goto env_vars
if "%method%"=="3" goto creds_file
if "%method%"=="4" goto iam_roles
goto invalid

:aws_cli
echo.
echo Setting up AWS CLI configuration...
echo.
echo You'll need:
echo - AWS Access Key ID
echo - AWS Secret Access Key
echo - Default region (e.g., us-east-1)
echo - Default output format (json)
echo.
aws configure
echo.
echo AWS CLI configuration completed!
goto end

:env_vars
echo.
echo Setting up environment variables...
echo.
echo Create a .env file with the following variables:
echo.
echo AWS_ACCESS_KEY_ID=your-access-key-id
echo AWS_SECRET_ACCESS_KEY=your-secret-access-key
echo AWS_DEFAULT_REGION=us-east-1
echo AWS_REGION=us-east-1
echo.
echo Or set them in your system environment variables.
echo.
echo To set environment variables in PowerShell:
echo $env:AWS_ACCESS_KEY_ID="your-access-key-id"
echo $env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
echo $env:AWS_DEFAULT_REGION="us-east-1"
goto end

:creds_file
echo.
echo Setting up AWS credentials file...
echo.
echo Create the file: %%USERPROFILE%%\.aws\credentials
echo.
echo [default]
echo aws_access_key_id = your-access-key-id
echo aws_secret_access_key = your-secret-access-key
echo.
echo And the file: %%USERPROFILE%%\.aws\config
echo.
echo [default]
echo region = us-east-1
echo output = json
goto end

:iam_roles
echo.
echo Setting up IAM roles...
echo.
echo For EC2 instances, you can use IAM roles instead of credentials.
echo Create an IAM role with the following policies:
echo.
echo - AmazonBedrockFullAccess
echo - AmazonEKSClusterPolicy
echo - AmazonRDSFullAccess
echo - AmazonSecretsManagerFullAccess
echo - AWSConfigRole
echo - SecurityHubFullAccess
echo - AmazonEC2FullAccess
echo.
echo Attach the role to your EC2 instance.
goto end

:invalid
echo Invalid choice. Please run the script again.
goto end

:end
echo.
echo ========================================
echo AWS Credentials Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Test your credentials: aws sts get-caller-identity
echo 2. Configure Bedrock access: aws bedrock list-foundation-models
echo 3. Deploy infrastructure: scripts\deploy-infrastructure.ps1
echo.
pause
