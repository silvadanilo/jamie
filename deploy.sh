#!/bin/bash
# Deployment script for Gigalixir

set -e

echo "🚀 Starting deployment to Gigalixir..."

# Check if we're in the right directory
if [ ! -f "mix.exs" ]; then
  echo "❌ Error: mix.exs not found. Run this script from the project root."
  exit 1
fi

# Check if gigalixir CLI is installed
if ! command -v gigalixir &> /dev/null; then
  echo "❌ Gigalixir CLI not found. Install it with: pip install --upgrade gigalixir"
  exit 1
fi

# Check if user is logged in
if ! gigalixir account &> /dev/null; then
  echo "❌ Not logged in to Gigalixir. Run: gigalixir login"
  exit 1
fi

# Get the app name (first argument or ask)
APP_NAME=${1:-}

if [ -z "$APP_NAME" ]; then
  echo "Usage: ./deploy.sh <app-name>"
  echo "Available apps:"
  gigalixir apps
  exit 1
fi

echo "📦 App name: $APP_NAME"

# Set required environment variables
echo "🔧 Setting up environment variables..."
echo "Make sure you've set:"
echo "  - PHX_HOST (your app's domain)"
echo "  - POSTMARK_API_KEY (for email)"
echo "  - Optional: POOL_SIZE, ECTO_IPV6"
echo ""
echo "To set them, run:"
echo "  gigalixir config:set PHX_HOST=$APP_NAME.gigalixir.com -a $APP_NAME"
echo "  gigalixir config:set POSTMARK_API_KEY=your-key -a $APP_NAME"

# Add remote if not exists
if ! git remote | grep -q gigalixir; then
  echo "🔗 Adding Gigalixir remote..."
  gigalixir git:remote $APP_NAME
else
  echo "✅ Gigalixir remote already configured"
fi

# Deploy
echo "📤 Deploying to Gigalixir..."
echo "Note: This will build assets and compile your application"
echo ""

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $CURRENT_BRANCH"

# Push to Gigalixir
echo "Pushing to Gigalixir..."
git push gigalixir $CURRENT_BRANCH:master

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "Monitor your deployment:"
echo "  gigalixir logs --tail -a $APP_NAME"
echo ""
echo "Check status:"
echo "  gigalixir ps -a $APP_NAME"
echo ""
echo "Open your app:"
echo "  gigalixir open -a $APP_NAME"

