# Gigalixir Deployment Checklist

Follow this checklist before and after deploying Jamie to Gigalixir.

## Pre-Deployment

### 1. Prerequisites Check
- [ ] Gigalixir account created (https://www.gigalixir.com)
- [ ] Gigalixir CLI installed (`pip install --upgrade gigalixir`)
- [ ] Logged in to Gigalixir (`gigalixir login`)
- [ ] Git is configured
- [ ] All local tests pass (`mix test`)
- [ ] App compiles locally (`mix compile`)

### 2. Configuration Check
- [ ] Review `gigalixir.toml` configuration
- [ ] Review `elixir_buildpack.config` for correct Elixir/Erlang versions
- [ ] Verify `force_ssl` is configured in `config/prod.exs`
- [ ] Check `config/runtime.exs` for production settings

### 3. Environment Variables
You'll need to set these in Gigalixir:

```bash
# Required
gigalixir config:set PHX_HOST=your-app-name.gigalixir.com -a your-app-name
gigalixir config:set MAILJET_API_KEY=your-mailjet-api-key -a your-app-name
gigalixir config:set MAILJET_SECRET_KEY=your-mailjet-secret-key -a your-app-name

# Optional
gigalixir config:set POOL_SIZE=5 -a your-app-name
```

### 4. Database Setup
- [ ] Mailjet account created and API credentials obtained
- [ ] Set POOL_SIZE to 5 or lower to avoid connection errors
- [ ] Understand that Gigalixir will create DB automatically
- [ ] Decide if you need to run seeds (usually NOT recommended)

## Deployment Steps

### Step 1: Create Gigalixir App
```bash
gigalixir create jamie
```
Note the app name (e.g., `jamie-12345`)

### Step 2: Set Environment Variables
```bash
gigalixir config:set PHX_HOST=jamie-12345.gigalixir.com -a jamie-12345
gigalixir config:set POSTMARK_API_KEY=your-key -a jamie-12345
```

### Step 3: Deploy
```bash
# Add remote (first time only)
gigalixir git:remote jamie-12345

# Or use the deployment script
./deploy.sh jamie-12345
```

## Post-Deployment

### Immediate Checks
- [ ] Check deployment status: `gigalixir ps -a your-app-name`
- [ ] View logs: `gigalixir logs --tail -a your-app-name`
- [ ] Test app URL: `gigalixir open -a your-app-name`
- [ ] Verify HTTPS redirects work
- [ ] Check SSL certificate (automatic with Gigalixir)

### Functionality Checks
- [ ] User registration works
- [ ] Email confirmation works (check Postmark logs)
- [ ] Login works
- [ ] Basic app functionality works
- [ ] Database migrations were applied successfully

### Database Verification
```bash
gigalixir run mix ecto.version -a your-app-name
```

### Email Testing
- [ ] Send a test email from the app
- [ ] Check Postmark dashboard for delivery
- [ ] Verify email templates render correctly

## Common Issues and Solutions

### Issue: Build fails
```bash
# Check build logs
gigalixir releases -a your-app-name

# Rollback if needed
gigalixir rollback previous-release -a your-app-name
```

### Issue: Database connection fails
```bash
# Check DATABASE_URL
gigalixir config -a your-app-name

# Run migrations manually
gigalixir run mix ecto.migrate -a your-app-name
```

### Issue: LiveView Socket Origin Error

If LiveView connections fail with "Could not check origin":

```bash
# Set the correct PHX_HOST
gigalixir config:set PHX_HOST=your-app.gigalixirapp.com -a your-app-name

# Restart to apply
gigalixir restart -a your-app-name
```

Note: The code already disables origin checking in production, but setting PHX_HOST correctly is still recommended.

### Issue: "too many connections" error

This error occurs when your pool size exceeds the database's connection limit.

**Fix:**
```bash
# Reduce pool size to 5 or lower for free tier
gigalixir config:set POOL_SIZE=5 -a your-app-name

# Or even lower for very small databases
gigalixir config:set POOL_SIZE=3 -a your-app-name

# Restart the app to apply changes
gigalixir restart -a your-app-name
```

**Check your database limits:**
```bash
# Connect to your database
gigalixir run mix ecto.migrate -a your-app-name

# Then run this SQL:
# SELECT setting FROM pg_settings WHERE name = 'max_connections';
```

### Issue: Assets not loading
```bash
# Check if assets were built
gigalixir run ls priv/static/assets -a your-app-name

# Assets should be in priv/static/cache_manifest.json
```

### Issue: Oban jobs not running
- Oban tables are created via migration
- Jobs start automatically with the app
- Check logs for Oban errors

## Maintenance

### Regular Tasks
- [ ] Monitor logs for errors: `gigalixir logs --tail`
- [ ] Check database size and performance
- [ ] Monitor Postmark usage
- [ ] Review app metrics in Gigalixir dashboard

### Updates and Deployments
- [ ] Test changes locally first
- [ ] Commit and push: `git push gigalixir master`
- [ ] Monitor deployment: `gigalixir releases`
- [ ] Verify deployment: `gigalixir ps`

### Scaling (if needed)
```bash
# Free tier is limited to 1 container
# For paid tier:
gigalixir ps:scale replicas=2 -a your-app-name
```

## Free Tier Notes

- App sleeps after 1 hour of inactivity
- First request after sleep takes ~30 seconds
- Limited to 1 container
- Shared resources
- For production, consider upgrading to paid plan

## Rollback

If something goes wrong:
```bash
# List all releases
gigalixir releases -a your-app-name

# Rollback to specific release
gigalixir rollback release-version -a your-app-name
```

## Security Checklist

- [ ] HTTPS is enforced (force_ssl)
- [ ] SECRET_KEY_BASE is set (automatic)
- [ ] DATABASE_URL is secure (automatic)
- [ ] No sensitive data in logs
- [ ] CSRF protection is enabled (automatic)
- [ ] Password hashing is configured (bcrypt)

## Monitoring

Set up monitoring for production:
- [ ] Error tracking (consider Sentry)
- [ ] Uptime monitoring
- [ ] Log aggregation
- [ ] Performance monitoring

## Support

- Gigalixir Documentation: https://docs.gigalixir.com
- Gigalixir Support: https://www.gigalixir.com/support
- Phoenix Deployment: https://hexdocs.pm/phoenix/deployment.html
- App Status Dashboard: https://www.gigalixir.com/dashboard

