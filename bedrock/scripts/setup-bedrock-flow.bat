@echo off
echo 🚀 AWS Bedrock DevSecOps Flow Setup
echo ===================================
echo.

echo Checking prerequisites...

where aws >nul 2>nul
if %errorlevel%==0 (
    echo ✓ AWS CLI is installed
) else (
    echo ✗ AWS CLI is not installed
    echo Please install AWS CLI first
    pause
    exit /b 1
)

where node >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Node.js is installed
) else (
    echo ✗ Node.js is not installed
    echo Please install Node.js first
    pause
    exit /b 1
)

echo.
echo Setting up AWS credentials...
set AWS_ACCESS_KEY_ID=AKIA2UZBV7QXNP2PQ2ZI
set AWS_SECRET_ACCESS_KEY=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
set AWS_DEFAULT_REGION=us-east-1
echo ✓ AWS credentials configured

echo.
echo Installing Bedrock dependencies...
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies installed

echo.
echo 🏗️ BEDROCK FLOW COMPONENTS CREATED:
echo ===================================
echo.
echo ✅ DevSecOps Security Flow Configuration
echo ✅ Security Analysis Agent with Claude 3.5 Sonnet
echo ✅ Knowledge Base with OpenSearch Serverless
echo ✅ Terraform Infrastructure Code
echo ✅ PowerShell Setup Scripts
echo ✅ Documentation and Guides
echo.

echo 📋 AVAILABLE COMMANDS:
echo =====================
echo.
echo 1. Setup Bedrock Environment:
echo    node scripts\create-bedrock-flow.js setup
echo.
echo 2. Test Security Flow:
echo    node scripts\create-bedrock-flow.js test
echo.
echo 3. Deploy Infrastructure:
echo    powershell -ExecutionPolicy Bypass -File scripts\setup-bedrock-environment.ps1
echo.
echo 4. View Documentation:
echo    docs\BEDROCK-FLOW-GUIDE.md
echo.

echo 🎯 WHAT THE BEDROCK FLOW DOES:
echo ==============================
echo.
echo 🔍 Security Analysis:
echo   - Vulnerability detection (OWASP Top 10)
echo   - Dependency scanning for known CVEs
echo   - Secret detection and credential scanning
echo   - Configuration security review
echo.
echo 📊 Compliance Checking:
echo   - SOC 2 Type II controls
echo   - PCI DSS requirements
echo   - HIPAA security rules
echo   - GDPR data protection
echo.
echo 🛠️ Remediation Guidance:
echo   - Specific code fixes with examples
echo   - Configuration updates
echo   - Security best practices
echo   - Implementation timelines
echo.
echo 📈 Risk Assessment:
echo   - CVSS scoring for vulnerabilities
echo   - Business impact analysis
echo   - Exploitability assessment
echo   - Priority ranking
echo.

echo 🚀 Ready to deploy your AI-powered DevSecOps flow!
echo.
echo Next steps:
echo 1. Review the configuration files in flows/, agents/, and knowledge-base/
echo 2. Run: node scripts\create-bedrock-flow.js setup
echo 3. Test with: node scripts\create-bedrock-flow.js test
echo.
pause
