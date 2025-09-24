# DevSecOps AWS Flow Setup Script (PowerShell)
# This script sets up the complete DevSecOps environment

param(
    [switch]$SkipTests,
    [switch]$SkipSecurity,
    [string]$Environment = "dev"
)

# Set error action preference
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
    exit 1
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

# Check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    $requiredTools = @("aws", "terraform", "kubectl", "docker", "node", "npm")
    $missingTools = @()
    
    foreach ($tool in $requiredTools) {
        if (-not (Test-Command $tool)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Error "Missing required tools: $($missingTools -join ', ')"
        Write-Info "Please install the missing tools and run this script again."
    }
    
    Write-Log "All prerequisites are installed!"
}

# Install dependencies
function Install-Dependencies {
    Write-Log "Installing dependencies..."
    
    # Install root dependencies
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

# Setup AWS credentials
function Setup-AWS {
    Write-Log "Setting up AWS configuration..."
    
    try {
        $accountInfo = aws sts get-caller-identity --output json | ConvertFrom-Json
        $accountId = $accountInfo.Account
        $region = aws configure get region
        
        Write-Log "AWS Account ID: $accountId"
        Write-Log "AWS Region: $region"
        
        # Check Bedrock access
        try {
            aws bedrock list-foundation-models --region us-east-1 --output json | Out-Null
            Write-Log "AWS Bedrock access confirmed"
        }
        catch {
            Write-Warn "AWS Bedrock access not available. Please request access to Claude models."
        }
    }
    catch {
        Write-Warn "AWS CLI is not configured. Please run 'aws configure' to set up your credentials."
        Write-Info "Required AWS permissions:"
        Write-Info "- AmazonBedrockFullAccess"
        Write-Info "- AmazonEKSClusterPolicy"
        Write-Info "- AmazonRDSFullAccess"
        Write-Info "- AmazonSecretsManagerFullAccess"
        Write-Info "- AWSConfigRole"
        Write-Info "- SecurityHubFullAccess"
        Read-Host "Press Enter after configuring AWS CLI..."
    }
}

# Setup Kubernetes
function Setup-Kubernetes {
    Write-Log "Setting up Kubernetes configuration..."
    
    $clusterName = "devsecops-$Environment-eks"
    $region = aws configure get region
    
    try {
        aws eks update-kubeconfig --region $region --name $clusterName | Out-Null
        Write-Log "Kubernetes configuration updated for cluster: $clusterName"
        
        # Verify cluster access
        $nodes = kubectl get nodes --no-headers 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Kubernetes cluster access confirmed"
            kubectl get nodes
        }
        else {
            Write-Warn "Cannot access Kubernetes cluster"
            return $false
        }
    }
    catch {
        Write-Warn "EKS cluster '$clusterName' not found. Please deploy infrastructure first."
        return $false
    }
    
    return $true
}

# Create security reports directory
function Setup-Security {
    Write-Log "Setting up security scanning..."
    
    if (-not (Test-Path "security-reports")) {
        New-Item -ItemType Directory -Path "security-reports" | Out-Null
    }
    
    # Create sample security configuration
    $gitkeepContent = @"
# This directory contains security scan reports
# Reports are generated by the security scanning pipeline
"@
    Set-Content -Path "security-reports\.gitkeep" -Value $gitkeepContent
    
    Write-Log "Security reports directory created"
}

# Build applications
function Build-Applications {
    Write-Log "Building applications..."
    
    $services = @("api", "auth", "gateway", "database")
    foreach ($service in $services) {
        $servicePath = "microservices\$service"
        if (Test-Path $servicePath) {
            Write-Log "Building $service microservice..."
            Set-Location $servicePath
            if ((Test-Path "package.json") -and ((Get-Content "package.json" | ConvertFrom-Json).scripts.PSObject.Properties.Name -contains "build")) {
                npm run build
                Write-Log "$service microservice built successfully"
            }
            else {
                Write-Info "$service microservice has no build script, skipping..."
            }
            Set-Location ..\..
        }
    }
}

# Run tests
function Invoke-Tests {
    if ($SkipTests) {
        Write-Info "Skipping tests as requested"
        return
    }
    
    Write-Log "Running tests..."
    
    # Run security tests
    if (Test-Path "security\package.json") {
        Set-Location security
        if ((Get-Content "package.json" | ConvertFrom-Json).scripts.PSObject.Properties.Name -contains "test") {
            try {
                npm test | Out-Null
                Write-Log "Security tests passed"
            }
            catch {
                Write-Warn "Security tests failed"
            }
        }
        Set-Location ..
    }
    
    # Run microservice tests
    $services = @("api", "auth", "gateway", "database")
    foreach ($service in $services) {
        $servicePath = "microservices\$service"
        if (Test-Path "$servicePath\package.json") {
            Set-Location $servicePath
            if ((Get-Content "package.json" | ConvertFrom-Json).scripts.PSObject.Properties.Name -contains "test") {
                try {
                    npm test | Out-Null
                    Write-Log "$service microservice tests passed"
                }
                catch {
                    Write-Warn "$service microservice tests failed"
                }
            }
            Set-Location ..\..
        }
    }
}

# Run security scan
function Invoke-SecurityScan {
    if ($SkipSecurity) {
        Write-Info "Skipping security scan as requested"
        return
    }
    
    Write-Log "Running security scan..."
    
    if (Test-Path "scripts\security-scan.js") {
        try {
            node scripts\security-scan.js
            Write-Log "Security scan completed"
        }
        catch {
            Write-Warn "Security scan failed"
        }
    }
    else {
        Write-Warn "Security scan script not found"
    }
}

# Main setup function
function Main {
    Write-Log "Starting DevSecOps AWS Flow Setup..."
    Write-Info "Environment: $Environment"
    Write-Info "Skip Tests: $SkipTests"
    Write-Info "Skip Security: $SkipSecurity"
    
    Test-Prerequisites
    Install-Dependencies
    Setup-AWS
    Setup-Security
    
    # Try to setup Kubernetes (might fail if infrastructure not deployed)
    if (Setup-Kubernetes) {
        Build-Applications
        Invoke-Tests
        Invoke-SecurityScan
    }
    else {
        Write-Warn "Kubernetes setup skipped - infrastructure not deployed yet"
    }
    
    Write-Log "Setup completed successfully!"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "1. Deploy infrastructure: .\scripts\deploy-infrastructure.ps1"
    Write-Info "2. Deploy applications: .\scripts\deploy-applications.ps1"
    Write-Info "3. Start monitoring: .\scripts\start-monitoring.ps1"
    Write-Info "4. Run security scan: .\scripts\security-scan.ps1"
}

# Run main function
Main
