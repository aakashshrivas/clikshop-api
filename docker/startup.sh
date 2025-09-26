#!/bin/bash
set -e

echo "🚀 Running Laravel setup..."

# Generate APP_KEY if missing
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Ensure storage symlink exists
php artisan storage:link --force || true

# Run migrations (optional, safe to keep || true)
php artisan migrate --force || true

echo "🎉 Laravel setup complete!"
