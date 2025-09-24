@echo off
echo DevSecOps AWS Flow - Setup
echo ==========================

echo Checking prerequisites...

where node >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Node.js is installed
    node --version
) else (
    echo ✗ Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
)

where npm >nul 2>nul
if %errorlevel%==0 (
    echo ✓ npm is available
    npm --version
) else (
    echo ✗ npm is not available
)

echo.
echo Installing dependencies...

if exist package.json (
    echo Installing root dependencies...
    npm install
)

if exist security\package.json (
    echo Installing security dependencies...
    cd security
    npm install
    cd ..
)

if exist microservices\api\package.json (
    echo Installing API dependencies...
    cd microservices\api
    npm install
    cd ..\..
)

if exist microservices\auth\package.json (
    echo Installing Auth dependencies...
    cd microservices\auth
    npm install
    cd ..\..
)

echo.
echo Creating configuration files...

if not exist .env (
    echo Creating .env file...
    echo NODE_ENV=development > .env
    echo LOG_LEVEL=info >> .env
    echo AWS_REGION=us-east-1 >> .env
    echo BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0 >> .env
    echo DATABASE_URL=postgresql://user:password@localhost:5432/devsecops >> .env
    echo JWT_SECRET=your-jwt-secret-here-change-in-production >> .env
    echo API_PORT=3000 >> .env
    echo AUTH_PORT=3001 >> .env
    echo GATEWAY_PORT=8080 >> .env
    echo ✓ Created .env file
)

if not exist security-reports (
    mkdir security-reports
    echo ✓ Created security-reports directory
)

if not exist infrastructure\terraform.tfvars (
    if exist infrastructure\terraform.tfvars.example (
        copy infrastructure\terraform.tfvars.example infrastructure\terraform.tfvars
        echo ✓ Created terraform.tfvars from example
    )
)

echo.
echo Running basic security check...

where npm >nul 2>nul
if %errorlevel%==0 (
    npm audit --audit-level=high
)

echo.
echo Setup completed!
echo ================

echo.
echo Next steps:
echo 1. Install missing tools if needed:
echo    - AWS CLI: https://aws.amazon.com/cli/
echo    - Terraform: https://www.terraform.io/downloads
echo    - Docker: https://www.docker.com/products/docker-desktop
echo    - kubectl: https://kubernetes.io/docs/tasks/tools/

echo.
echo 2. Configure AWS CLI:
echo    aws configure

echo.
echo 3. Deploy infrastructure:
echo    scripts\deploy-infrastructure.ps1

echo.
echo 4. Deploy applications:
echo    scripts\deploy-applications.ps1

echo.
echo 5. Run security scan:
echo    scripts\security-scan.ps1

echo.
echo Available commands:
echo - scripts\deploy-infrastructure.ps1 -Plan    (plan infrastructure)
echo - scripts\security-scan.ps1 -Quick         (quick security scan)
echo - scripts\security-scan.ps1 -Full          (full security scan)

echo.
echo For help, see the documentation in the docs/ folder.

pause
