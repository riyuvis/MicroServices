# DevSecOps Quick Start Script (PowerShell)
# This script provides a quick way to get started with the DevSecOps flow

$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" -ForegroundColor $Color
}

function Write-Log {
    param([string]$Message)
    Write-ColorOutput $Message "Green"
}

function Write-Warn {
    param([string]$Message)
    Write-ColorOutput "WARNING: $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "ERROR: $Message" "Red"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "INFO: $Message" "Cyan"
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Install Node.js dependencies
function Install-Dependencies {
    Write-Log "Installing Node.js dependencies..."
    
    if (Test-Command npm) {
        if (Test-Path "package.json") {
            npm install
            Write-Log "Root dependencies installed"
        }
        
        # Install security dependencies
        if (Test-Path "security\package.json") {
            Set-Location security
            npm install
            Set-Location ..
            Write-Log "Security dependencies installed"
        }
        
        # Install microservice dependencies
        $services = @("api", "auth", "gateway", "database")
        foreach ($service in $services) {
            $servicePath = "microservices\$service"
            if (Test-Path "$servicePath\package.json") {
                Set-Location $servicePath
                npm install
                Set-Location ..\..
                Write-Log "$service microservice dependencies installed"
            }
        }
    }
    else {
        Write-Warn "npm not available. Please install Node.js first."
    }
}

# Create basic configuration files
function New-BasicConfig {
    Write-Log "Creating basic configuration files..."
    
    # Create .env file if it doesn't exist
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
        Write-Log "Created .env file"
    }
    
    # Create security reports directory
    if (-not (Test-Path "security-reports")) {
        New-Item -ItemType Directory -Path "security-reports" | Out-Null
        Write-Log "Created security-reports directory"
    }
    
    # Create basic terraform.tfvars if it doesn't exist
    if (-not (Test-Path "infrastructure\terraform.tfvars")) {
        if (Test-Path "infrastructure\terraform.tfvars.example") {
            Copy-Item "infrastructure\terraform.tfvars.example" "infrastructure\terraform.tfvars"
            Write-Log "Created terraform.tfvars from example"
        }
    }
}

# Run basic security scan
function Invoke-BasicSecurityScan {
    Write-Log "Running basic security scan..."
    
    if (Test-Command npm) {
        # Run npm audit
        Write-Info "Running npm audit..."
        npm audit --audit-level=high
        
        # Run ESLint if available
        if (Test-Path "node_modules\.bin\eslint.cmd") {
            Write-Info "Running ESLint..."
            npx eslint . --ext .js,.ts --max-warnings 0
        }
    }
    
    Write-Log "Basic security scan completed"
}

# Build applications
function Build-Applications {
    Write-Log "Building applications..."
    
    $services = @("api", "auth", "gateway", "database")
    foreach ($service in $services) {
        $servicePath = "microservices\$service"
        if (Test-Path $servicePath) {
            Set-Location $servicePath
            if ((Test-Path "package.json") -and ((Get-Content "package.json" | ConvertFrom-Json).scripts.PSObject.Properties.Name -contains "build")) {
                Write-Info "Building $service microservice..."
                npm run build
                Write-Log "$service microservice built successfully"
            }
            Set-Location ..\..
        }
    }
}

# Test applications locally
function Test-ApplicationsLocally {
    Write-Log "Testing applications locally..."
    
    if (Test-Command node) {
        # Test API service
        if (Test-Path "microservices\api\src\server.js") {
            Write-Info "Testing API service..."
            Set-Location "microservices\api"
            Start-Job -ScriptBlock {
                Set-Location $args[0]
                node src\server.js
            } -ArgumentList (Get-Location)
            Set-Location ..\..
            
            # Wait a moment for server to start
            Start-Sleep -Seconds 3
            
            # Test health endpoint
            try {
                $response = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 5
                Write-Log "API service is running: $($response.status)"
            }
            catch {
                Write-Warn "API service health check failed: $_"
            }
        }
    }
}

