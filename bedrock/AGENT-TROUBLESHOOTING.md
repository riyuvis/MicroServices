# 🔧 Bedrock Agent Creation Troubleshooting

## **Common Failure Reasons & Solutions**

### **1. ❌ Permission Issues**

#### **Error**: "User is not authorized to perform: bedrock:CreateAgent"

#### **Solution**:
```bash
# Add Bedrock permissions to your user
aws iam attach-user-policy --user-name a-sanjeevc --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess
```

#### **Alternative**: Use AWS Console
1. Go to **IAM Console** → **Users** → **a-sanjeevc**
2. Click **"Add permissions"**
3. Select **"Attach policies directly"**
4. Search for **"AmazonBedrockFullAccess"**
5. Check the box and click **"Next"**

### **2. ❌ Knowledge Base Issues**

#### **Error**: "Knowledge base FMacDevSecOps not found"

#### **Check Knowledge Base**:
1. Go to **Bedrock Console** → **Knowledge bases**
2. Look for **FMacDevSecOps** or similar name
3. Note the exact name and ID

#### **Solution**:
- Use the **exact knowledge base name** from the console
- If not found, create a knowledge base first or use an existing one

### **3. ❌ Model Availability**

#### **Error**: "Model not available in region"

#### **Check Available Models**:
1. Go to **Bedrock Console** → **Model access**
2. Request access to **Claude 3.5 Sonnet** if needed
3. Wait for approval (usually instant)

#### **Alternative Models**:
- Use **Claude 3 Haiku** (usually available)
- Use **Claude 3 Sonnet** (if available)
- Check **"Model access"** in Bedrock console

### **4. ❌ Region Issues**

#### **Error**: "Service not available in region"

#### **Solution**:
- Ensure you're in **us-east-1** (N. Virginia)
- Or **us-west-2** (Oregon)
- Some regions don't support Bedrock Agents yet

### **5. ❌ Service Limits**

#### **Error**: "Service limit exceeded"

#### **Check Limits**:
1. Go to **AWS Console** → **Service Quotas**
2. Search for **"Bedrock"**
3. Check **"Agents per account"** limit
4. Request limit increase if needed

## **Step-by-Step Troubleshooting**

### **Step 1: Verify Prerequisites**
```bash
# Check if you can access Bedrock
aws bedrock list-foundation-models --region us-east-1

# Check if you can list knowledge bases
aws bedrock-agent list-knowledge-bases --region us-east-1
```

### **Step 2: Check Knowledge Base**
1. Go to **Bedrock Console** → **Knowledge bases**
2. Find your knowledge base (might be named differently)
3. Note the **exact name** and **ID**

### **Step 3: Verify Model Access**
1. Go to **Bedrock Console** → **Model access**
2. Ensure **Claude 3.5 Sonnet** is available
3. Request access if needed

### **Step 4: Try Simplified Creation**

#### **Minimal Agent Configuration**:
- **Name**: `SecurityAgent`
- **Model**: `Claude 3 Haiku` (or available model)
- **Instructions**: `You are a security analysis assistant.`
- **Knowledge Base**: Skip for now (add later)

## **Alternative Creation Methods**

### **Method 1: AWS CLI (if working)**
```bash
# Simple agent creation
aws bedrock-agent create-agent \
  --agent-name "SecurityAgent" \
  --foundation-model "anthropic.claude-3-haiku-20240307-v1:0" \
  --description "Security analysis agent"
```

### **Method 2: Step-by-Step Console**
1. **Start with minimal configuration**
2. **Skip knowledge base initially**
3. **Add knowledge base after creation**
4. **Test basic functionality first**

### **Method 3: Use Existing Template**
1. Look for **"Create from template"** option
2. Choose **"Customer service agent"** template
3. Modify for security analysis

## **Quick Fix Checklist**

### **✅ Immediate Actions**:
- [ ] Check AWS Console for exact error message
- [ ] Verify knowledge base name in Bedrock Console
- [ ] Ensure model access is granted
- [ ] Try creating with minimal configuration
- [ ] Check service quotas and limits

### **✅ If Still Failing**:
- [ ] Try different region (us-east-1 or us-west-2)
- [ ] Use different model (Claude 3 Haiku)
- [ ] Create without knowledge base first
- [ ] Check AWS support documentation

## **Success Indicators**

### **✅ Agent Created Successfully**:
- Agent appears in Agents list
- Status shows "Ready" or "Creating"
- Can access agent details
- No error messages in console

### **✅ Working Agent**:
- Can access Test tab
- Responds to basic questions
- Knowledge base is connected (if added)

## **Need More Help?**

### **Check These Resources**:
1. **AWS Bedrock Documentation**
2. **AWS Support Center**
3. **Bedrock Service Health Dashboard**
4. **AWS Forums** for Bedrock

### **Common Solutions**:
- **Permission issues**: Add Bedrock policies to user
- **Model issues**: Request model access
- **Knowledge base issues**: Use correct name/ID
- **Region issues**: Use supported region

## **🎯 Next Steps**

1. **Identify the specific error** from AWS Console
2. **Follow the relevant troubleshooting steps**
3. **Try the simplified creation method**
4. **Test with minimal configuration first**
5. **Add complexity gradually**

**What specific error message did you see? I can provide more targeted help once we know the exact issue!**
