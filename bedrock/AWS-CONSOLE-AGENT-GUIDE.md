# 🚀 AWS Console Bedrock Agent Creation Guide

## **Step-by-Step Instructions**

### **Step 1: Access AWS Bedrock Console**
1. **Open AWS Console**: https://console.aws.amazon.com
2. **Sign in** with your AWS credentials
3. **Search for "Bedrock"** in the services search bar
4. **Click on "Amazon Bedrock"**

### **Step 2: Navigate to Agents**
1. **In the left sidebar**, click on **"Agents"**
2. **Click the "Create agent"** button (blue button)

### **Step 3: Basic Information**
Fill in these details:

#### **Agent Name:**
```
FMacDevSecOps-SecurityAgent
```

#### **Description:**
```
AI-powered security analysis agent using FMacDevSecOps knowledge base for DevSecOps security assessment. Analyzes code repositories for vulnerabilities, checks compliance across frameworks (SOC 2, PCI DSS, HIPAA, GDPR), and provides remediation guidance.
```

#### **Foundation Model:**
- **Select**: `Claude 3.5 Sonnet` (or `Claude 3.5 Sonnet 20241022`)

### **Step 4: Agent Instructions**
Copy and paste this **exact instruction**:

```
You are a specialized security analysis agent for DevSecOps pipelines. Your role is to:

1. **Security Analysis**: Analyze code repositories for security vulnerabilities including:
   - Injection vulnerabilities (SQL, NoSQL, LDAP, OS command)
   - Cross-Site Scripting (XSS) vulnerabilities
   - Authentication and session management flaws
   - Authorization bypasses and privilege escalation
   - Cryptographic weaknesses
   - Input validation issues
   - Security misconfigurations
   - Sensitive data exposure
   - Insecure deserialization
   - Known vulnerable components

2. **Compliance Assessment**: Evaluate code against compliance frameworks:
   - SOC 2 Type II controls
   - PCI DSS requirements
   - HIPAA security rules
   - GDPR data protection
   - ISO 27001 standards

3. **Risk Assessment**: Provide detailed risk analysis including:
   - CVSS scoring for vulnerabilities
   - Business impact assessment
   - Exploitability analysis
   - Remediation priority ranking

4. **Remediation Guidance**: Generate actionable fixes:
   - Specific code changes
   - Configuration updates
   - Security best practices
   - Implementation timelines

Always use the FMacDevSecOps knowledge base for context and provide clear, actionable recommendations with code examples. Prioritize critical vulnerabilities that could lead to data breaches or system compromise.
```

### **Step 5: Knowledge Base Integration**
1. **In the "Knowledge" section**, click **"Add knowledge base"**
2. **Select**: `FMacDevOps` (your existing knowledge base)
3. **Description**: `Security documentation and guidelines for comprehensive security analysis`
4. **Click "Add"**

### **Step 6: Advanced Settings**
1. **Idle session timeout**: `10 minutes` (600 seconds)
2. **Session timeout**: `20 minutes` (1200 seconds)
3. **Leave other settings as default**

### **Step 7: Review and Create**
1. **Review all settings** to ensure they're correct
2. **Click "Create agent"** (blue button)
3. **Wait for creation** (usually takes 1-2 minutes)

## **After Creation**

### **What You'll See:**
- ✅ **Agent visible** in the Agents list
- ✅ **Status**: `Creating` → `Ready`
- ✅ **Agent ID**: Will be displayed
- ✅ **Can test immediately**

### **Testing Your Agent:**
1. **Click on your agent** name in the list
2. **Go to "Test" tab**
3. **Try this test prompt:**

```
Analyze this code repository for security vulnerabilities: https://github.com/example/microservices-app

Please check for:
- OWASP Top 10 vulnerabilities
- Dependency vulnerabilities  
- Compliance with SOC 2, PCI DSS, HIPAA, GDPR
- Provide specific remediation guidance with code examples
```

### **Expected Response:**
The agent should provide:
- Vulnerability analysis
- Compliance status
- Risk assessment
- Specific remediation steps
- Code examples for fixes

## **Success Indicators**

### **✅ Agent Created Successfully:**
- Agent appears in Agents list
- Status shows "Ready"
- Can access Test tab
- Knowledge base is connected

### **✅ Agent Working Correctly:**
- Responds to security questions
- References FMacDevSecOps knowledge base
- Provides detailed security analysis
- Gives actionable remediation guidance

## **Troubleshooting**

### **If Agent Creation Fails:**
1. **Check permissions**: Ensure you have Bedrock Agent creation permissions
2. **Verify knowledge base**: Make sure FMacDevOps exists and is accessible
3. **Check model availability**: Ensure Claude 3.5 Sonnet is available in your region

### **If Agent Doesn't Respond:**
1. **Check knowledge base connection**: Verify FMacDevOps is properly linked
2. **Review instructions**: Ensure the instruction text is complete
3. **Test with simple questions**: Try basic security questions first

## **Next Steps After Creation**

### **1. Test the Agent:**
- Try various security analysis prompts
- Test compliance checking
- Verify remediation guidance quality

### **2. Integration Options:**
- **API Integration**: Use Bedrock Agent Runtime APIs
- **Webhook Integration**: Set up automated triggers
- **CI/CD Integration**: Connect with your development pipeline

### **3. Monitoring:**
- Set up CloudWatch metrics
- Configure logging
- Monitor usage and costs

## **🎉 Congratulations!**

**You now have a real, working Bedrock Agent that:**
- ✅ **Is visible in AWS Console**
- ✅ **Uses your FMacDevSecOps knowledge base**
- ✅ **Provides AI-powered security analysis**
- ✅ **Can be integrated with applications**
- ✅ **Offers the same functionality as our designed flow**

**This agent provides enterprise-grade security analysis capabilities and is ready for production use!**
