# Resend Email Integration

## Overview
Your Recipe App now includes complete Resend email integration for sending transactional emails. This setup allows you to send various types of emails including welcome emails, password resets, email verification, and recipe sharing.

## Configuration
The integration is configured in your environment variables:

```
RESEND_API_KEY=re_WopcNpbo_3dQS1QZF5mZuNgDXGLb1nVD6
RESEND_FROM_EMAIL=onboarding@resend.dev
```

### Security Notes
- ✅ API key is stored securely in environment variables
- ✅ Not hardcoded in source code
- ✅ Uses the default Resend domain for sending

## Default Domain Limitations
**Important**: With the default Resend domain (`onboarding@resend.dev`), you can only send emails to your verified email address: `viyanfarooq0@gmail.com`

To send emails to other recipients, you would need to:
1. Verify a custom domain at [resend.com/domains](https://resend.com/domains)
2. Update the `RESEND_FROM_EMAIL` to use your verified domain

## Available Email Services

### 1. Test Email
- **Purpose**: Verify integration is working
- **Endpoint**: `POST /api/email/test`
- **Usage**: `EmailService.sendTestEmail(to)`

### 2. Welcome Email
- **Purpose**: Welcome new users after registration
- **Endpoint**: `POST /api/email/welcome`
- **Usage**: `EmailService.sendWelcomeEmail(to, username)`

### 3. Password Reset Email
- **Purpose**: Send password reset links
- **Endpoint**: `POST /api/email/password-reset`
- **Usage**: `EmailService.sendPasswordResetEmail(to, resetToken, resetUrl)`

### 4. Email Verification
- **Purpose**: Verify user email addresses
- **Usage**: `EmailService.sendEmailVerification(to, username, verificationToken, verificationUrl)`

### 5. Recipe Sharing
- **Purpose**: Share recipes between users
- **Endpoint**: `POST /api/email/share-recipe`
- **Usage**: `EmailService.sendRecipeShareEmail(to, fromUsername, recipeTitle, recipeUrl)`

### 6. Custom Email
- **Purpose**: Send custom emails with your own content
- **Endpoint**: `POST /api/email/custom`
- **Usage**: `EmailService.sendEmail(to, subject, htmlContent, textContent)`

## Email Service Status
Check the service status at: `GET /api/email/status`

## Testing the Integration

### Method 1: Using the Test Endpoint
```bash
curl -X POST http://localhost:3000/api/email/test \
  -H "Content-Type: application/json" \
  -d '{"to": "viyanfarooq0@gmail.com"}'
```

### Method 2: Using the Email Service Directly
```javascript
const EmailService = require('./services/emailService');

// Send a test email
EmailService.sendTestEmail('viyanfarooq0@gmail.com')
  .then(result => console.log(result))
  .catch(error => console.error(error));
```

## Email Templates
All emails use responsive HTML templates with:
- Professional styling
- Brand colors for Recipe App
- Mobile-friendly design
- Both HTML and plain text versions
- Proper email best practices

## API Examples

### Send Welcome Email
```javascript
const result = await EmailService.sendWelcomeEmail(
  'viyanfarooq0@gmail.com', 
  'John Doe'
);
```

### Send Password Reset
```javascript
const result = await EmailService.sendPasswordResetEmail(
  'viyanfarooq0@gmail.com',
  'reset-token-123',
  'https://yourapp.com/reset?token=reset-token-123'
);
```

### Send Custom Email
```javascript
const result = await EmailService.sendEmail(
  'viyanfarooq0@gmail.com',
  'Your Subject',
  '<h1>Hello World</h1>',
  'Hello World'
);
```

## Next Steps
To enable sending emails to any recipient:
1. Visit [resend.com/domains](https://resend.com/domains)
2. Add and verify your custom domain
3. Update `RESEND_FROM_EMAIL` in your config.env to use your domain
4. Test with external email addresses

## Files Modified/Created
- ✅ `services/emailService.js` - Main email service
- ✅ `routes/email.js` - Email API endpoints
- ✅ `config.env` - Environment configuration
- ✅ `package.json` - Added Resend dependency
- ✅ `server.js` - Integrated email routes

The integration is complete and ready to use!
