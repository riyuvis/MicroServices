# ✅ Bedrock Agent Creation Checklist

## **Pre-Creation Checklist**

### **✅ AWS Access:**
- [ ] AWS Console access confirmed
- [ ] Bedrock service accessible in your region
- [ ] FMacDevSecOps knowledge base exists and accessible

### **✅ Required Information Ready:**
- [ ] Agent name: `FMacDevSecOps-SecurityAgent`
- [ ] Description text ready
- [ ] Instruction text ready (copied from guide)
- [ ] Knowledge base name: `FMacDevOps`

## **Creation Steps Checklist**

### **✅ Step 1: Navigate to Bedrock**
- [ ] Open AWS Console
- [ ] Search for "Bedrock"
- [ ] Click on Amazon Bedrock service

### **✅ Step 2: Access Agents**
- [ ] Click "Agents" in left sidebar
- [ ] Click "Create agent" button

### **✅ Step 3: Basic Information**
- [ ] Agent name: `FMacDevSecOps-SecurityAgent`
- [ ] Description: Security analysis agent description
- [ ] Foundation model: `Claude 3.5 Sonnet`

### **✅ Step 4: Instructions**
- [ ] Copy instruction text from guide
- [ ] Paste into instructions field
- [ ] Verify text is complete

### **✅ Step 5: Knowledge Base**
- [ ] Click "Add knowledge base"
- [ ] Select `FMacDevOps`
- [ ] Add description
- [ ] Click "Add"

### **✅ Step 6: Advanced Settings**
- [ ] Idle timeout: 10 minutes
- [ ] Session timeout: 20 minutes
- [ ] Other settings: default

### **✅ Step 7: Create**
- [ ] Review all settings
- [ ] Click "Create agent"
- [ ] Wait for creation (1-2 minutes)

## **Post-Creation Checklist**

### **✅ Verification:**
- [ ] Agent appears in Agents list
- [ ] Status shows "Ready"
- [ ] Agent ID is displayed
- [ ] Knowledge base is connected

### **✅ Testing:**
- [ ] Click on agent name
- [ ] Go to "Test" tab
- [ ] Try test prompt
- [ ] Verify response quality
- [ ] Check knowledge base integration

### **✅ Success Indicators:**
- [ ] Agent responds to security questions
- [ ] References FMacDevSecOps knowledge base
- [ ] Provides detailed security analysis
- [ ] Gives actionable remediation guidance

## **Test Prompts to Try**

### **✅ Basic Security Test:**
```
What are the OWASP Top 10 security vulnerabilities?
```

### **✅ Compliance Test:**
```
What are the key requirements for SOC 2 compliance?
```

### **✅ Analysis Test:**
```
Analyze this code for security vulnerabilities: 
function login(username, password) {
    const query = "SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'";
    return database.query(query);
}
```

### **✅ Knowledge Base Test:**
```
Using the FMacDevSecOps knowledge base, provide guidance on securing microservices architecture.
```

## **Expected Results**

### **✅ Successful Agent Should:**
- Respond with detailed security information
- Reference knowledge base content
- Provide specific code examples
- Give actionable recommendations
- Show understanding of compliance frameworks

## **If Something Goes Wrong**

### **✅ Common Issues:**
- [ ] **Agent creation fails**: Check permissions
- [ ] **Knowledge base not found**: Verify FMacDevOps exists
- [ ] **Model not available**: Check region support
- [ ] **Agent doesn't respond**: Check instruction text
- [ ] **Poor responses**: Verify knowledge base connection

### **✅ Troubleshooting Steps:**
1. Check agent status and logs
2. Verify knowledge base connection
3. Test with simpler prompts
4. Review instruction text
5. Check AWS service limits

## **🎉 Success!**

**When all checkboxes are marked, you have:**
- ✅ A working Bedrock Agent visible in AWS Console
- ✅ Integration with FMacDevSecOps knowledge base
- ✅ AI-powered security analysis capabilities
- ✅ Production-ready security assessment tool

**Your DevSecOps security analysis system is now live and operational!**
