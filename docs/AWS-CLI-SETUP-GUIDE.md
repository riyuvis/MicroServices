# AWS CLI Setup Guide

## 🚨 **Current Status: AWS CLI Installed but PATH Not Updated**

AWS CLI has been successfully installed, but your current terminal session doesn't recognize the `aws` command because the PATH environment variable hasn't been refreshed.

## 🔧 **Solution Options**

### **Option 1: Restart Terminal (Recommended)**
1. **Close your current terminal/command prompt completely**
2. **Open a new terminal/command prompt**
3. **Test AWS CLI:**
   ```bash
   aws --version
   ```

### **Option 2: Restart Computer**
1. **Restart your computer** to refresh all environment variables
2. **Open a new terminal**
3. **Test AWS CLI:**
   ```bash
   aws --version
   ```

### **Option 3: Manual PATH Update (Advanced)**
1. **Find AWS CLI installation path:**
   ```bash
   dir "C:\Program Files\Amazon\AWSCLIV2"
   ```
2. **Add to PATH manually:**
   ```bash
   set PATH=%PATH%;C:\Program Files\Amazon\AWSCLIV2
   ```
3. **Test AWS CLI:**
   ```bash
   aws --version
   ```

## ✅ **Verification Steps**

After restarting your terminal, run these commands to verify AWS CLI is working:

```bash
# 1. Check AWS CLI version
aws --version

# 2. Configure AWS credentials
aws configure set aws_access_key_id AKIA2UZBV7QXNP2PQ2ZI
aws configure set aws_secret_access_key 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
aws configure set default.region us-east-1

# 3. Test AWS connection
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/DevSecOps"
}
```

## 🚀 **Next Steps After AWS CLI Setup**

### **1. Test Bedrock Flow Setup**
```bash
# Navigate to bedrock directory
cd bedrock

# Test the setup script
node scripts\create-bedrock-flow.js help

# Run full setup
node scripts\create-bedrock-flow.js setup
```

### **2. Deploy Infrastructure**
```bash
# Deploy complete infrastructure
powershell -ExecutionPolicy Bypass -File bedrock\scripts\setup-bedrock-environment.ps1
```

### **3. Test Security Flow**
```bash
# Test with sample repository
node scripts\create-bedrock-flow.js test https://github.com/example/test-repo
```

## 🛠️ **Troubleshooting**

### **If AWS CLI Still Not Found:**
```bash
# Check if AWS CLI is installed
dir "C:\Program Files\Amazon\AWSCLIV2"

# If not found, reinstall
winget install Amazon.AWSCLI

# Or download manually from: https://aws.amazon.com/cli/
```

### **If Credentials Don't Work:**
```bash
# Check current configuration
aws configure list

# Reconfigure if needed
aws configure
```

### **If Permission Denied:**
```bash
# Run as Administrator
# Or check IAM permissions for your AWS user
```

## 📋 **Quick Reference**

### **AWS CLI Commands for Bedrock:**
```bash
# List Bedrock models
aws bedrock list-foundation-models

# Create knowledge base
aws bedrockagent create-knowledge-base --cli-input-json file://kb-config.json

# Create agent
aws bedrockagent create-agent --cli-input-json file://agent-config.json

# Test agent
aws bedrockagent-runtime invoke-agent --agent-id YOUR_AGENT_ID --session-id test-session
```

### **Environment Variables:**
```bash
# Set AWS credentials as environment variables
set AWS_ACCESS_KEY_ID=AKIA2UZBV7QXNP2PQ2ZI
set AWS_SECRET_ACCESS_KEY=gbxeU+WD3JiX9FQhMSijAXzIu8a+SUnLrAr2cPfv
set AWS_DEFAULT_REGION=us-east-1
```

## 🎯 **Success Indicators**

You'll know AWS CLI is working when:
- ✅ `aws --version` shows version 2.30.6 or higher
- ✅ `aws sts get-caller-identity` returns your AWS account info
- ✅ No "command not found" errors
- ✅ Bedrock setup scripts run successfully

## 📞 **Need Help?**

If you continue to have issues:
1. **Check Windows Event Viewer** for installation logs
2. **Verify PATH environment variable** includes AWS CLI directory
3. **Try running as Administrator**
4. **Contact AWS Support** if credentials are invalid

---

**🚀 Once AWS CLI is working, you'll be ready to deploy your AI-powered DevSecOps flow!**