# Show system status
function Show-SystemStatus {
    Write-Log "System Status:"
    
    # Check Node.js
    if (Test-Command node) {
        $nodeVersion = node --version
        Write-Info "✓ Node.js: $nodeVersion"
    }
    else {
        Write-Warn "✗ Node.js: Not installed"
    }
    
    # Check npm
    if (Test-Command npm) {
        $npmVersion = npm --version
        Write-Info "✓ npm: $npmVersion"
    }
    else {
        Write-Warn "✗ npm: Not installed"
    }
    
    # Check AWS CLI
    if (Test-Command aws) {
        try {
            $awsVersion = aws --version
            Write-Info "✓ AWS CLI: $awsVersion"
        }
        catch {
            Write-Warn "✗ AWS CLI: Not configured"
        }
    }
    else {
        Write-Warn "✗ AWS CLI: Not installed"
    }
    
    # Check Terraform
    if (Test-Command terraform) {
        $terraformVersion = terraform --version
        Write-Info "✓ Terraform: $terraformVersion"
    }
    else {
        Write-Warn "✗ Terraform: Not installed"
    }
    
    # Check kubectl
    if (Test-Command kubectl) {
        try {
            $kubectlVersion = kubectl version --client
            Write-Info "✓ kubectl: $kubectlVersion"
        }
        catch {
            Write-Warn "✗ kubectl: Not configured"
        }
    }
    else {
        Write-Warn "✗ kubectl: Not installed"
    }
    
    # Check Docker
    if (Test-Command docker) {
        try {
            $dockerVersion = docker --version
            Write-Info "✓ Docker: $dockerVersion"
        }
        catch {
            Write-Warn "✗ Docker: Not running"
        }
    }
    else {
        Write-Warn "✗ Docker: Not installed"
    }
}

# Show available commands
function Show-AvailableCommands {
    Write-Log "Available Commands:"
    Write-Info ""
    Write-Info "Setup Commands:"
    Write-Info "  .\scripts\install-tools.ps1     - Install required tools"
    Write-Info "  .\scripts\setup.ps1            - Full environment setup"
    Write-Info ""
    Write-Info "Deployment Commands:"
    Write-Info "  .\scripts\deploy-infrastructure.ps1 - Deploy AWS infrastructure"
    Write-Info "  .\scripts\deploy-applications.ps1   - Deploy microservices"
    Write-Info ""
    Write-Info "Security Commands:"
    Write-Info "  .\scripts\security-scan.ps1    - Run security scans"
    Write-Info "  .\scripts\security-scan.ps1 -Quick - Quick security scan"
    Write-Info "  .\scripts\security-scan.ps1 -Full  - Full security scan"
    Write-Info ""
    Write-Info "Development Commands:"
    Write-Info "  npm run dev                    - Start development server"
    Write-Info "  npm run test                   - Run tests"
    Write-Info "  npm run lint                   - Run linting"
    Write-Info ""
    Write-Info "Make Commands (if Make is available):"
    Write-Info "  make install                   - Install dependencies"
    Write-Info "  make build                     - Build applications"
    Write-Info "  make test                      - Run tests"
    Write-Info "  make security-scan             - Run security scan"
    Write-Info "  make deploy-dev                - Deploy to development"
}

# Main function
function Main {
    Write-Log "DevSecOps AWS Flow - Quick Start"
    Write-Info "This script will help you get started quickly with the DevSecOps environment"
    
    Show-SystemStatus
    
    Write-Info ""
    $proceedChoice = Read-Host "Do you want to proceed with basic setup? (y/n)"
    
    if ($proceedChoice -eq "y" -or $proceedChoice -eq "Y") {
        Install-Dependencies
        New-BasicConfig
        Invoke-BasicSecurityScan
        Build-Applications
        
        Write-Info ""
        $testChoice = Read-Host "Do you want to test applications locally? (y/n)"
        if ($testChoice -eq "y" -or $testChoice -eq "Y") {
            Test-ApplicationsLocally
        }
    }
    
    Write-Log "Quick start completed!"
    Write-Info ""
    Show-AvailableCommands
}

# Run main function
Main
