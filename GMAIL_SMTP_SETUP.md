# 📧 How to Configure Custom Email OTP & 6-Digit OTP Length in Supabase

This guide explains how to ensure Supabase Auth sends **6-digit OTP codes** and applies the custom branded HTML Email OTP design in Supabase.

---

## 🔢 Step 1: Set Supabase OTP Length to 6 Digits (CRITICAL)

By default, some Supabase projects generate an 8-digit OTP code (`12345678`). To configure Supabase to send **6-digit codes (`123456`)**:

1. Open your **[Supabase Dashboard](https://supabase.com/dashboard)** and select your project.
2. Go to **Authentication** → **Providers** (or **Project Settings** → **Authentication**).
3. Under **Auth Settings** / **OTP Settings**, locate **Mailer OTP Length** or **OTP Length**.
4. Set the OTP Length value to **`6`**.
5. Click **Save**.

---

## 🎨 Step 2: Apply Custom Email OTP Design (`EMAIL_OTP_TEMPLATE.html`)

Copy and paste the HTML code below into Supabase Dashboard (**Authentication** → **Email Templates** → **Confirm Signup** & **Magic Link**):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RAMP - Email Verification Code</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #F8FAFC; padding: 40px 16px;">
    <tr>
      <td align="center">
        <!-- Main Email Container -->
        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 520px; background-color: #FFFFFF; border-radius: 16px; border: 1px solid #E2E8F0; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05); overflow: hidden;">
          
          <!-- Brand Blue Header Bar -->
          <tr>
            <td style="background-color: #1E40AF; padding: 28px 32px; text-align: center;">
              <span style="display: inline-block; background-color: rgba(255, 255, 255, 0.15); color: #FFFFFF; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; padding: 4px 12px; border-radius: 20px; margin-bottom: 8px;">RAMP PROPERTY MANAGEMENT</span>
              <h1 style="color: #FFFFFF; font-size: 24px; font-weight: 800; margin: 6px 0 0 0; letter-spacing: -0.5px;">Email Verification</h1>
            </td>
          </tr>

          <!-- Email Content Body -->
          <tr>
            <td style="padding: 32px; text-align: center;">
              <p style="color: #0F172A; font-size: 16px; font-weight: 600; margin: 0 0 8px 0;">Hello,</p>
              <p style="color: #64748B; font-size: 14px; line-height: 22px; margin: 0 0 28px 0;">
                Please use the 6-digit verification code below to confirm your email address and complete your RAMP account setup.
              </p>

              <!-- 6-Digit OTP Code Container -->
              <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-bottom: 28px;">
                <tr>
                  <td align="center">
                    <div style="background-color: #EFF6FF; border: 2px dashed #3B82F6; border-radius: 12px; padding: 20px 16px; display: inline-block; width: 100%; max-width: 360px; box-sizing: border-box;">
                      <span style="display: block; color: #1E40AF; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.2px; margin-bottom: 8px;">Your Verification Code</span>
                      <span style="display: block; color: #1E40AF; font-size: 38px; font-weight: 800; font-family: 'Courier New', Courier, monospace; letter-spacing: 8px; line-height: 1;">{{ .Token }}</span>
                    </div>
                  </td>
                </tr>
              </table>

              <!-- Expiry & Security Warning -->
              <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #F8FAFC; border-radius: 10px; padding: 14px 16px; margin-bottom: 24px; text-align: left;">
                <tr>
                  <td style="font-size: 13px; color: #64748B; line-height: 18px;">
                    <strong style="color: #0F172A;">Important Note:</strong> This code is valid for <strong>5 minutes</strong>. For security reasons, do not share this code with anyone.
                  </td>
                </tr>
              </table>

              <p style="color: #94A3B8; font-size: 12px; line-height: 18px; margin: 0;">
                If you did not request this verification code, you can safely ignore this email.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #F8FAFC; border-top: 1px solid #E2E8F0; padding: 20px 32px; text-align: center;">
              <p style="color: #94A3B8; font-size: 12px; margin: 0 0 4px 0; font-weight: 500;">
                RAMP — Rental Administration & Maintenance Platform
              </p>
              <p style="color: #CBD5E1; font-size: 11px; margin: 0;">
                Automated System Message • Please do not reply directly to this email
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

---

## 🔑 Custom SMTP Settings (Gmail)

In **Project Settings** → **Authentication** → **SMTP Settings**:
- **Host**: `smtp.gmail.com`
- **Port**: `587`
- **Encryption**: `STARTTLS`
- **Sender Email**: `your-email@gmail.com`
- **Sender Name**: `RAMP Property Management`
- **Username**: `your-email@gmail.com`
- **Password**: `<Your 16-character Google App Password>`
