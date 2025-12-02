#!/bin/bash
# Force npm install to run for production dependencies

set -e

echo "Running npm install for production dependencies..."
cd /var/app/staging

# Remove any existing node_modules to force fresh install
if [ -d "node_modules" ]; then
    echo "Removing existing node_modules..."
    rm -rf node_modules
fi

# Install production dependencies only
echo "Installing production dependencies..."
npm ci --only=production || npm install --only=production

echo "Dependencies installed successfully!"
ls -la node_modules/ | head -20

