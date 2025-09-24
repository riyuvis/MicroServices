# AWS Bedrock DevSecOps Flow Guide

## 🚀 Overview

This guide explains how to create and manage AWS Bedrock flows for DevSecOps security analysis. The Bedrock flow automates security vulnerability detection, compliance checking, and remediation guidance using AI-powered analysis.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 DevSecOps Pipeline                      │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   GitHub    │───▶│  Bedrock    │───▶│  Security   │  │
│  │ Repository  │    │   Flow      │    │   Report    │  │
│  └─────────────┘    └─────────────┘    └─────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│              Bedrock Flow Components                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Knowledge   │  │  Security   │  │  Claude 3   │     │
│  │    Base     │  │   Agent     │  │   Sonnet    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ OpenSearch  │  │ S3 Storage  │  │   Lambda    │     │
│  │ Serverless  │  │             │  │ Functions   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Components

### 1. **Bedrock Flow**
- **Purpose**: Orchestrates the security analysis workflow
- **Model**: Claude 3.5 Sonnet for advanced reasoning
- **Features**: Multi-step analysis, error handling, retry logic

### 2. **Security Agent**
- **Purpose**: Specialized AI agent for security analysis
- **Capabilities**: Vulnerability detection, compliance checking, remediation guidance
- **Knowledge**: OWASP Top 10, compliance frameworks, security best practices

### 3. **Knowledge Base**
- **Purpose**: Stores security documentation and guidelines
- **Storage**: OpenSearch Serverless for vector search
- **Content**: OWASP guidelines, compliance frameworks, remediation patterns

### 4. **Supporting Infrastructure**
- **S3 Bucket**: Document storage for knowledge base
- **Lambda Functions**: Action groups for specific tasks
- **SNS Topic**: Security alert notifications
- **IAM Roles**: Secure access control

## 📋 Flow Steps

### Step 1: Security Scan Trigger
```json
{
  "name": "security-scan-trigger",
  "type": "Task",
  "resource": "claude-3-5-sonnet",
  "parameters": {
    "prompt": "Analyze the incoming code repository for security vulnerabilities..."
  }
}
```

### Step 2: Vulnerability Analysis
- Categorize vulnerabilities by severity (Critical, High, Medium, Low)
- Provide specific remediation steps
- Generate code examples for fixes

### Step 3: Compliance Check
- Evaluate against SOC 2, PCI DSS, HIPAA, GDPR
- Identify compliance violations
- Provide remediation guidance

### Step 4: Remediation Generation
- Generate specific code fixes
- Provide configuration updates
- Create implementation timelines

### Step 5: Security Report
- Executive summary with risk score
- Detailed findings with CVSS scores
- Prioritized remediation roadmap

### Step 6: Notification
- Send alerts to security team
- Update monitoring dashboards
- Log results for audit

## 🚀 Setup Instructions

### Prerequisites
- AWS CLI configured with appropriate permissions
- Node.js 18+ installed
- Terraform installed (optional, for infrastructure)

### Quick Setup
```bash
# 1. Set AWS credentials
$env:AWS_ACCESS_KEY_ID='your-access-key'
$env:AWS_SECRET_ACCESS_KEY='your-secret-key'
$env:AWS_DEFAULT_REGION='us-east-1'

# 2. Run setup script
.\bedrock\scripts\setup-bedrock-environment.ps1

# 3. Test the flow
node bedrock\scripts\create-bedrock-flow.js test
```

### Manual Setup
```bash
# 1. Install dependencies
cd bedrock
npm install

# 2. Deploy infrastructure (optional)
cd terraform
terraform init
terraform apply

# 3. Create Bedrock resources
cd ..
node scripts/create-bedrock-flow.js setup
```

## 🔍 Usage Examples

### Basic Security Analysis
```javascript
const bedrockFlow = new BedrockFlowManager();

const result = await bedrockFlow.testSecurityFlow(
  'https://github.com/company/application'
);

console.log('Vulnerabilities:', result.vulnerabilities);
console.log('Compliance:', result.compliance);
```

### Custom Analysis
```javascript
const analysisParams = {
  repositoryUrl: 'https://github.com/company/app',
  branch: 'main',
  scanType: 'full',
  complianceFrameworks: ['SOC2', 'PCI-DSS']
};

const result = await bedrockFlow.analyzeSecurity(analysisParams);
```

