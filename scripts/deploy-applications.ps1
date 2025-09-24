# DevSecOps Applications Deployment Script (PowerShell)
# This script deploys microservices to Kubernetes

param(
    [string]$Environment = "dev",
    [string]$Namespace = "microservices",
    [switch]$DryRun,
    [switch]$Rollback
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

# Check kubectl connectivity
function Test-KubernetesAccess {
    Write-Log "Testing Kubernetes access..."
    
    try {
        $nodes = kubectl get nodes --no-headers 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Kubernetes cluster access confirmed"
            Write-Info "Connected to cluster: $($nodes.Count) nodes available"
        }
        else {
            Write-Error "Cannot access Kubernetes cluster. Please check your kubeconfig."
        }
    }
    catch {
        Write-Error "Kubernetes access test failed: $_"
    }
}

# Create namespace if it doesn't exist
function New-Namespace {
    Write-Log "Creating namespace '$Namespace'..."
    
    try {
        kubectl get namespace $Namespace 2>$null
        if ($LASTEXITCODE -ne 0) {
            kubectl create namespace $Namespace
            Write-Log "Namespace '$Namespace' created"
        }
        else {
            Write-Info "Namespace '$Namespace' already exists"
        }
    }
    catch {
        Write-Error "Failed to create namespace: $_"
    }
}

# Apply Kubernetes manifests
function Deploy-Manifests {
    Write-Log "Deploying Kubernetes manifests..."
    
    $manifestPaths = @(
        "k8s\namespaces",
        "k8s\configmaps",
        "k8s\secrets",
        "k8s\deployments",
        "k8s\services",
        "k8s\ingress"
    )
    
    foreach ($path in $manifestPaths) {
        if (Test-Path $path) {
            Write-Info "Deploying manifests from: $path"
            
            if ($DryRun) {
                kubectl apply -f $path --dry-run=client
            }
            else {
                kubectl apply -f $path
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Failed to apply manifests from $path"
                }
            }
            
            Write-Log "Manifests from $path deployed successfully"
        }
        else {
            Write-Warn "Manifest path not found: $path"
        }
    }
}

# Wait for deployments to be ready
function Wait-ForDeployments {
    Write-Log "Waiting for deployments to be ready..."
    
    $deployments = @("api", "auth", "gateway", "database")
    
    foreach ($deployment in $deployments) {
        Write-Info "Waiting for deployment: $deployment"
        
        try {
            kubectl rollout status deployment/$deployment -n $Namespace --timeout=300s
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Deployment '$deployment' is ready"
            }
            else {
                Write-Warn "Deployment '$deployment' failed to become ready"
            }
        }
        catch {
            Write-Warn "Failed to check deployment status for '$deployment': $_"
        }
    }
}

# Verify deployment
function Test-Deployment {
    Write-Log "Verifying deployment..."
    
    # Check pods
    Write-Info "Checking pod status..."
    $pods = kubectl get pods -n $Namespace --no-headers 2>$null
    if ($LASTEXITCODE -eq 0) {
        $runningPods = ($pods | Where-Object { $_ -match "Running" }).Count
        $totalPods = $pods.Count
        Write-Log "Pod status: $runningPods/$totalPods running"
        
        if ($runningPods -lt $totalPods) {
            Write-Warn "Some pods are not running. Checking pod details..."
            kubectl get pods -n $Namespace
        }
    }
    
    # Check services
    Write-Info "Checking service status..."
    kubectl get services -n $Namespace
    
    # Check ingress
    Write-Info "Checking ingress status..."
    kubectl get ingress -n $Namespace
}

# Get application URLs
function Get-ApplicationUrls {
    Write-Log "Application URLs:"
    
    try {
        # Get ingress details
        $ingress = kubectl get ingress -n $Namespace -o json | ConvertFrom-Json
        if ($ingress.items) {
            foreach ($item in $ingress.items) {
                $host = $item.spec.rules[0].host
                Write-Info "Application URL: https://$host"
            }
        }
        else {
            Write-Info "No ingress found. Services are accessible via ClusterIP or LoadBalancer."
            kubectl get services -n $Namespace
        }
    }
    catch {
        Write-Warn "Could not retrieve application URLs: $_"
    }
}

# Rollback deployment
function Invoke-Rollback {
    Write-Log "Rolling back deployment..."
    
    $deployments = @("api", "auth", "gateway", "database")
    
    foreach ($deployment in $deployments) {
        Write-Info "Rolling back deployment: $deployment"
        
        try {
            kubectl rollout undo deployment/$deployment -n $Namespace
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Rollback initiated for '$deployment'"
                
                # Wait for rollback to complete
                kubectl rollout status deployment/$deployment -n $Namespace --timeout=300s
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Rollback completed for '$deployment'"
                }
                else {
                    Write-Warn "Rollback failed for '$deployment'"
                }
            }
            else {
                Write-Warn "Failed to initiate rollback for '$deployment'"
            }
        }
        catch {
            Write-Warn "Rollback error for '$deployment': $_"
        }
    }
}

# Port forwarding for local access
function Start-PortForwarding {
    Write-Log "Starting port forwarding for local access..."
    
    $services = @(
        @{Name="api"; LocalPort=3000; ServicePort=80},
        @{Name="auth"; LocalPort=3001; ServicePort=80},
        @{Name="gateway"; LocalPort=8080; ServicePort=80}
    )
    
    foreach ($service in $services) {
        Write-Info "Port forwarding $($service.Name): localhost:$($service.LocalPort) -> $($service.Name)-service:$($service.ServicePort)"
        
        # Start port forwarding in background
        Start-Job -ScriptBlock {
            param($Namespace, $ServiceName, $LocalPort, $ServicePort)
            kubectl port-forward svc/$ServiceName-service $LocalPort`:$ServicePort -n $Namespace
        } -ArgumentList $Namespace, $service.Name, $service.LocalPort, $service.ServicePort
    }
    
    Write-Info "Port forwarding started. Access applications at:"
    Write-Info "- API: http://localhost:3000"
    Write-Info "- Auth: http://localhost:3001"
    Write-Info "- Gateway: http://localhost:8080"
}

# Main function
function Main {
    Write-Log "Starting Applications Deployment..."
    Write-Info "Environment: $Environment"
    Write-Info "Namespace: $Namespace"
    Write-Info "Dry Run: $DryRun"
    Write-Info "Rollback: $Rollback"
    
    if ($Rollback) {
        Invoke-Rollback
        return
    }
    
    Test-KubernetesAccess
    New-Namespace
    Deploy-Manifests
    
    if (-not $DryRun) {
        Wait-ForDeployments
        Test-Deployment
        Get-ApplicationUrls
        
        # Ask if user wants port forwarding
        $startPortForward = Read-Host "Do you want to start port forwarding for local access? (y/n)"
        if ($startPortForward -eq "y" -or $startPortForward -eq "Y") {
            Start-PortForwarding
        }
    }
    
    Write-Log "Applications deployment completed!"
}

# Run main function
Main
