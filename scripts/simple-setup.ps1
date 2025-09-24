# Simple DevSecOps Setup Script
# This script provides basic setup without complex error handling

Write-Host "DevSecOps AWS Flow - Simple Setup" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if Node.js is available
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$nodeAvailable = $false
$npmAvailable = $false

try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green
        $nodeAvailable = $true
    }
}
catch {
    Write-Host "✗ Node.js: Not installed" -ForegroundColor Red
}

try {
    $npmVersion = npm --version 2>$null
    if ($npmVersion) {
        Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
        $npmAvailable = $true
    }
}
catch {
    Write-Host "✗ npm: Not installed" -ForegroundColor Red
}

# Install dependencies if npm is available
if ($npmAvailable) {
    Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
    
    if (Test-Path "package.json") {
        Write-Host "Installing root dependencies..." -ForegroundColor Cyan
        npm install
    }
    
    if (Test-Path "security\package.json") {
        Write-Host "Installing security dependencies..." -ForegroundColor Cyan
        Set-Location security
        npm install
        Set-Location ..
    }
    
    # Install microservice dependencies
    $services = @("api", "auth", "gateway", "database")
    foreach ($service in $services) {
        $servicePath = "microservices\$service"
        if (Test-Path "$servicePath\package.json") {
            Write-Host "Installing $service dependencies..." -ForegroundColor Cyan
            Set-Location $servicePath
            npm install
            Set-Location ..\..
        }
    }
    
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
}

# Create basic configuration
Write-Host "`nCreating configuration files..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    $envContent = @"
# DevSecOps Environment Configuration
NODE_ENV=development
LOG_LEVEL=info
AWS_REGION=us-east-1
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/devsecops

# JWT Configuration
JWT_SECRET=your-jwt-secret-here-change-in-production

# API Configuration
API_PORT=3000
AUTH_PORT=3001
GATEWAY_PORT=8080
"@
    Set-Content -Path ".env" -Value $envContent
    Write-Host "✓ Created .env file" -ForegroundColor Green
}

# Create security reports directory
if (-not (Test-Path "security-reports")) {
    New-Item -ItemType Directory -Path "security-reports" | Out-Null
    Write-Host "✓ Created security-reports directory" -ForegroundColor Green
}

# Create terraform.tfvars if needed
if (-not (Test-Path "infrastructure\terraform.tfvars")) {
    if (Test-Path "infrastructure\terraform.tfvars.example") {
        Copy-Item "infrastructure\terraform.tfvars.example" "infrastructure\terraform.tfvars"
        Write-Host "✓ Created terraform.tfvars from example" -ForegroundColor Green
    }
}

# Run basic security check
if ($npmAvailable) {
    Write-Host "`nRunning basic security check..." -ForegroundColor Yellow
    
    try {
        npm audit --audit-level=high
        Write-Host "✓ Security audit completed" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Security audit had issues" -ForegroundColor Yellow
    }
}

# Show next steps
Write-Host "`nSetup completed!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Install missing tools if needed:" -ForegroundColor White
Write-Host "   - AWS CLI: https://aws.amazon.com/cli/" -ForegroundColor Gray
Write-Host "   - Terraform: https://www.terraform.io/downloads" -ForegroundColor Gray
Write-Host "   - Docker: https://www.docker.com/products/docker-desktop" -ForegroundColor Gray
Write-Host "   - kubectl: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Gray

Write-Host "`n2. Configure AWS CLI:" -ForegroundColor White
Write-Host "   aws configure" -ForegroundColor Gray

Write-Host "`n3. Deploy infrastructure:" -ForegroundColor White
Write-Host "   .\scripts\deploy-infrastructure.ps1" -ForegroundColor Gray

Write-Host "`n4. Deploy applications:" -ForegroundColor White
Write-Host "   .\scripts\deploy-applications.ps1" -ForegroundColor Gray

Write-Host "`n5. Run security scan:" -ForegroundColor White
Write-Host "   .\scripts\security-scan.ps1" -ForegroundColor Gray

Write-Host "`nAvailable commands:" -ForegroundColor Cyan
Write-Host "- .\scripts\deploy-infrastructure.ps1 -Plan    (plan infrastructure)" -ForegroundColor Gray
Write-Host "- .\scripts\security-scan.ps1 -Quick         (quick security scan)" -ForegroundColor Gray
Write-Host "- .\scripts\security-scan.ps1 -Full          (full security scan)" -ForegroundColor Gray

Write-Host "`nFor help, see the documentation in the docs/ folder." -ForegroundColor Yellow
