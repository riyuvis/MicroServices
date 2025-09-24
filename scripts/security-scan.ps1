# DevSecOps Security Scan Script (PowerShell)
# This script runs comprehensive security scanning

param(
    [switch]$Quick,
    [switch]$Full,
    [string]$OutputPath = "security-reports",
    [switch]$Fix
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

# Create output directory
function New-OutputDirectory {
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
        Write-Log "Created output directory: $OutputPath"
    }
}

# Run npm audit
function Invoke-NpmAudit {
    Write-Log "Running npm audit..."
    
    try {
        # Root package.json
        if (Test-Path "package.json") {
            Write-Info "Auditing root dependencies..."
            npm audit --json > "$OutputPath\npm-audit-root.json"
            Write-Log "Root npm audit completed"
        }
        
        # Security package.json
        if (Test-Path "security\package.json") {
            Write-Info "Auditing security dependencies..."
            Set-Location security
            npm audit --json > "..\$OutputPath\npm-audit-security.json"
            Set-Location ..
            Write-Log "Security npm audit completed"
        }
        
        # Microservice package.json files
        $services = @("api", "auth", "gateway", "database")
        foreach ($service in $services) {
            $servicePath = "microservices\$service"
            if (Test-Path "$servicePath\package.json") {
                Write-Info "Auditing $service dependencies..."
                Set-Location $servicePath
                npm audit --json > "..\..\$OutputPath\npm-audit-$service.json"
                Set-Location ..\..
                Write-Log "$service npm audit completed"
            }
        }
    }
    catch {
        Write-Warn "NPM audit failed: $_"
    }
}

# Run Snyk scan
function Invoke-SnykScan {
    Write-Log "Running Snyk vulnerability scan..."
    
    try {
        if (Get-Command snyk -ErrorAction SilentlyContinue) {
            # Root project
            if (Test-Path "package.json") {
                Write-Info "Snyk scanning root project..."
                snyk test --json > "$OutputPath\snyk-scan-root.json"
                Write-Log "Root Snyk scan completed"
            }
            
            # Microservices
            $services = @("api", "auth", "gateway", "database")
            foreach ($service in $services) {
                $servicePath = "microservices\$service"
                if (Test-Path "$servicePath\package.json") {
                    Write-Info "Snyk scanning $service..."
                    Set-Location $servicePath
                    snyk test --json > "..\..\$OutputPath\snyk-scan-$service.json"
                    Set-Location ..\..
                    Write-Log "$service Snyk scan completed"
                }
            }
        }
        else {
            Write-Warn "Snyk not installed. Install with: npm install -g snyk"
        }
    }
    catch {
        Write-Warn "Snyk scan failed: $_"
    }
}

# Run TruffleHog for secrets detection
function Invoke-TruffleHogScan {
    Write-Log "Running TruffleHog secrets detection..."
    
    try {
        if (Get-Command trufflehog -ErrorAction SilentlyContinue) {
            Write-Info "Scanning for secrets..."
            trufflehog filesystem . --json > "$OutputPath\trufflehog-scan.json"
            Write-Log "TruffleHog scan completed"
        }
        else {
            Write-Warn "TruffleHog not installed. Install with: npm install -g trufflehog"
        }
    }
    catch {
        Write-Warn "TruffleHog scan failed: $_"
    }
}

# Run ESLint security scan
function Invoke-EslintSecurity {
    Write-Log "Running ESLint security scan..."
    
    try {
        # Install eslint-plugin-security if not present
        if (-not (Test-Path "node_modules\eslint-plugin-security")) {
            Write-Info "Installing eslint-plugin-security..."
            npm install --save-dev eslint-plugin-security
        }
        
        # Run ESLint with security rules
        Write-Info "Running ESLint security scan..."
        npx eslint . --ext .js,.ts --format json --output-file "$OutputPath\eslint-security.json" 2>$null
        
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
            Write-Log "ESLint security scan completed"
        }
        else {
            Write-Warn "ESLint security scan failed"
        }
    }
    catch {
        Write-Warn "ESLint security scan failed: $_"
    }
}

# Run AWS Bedrock security analysis
function Invoke-BedrockSecurityScan {
    Write-Log "Running AWS Bedrock security analysis..."
    
    try {
        if (Test-Path "scripts\security-scan.js") {
            Write-Info "Running Bedrock-powered security scan..."
            node scripts\security-scan.js
            Write-Log "Bedrock security scan completed"
        }
        else {
            Write-Warn "Security scan script not found"
        }
    }
    catch {
        Write-Warn "Bedrock security scan failed: $_"
    }
}

