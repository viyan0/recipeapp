const EmailService = require('./services/emailService');

// Load environment variables
require('dotenv').config({ path: __dirname + '/config.env' });

async function testEmailService() {
  console.log('🧪 Testing Email Service Integration...\n');
  
  // Check configuration
  console.log('📋 Configuration Check:');
  console.log(`   Resend API Key: ${process.env.RESEND_API_KEY ? '✅ Configured' : '❌ Missing'}`);
  console.log(`   From Email: ${process.env.RESEND_FROM_EMAIL || '❌ Not set'}`);
  console.log('');
  
  if (!process.env.RESEND_API_KEY) {
    console.log('❌ RESEND_API_KEY not found in config.env');
    console.log('   Please add your Resend API key to the config.env file');
    return;
  }
  
  if (!process.env.RESEND_FROM_EMAIL) {
    console.log('❌ RESEND_FROM_EMAIL not found in config.env');
    console.log('   Please add your Resend from email to the config.env file');
    return;
  }
  
  // Test email service
  console.log('📧 Testing Email Service...');
  
  // Replace with your actual email address for testing
  const testEmail = 'your-email@example.com'; // CHANGE THIS TO YOUR EMAIL
  
  if (testEmail === 'your-email@example.com') {
    console.log('⚠️  Please update the testEmail variable in this script with your actual email address');
    console.log('   Then run: node test-email.js');
    return;
  }
  
  try {
    console.log(`   Sending test email to: ${testEmail}`);
    
    const result = await EmailService.sendTestEmail(testEmail);
    
    if (result.success) {
      console.log('✅ Test email sent successfully!');
      console.log('   Check your email inbox for the test message');
      console.log(`   Resend Response:`, result.data);
    } else {
      console.log('❌ Failed to send test email:');
      console.log(`   Error: ${result.error}`);
    }
  } catch (error) {
    console.log('❌ Error testing email service:');
    console.log(`   ${error.message}`);
  }
  
  console.log('\n🔗 You can also test the email endpoints via HTTP:');
  console.log(`   GET  http://localhost:3000/api/email/status`);
  console.log(`   POST http://localhost:3000/api/email/test`);
  console.log(`   POST http://localhost:3000/api/email/welcome`);
  console.log(`   POST http://localhost:3000/api/email/custom`);
}

// Run the test
testEmailService().catch(console.error);
