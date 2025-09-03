const { Resend } = require('resend');

// Initialize Resend with API key
const resend = new Resend(process.env.RESEND_API_KEY);

class EmailService {
  /**
   * Send a simple email
   * @param {string} to - Recipient email address
   * @param {string} subject - Email subject
   * @param {string} htmlContent - HTML content of the email
   * @param {string} textContent - Plain text content (optional)
   * @returns {Promise<Object>} - Resend API response
   */
  static async sendEmail(to, subject, htmlContent, textContent = null) {
    try {
      const emailData = {
        from: process.env.RESEND_FROM_EMAIL,
        to: [to],
        subject: subject,
        html: htmlContent,
      };

      // Add text content if provided
      if (textContent) {
        emailData.text = textContent;
      }

      const response = await resend.emails.send(emailData);
      console.log('Email sent successfully:', response);
      return { success: true, data: response };
    } catch (error) {
      console.error('Error sending email:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send a welcome email to new users
   * @param {string} to - Recipient email address
   * @param {string} username - User's username
   * @returns {Promise<Object>} - Email send result
   */
  static async sendWelcomeEmail(to, username) {
    const subject = 'Welcome to Recipe App!';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #2c3e50; text-align: center;">Welcome to Recipe App! 🍳</h1>
        <p>Hi ${username},</p>
        <p>Thank you for joining our recipe community! We're excited to have you on board.</p>
        <p>With Recipe App, you can:</p>
        <ul>
          <li>Discover delicious recipes from around the world</li>
          <li>Save your favorite recipes</li>
          <li>Share cooking tips with other food lovers</li>
          <li>Create your own recipe collections</li>
        </ul>
        <p>Start exploring now and happy cooking!</p>
        <br>
        <p>Best regards,<br>The Recipe App Team</p>
      </div>
    `;

    const textContent = `Welcome to Recipe App! Hi ${username}, thank you for joining our recipe community. We're excited to have you on board. Start exploring now and happy cooking!`;

    return await this.sendEmail(to, subject, htmlContent, textContent);
  }

  /**
   * Send a password reset email
   * @param {string} to - Recipient email address
   * @param {string} resetToken - Password reset token
   * @param {string} resetUrl - Password reset URL
   * @returns {Promise<Object>} - Email send result
   */
  static async sendPasswordResetEmail(to, resetToken, resetUrl) {
    const subject = 'Password Reset Request - Recipe App';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #e74c3c; text-align: center;">Password Reset Request</h1>
        <p>You requested a password reset for your Recipe App account.</p>
        <p>Click the button below to reset your password:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetUrl}" style="background-color: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">Reset Password</a>
        </div>
        <p>If the button doesn't work, copy and paste this link into your browser:</p>
        <p style="word-break: break-all; color: #7f8c8d;">${resetUrl}</p>
        <p>This link will expire in 1 hour for security reasons.</p>
        <p>If you didn't request this reset, please ignore this email.</p>
        <br>
        <p>Best regards,<br>The Recipe App Team</p>
      </div>
    `;

    const textContent = `Password Reset Request - You requested a password reset for your Recipe App account. Click this link to reset your password: ${resetUrl}. This link will expire in 1 hour. If you didn't request this reset, please ignore this email.`;

    return await this.sendEmail(to, subject, htmlContent, textContent);
  }

  /**
   * Send an email verification email with OTP code
   * @param {string} to - Recipient email address
   * @param {string} username - User's username
   * @param {string} otpCode - 6-digit OTP verification code
   * @returns {Promise<Object>} - Email send result
   */
  static async sendEmailVerification(to, username, otpCode) {
    const subject = 'Verify your email address';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <p>Hey ${to}</p>
        <br>
        <p>welcome to Recipe app, to complete your signup, please use the following verification code:</p>
        <br>
        <div style="text-align: center; margin: 30px 0; padding: 20px; background-color: #f8f9fa; border-radius: 10px; border: 2px solid #27ae60;">
          <div style="font-size: 36px; font-weight: bold; color: #2c3e50; letter-spacing: 8px; margin: 15px 0; font-family: 'Courier New', monospace;">
            ${otpCode}
          </div>
        </div>
        <br>
        <p>This code will expire in 5 minutes.</p>
        <br>
        <p>Thank you,</p>
        <br>
      </div>
    `;

    const textContent = `Hey ${to}, welcome to Recipe app, to complete your signup, please use the following verification code: ${otpCode}. This code will expire in 5 minutes. Thank you,`;

    return await this.sendEmail(to, subject, htmlContent, textContent);
  }

  /**
   * Send a test email for testing purposes
   * @param {string} to - Recipient email address
   * @returns {Promise<Object>} - Email send result
   */
  static async sendTestEmail(to) {
    const subject = 'Test Email from Recipe App Backend';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #27ae60; text-align: center;">✅ Test Email Successful!</h1>
        <p>This is a test email to verify that your Resend integration is working correctly.</p>
        <p><strong>Timestamp:</strong> ${new Date().toLocaleString()}</p>
        <p><strong>Recipient:</strong> ${to}</p>
        <p><strong>From:</strong> ${process.env.RESEND_FROM_EMAIL}</p>
        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <p style="margin: 0;"><strong>Configuration Status:</strong></p>
          <ul style="margin: 10px 0;">
            <li>✅ Resend API Key: Configured</li>
            <li>✅ From Email: ${process.env.RESEND_FROM_EMAIL}</li>
            <li>✅ Email Service: Active</li>
          </ul>
        </div>
        <p>If you received this email, congratulations! Your email integration is working perfectly.</p>
        <br>
        <p>Best regards,<br>Recipe App Backend</p>
      </div>
    `;

    const textContent = `Test Email Successful! This is a test email to verify that your Resend integration is working correctly. Timestamp: ${new Date().toLocaleString()}, Recipient: ${to}, From: ${process.env.RESEND_FROM_EMAIL}. If you received this email, congratulations! Your email integration is working perfectly.`;

    return await this.sendEmail(to, subject, htmlContent, textContent);
  }

  /**
   * Send a recipe sharing email
   * @param {string} to - Recipient email address
   * @param {string} fromUsername - Sender's username
   * @param {string} recipeTitle - Title of the shared recipe
   * @param {string} recipeUrl - URL to view the recipe
   * @returns {Promise<Object>} - Email send result
   */
  static async sendRecipeShareEmail(to, fromUsername, recipeTitle, recipeUrl) {
    const subject = `${fromUsername} shared a recipe with you!`;
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #e67e22; text-align: center;">🍽️ Recipe Shared!</h1>
        <p>Hi there!</p>
        <p><strong>${fromUsername}</strong> thought you might like this recipe:</p>
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;">
          <h2 style="color: #2c3e50; margin: 0 0 10px 0;">${recipeTitle}</h2>
          <a href="${recipeUrl}" style="background-color: #e67e22; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">View Recipe</a>
        </div>
        <p>Check it out and let them know what you think!</p>
        <br>
        <p>Happy cooking!<br>The Recipe App Team</p>
      </div>
    `;

    const textContent = `Recipe Shared! ${fromUsername} thought you might like this recipe: ${recipeTitle}. Check it out at: ${recipeUrl}. Happy cooking!`;

    return await this.sendEmail(to, subject, htmlContent, textContent);
  }
}

module.exports = EmailService;
