#!/bin/bash

# NeuroVis GUT Testing Framework Setup Script
# This script downloads and installs the GUT testing framework

echo "=== NeuroVis GUT Testing Framework Setup ==="
echo

# Check if we're in the project root
if [ ! -f "project.godot" ]; then
    echo "ERROR: Must run from project root directory"
    exit 1
fi

# GUT version to install
GUT_VERSION="9.2.1"
GUT_URL="https://github.com/bitwes/Gut/releases/download/v${GUT_VERSION}/gut_v${GUT_VERSION}.zip"

echo "Installing GUT v${GUT_VERSION}..."

# Create addons directory if it doesn't exist
mkdir -p addons

# Download GUT
echo "Downloading GUT..."
curl -L -o gut.zip "$GUT_URL" || {
    echo "ERROR: Failed to download GUT"
    exit 1
}

# Extract to addons directory
echo "Extracting GUT..."
unzip -q gut.zip -d addons/ || {
    echo "ERROR: Failed to extract GUT"
    rm gut.zip
    exit 1
}

# Clean up
rm gut.zip

# Remove temporary GutTest.gd if it exists
if [ -f "tests/GutTest.gd" ]; then
    echo "Removing temporary GutTest.gd..."
    rm tests/GutTest.gd
fi

echo
echo "✅ GUT installed successfully!"
echo
echo "Next steps:"
echo "1. Open the project in Godot Editor"
echo "2. Go to Project > Project Settings > Plugins"
echo "3. Enable the 'Gut' plugin"
echo "4. Run tests with: godot --headless -s addons/gut/gut_cmdln.gd"
echo
echo "Or use the GUT panel in the editor (bottom dock)"

# Make the script executable for future use
chmod +x scripts/setup_gut.sh