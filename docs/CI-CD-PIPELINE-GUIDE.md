# 🚀 CI/CD Pipeline Configuration Guide

## **Overview**

This guide explains how to configure and use the AI-powered DevSecOps CI/CD pipeline that integrates with your Bedrock Agent for automated security analysis.

## **Pipeline Architecture**

### **🔄 Pipeline Flow**
```
Code Push/PR → Bedrock AI Analysis → Security Gate Check → Deployment → Monitoring
```

### **📊 Pipeline Components**

1. **🤖 Bedrock AI Security Analysis**
   - Analyzes code changes using Claude 3.5 Sonnet
   - Leverages FMacDevSecOps knowledge base
   - Provides detailed vulnerability assessment

2. **🔍 Traditional Security Scans**
   - npm audit for dependency vulnerabilities
   - ESLint security rules
   - Snyk security scanning

3. **🚨 Security Gate Check**
   - Configurable thresholds for vulnerability counts
   - Blocks deployment on critical issues
   - Generates security scores

4. **🚀 Automated Deployment**
   - Infrastructure deployment with Terraform
   - Container builds and pushes to ECR
   - Kubernetes deployment

5. **📊 Monitoring & Reporting**
   - Grafana dashboard updates
   - Security summary notifications
   - Compliance tracking

## **Setup Instructions**

### **Step 1: Configure GitHub Secrets**

Add these secrets to your GitHub repository:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Bedrock Agent Configuration
BEDROCK_AGENT_ID=your_agent_id
BEDROCK_AGENT_ALIAS_ID=your_alias_id

# Container Registry
ECR_REGISTRY=your_account.dkr.ecr.region.amazonaws.com

# Security Tools (Optional)
SNYK_TOKEN=your_snyk_token

# Notification Channels (Optional)
SECURITY_TEAM_EMAIL=security@yourcompany.com
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...

# Monitoring (Optional)
GRAFANA_URL=https://grafana.yourdomain.com
GRAFANA_API_KEY=your_grafana_api_key
```

### **Step 2: Install Required Dependencies**

```bash
# Install Node.js dependencies
npm install

# Install security scanning dependencies
cd security && npm install

# Install Bedrock dependencies
cd ../bedrock && npm install
```

### **Step 3: Configure Security Thresholds**

Edit `.github/workflows/bedrock-security-pipeline.yml`:

```yaml
- name: 🚨 Security Gate Check
  run: |
    node scripts/security-gate-check.js \
      --report="security-analysis-report.json" \
      --max-critical="0"      # Block on any critical issues
      --max-high="3"          # Allow up to 3 high issues
      --max-medium="10"       # Allow up to 10 medium issues
      --max-low="50"          # Allow up to 50 low issues
```

### **Step 4: Test the Pipeline**

```bash
# Test Bedrock security analysis locally
node scripts/bedrock-security-pipeline.js \
  --repository="your-repo" \
  --branch="main" \
  --commit="HEAD" \
  --agent-id="your-agent-id" \
  --output="test-report.json"

# Test security gate check
node scripts/security-gate-check.js \
  --report="test-report.json" \
  --max-critical="0" \
  --max-high="3"

# Generate security report
node scripts/generate-security-report.js \
  --input="test-report.json" \
  --output="SECURITY-REPORT.md" \
  --format="markdown"
```

## **Pipeline Triggers**

### **🔄 Automatic Triggers**

1. **Push to Main/Develop**
   - Full security analysis
   - Automatic deployment if security gate passes

2. **Pull Request**
   - Security analysis of changed files
   - Comment with security report
   - Block merge on critical issues

3. **Scheduled (Daily)**
   - Full repository security scan
   - Security summary email/Slack notification

### **🚀 Manual Triggers**

```bash
# Trigger security analysis only
gh workflow run "Bedrock AI Security Analysis Pipeline" \
  --field trigger="security-analysis"

# Trigger deployment only (bypass security checks)
gh workflow run "Deploy to Production" \
  --field bypass-security="true"
```

## **Security Gate Configuration**

### **🎯 Thresholds**

| Severity | Default Threshold | Description |
|----------|------------------|-------------|
| Critical | 0 | Blocks deployment |
| High | 3 | Warns, allows deployment |
| Medium | 10 | Monitors, allows deployment |
| Low | 50 | Tracks, allows deployment |

### **🔧 Customizing Thresholds**

```yaml
# In your workflow file
- name: Security Gate Check
  run: |
    node scripts/security-gate-check.js \
      --report="security-analysis-report.json" \
      --max-critical="0"      # Zero tolerance for critical issues
      --max-high="1"          # Very strict high threshold
      --max-medium="5"        # Moderate medium threshold
      --max-low="25"          # Relaxed low threshold
```

## **Integration Examples**

### **🔗 API Integration**

```javascript
// Use Bedrock Agent in your applications
const { BedrockAgentRuntimeClient, InvokeAgentCommand } = require('@aws-sdk/client-bedrock-agent-runtime');

const client = new BedrockAgentRuntimeClient({ region: 'us-east-1' });

