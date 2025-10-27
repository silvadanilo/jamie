# Gigalixir Deployment Guide for Jamie

This guide will help you deploy the Jamie Phoenix application to Gigalixir.

## Prerequisites

1. A Gigalixir account (sign up at https://www.gigalixir.com)
2. Git installed and configured
3. Gigalixir CLI installed (install from: https://docs.gigalixir.com/getting-started-guide.html#install-the-gigalixir-cli)
4. A Mailjet account (sign up at https://www.mailjet.com/) for sending emails

## Initial Setup

### 1. Install Gigalixir CLI

If you haven't already, install the Gigalixir CLI:

```bash
pip install --upgrade gigalixir
```

### 2. Login to Gigalixir

```bash
gigalixir login
```

This will open your browser to complete authentication.

### 3. Create a New App

```bash
gigalixir create jamie
```

Note the app name you get (e.g., `jamie-12345`). Gigalixir will automatically provide:
- PostgreSQL database (DATABASE_URL)
- SECRET_KEY_BASE
- SSL certificate
- Deployment pipeline

### 4. Add Postgres Database (Free Tier)

The free tier includes a small Postgres database. If you need more, you can upgrade:

```bash
gigalixir addons:install cloud.services.amnh.org -a jamie
```

## Configuration

### Environment Variables

Set the required environment variables:

```bash
# Set your app's hostname
gigalixir config:set PHX_HOST=your-app-name.gigalixir.com

# Set your Mailjet API credentials (required for email)
gigalixir config:set MAILJET_API_KEY=your-mailjet-api-key
gigalixir config:set MAILJET_SECRET_KEY=your-mailjet-secret-key

# For free tier, use smaller pool size to avoid "too many connections" errors
gigalixir config:set POOL_SIZE=5

# Optional: Enable IPv6 if needed
gigalixir config:set ECTO_IPV6=false
```

### Verify Environment Variables

```bash
gigalixir config
```

## Database Setup

Gigalixir will automatically set up and migrate your database when you deploy. However, you can also run migrations manually:

### Run Migrations

```bash
gigalixir run mix ecto.migrate
```

### Seed Database (Optional)

```bash
gigalixir run mix run priv/repo/seeds.exs
```

Note: Be careful with seed data in production!

## Deployment

### Initial Deployment

1. **Build and push to Gigalixir:**

```bash
# Add Gigalixir remote
gigalixir git:remote jamie

# Push to deploy
git push gigalixir master
```

Or if you're using `main` branch:

```bash
git push gigalixir main:master
```

2. **Check deployment status:**

```bash
gigalixir releases
```

3. **View logs:**

```bash
gigalixir logs
```

Or follow logs in real-time:

```bash
gigalixir logs --tail
```

### Subsequent Deployments

Once set up, deploying is simple:

```bash
git push gigalixir master
```

Gigalixir will:
1. Build your application
2. Run database migrations (automatically)
3. Restart the app with zero downtime

## Verify Deployment

1. **Check app status:**

```bash
gigalixir ps
```

2. **Open your app in browser:**

```bash
gigalixir open
```

3. **Test the application** at the provided URL

## Useful Commands

### View Logs

```bash
# All logs
gigalixir logs

# Follow logs
gigalixir logs --tail

# Last 100 lines
gigalixir logs --num 100
```

### Scale Your Application

```bash
# View current scale
gigalixir ps:scale

# Scale to 2 containers
gigalixir ps:scale replicas=2

# Scale to 1 container (free tier limit)
gigalixir ps:scale replicas=1
```

### Run One-Off Commands

```bash
# Run a Mix task
gigalixir run mix your_task

# Open an IEx console
gigalixir run iex -S mix

# Check database connection
gigalixir run mix ecto.version
```

### Restart Application

```bash
gigalixir restart
```

### View Environment Variables

```bash
gigalixir config
```

### Update Environment Variables

```bash
gigalixir config:set KEY=value
```

### Delete Environment Variables

```bash
gigalixir config:unset KEY
```

## Troubleshooting

### Issue: LiveView Socket "Could not check origin" Error

If you see errors like:
```
Could not check origin for Phoenix.Socket transport.
Origin of the request: https://jamie.gigalixirapp.com
```

**Fix:** Make sure `PHX_HOST` matches your actual domain:

```bash
# Get your app's domain
gigalixir apps:info -a your-app-name

# Set PHX_HOST to match
gigalixir config:set PHX_HOST=jamie.gigalixirapp.com -a your-app-name

# Or use wildcard for Gigalixir's default domain
gigalixir config:set PHX_HOST=*.gigalixirapp.com -a your-app-name

# Restart to apply
gigalixir restart -a your-app-name
```

The fix is already applied in the code (origin checking is disabled for production), but setting PHX_HOST correctly is still recommended.

### Check Application Status

```bash
gigalixir ps
gigalixir logs
```

### Database Issues

```bash
# Check database connection
gigalixir run mix ecto.version

# Rollback migration
gigalixir run mix ecto.rollback

# Run migrations
gigalixir run mix ecto.migrate
```

### Build Issues

```bash
# Check build logs
gigalixir releases -r your-release-version

# View release details
gigalixir releases
```

### Force Deploy

If a deployment fails, you can force a new deployment:

```bash
git commit --allow-empty -m "Force deployment"
git push gigalixir master
```

## Production Checklist

Before going live, ensure:

- [ ] All environment variables are set (PHX_HOST, MAILJET_API_KEY, MAILJET_SECRET_KEY)
- [ ] Database migrations are up to date
- [ ] SSL is configured (automatic with Gigalixir)
- [ ] Email service is working (test sending emails)
- [ ] Background jobs (Oban) are running
- [ ] Monitoring and logging are enabled
- [ ] You have backups configured (if using paid tier)

## Email Configuration

The app is configured to use Mailjet for sending emails in production. Make sure to:

1. Sign up for Mailjet at https://www.mailjet.com/
2. Complete the account setup and verify your email
3. Get your API credentials from https://app.mailjet.com/account/api_keys
   - You'll need both the **API Key** and **Secret Key**
4. Set the environment variables:
   ```bash
   gigalixir config:set MAILJET_API_KEY=your-api-key
   gigalixir config:set MAILJET_SECRET_KEY=your-secret-key
   ```

**Mailjet Free Plan:**
- 6,000 emails per month
- 200 emails per day
- SMTP and API access
- Email tracking and analytics
- Templates support

## Background Jobs (Oban)

Oban is configured to run background jobs. Monitor job queues:

```bash
# Check Oban job status
gigalixir run mix ecto.migrate
```

View jobs in the LiveDashboard at `/dashboard` (if accessible).

## Free Tier Limitations

On the Gigalixir free tier:
- ✅ Unlimited deploys
- ✅ PostgreSQL database
- ✅ SSL certificates
- ⚠️ Sleeps after 1 hour of inactivity (first request after sleep takes ~30 seconds)
- ⚠️ Limited to 1 container
- ⚠️ Shared resources

For production use, consider upgrading to a paid plan for better performance and reliability.

## Next Steps

1. **Monitoring**: Set up error tracking (consider Sentry, Bugsnag, etc.)
2. **Analytics**: Add analytics to track user behavior
3. **Domain**: Configure custom domain if needed
4. **CDN**: Consider adding a CDN for static assets (if on paid tier)

## Support

- Gigalixir Docs: https://docs.gigalixir.com
- Gigalixir Support: https://www.gigalixir.com/support
- Phoenix Deployment: https://hexdocs.pm/phoenix/deployment.html

## Upgrading

To upgrade Phoenix or dependencies:

```bash
# Update dependencies
mix deps.update --all

# Test locally
mix test

# Commit changes
git add .
git commit -m "Update dependencies"

# Deploy
git push gigalixir master
```

## Rollback

If a deployment causes issues:

```bash
# List releases
gigalixir releases

# Rollback to previous version
gigalixir rollback release-version-number
```

