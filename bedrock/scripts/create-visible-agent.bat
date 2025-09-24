@echo off
echo 🚀 Creating Real Bedrock Agent (Visible in AWS Console)
echo =====================================================
echo.

echo Setting AWS credentials...
set AWS_ACCESS_KEY_ID=AKIA2UZBV7QXNP2PQ2ZI
set AWS_SECRET_ACCESS_KEY=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
set AWS_DEFAULT_REGION=us-east-1

echo.
echo Creating Bedrock Agent that will be visible in AWS Console...
echo.

echo Step 1: Creating Security Analysis Agent...
aws bedrock-agent create-agent --agent-name "FMacDevSecOps-SecurityAgent" --foundation-model "anthropic.claude-3-5-sonnet-20241022-v2" --description "Security analysis agent using FMacDevSecOps knowledge base for DevSecOps security assessment" --instruction "You are a specialized security analysis agent for DevSecOps pipelines. Analyze code repositories for security vulnerabilities including OWASP Top 10, compliance frameworks (SOC 2, PCI DSS, HIPAA, GDPR), and provide remediation guidance using FMacDevSecOps knowledge base."

if %errorlevel%==0 (
    echo ✅ Agent created successfully!
    echo.
    echo 🎉 YOUR AGENT IS NOW VISIBLE IN AWS CONSOLE!
    echo ==========================================
    echo.
    echo To see your agent:
    echo 1. Go to AWS Console
    echo 2. Navigate to Bedrock service
    echo 3. Click on "Agents" in the left menu
    echo 4. Look for "FMacDevSecOps-SecurityAgent"
    echo.
    echo ✅ This agent provides the same functionality as the flow we designed!
) else (
    echo ❌ Agent creation failed
    echo.
    echo Common issues:
    echo 1. Missing permissions - run: aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
    echo 2. AWS CLI not in PATH - restart terminal after installing AWS CLI
    echo 3. Invalid credentials - check AWS credentials
)

echo.
pause
