# Gigalixir Deployment Fixes Applied

## Issues Fixed

### 1. UUID Generation Error

**Problem:** `gen_random_uuid()` function not found in PostgreSQL

**Error:**
```
ERROR 42883 (undefined_function) function gen_random_uuid() does not exist
```

**Solution:** 
- Added `pgcrypto` extension enablement to the first migration (`20251024105100_add_oban_jobs_table.exs`)
- This extension is required for UUID generation functions
- The extension will be enabled before any migrations that need it

### 2. Too Many Database Connections

**Problem:** `too many connections for role`

**Error:**
```
FATAL 53300 (too_many_connections) too many connections for role
```

**Solution:**
- Reduced default `POOL_SIZE` from 10 to 5 in `config/runtime.exs`
- Reduced Oban worker counts in production from (10/20/10) to (3/5/3) in `config/prod.exs`
- Updated deployment documentation to recommend setting `POOL_SIZE=5`

## Changes Made

### Configuration Files

1. **`config/runtime.exs`**
   - Changed default `pool_size` from 10 to 5

2. **`config/prod.exs`**
   - Added Oban queue configuration to reduce workers:
   ```elixir
   config :jamie, Oban,
     queues: [default: 3, emails: 5, notifications: 3]
   ```

3. **`priv/repo/migrations/20251024105100_add_oban_jobs_table.exs`**
   - Added pgcrypto extension enablement before Oban tables creation
   - Ensures UUID functions are available for later migrations

4. **`priv/repo/migrations/20251025122912_populate_creators_as_coorganizers.exs`**
   - Removed duplicate pgcrypto extension enablement (now handled in earlier migration)

### Documentation Updates

1. **`GIGALIXIR_DEPLOYMENT.md`**
   - Updated pool size recommendation from 10 to 5
   - Added troubleshooting section for connection errors

2. **`DEPLOYMENT_CHECKLIST.md`**
   - Added POOL_SIZE to environment variables section
   - Updated checklist items to include pool size configuration
   - Added troubleshooting section for "too many connections" error

## Deployment Steps

After applying these fixes, redeploy to Gigalixir:

```bash
# Make sure you have the fixes committed
git add .
git commit -m "Fix database connection pooling and UUID generation"

# Set the pool size environment variable
gigalixir config:set POOL_SIZE=5 -a your-app-name

# Redeploy
git push gigalixir master

# Or use the deployment script
./deploy.sh your-app-name
```

## Verification

After deployment, verify the fixes:

```bash
# Check the app is running
gigalixir ps -a your-app-name

# Check logs for any connection errors
gigalixir logs --tail -a your-app-name

# Verify database connections are being managed properly
# (You should NOT see "too many connections" errors)
```

## Database Connection Management

The app now uses:
- **Database Pool:** 5 connections (down from 10)
- **Oban Workers:** 3 default, 5 emails, 3 notifications (down from 10/20/10)

This should be sufficient for free tier and smaller databases. If you upgrade to a paid tier, you can increase these values:

```bash
# For larger databases, you can increase pool size
gigalixir config:set POOL_SIZE=10 -a your-app-name

# Restart to apply changes
gigalixir restart -a your-app-name
```

## Additional Notes

- The pgcrypto extension is now enabled automatically with your first migration
- No manual database configuration needed for UUID generation
- Connection pooling is optimized for Gigalixir's free tier
- Monitor your app's logs to ensure no connection errors persist

