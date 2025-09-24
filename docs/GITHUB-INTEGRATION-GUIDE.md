# 🐙 GitHub Repository Integration Guide

## **Overview**

This guide helps you connect your GitHub repository to the AI-powered DevSecOps CI/CD pipeline for automated security analysis and deployment.

## **Prerequisites**

### **Required Tools**
- ✅ **Git** - Version control system
- ✅ **GitHub CLI** - Command-line interface for GitHub
- ✅ **AWS CLI** - For AWS integration
- ✅ **Node.js** - For running pipeline scripts

### **Required Information**
- 🔑 **AWS Credentials** (Access Key ID & Secret Access Key)
- 🤖 **Bedrock Agent ID** (from AWS Console)
- 🐳 **ECR Registry URL** (for container images)
- 📧 **Notification preferences** (optional)

## **Quick Setup**

### **Option 1: Automated Setup (Recommended)**
```bash
# Run the automated setup script
.\scripts\setup-github-integration.bat
```

### **Option 2: Manual Setup**
Follow the step-by-step instructions below.

## **Step-by-Step Setup**

### **Step 1: Install Required Tools**

#### **Install Git**
```bash
# Download from: https://git-scm.com/downloads
# Or use package manager:
winget install Git.Git
```

#### **Install GitHub CLI**
```bash
# Using winget:
winget install --id GitHub.cli

# Verify installation:
gh --version
```

### **Step 2: Authenticate with GitHub**

```bash
# Login to GitHub
gh auth login

# Choose:
# - GitHub.com
# - HTTPS
# - Login with web browser
```

### **Step 3: Initialize Git Repository**

```bash
# If not already a git repository:
git init

# Add your GitHub repository as origin:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Verify remote:
git remote -v
```

### **Step 4: Configure GitHub Secrets**

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

#### **Required Secrets:**
```bash
AWS_ACCESS_KEY_ID=your_aws_access_key_id
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
BEDROCK_AGENT_ID=your_bedrock_agent_id
BEDROCK_AGENT_ALIAS_ID=your_bedrock_alias_id
ECR_REGISTRY=your_account.dkr.ecr.region.amazonaws.com
```

#### **Optional Secrets:**
```bash
SECURITY_TEAM_EMAIL=security@yourcompany.com
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
GRAFANA_URL=https://grafana.yourdomain.com
GRAFANA_API_KEY=your_grafana_api_key
SNYK_TOKEN=your_snyk_token
```

### **Step 5: Commit and Push Pipeline**

```bash
# Add all files:
git add .

# Commit with descriptive message:
git commit -m "Add AI-powered DevSecOps CI/CD pipeline configuration

- GitHub Actions workflow for automated security analysis
- Bedrock Agent integration for AI-powered vulnerability detection
- Security gate checks with configurable thresholds
- Automated deployment pipeline with Terraform and Kubernetes
- Monitoring and reporting with Grafana dashboards
- Email and Slack notifications for security alerts

Powered by AWS Bedrock with Claude 3.5 Sonnet"

# Push to GitHub:
git push origin main
```

## **Pipeline Configuration**

### **Workflow Triggers**

The pipeline automatically runs on:

1. **Push to main/develop branches**
   - Full security analysis
   - Automatic deployment if security gate passes

2. **Pull Request creation/updates**
   - Security analysis of changed files
   - PR comments with security report
   - Blocks merge on critical issues

3. **Daily schedule (2 AM UTC)**
   - Full repository security scan
   - Security summary notifications

### **Security Gate Configuration**

Default thresholds:
- **Critical Issues**: 0 (blocks deployment)
- **High Issues**: 3 (warns, allows deployment)
- **Medium Issues**: 10 (monitors)
- **Low Issues**: 50 (tracks)

### **Customizing Thresholds**

Edit `.github/workflows/bedrock-security-pipeline.yml`:

```yaml
- name: 🚨 Security Gate Check
  run: |
    node scripts/security-gate-check.js \
      --report="security-analysis-report.json" \
      --max-critical="0"      # Zero tolerance for critical
      --max-high="1"          # Very strict high threshold
      --max-medium="5"        # Moderate medium threshold
      --max-low="25"          # Relaxed low threshold
```

## **Testing the Integration**

### **Test 1: Trigger Pipeline**

```bash
# Make a small change and push:
echo "# Test commit for CI/CD pipeline" >> README.md
git add README.md
git commit -m "Test: Trigger CI/CD pipeline"
git push origin main
```

### **Test 2: Check GitHub Actions**

1. Go to your GitHub repository
2. Click on the **"Actions"** tab
3. Look for **"🛡️ Bedrock AI Security Analysis Pipeline"**
4. Click on the workflow run to see details

### **Test 3: Verify Security Analysis**

The pipeline should:
- ✅ Analyze your code with Bedrock Agent
- ✅ Generate security reports
- ✅ Check security gate thresholds
- ✅ Deploy if security gate passes

## **Monitoring and Alerts**

### **GitHub Actions Dashboard**