async function analyzeSecurity(code) {
    const command = new InvokeAgentCommand({
        agentId: process.env.BEDROCK_AGENT_ID,
        agentAliasId: process.env.BEDROCK_AGENT_ALIAS_ID,
        sessionId: `session-${Date.now()}`,
        inputText: `Analyze this code for security vulnerabilities: ${code}`
    });
    
    const response = await client.send(command);
    return response;
}
```

### **🔄 Pre-commit Hook**

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Running pre-commit security check..."

# Run security analysis on staged files
node scripts/bedrock-security-pipeline.js \
  --repository="$(git config --get remote.origin.url)" \
  --branch="$(git branch --show-current)" \
  --commit="HEAD" \
  --agent-id="$BEDROCK_AGENT_ID" \
  --output="pre-commit-report.json"

# Check security gate
node scripts/security-gate-check.js \
  --report="pre-commit-report.json" \
  --max-critical="0" \
  --max-high="0"

if [ $? -ne 0 ]; then
    echo "❌ Security check failed. Please fix issues before committing."
    exit 1
fi

echo "✅ Security check passed."
```

### **📱 Slack Integration**

```yaml
# Add to your workflow
- name: Notify Slack on Security Issues
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: |
      🚨 Security Gate Failed!
      Repository: ${{ github.repository }}
      Branch: ${{ github.ref }}
      Check the security report for details.
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## **Monitoring & Dashboards**

### **📊 Grafana Dashboard**

The pipeline automatically updates a Grafana dashboard with:

- Security score trends
- Vulnerability counts by severity
- Compliance status
- Top vulnerabilities
- Remediation progress

### **📧 Email Notifications**

Daily security summaries include:

- Security score
- Vulnerability breakdown
- Top issues requiring attention
- Compliance status
- Priority recommendations

### **📱 Slack Notifications**

Real-time notifications for:

- Security gate failures
- Critical vulnerability discoveries
- Deployment status
- Compliance alerts

## **Troubleshooting**

### **🔧 Common Issues**

#### **1. Bedrock Agent Not Responding**
```bash
# Check agent status
aws bedrock-agent get-agent --agent-id your-agent-id

# Verify agent is prepared
aws bedrock-agent get-agent --agent-id your-agent-id --query 'agent.status'
```

#### **2. Security Gate Failing Unexpectedly**
```bash
# Check security report
cat security-analysis-report.json | jq '.summary'

# Adjust thresholds if needed
node scripts/security-gate-check.js \
  --report="security-analysis-report.json" \
  --max-critical="0" \
  --max-high="5"  # Increase threshold
```

#### **3. Pipeline Timeout**
```yaml
# Increase timeout in workflow
jobs:
  bedrock-security-analysis:
    timeout-minutes: 30  # Increase from default 15
```

### **🔍 Debug Mode**

```bash
# Enable debug logging
export DEBUG=true
node scripts/bedrock-security-pipeline.js --debug
```

### **📋 Logs and Artifacts**

The pipeline generates several artifacts:

- `security-analysis-report.json` - Raw analysis data
- `SECURITY-REPORT.md` - Human-readable report
- `npm-audit-report.json` - Dependency vulnerabilities
- `eslint-security-report.json` - Code quality issues
- `snyk-report.json` - Snyk scan results

## **Best Practices**

### **✅ Security**

1. **Regular Updates**: Keep security tools and dependencies updated
2. **Threshold Tuning**: Adjust security thresholds based on project maturity
3. **Monitoring**: Set up alerts for security score degradation
4. **Documentation**: Document security decisions and exceptions

### **✅ Performance**

1. **Caching**: Use npm cache and Docker layer caching
2. **Parallel Jobs**: Run independent scans in parallel
3. **Incremental Analysis**: Only analyze changed files when possible
4. **Resource Limits**: Set appropriate timeouts and resource limits

### **✅ Compliance**

1. **Audit Trails**: Keep detailed logs of security decisions
2. **Approval Workflows**: Require approval for security exceptions
3. **Regular Reviews**: Schedule periodic security reviews
4. **Training**: Ensure team understands security requirements

## **Advanced Configuration**

### **🎯 Custom Security Rules**

```javascript
// Custom security analysis logic
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

### **🔄 Multi-Environment Pipeline**

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

### **📊 Custom Metrics**

```javascript
// Track custom security metrics
const metrics = {
    timeToRemediate: calculateRemediationTime(),
    securityScoreTrend: calculateScoreTrend(),
    compliancePercentage: calculateCompliance(),
    vulnerabilityDensity: calculateDensity()
};

// Send to monitoring system
await sendMetrics(metrics);
```

## **🎉 Success Metrics**

Track these KPIs to measure pipeline effectiveness:

- **Security Score**: 0-100 (target: >90)
- **Time to Detection**: Average time to find vulnerabilities
- **Time to Remediation**: Average time to fix issues
- **False Positive Rate**: Accuracy of security analysis
- **Compliance Score**: Percentage of compliance requirements met
- **Deployment Frequency**: How often secure deployments occur

## **🚀 Next Steps**

1. **Configure your Bedrock Agent** (if not already done)
2. **Set up GitHub secrets** with your AWS credentials
3. **Test the pipeline** with a small change
4. **Customize security thresholds** for your project
5. **Set up monitoring** and notifications
6. **Train your team** on the new security workflow

**Your AI-powered DevSecOps pipeline is now ready to automatically analyze and secure your deployments!** 🛡️
