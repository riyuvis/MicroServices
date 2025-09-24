# DevSecOps Infrastructure Deployment Script (PowerShell)
# This script deploys the AWS infrastructure using Terraform

param(
    [string]$Environment = "dev",
    [switch]$Destroy,
    [switch]$Plan
)

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

# Check if Terraform is installed
function Test-Terraform {
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "Terraform is not installed. Please install Terraform and try again."
    }
    Write-Log "Terraform is available"
}

# Initialize Terraform
function Initialize-Terraform {
    Write-Log "Initializing Terraform..."
    
    Set-Location infrastructure
    
    # Create terraform.tfvars if it doesn't exist
    if (-not (Test-Path "terraform.tfvars")) {
        if (Test-Path "terraform.tfvars.example") {
            Copy-Item "terraform.tfvars.example" "terraform.tfvars"
            Write-Info "Created terraform.tfvars from example file"
            Write-Warn "Please review and update terraform.tfvars with your specific values"
        }
        else {
            Write-Error "terraform.tfvars.example not found. Please create terraform.tfvars manually."
        }
    }
    
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform initialization failed"
    }
    
    Write-Log "Terraform initialized successfully"
}

# Plan Terraform deployment
function Plan-Terraform {
    Write-Log "Planning Terraform deployment..."
    
    terraform plan -var="environment=$Environment" -out="terraform.tfplan"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform plan failed"
    }
    
    Write-Log "Terraform plan completed successfully"
}

# Apply Terraform deployment
function Apply-Terraform {
    Write-Log "Applying Terraform deployment..."
    
    if (Test-Path "terraform.tfplan") {
        terraform apply "terraform.tfplan"
    }
    else {
        terraform apply -var="environment=$Environment" -auto-approve
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform apply failed"
    }
    
    Write-Log "Terraform deployment completed successfully"
}

# Destroy Terraform infrastructure
function Destroy-Terraform {
    Write-Log "Destroying Terraform infrastructure..."
    
    Write-Warn "This will destroy all infrastructure. Are you sure?"
    $confirmation = Read-Host "Type 'yes' to confirm"
    
    if ($confirmation -eq "yes") {
        terraform destroy -var="environment=$Environment" -auto-approve
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Terraform destroy failed"
        }
        Write-Log "Terraform infrastructure destroyed successfully"
    }
    else {
        Write-Info "Destroy cancelled"
    }
}

# Verify infrastructure
function Test-Infrastructure {
    Write-Log "Verifying infrastructure deployment..."
    
    # Check EKS cluster
    $clusterName = "devsecops-$Environment-eks"
    try {
        $cluster = aws eks describe-cluster --name $clusterName --output json | ConvertFrom-Json
        if ($cluster.cluster.status -eq "ACTIVE") {
            Write-Log "EKS cluster '$clusterName' is active"
        }
        else {
            Write-Warn "EKS cluster '$clusterName' is not active (status: $($cluster.cluster.status))"
        }
    }
    catch {
        Write-Warn "Could not verify EKS cluster: $_"
    }
    
    # Check RDS instance
    $dbIdentifier = "devsecops-$Environment-db"
    try {
        $db = aws rds describe-db-instances --db-instance-identifier $dbIdentifier --output json | ConvertFrom-Json
        if ($db.DBInstances[0].DBInstanceStatus -eq "available") {
            Write-Log "RDS instance '$dbIdentifier' is available"
        }
        else {
            Write-Warn "RDS instance '$dbIdentifier' is not available (status: $($db.DBInstances[0].DBInstanceStatus))"
        }
    }
    catch {
        Write-Warn "Could not verify RDS instance: $_"
    }
    
    # Check VPC
    try {
        $vpcs = aws ec2 describe-vpcs --filters "Name=tag:Name,Values=devsecops-$Environment-vpc" --output json | ConvertFrom-Json
        if ($vpcs.Vpcs.Count -gt 0) {
            Write-Log "VPC created successfully"
        }
        else {
            Write-Warn "VPC not found"
        }
    }
    catch {
        Write-Warn "Could not verify VPC: $_"
    }
}

# Output infrastructure information
function Show-InfrastructureInfo {
    Write-Log "Infrastructure Information:"
    
    Set-Location infrastructure
    terraform output
    Set-Location ..
}

# Main function
function Main {
    Write-Log "Starting Infrastructure Deployment..."
    Write-Info "Environment: $Environment"
    Write-Info "Action: $(if ($Destroy) { 'Destroy' } elseif ($Plan) { 'Plan' } else { 'Apply' })"
    
    Test-Terraform
    Initialize-Terraform
    
    if ($Destroy) {
        Destroy-Terraform
    }
    elseif ($Plan) {
        Plan-Terraform
    }
    else {
        Plan-Terraform
        Apply-Terraform
        Test-Infrastructure
        Show-InfrastructureInfo
    }
    
    Write-Log "Infrastructure deployment completed!"
}

# Run main function
Main
