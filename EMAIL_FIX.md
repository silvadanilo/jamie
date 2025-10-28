# Email Configuration Fix

## Problem
No emails were being received from production because the Mailjet adapter wasn't installed properly.

## Solution
Changed the email configuration to use SMTP instead of the Mailjet REST API, which is simpler and more reliable.

## Changes Made

### 1. `mix.exs`
Added the required dependencies for Swoosh's SMTP adapter:
```elixir
{:mail, "~> 0.3"},
{:gen_smtp, "~> 1.2"},
```

**Note:** The `gen_smtp` package is essential - it provides the `:mimemail` module that Swoosh's SMTP adapter needs for MIME encoding.

### 2. `config/runtime.exs`
Changed from:
```elixir
config :jamie, Jamie.Mailer,
  adapter: Swoosh.Adapters.Mailjet,
  api_key: System.get_env("MAILJET_API_KEY"),
  secret: System.get_env("MAILJET_SECRET_KEY")
```

To:
```elixir
config :jamie, Jamie.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "in-v3.mailjet.com",
  port: 587,
  username: System.get_env("MAILJET_API_KEY"),
  password: System.get_env("MAILJET_SECRET_KEY"),
  ssl: false,
  tls: :always,
  auth: :always
```

## How to Deploy the Fix

### 1. Commit the Changes
```bash
git add config/runtime.exs
git commit -m "Fix email configuration to use SMTP"
```

### 2. Verify Mailjet Credentials are Set
```bash
# Check if credentials are set
gigalixir config | grep MAILJET

# If not set, set them:
gigalixir config:set MAILJET_API_KEY=your-api-key -a your-app-name
gigalixir config:set MAILJET_SECRET_KEY=your-secret-key -a your-app-name
```

### 3. Get Your Mailjet SMTP Credentials

1. Go to https://app.mailjet.com/
2. Login to your account
3. Go to "Account" → "SMTP" 
4. You'll find your:
   - **API Key** (use as username)
   - **Secret Key** (use as password)

### 4. Set Environment Variables in Gigalixir

```bash
gigalixir config:set MAILJET_API_KEY=your_smtp_api_key -a your-app-name
gigalixir config:set MAILJET_SECRET_KEY=your_smtp_secret_key -a your-app-name
```

Note: The SMTP API key and Secret are different from the REST API credentials. Make sure to get them from the SMTP section in your Mailjet dashboard.

### 5. Deploy
```bash
git push gigalixir master
```

### 6. Test Email Delivery
```bash
# Monitor logs
gigalixir logs --tail -a your-app-name

# Try triggering an email (e.g., registration or password reset)
```

## Troubleshooting

### Check Mailjet Credentials Format

Mailjet SMTP credentials:
- **Username (API Key)**: Usually starts with a combination of letters and numbers (e.g., `abc123def456...`)
- **Password (Secret Key)**: Usually starts with a combination of letters and numbers (e.g., `xyz789ghi012...`)

Both should be available in your Mailjet dashboard at:
https://app.mailjet.com/account/smtp

### Verify Configuration

Check the production logs for SMTP connection errors:
```bash
gigalixir logs --tail -a your-app-name | grep -i smtp
```

### Test Locally First

You can test the SMTP configuration locally:

1. Set environment variables:
```bash
export MAILJET_API_KEY=your_key
export MAILJET_SECRET_KEY=your_secret
```

2. Run in production mode locally:
```bash
MIX_ENV=prod iex -S mix
```

3. Test email sending:
```elixir
alias Jamie.Mailer
alias Swoosh.Email

email = Email.new()
  |> Email.from({"Jamie", "noreply@jamapp.com"})
  |> Email.to({"Your Name", "your-email@example.com"})
  |> Email.subject("Test Email")
  |> Email.text_body("This is a test email from production")

Mailer.deliver(email)
```

### Common Issues

**Issue:** "authentication failed"
- Make sure you're using SMTP credentials, not REST API credentials
- Verify the credentials in Mailjet dashboard

**Issue:** "connection timeout"
- Check firewall rules
- Verify SMTP server: `in-v3.mailjet.com`
- Verify port: `587`

**Issue:** "TLS handshake failed"
- Ensure TLS is set to `:always` (already configured)
- Make sure SSL is set to `false` (already configured)

## After Deployment

Once the fix is deployed, try triggering an email again (e.g., user registration, password reset). Check the Gigalixir logs to ensure emails are being sent successfully:

```bash
gigalixir logs --tail -a your-app-name | grep -i email
```

Look for successful delivery confirmations or error messages.

