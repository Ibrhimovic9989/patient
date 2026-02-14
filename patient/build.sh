#!/bin/bash
set -e

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  # Use git clone as it's more reliable than downloading archives
  if [ ! -d /tmp/flutter ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter
  fi
  export PATH="$PATH:/tmp/flutter/bin"
  flutter --version
  flutter doctor
fi

# Create .env file in root directory from Vercel environment variables
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env

# Get dependencies
flutter pub get

# Build web app
flutter build web --release --base-href /
