#!/bin/bash
# Install only Express for serving the pre-built React app

set -e

echo "=========================================="
echo "Installing minimal production dependencies"
echo "=========================================="

cd /var/app/staging

# Use production package.json if it exists, otherwise use regular package.json
if [ -f "package.production.json" ]; then
    echo "✓ Found package.production.json - using minimal dependencies"
    cp package.production.json package.json
fi

# Remove any existing node_modules to ensure clean install
if [ -d "node_modules" ]; then
    echo "✓ Removing existing node_modules..."
    rm -rf node_modules
fi

# Install only production dependencies (just Express)
echo "✓ Installing production dependencies..."
npm install --production --no-optional

echo ""
echo "=========================================="
echo "Installed packages:"
echo "=========================================="
ls -la node_modules/ | grep -E '^d' | wc -l
echo "packages installed"
echo ""
echo "Dependencies installed successfully!"
echo "=========================================="

