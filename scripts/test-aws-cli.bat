@echo off
echo 🔧 Testing AWS CLI Installation
echo ================================
echo.

echo Checking if AWS CLI is installed...
where aws >nul 2>nul
if %errorlevel%==0 (
    echo ✅ AWS CLI is installed and accessible
    aws --version
    echo.
    echo Testing AWS credentials...
    set AWS_ACCESS_KEY_ID=AKIA2UZBV7QXNP2PQ2ZI
    set AWS_SECRET_ACCESS_KEY=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
    set AWS_DEFAULT_REGION=us-east-1
    
    echo Testing AWS connection...
    aws sts get-caller-identity
    if %errorlevel%==0 (
        echo ✅ AWS credentials working correctly
        echo.
        echo 🚀 Ready to deploy Bedrock flow!
        echo.
        echo Next steps:
        echo 1. cd bedrock
        echo 2. node scripts\create-bedrock-flow.js setup
        echo 3. node scripts\create-bedrock-flow.js test
    ) else (
        echo ❌ AWS credentials test failed
        echo Please check your AWS credentials
    )
) else (
    echo ❌ AWS CLI is not found in PATH
    echo.
    echo The AWS CLI was installed but needs a terminal restart.
    echo Please:
    echo 1. Close this terminal/command prompt
    echo 2. Open a new terminal/command prompt
    echo 3. Run this script again
    echo.
    echo Alternative: Restart your computer to refresh PATH
)

echo.
pause