Monitor pipeline runs at:
```
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

### **Security Reports**

Reports are generated as artifacts:
- `security-analysis-report.json` - Raw analysis data
- `SECURITY-REPORT.md` - Human-readable report
- `npm-audit-report.json` - Dependency vulnerabilities
- `eslint-security-report.json` - Code quality issues

### **Notifications**

Configure notifications for:
- **Email**: Daily security summaries
- **Slack**: Real-time security alerts
- **GitHub**: PR comments with security analysis

## **Troubleshooting**

### **Common Issues**

#### **1. GitHub Secrets Not Working**
```bash
# Check secrets are set:
gh secret list

# Verify secret values:
gh secret get SECRET_NAME
```

#### **2. Pipeline Failing on AWS Authentication**
```bash
# Test AWS credentials:
aws sts get-caller-identity

# Check Bedrock access:
aws bedrock list-foundation-models --region us-east-1
```

#### **3. Bedrock Agent Not Responding**
```bash
# Check agent status:
aws bedrock-agent get-agent --agent-id YOUR_AGENT_ID

# Verify agent is prepared:
aws bedrock-agent get-agent --agent-id YOUR_AGENT_ID --query 'agent.status'
```

#### **4. Security Gate Failing**
```bash
# Check security report:
cat security-analysis-report.json | jq '.summary'

# Adjust thresholds if needed:
node scripts/security-gate-check.js \
  --report="security-analysis-report.json" \
  --max-critical="0" \
  --max-high="5"  # Increase threshold
```

### **Debug Mode**

Enable debug logging:
```bash
# In your workflow file:
env:
  DEBUG: true

# Or locally:
export DEBUG=true
node scripts/bedrock-security-pipeline.js --debug
```

## **Advanced Configuration**

### **Custom Security Rules**

Create custom security analysis:

```javascript
// scripts/custom-security-rules.js
class CustomSecurityAnalyzer {
    analyzeCode(filePath, content) {
        const issues = [];
        
        // Custom security checks
        if (content.includes('eval(')) {
            issues.push({
                type: 'Code Injection',
                severity: 'Critical',
                description: 'Use of eval() detected',
                remediation: 'Use JSON.parse() or safe alternatives'
            });
        }
        
        return issues;
    }
}
```

### **Multi-Environment Deployment**

```yaml
# Separate pipelines for different environments
strategy:
  matrix:
    environment: [dev, staging, production]
    
steps:
  - name: Deploy to ${{ matrix.environment }}
    run: |
      terraform workspace select ${{ matrix.environment }}
      terraform apply -var-file="${{ matrix.environment }}.tfvars"
```

### **Custom Notifications**

```yaml
# Add custom notification step
- name: Custom Security Alert
  if: failure()
  run: |
    curl -X POST "https://api.yourcompany.com/security-alerts" \
      -H "Content-Type: application/json" \
      -d '{
        "repository": "${{ github.repository }}",
        "branch": "${{ github.ref }}",
        "status": "failed",
        "security_score": "${{ steps.security-gate.outputs.score }}"
      }'
```

## **Best Practices**

### **Security**

1. **Rotate Secrets Regularly**
   - Update AWS credentials quarterly
   - Rotate API keys monthly
   - Use least-privilege access

2. **Monitor Pipeline Security**
   - Review security reports weekly
   - Set up alerts for critical issues
   - Document security exceptions

3. **Compliance Tracking**
   - Track compliance scores over time
   - Generate compliance reports
   - Maintain audit trails

### **Performance**

1. **Optimize Pipeline Speed**
   - Use caching for dependencies
   - Run parallel jobs when possible
   - Incremental analysis for large repos

2. **Resource Management**
   - Set appropriate timeouts
   - Monitor AWS costs
   - Use spot instances for non-critical jobs

### **Maintenance**

1. **Regular Updates**
   - Keep security tools updated
   - Update Bedrock Agent configurations
   - Review and update thresholds

2. **Documentation**
   - Document security decisions
   - Maintain runbooks
   - Train team on new processes

## **Success Metrics**

Track these KPIs:

- **Security Score**: Target >90/100
- **Time to Detection**: Average time to find vulnerabilities
- **Time to Remediation**: Average time to fix issues
- **False Positive Rate**: Accuracy of security analysis
- **Compliance Score**: Percentage of compliance requirements met
- **Deployment Frequency**: How often secure deployments occur

## **Next Steps**

1. ✅ **Connect GitHub repository** (this guide)
2. ✅ **Configure Bedrock Agent** (if not already done)
3. ✅ **Test the pipeline** with a small change
4. ✅ **Customize security thresholds** for your project
5. ✅ **Set up monitoring** and notifications
6. ✅ **Train your team** on the new security workflow

## **Support and Resources**

### **Documentation**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [DevSecOps Best Practices](https://devops.com/devsecops-best-practices/)

### **Community**
- [GitHub Actions Community](https://github.com/actions)
- [AWS Bedrock Community](https://repost.aws/tags/TAWSz3oX3k/amazon-bedrock)
- [DevSecOps Community](https://devops.com/category/devsecops/)

**Your AI-powered DevSecOps pipeline is now fully integrated with GitHub and ready to automatically secure your deployments!** 🛡️
