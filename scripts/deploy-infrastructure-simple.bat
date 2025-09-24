@echo off
echo DevSecOps AWS Infrastructure Deployment
echo =======================================

echo.
echo This script will deploy your AWS infrastructure using Terraform.
echo.

echo Checking prerequisites...

where terraform >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Terraform is installed
    terraform --version
) else (
    echo ✗ Terraform is not installed
    echo Please install Terraform first:
    echo winget install HashiCorp.Terraform
    echo.
    echo Then restart your terminal and run this script again.
    pause
    exit /b 1
)

echo.
echo Setting up AWS credentials...
set AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
set AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
set AWS_DEFAULT_REGION=us-east-1
echo ✓ AWS credentials configured

echo.
echo Preparing infrastructure deployment...
cd infrastructure

echo.
echo Creating terraform.tfvars from example...
if not exist terraform.tfvars (
    if exist terraform.tfvars.example (
        copy terraform.tfvars.example terraform.tfvars
        echo ✓ terraform.tfvars created
    ) else (
        echo ⚠️ terraform.tfvars.example not found
    )
)

echo.
echo Initializing Terraform...
terraform init
if %errorlevel% neq 0 (
    echo ❌ Terraform initialization failed
    pause
    exit /b 1
)
echo ✓ Terraform initialized

echo.
echo Planning infrastructure deployment...
terraform plan
if %errorlevel% neq 0 (
    echo ❌ Terraform plan failed
    pause
    exit /b 1
)

echo.
echo Do you want to proceed with the deployment?
echo This will create AWS resources that may incur costs.
set /p confirm="Type 'yes' to confirm deployment: "

if "%confirm%" neq "yes" (
    echo Deployment cancelled.
    pause
    exit /b 0
)

echo.
echo Deploying infrastructure...
terraform apply -auto-approve
if %errorlevel% neq 0 (
    echo ❌ Infrastructure deployment failed
    pause
    exit /b 1
)

echo.
echo ✓ Infrastructure deployment completed successfully!
echo.
echo Next steps:
echo 1. Update kubectl config: aws eks update-kubeconfig --region us-east-1 --name devsecops-dev-eks
echo 2. Deploy applications: scripts\deploy-applications.ps1
echo 3. Start monitoring: scripts\start-monitoring.ps1
echo.
echo Infrastructure Summary:
terraform output

cd ..
pause