# Run container image scan
function Invoke-ContainerScan {
    Write-Log "Running container image security scan..."
    
    try {
        if (Get-Command docker -ErrorAction SilentlyContinue) {
            $images = @("api:latest", "auth:latest", "gateway:latest", "database:latest")
            
            foreach ($image in $images) {
                Write-Info "Scanning container image: $image"
                
                # Check if image exists
                $imageExists = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String $image
                
                if ($imageExists) {
                    # Use Trivy if available
                    if (Get-Command trivy -ErrorAction SilentlyContinue) {
                        trivy image --format json --output "$OutputPath\trivy-scan-$($image.Replace(':', '_')).json" $image
                        Write-Log "Trivy scan completed for $image"
                    }
                    # Use Docker Scout if available
                    elseif (docker scout version 2>$null) {
                        docker scout cves --format json $image > "$OutputPath\docker-scout-scan-$($image.Replace(':', '_')).json"
                        Write-Log "Docker Scout scan completed for $image"
                    }
                    else {
                        Write-Warn "No container scanning tool available (Trivy or Docker Scout)"
                    }
                }
                else {
                    Write-Warn "Container image $image not found. Build images first."
                }
            }
        }
        else {
            Write-Warn "Docker not available for container scanning"
        }
    }
    catch {
        Write-Warn "Container scan failed: $_"
    }
}

# Generate security report
function New-SecurityReport {
    Write-Log "Generating security report..."
    
    $reportPath = "$OutputPath\security-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    
    $report = @{
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        scanType = if ($Quick) { "quick" } elseif ($Full) { "full" } else { "standard" }
        summary = @{
            totalScans = 0
            criticalIssues = 0
            highIssues = 0
            mediumIssues = 0
            lowIssues = 0
        }
        scans = @()
        recommendations = @()
    }
    
    # Collect scan results
    $scanFiles = Get-ChildItem -Path $OutputPath -Filter "*.json" | Where-Object { $_.Name -notlike "*security-report*" }
    
    foreach ($file in $scanFiles) {
        try {
            $scanData = Get-Content $file.FullName | ConvertFrom-Json
            $report.scans += @{
                name = $file.BaseName
                timestamp = $file.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                file = $file.Name
                data = $scanData
            }
            $report.summary.totalScans++
        }
        catch {
            Write-Warn "Could not process scan file: $($file.Name)"
        }
    }
    
    # Add recommendations
    $report.recommendations = @(
        "Review all security findings and prioritize based on severity",
        "Update dependencies with known vulnerabilities",
        "Implement security monitoring and alerting",
        "Regular security scans should be automated in CI/CD pipeline",
        "Train development team on secure coding practices",
        "Implement secrets management best practices",
        "Enable runtime security monitoring"
    )
    
    # Save report
    $report | ConvertTo-Json -Depth 10 | Set-Content $reportPath
    Write-Log "Security report generated: $reportPath"
    
    return $reportPath
}

# Fix security issues
function Repair-SecurityIssues {
    Write-Log "Attempting to fix security issues..."
    
    try {
        # Fix npm vulnerabilities
        Write-Info "Fixing npm vulnerabilities..."
        npm audit fix --force
        
        # Fix in microservices
        $services = @("api", "auth", "gateway", "database")
        foreach ($service in $services) {
            $servicePath = "microservices\$service"
            if (Test-Path "$servicePath\package.json") {
                Write-Info "Fixing vulnerabilities in $service..."
                Set-Location $servicePath
                npm audit fix --force
                Set-Location ..\..
            }
        }
        
        Write-Log "Security fixes applied"
    }
    catch {
        Write-Warn "Failed to apply security fixes: $_"
    }
}

# Main function
function Main {
    Write-Log "Starting Security Scan..."
    Write-Info "Output Path: $OutputPath"
    Write-Info "Scan Type: $(if ($Quick) { 'Quick' } elseif ($Full) { 'Full' } else { 'Standard' })"
    Write-Info "Fix Issues: $Fix"
    
    New-OutputDirectory
    
    if ($Quick) {
        Write-Info "Running quick security scan..."
        Invoke-NpmAudit
        Invoke-EslintSecurity
    }
    elseif ($Full) {
        Write-Info "Running full security scan..."
        Invoke-NpmAudit
        Invoke-SnykScan
        Invoke-TruffleHogScan
        Invoke-EslintSecurity
        Invoke-BedrockSecurityScan
        Invoke-ContainerScan
    }
    else {
        Write-Info "Running standard security scan..."
        Invoke-NpmAudit
        Invoke-SnykScan
        Invoke-EslintSecurity
        Invoke-BedrockSecurityScan
    }
    
    if ($Fix) {
        Repair-SecurityIssues
    }
    
    $reportPath = New-SecurityReport
    
    Write-Log "Security scan completed!"
    Write-Info "Report saved to: $reportPath"
    Write-Info "Review the findings and apply necessary fixes."
}

# Run main function
Main
