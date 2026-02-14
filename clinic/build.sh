#!/bin/bash
set -e

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.6.0-stable.tar.xz | tar xJ -C /tmp
  export PATH="$PATH:/tmp/flutter/bin"
fi

# Create .env file in web directory from Vercel environment variables
echo "SUPABASE_URL=$SUPABASE_URL" > web/.env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> web/.env
echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> web/.env

# Get dependencies
flutter pub get

# Build web app
flutter build web --release --web-renderer canvaskit --base-href /