### Integration with CI/CD
```yaml
# GitHub Actions example
- name: Security Analysis
  run: |
    node bedrock/scripts/create-bedrock-flow.js test ${{ github.repository }}
```

## 📊 Output Format

### Security Analysis Result
```json
{
  "scanId": "scan-12345",
  "timestamp": "2024-01-19T16:00:00Z",
  "vulnerabilities": {
    "critical": 2,
    "high": 5,
    "medium": 8,
    "low": 3
  },
  "compliance": {
    "SOC2": "COMPLIANT",
    "PCI_DSS": "PARTIAL",
    "HIPAA": "NON_COMPLIANT"
  },
  "remediation": [
    {
      "vulnerabilityId": "CVE-2024-1234",
      "fix": "Update dependency to version 2.1.0",
      "priority": "IMMEDIATE"
    }
  ],
  "reportUrl": "https://s3.amazonaws.com/bucket/security-report.pdf"
}
```

## 🛡️ Security Features

### Vulnerability Detection
- **SAST Analysis**: Static code analysis for security flaws
- **Dependency Scanning**: Check for known vulnerabilities in dependencies
- **Secret Detection**: Identify hardcoded credentials and API keys
- **Configuration Review**: Security misconfigurations

### Compliance Checking
- **SOC 2 Type II**: Security, availability, processing integrity
- **PCI DSS**: Payment card industry data security
- **HIPAA**: Healthcare information protection
- **GDPR**: General data protection regulation

### Risk Assessment
- **CVSS Scoring**: Common Vulnerability Scoring System
- **Business Impact**: Risk to business operations
- **Exploitability**: Likelihood of exploitation
- **Remediation Priority**: Action timeline

## 🔧 Configuration

### Environment Variables
```bash
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
BEDROCK_KNOWLEDGE_BASE_ID=your-kb-id
BEDROCK_AGENT_ID=your-agent-id
```

### Flow Parameters
```json
{
  "maxTokens": 4000,
  "temperature": 0.1,
  "retryAttempts": 3,
  "timeoutSeconds": 300
}
```

## 📈 Monitoring and Alerts

### CloudWatch Metrics
- Flow execution duration
- Success/failure rates
- Token usage
- Error rates

### SNS Notifications
- Security alerts for critical vulnerabilities
- Compliance violations
- Flow execution failures
- Cost threshold breaches

### Dashboards
- Real-time security metrics
- Compliance status
- Vulnerability trends
- Remediation progress

## 💰 Cost Optimization

### Token Usage
- Optimize prompts for efficiency
- Use appropriate model sizes
- Implement caching for repeated analyses

### Infrastructure Costs
- Use OpenSearch Serverless for vector storage
- Implement S3 lifecycle policies
- Monitor Lambda execution time

### Best Practices
- Schedule non-critical scans during off-peak hours
- Use incremental scans for frequent updates
- Implement result caching for unchanged code

## 🚨 Troubleshooting

### Common Issues

#### Flow Execution Fails
```bash
# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix /aws/bedrock

# Verify IAM permissions
aws iam get-role --role-name BedrockDevSecOpsExecutionRole
```

#### Knowledge Base Sync Issues
```bash
# Check data source status
aws bedrockagent get-data-source --knowledge-base-id kb-id --data-source-id ds-id

# Verify S3 bucket permissions
aws s3api get-bucket-policy --bucket your-bucket-name
```

#### Agent Response Issues
```bash
# Test agent directly
aws bedrockagent-runtime invoke-agent \
  --agent-id your-agent-id \
  --session-id test-session \
  --input-text "Analyze this code for vulnerabilities"
```

### Support Resources
- AWS Bedrock Documentation
- CloudWatch Logs for debugging
- AWS Support for service issues
- Community forums for best practices

## 🔄 Maintenance

### Regular Tasks
- Update knowledge base with new security guidelines
- Review and optimize flow prompts
- Monitor cost usage and optimize
- Update compliance frameworks

### Version Management
- Version control for flow definitions
- Backup knowledge base content
- Document changes and improvements
- Test updates in development environment

## 📚 Additional Resources

- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SOC 2 Compliance Guide](https://aws.amazon.com/compliance/soc-faqs/)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/)
- [HIPAA Compliance](https://aws.amazon.com/compliance/hipaa-compliance/)
