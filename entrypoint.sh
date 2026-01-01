#!/bin/sh
set -e

echo "🚀 Starting FoodAdda Backend..."

# Wait for MySQL to be ready (if using docker-compose)
if [ -n "$DB_HOST" ] && [ "$DB_HOST" != "localhost" ]; then
  echo "⏳ Waiting for MySQL to be ready..."
  until nc -z "$DB_HOST" "${DB_PORT:-3306}" 2>/dev/null; do
    echo "   MySQL is unavailable - sleeping"
    sleep 2
  done
  echo "✓ MySQL is ready"
fi

# Run migrations
echo "🔄 Running database migrations..."
npm run migrate:prod || {
  echo "⚠️  Migration failed, but continuing..."
}

# Start the application
echo "▶️  Starting application..."
exec npm run start

