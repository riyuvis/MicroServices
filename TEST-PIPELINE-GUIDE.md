# 🧪 Test Your DevSecOps Pipeline

## **Step 1: Check GitHub Push Status**

First, let's see if your code was successfully pushed to GitHub:

```bash
# Check git status
git status

# Check if there are any uncommitted changes
git log --oneline -5
```

## **Step 2: Push to GitHub (if needed)**

If the push hasn't been completed yet:

```bash
# Try pushing again
git push origin master
```

## **Step 3: Configure GitHub Secrets**

Once your code is on GitHub, configure your real AWS credentials:

### **Go to GitHub Repository Settings:**
https://github.com/riyuvis/MicroServices/settings/secrets/actions

### **Add Required Secrets:**
Click "New repository secret" and add:

```
Name: AWS_ACCESS_KEY_ID
Value: your_actual_aws_access_key_id

Name: AWS_SECRET_ACCESS_KEY  
Value: your_actual_aws_secret_access_key

Name: BEDROCK_AGENT_ID
Value: your_bedrock_agent_id

Name: BEDROCK_AGENT_ALIAS_ID
Value: TSTALIASID

Name: ECR_REGISTRY
Value: your_account.dkr.ecr.us-east-1.amazonaws.com
```

## **Step 4: Test the Pipeline**

### **Make a Test Commit:**
```bash
# Add a test line to README
echo "# Pipeline Test - $(date)" >> README.md

# Commit the change
git add README.md
git commit -m "Test: Trigger CI/CD pipeline with security analysis"

# Push to trigger the pipeline
git push origin master
```

### **Monitor GitHub Actions:**
1. Go to: https://github.com/riyuvis/MicroServices/actions
2. Look for "🛡️ Bedrock AI Security Analysis Pipeline"
3. Click on the workflow run to see details

## **Step 5: Expected Pipeline Flow**

The pipeline should execute these steps:

### **🤖 Bedrock AI Security Analysis**
- Analyze your Spring Boot microservices code
- Use Claude 3.5 Sonnet for AI-powered vulnerability detection
- Leverage FMacDevSecOps knowledge base
- Generate detailed security reports

### **🔍 Traditional Security Scans**
- npm audit for dependency vulnerabilities
- ESLint security rules
- Snyk security scanning (if configured)

### **🚨 Security Gate Check**
- Check vulnerability counts against thresholds:
  - Critical Issues: 0 (blocks deployment)
  - High Issues: 3 (warns, allows deployment)
  - Medium Issues: 10 (monitors)
  - Low Issues: 50 (tracks)

### **🚀 Deployment (if security passes)**
- Deploy infrastructure with Terraform
- Build and push Docker images to ECR
- Deploy to Kubernetes (EKS)
- Update monitoring dashboards

## **Step 6: Verify Results**

### **Check Security Reports:**
- Download artifacts from GitHub Actions
- Review `security-analysis-report.json`
- Check `SECURITY-REPORT.md` for human-readable summary

### **Monitor Deployment:**
- Check Kubernetes pods: `kubectl get pods -n devsecops`
- Verify services: `kubectl get services -n devsecops`
- Check ingress: `kubectl get ingress -n devsecops`

## **Step 7: Troubleshooting**

### **If Pipeline Fails:**

#### **1. Check GitHub Secrets**
- Verify all required secrets are set
- Ensure AWS credentials are valid
- Confirm Bedrock Agent ID is correct

#### **2. Check AWS Permissions**
```bash
# Test AWS credentials
aws sts get-caller-identity

# Test Bedrock access
aws bedrock list-foundation-models --region us-east-1
```

#### **3. Check Bedrock Agent Status**
```bash
# Verify agent is prepared
aws bedrock-agent get-agent --agent-id YOUR_AGENT_ID
```

#### **4. Review Pipeline Logs**
- Go to GitHub Actions
- Click on failed workflow run
- Review error messages in each step

### **Common Issues & Solutions:**

#### **Issue: "Bedrock Agent not responding"**
- **Solution**: Ensure agent is prepared in AWS Console
- **Check**: Agent status should be "Prepared"

#### **Issue: "AWS credentials not configured"**
- **Solution**: Add correct AWS credentials to GitHub secrets
- **Check**: Verify credentials work locally

#### **Issue: "Security gate failed"**
- **Solution**: Review security report and fix critical issues
- **Alternative**: Adjust security thresholds if needed

#### **Issue: "ECR registry not found"**
- **Solution**: Create ECR repository or update ECR_REGISTRY secret
- **Check**: Ensure ECR repository exists in your AWS account

## **Step 8: Success Indicators**

### **✅ Pipeline Success:**
- All workflow steps complete without errors
- Security analysis generates reports
- Security gate passes
- Deployment completes successfully
- Monitoring dashboards update

### **✅ Security Analysis Success:**
- Bedrock Agent responds to analysis requests
- Security vulnerabilities are detected and reported
- Compliance checks are performed
- Recommendations are generated

### **✅ Deployment Success:**
- Infrastructure deploys via Terraform
- Docker images build and push to ECR
- Kubernetes deployments are healthy
- Services are accessible

## **Step 9: Next Steps After Success**

### **1. Customize Security Thresholds**
Edit `.github/workflows/bedrock-security-pipeline.yml`:
```yaml
--max-critical="0"      # Zero tolerance for critical
--max-high="3"          # Allow up to 3 high issues
--max-medium="10"       # Allow up to 10 medium issues
--max-low="50"          # Allow up to 50 low issues
```

### **2. Set Up Notifications**
- Configure email notifications for security alerts
- Set up Slack webhooks for real-time updates
- Enable GitHub notifications for failed builds

### **3. Monitor and Optimize**
- Review security reports regularly
- Update Bedrock Agent knowledge base
- Optimize pipeline performance
- Track security metrics over time

## **🎉 Expected Outcome**

**Your AI-powered DevSecOps pipeline will now:**
- ✅ **Automatically analyze** every code change for security vulnerabilities
- ✅ **Use your Bedrock Agent** with FMacDevSecOps knowledge base
- ✅ **Block deployments** with critical security issues
- ✅ **Deploy securely** to AWS EKS when security gates pass
- ✅ **Monitor compliance** and generate security reports
- ✅ **Notify your team** of security findings

**You'll have a fully automated, enterprise-grade security pipeline protecting your Spring Boot microservices!** 🛡️

---

**Ready to test? Run the commands above and monitor your GitHub Actions!** 🚀
