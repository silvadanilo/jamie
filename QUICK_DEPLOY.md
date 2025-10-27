# Quick Deployment Steps for Gigalixir

## Fixes Applied

✅ **Database connection pooling** - Reduced to prevent "too many connections" errors
✅ **UUID generation** - pgcrypto extension properly enabled
✅ **LiveView socket origin** - Origin checking disabled for production

## Current Configuration

- **Pool Size:** 5 (configured via POOL_SIZE env var)
- **Oban Workers:** 1 for each queue (default, emails, notifications)
- **Socket Origin Checking:** Disabled for production

## Next Steps to Deploy

### 1. Commit the Changes

```bash
git add .
git commit -m "Fix LiveView socket origin and connection pooling for Gigalixir"
```

### 2. Set Environment Variables in Gigalixir

```bash
# Set your app name (replace with your actual app name)
APP_NAME="your-app-name"

# Set the host (use your actual Gigalixir domain)
gigalixir config:set PHX_HOST=jamie.gigalixirapp.com -a $APP_NAME

# Set pool size to prevent connection errors
gigalixir config:set POOL_SIZE=5 -a $APP_NAME

# Set Mailjet credentials
gigalixir config:set MAILJET_API_KEY=your-api-key -a $APP_NAME
gigalixir config:set MAILJET_SECRET_KEY=your-secret-key -a $APP_NAME
```

### 3. Deploy

```bash
# Using the deployment script
./deploy.sh $APP_NAME

# Or manually
git push gigalixir master
```

### 4. Monitor Deployment

```bash
# Watch the deployment
gigalixir releases -a $APP_NAME

# Follow logs
gigalixir logs --tail -a $APP_NAME

# Check app status
gigalixir ps -a $APP_NAME
```

### 5. Verify Deployment

Visit your app URL:
```bash
gigalixir open -a $APP_NAME
```

The app should now work with LiveView connections!

## If You See Errors

### LiveView still not working?

1. Check logs for socket errors:
   ```bash
   gigalixir logs --tail -a $APP_NAME | grep "Could not check origin"
   ```

2. Verify PHX_HOST is set correctly:
   ```bash
   gigalixir config -a $APP_NAME | grep PHX_HOST
   ```

3. Restart the app:
   ```bash
   gigalixir restart -a $APP_NAME
   ```

### Database connection errors?

1. Reduce pool size further:
   ```bash
   gigalixir config:set POOL_SIZE=3 -a $APP_NAME
   gigalixir restart -a $APP_NAME
   ```

2. Check database status:
   ```bash
   gigalixir run mix ecto.version -a $APP_NAME
   ```

## Configuration Summary

Your production app now has:

- ✅ Proper connection pooling (5 connections max)
- ✅ Reduced Oban workers (1 per queue)
- ✅ Disabled origin checking for WebSockets
- ✅ SSL enforcement enabled
- ✅ Proper database migration with pgcrypto extension

All fixes have been applied to the codebase. Just commit, set environment variables, and deploy!

