# DevSecOps Tools Installation Script (PowerShell)
# This script helps install the required tools for DevSecOps

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

# Install Node.js and npm
function Install-NodeJS {
    if (-not (Test-Command node)) {
        Write-Log "Installing Node.js and npm..."
        
        # Check if winget is available
        if (Test-Command winget) {
            Write-Info "Using winget to install Node.js..."
            winget install OpenJS.NodeJS
        }
        # Check if chocolatey is available
        elseif (Test-Command choco) {
            Write-Info "Using chocolatey to install Node.js..."
            choco install nodejs -y
        }
        else {
            Write-Info "Please install Node.js manually from: https://nodejs.org/"
            Write-Info "Or install winget/chocolatey first"
        }
    }
    else {
        Write-Log "Node.js is already installed"
    }
}

# Install AWS CLI
function Install-AWSCLI {
    if (-not (Test-Command aws)) {
        Write-Log "Installing AWS CLI..."
        
        if (Test-Command winget) {
            Write-Info "Using winget to install AWS CLI..."
            winget install Amazon.AWSCLI
        }
        elseif (Test-Command choco) {
            Write-Info "Using chocolatey to install AWS CLI..."
            choco install awscli -y
        }
        else {
            Write-Info "Please install AWS CLI manually from: https://aws.amazon.com/cli/"
        }
    }
    else {
        Write-Log "AWS CLI is already installed"
    }
}

# Install Terraform
function Install-Terraform {
    if (-not (Test-Command terraform)) {
        Write-Log "Installing Terraform..."
        
        if (Test-Command winget) {
            Write-Info "Using winget to install Terraform..."
            winget install HashiCorp.Terraform
        }
        elseif (Test-Command choco) {
            Write-Info "Using chocolatey to install Terraform..."
            choco install terraform -y
        }
        else {
            Write-Info "Please install Terraform manually from: https://www.terraform.io/downloads"
        }
    }
    else {
        Write-Log "Terraform is already installed"
    }
}

# Install kubectl
function Install-Kubectl {
    if (-not (Test-Command kubectl)) {
        Write-Log "Installing kubectl..."
        
        if (Test-Command winget) {
            Write-Info "Using winget to install kubectl..."
            winget install Kubernetes.kubectl
        }
        elseif (Test-Command choco) {
            Write-Info "Using chocolatey to install kubectl..."
            choco install kubernetes-cli -y
        }
        else {
            Write-Info "Please install kubectl manually from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/"
        }
    }
    else {
        Write-Log "kubectl is already installed"
    }
}

# Install Docker
function Install-Docker {
    if (-not (Test-Command docker)) {
        Write-Log "Installing Docker..."
        
        if (Test-Command winget) {
            Write-Info "Using winget to install Docker Desktop..."
            winget install Docker.DockerDesktop
        }
        elseif (Test-Command choco) {
            Write-Info "Using chocolatey to install Docker Desktop..."
            choco install docker-desktop -y
        }
        else {
            Write-Info "Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop"
        }
    }
    else {
        Write-Log "Docker is already installed"
    }
}

# Install additional security tools
function Install-SecurityTools {
    Write-Log "Installing security tools..."
    
    # Install Snyk
    if (Test-Command npm) {
        if (-not (Test-Command snyk)) {
            Write-Info "Installing Snyk..."
            npm install -g snyk
        }
        else {
            Write-Log "Snyk is already installed"
        }
        
        # Install TruffleHog
        if (-not (Test-Command trufflehog)) {
            Write-Info "Installing TruffleHog..."
            npm install -g trufflehog
        }
        else {
            Write-Log "TruffleHog is already installed"
        }
    }
    else {
        Write-Warn "npm not available for installing security tools"
    }
}

# Show installation status
function Show-InstallationStatus {
    Write-Log "Installation Status:"
    
    $tools = @(
        @{Name="Node.js"; Command="node"},
        @{Name="npm"; Command="npm"},
        @{Name="AWS CLI"; Command="aws"},
        @{Name="Terraform"; Command="terraform"},
        @{Name="kubectl"; Command="kubectl"},
        @{Name="Docker"; Command="docker"},
        @{Name="Snyk"; Command="snyk"},
        @{Name="TruffleHog"; Command="trufflehog"}
    )
    
    foreach ($tool in $tools) {
        if (Test-Command $tool.Command) {
            $version = & $tool.Command --version 2>$null
            Write-Info "✓ $($tool.Name): $version"
        }
        else {
            Write-Warn "✗ $($tool.Name): Not installed"
        }
    }
}

# Main installation function
function Main {
    Write-Log "Starting DevSecOps Tools Installation..."
    
    Write-Info "This script will help you install the required tools for DevSecOps"
    Write-Info "Some tools require manual installation or package managers"
    
    $installChoice = Read-Host "Do you want to proceed with automatic installation where possible? (y/n)"
    
    if ($installChoice -eq "y" -or $installChoice -eq "Y") {
        Install-NodeJS
        Install-AWSCLI
        Install-Terraform
        Install-Kubectl
        Install-Docker
        Install-SecurityTools
    }
    
    Show-InstallationStatus
    
    Write-Log "Installation process completed!"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "1. Restart your terminal/command prompt"
    Write-Info "2. Configure AWS CLI: aws configure"
    Write-Info "3. Run the setup script: .\scripts\setup.ps1"
}

# Run main function
Main
