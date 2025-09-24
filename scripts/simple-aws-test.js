// Simple AWS Credentials Test
console.log('🔐 Testing AWS Credentials...');
console.log('📍 AWS_ACCESS_KEY_ID:', process.env.AWS_ACCESS_KEY_ID ? '✅ Set' : '❌ Not set');
console.log('📍 AWS_SECRET_ACCESS_KEY:', process.env.AWS_SECRET_ACCESS_KEY ? '✅ Set' : '❌ Not set');
console.log('📍 AWS_DEFAULT_REGION:', process.env.AWS_DEFAULT_REGION || 'Not set');

if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
    console.log('✅ AWS credentials are configured!');
    console.log('🚀 Ready to test with security scan...');
} else {
    console.log('❌ AWS credentials are missing!');
    console.log('💡 Please set the environment variables first.');
}
