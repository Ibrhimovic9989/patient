#!/bin/bash
# Create .env file in web directory from Vercel environment variables
# This script is called during Vercel build

WEB_DIR="web"
if [ -d "../$WEB_DIR" ]; then
  WEB_DIR="../$WEB_DIR"
fi

# Create .env file in web directory
cat > "$WEB_DIR/.env" << EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY}
EOF

echo "Created .env file in $WEB_DIR/.env"
cat "$WEB_DIR/.env" | sed 's/\(.*=\).*/\1***/' # Show file with masked values
