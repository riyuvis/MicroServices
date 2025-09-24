// Test AWS Credentials
const { BedrockRuntimeClient } = require('@aws-sdk/client-bedrock-runtime');

async function testAWSCredentials() {
    try {
        console.log('🔐 Testing AWS Credentials...');
        console.log('📍 Region:', process.env.AWS_DEFAULT_REGION || 'us-east-1');
        
        // Initialize Bedrock client
        const client = new BedrockRuntimeClient({
            region: process.env.AWS_DEFAULT_REGION || 'us-east-1'
        });
        
        console.log('✅ AWS Bedrock client initialized successfully!');
        
        // Test basic Bedrock access
        console.log('🔍 Testing Bedrock access...');
        
        const command = {
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
            contentType: 'application/json',
            accept: 'application/json',
            body: JSON.stringify({
                anthropic_version: 'bedrock-2023-05-31',
                max_tokens: 10,
                temperature: 0.1,
                messages: [{
                    role: 'user',
                    content: 'Hello'
                }]
            })
        };
        
        const response = await client.send(command);
        console.log('✅ Bedrock API access confirmed!');
        console.log('🎉 AWS credentials are working correctly!');
        
        return true;
    } catch (error) {
        console.error('❌ AWS credentials test failed:');
        console.error('Error:', error.message);
        
        if (error.name === 'CredentialsProviderError') {
            console.log('\n💡 Troubleshooting:');
            console.log('- Check if AWS_ACCESS_KEY_ID is set');
            console.log('- Check if AWS_SECRET_ACCESS_KEY is set');
            console.log('- Verify the credentials are valid');
        } else if (error.name === 'UnauthorizedOperation') {
            console.log('\n💡 Troubleshooting:');
            console.log('- Check if your AWS user has Bedrock permissions');
            console.log('- Request access to Bedrock models in AWS console');
        }
        
        return false;
    }
}

// Run the test
testAWSCredentials().then(success => {
    if (success) {
        console.log('\n🚀 Ready to proceed with DevSecOps deployment!');
    } else {
        console.log('\n⚠️  Please fix AWS credentials before proceeding.');
    }
    process.exit(success ? 0 : 1);
});
