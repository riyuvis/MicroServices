# Clean up example credentials from documentation
Write-Host "Cleaning up example AWS credentials from documentation files..." -ForegroundColor Yellow

# List of files that need credential cleanup
$files = @(
    "bedrock\scripts\create-visible-agent.bat",
    "scripts\add-bedrock-permissions.bat", 
    "STATUS-SUMMARY.md",
    "scripts\quick-aws-setup.bat",
    "docs\AWS-CLI-SETUP-GUIDE.md",
    "scripts\test-aws-cli.bat",
    "docs\BEDROCK-FLOW-SUMMARY.md",
    "scripts\deploy-infrastructure-simple.bat",
    "scripts\deploy-infrastructure-manual.md",
    "scripts\fix-critical-vulnerabilities.js",
    "docs\SECURITY-VULNERABILITIES.md"
)

# Credentials to replace
$replacements = @{
    "AKIA2UZBV7QXNP2PQ2ZI" = "YOUR_AWS_ACCESS_KEY_ID"
    "gbxeU+WD3JiX9FQhMSijAXzIu8a+SUnLrAr2cPfv" = "YOUR_AWS_SECRET_ACCESS_KEY"
}

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Cleaning up: $file" -ForegroundColor Cyan
        
        $content = Get-Content $file -Raw
        $originalContent = $content
        
        foreach ($credential in $replacements.Keys) {
            $content = $content -replace [regex]::Escape($credential), $replacements[$credential]
        }
        
        if ($content -ne $originalContent) {
            Set-Content $file -Value $content
            Write-Host "Updated: $file" -ForegroundColor Green
        } else {
            Write-Host "No changes needed: $file" -ForegroundColor Blue
        }
    } else {
        Write-Host "File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Credential cleanup completed!" -ForegroundColor Green
Write-Host "All example AWS credentials have been replaced with placeholders." -ForegroundColor Green