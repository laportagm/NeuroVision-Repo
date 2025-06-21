#!/bin/bash

echo "Setting up NeuroVision development environment..."

# Configure Git
git config --global --add safe.directory /workspace

# Install additional Python packages for NeuroVision
pip3 install --user numpy pandas matplotlib scikit-learn

# Create necessary directories
mkdir -p ~/.config/godot
mkdir -p ~/.cache/godot

# Set up GDScript linting
echo "Configuring GDScript tools..."
gdformat --version
gdtoolkit --version

# Install MCP servers if needed
if command -v npm &> /dev/null; then
    echo "Installing MCP servers..."
    npm install -g @modelcontextprotocol/server-godot
    npm install -g @modelcontextprotocol/server-filesystem
fi

# Set executable permissions for scripts
find /workspace/tools/scripts -name "*.sh" -exec chmod +x {} \;

# Validate Godot installation
echo "Validating Godot installation..."
/usr/local/bin/godot --version

echo "NeuroVision devcontainer setup complete!"
echo "You can now:"
echo "  - Open Godot projects with full language server support"
echo "  - Run GDScript linting and formatting"
echo "  - Use integrated debugging"
echo "  - Access GPU acceleration (if available)"