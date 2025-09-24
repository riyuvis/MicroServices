@echo off
echo Testing DevSecOps Microservices
echo ================================

echo.
echo Building microservices...

cd microservices\api
if exist package.json (
    echo Building API microservice...
    npm run build
)
cd ..\..

cd microservices\auth
if exist package.json (
    echo Building Auth microservice...
    npm run build
)
cd ..\..

echo.
echo Testing API microservice...

cd microservices\api
if exist src\server.js (
    echo Starting API server for testing...
    start "API Server" cmd /k "node src\server.js"
    timeout /t 3 /nobreak >nul
    
    echo Testing API health endpoint...
    powershell -Command "try { $response = Invoke-RestMethod -Uri 'http://localhost:3000/health' -Method Get -TimeoutSec 5; Write-Host 'API Health:' $response.status -ForegroundColor Green } catch { Write-Host 'API Health check failed:' $_.Exception.Message -ForegroundColor Red }"
)
cd ..\..

echo.
echo Testing completed!
echo ==================

echo.
echo Next steps:
echo 1. Install missing tools:
echo    - AWS CLI: https://aws.amazon.com/cli/
echo    - Terraform: https://www.terraform.io/downloads
echo    - kubectl: https://kubernetes.io/docs/tasks/tools/
echo    - Docker: https://www.docker.com/products/docker-desktop

echo.
echo 2. Configure AWS credentials:
echo    aws configure

echo.
echo 3. Deploy infrastructure:
echo    scripts\deploy-infrastructure.ps1

echo.
echo 4. Deploy to Kubernetes:
echo    scripts\deploy-applications.ps1

echo.
echo 5. Start monitoring:
echo    scripts\start-monitoring.ps1

pause
