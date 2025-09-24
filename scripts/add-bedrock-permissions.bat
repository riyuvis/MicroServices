@echo off
echo 🔐 Adding Bedrock Permissions to AWS User
echo ========================================
echo.

echo Setting AWS credentials...
set AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
set AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
set AWS_DEFAULT_REGION=us-east-1

echo.
echo Adding Bedrock permissions...

echo 1. Creating custom Bedrock policy...
aws iam create-policy --policy-name BedrockDevSecOpsPolicy --policy-document file://bedrock-custom-policy.json

echo.
echo 2. Attaching policy to user...
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::731825699886:policy/BedrockDevSecOpsPolicy

echo.
echo 3. Waiting for policy propagation (30 seconds)...
timeout /t 30 /nobreak >nul

echo.
echo 4. Testing Bedrock permissions...
aws bedrock list-foundation-models --region us-east-1

echo.
echo 5. Testing Knowledge Base access...
aws bedrockagent list-knowledge-bases --region us-east-1

echo.
echo ✅ Bedrock permissions setup completed!
echo.
echo Next steps:
echo 1. cd bedrock
echo 2. node scripts/create-bedrock-flow.js setup
echo.
pause

