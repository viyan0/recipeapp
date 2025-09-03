# 📧 Email Integration with Resend

This document explains how to use the email integration in your Recipe App backend.

## 🚀 Quick Start

### 1. Configuration
Your Resend API key is already configured in `config.env`:
```
RESEND_API_KEY=re_WopcNpbo_3dQS1QZF5mZuNgDXGLb1nVD6
RESEND_FROM_EMAIL=onboarding@resend.dev
```

### 2. Test the Integration
Run the test script to verify everything works:
```bash
cd backend
node test-email.js
```

**Important**: Update the `testEmail` variable in `test-email.js` with your actual email address first!

### 3. Use the Web Interface
Open `test-email.html` in your browser to test all email endpoints with a user-friendly interface.

## 📋 Available Email Types

### 1. Test Email
- **Endpoint**: `POST /api/email/test`
- **Purpose**: Verify Resend integration is working
- **Body**: `{ "to": "user@example.com" }`

### 2. Welcome Email
- **Endpoint**: `POST /api/email/welcome`
- **Purpose**: Send welcome emails to new users
- **Body**: `{ "to": "user@example.com", "username": "JohnDoe" }`

### 3. Password Reset Email
- **Endpoint**: `POST /api/email/password-reset`
- **Purpose**: Send password reset links
- **Body**: `{ "to": "user@example.com", "resetToken": "abc123", "resetUrl": "https://..." }`

### 4. Recipe Share Email
- **Endpoint**: `POST /api/email/share-recipe`
- **Purpose**: Share recipes with other users
- **Body**: `{ "to": "friend@example.com", "fromUsername": "JohnDoe", "recipeTitle": "Pasta Carbonara", "recipeUrl": "https://..." }`

### 5. Custom Email
- **Endpoint**: `POST /api/email/custom`
- **Purpose**: Send custom emails with your own content
- **Body**: `{ "to": "user@example.com", "subject": "Custom Subject", "htmlContent": "<h1>Hello</h1>", "textContent": "Hello" }`

### 6. Service Status
- **Endpoint**: `GET /api/email/status`
- **Purpose**: Check email service configuration and status

## 🧪 Testing

### Method 1: Command Line
```bash
cd backend
node test-email.js
```

### Method 2: Web Interface
1. Start your backend server: `npm start`
2. Open `test-email.html` in your browser
3. Test all email endpoints with the interactive forms

### Method 3: HTTP Requests
```bash
# Check status
curl http://localhost:3000/api/email/status

# Send test email
curl -X POST http://localhost:3000/api/email/test \
  -H "Content-Type: application/json" \
  -d '{"to": "your-email@example.com"}'
```

## 🔧 Integration Examples

### In Your Auth Routes
```javascript
const EmailService = require('../services/emailService');

// Send welcome email after user registration
app.post('/register', async (req, res) => {
  // ... user creation logic ...
  
  // Send welcome email
  await EmailService.sendWelcomeEmail(user.email, user.username);
  
  res.json({ success: true, message: 'User registered successfully' });
});
```

### In Your Recipe Routes
```javascript
// Share recipe via email
app.post('/recipes/:id/share', async (req, res) => {
  const { to, fromUsername } = req.body;
  const recipe = await getRecipe(req.params.id);
  
  await EmailService.sendRecipeShareEmail(
    to, 
    fromUsername, 
    recipe.title, 
    `https://yourapp.com/recipes/${recipe.id}`
  );
  
  res.json({ success: true, message: 'Recipe shared successfully' });
});
```

## 📧 Email Templates

The email service includes pre-built templates for:
- ✅ Welcome emails with app features
- ✅ Password reset with secure links
- ✅ Recipe sharing with beautiful formatting
- ✅ Test emails for verification

All emails are sent from `onboarding@resend.dev` (Resend's default domain).

## 🚨 Error Handling

The email service includes comprehensive error handling:
- API key validation
- Email format validation
- Resend API error handling
- Detailed error messages for debugging

## 🔒 Security Features

- Input validation and sanitization
- Rate limiting (inherited from main server)
- CORS protection
- Environment variable configuration

## 📊 Monitoring

Check email service status:
```bash
curl http://localhost:3000/api/email/status
```

Response includes:
- Service configuration status
- Available endpoints
- Timestamp information

## 🐛 Troubleshooting

### Common Issues

1. **"API Key Invalid"**
   - Verify your Resend API key in `config.env`
   - Check if the key has proper permissions

2. **"From Email Not Configured"**
   - Ensure `RESEND_FROM_EMAIL` is set in `config.env`
   - Default: `onboarding@resend.dev`

3. **"CORS Error"**
   - Verify your backend is running on port 3000
   - Check CORS configuration in `server.js`

4. **"Email Not Received"**
   - Check spam/junk folder
   - Verify recipient email address
   - Check Resend dashboard for delivery status

### Debug Mode
Enable detailed logging by setting `NODE_ENV=development` in your environment.

## 📚 Additional Resources

- [Resend Documentation](https://resend.com/docs)
- [Resend Dashboard](https://resend.com/emails)
- [Email Templates](https://resend.com/templates)

## 🎯 Next Steps

1. **Test the integration** with your own email
2. **Customize email templates** in `services/emailService.js`
3. **Integrate with your app logic** (user registration, password reset, etc.)
4. **Monitor email delivery** through Resend dashboard
5. **Set up custom domain** when ready for production

---

**Happy emailing! 📧✨**
