#!/bin/bash
# Setup linting for NeuroVision project

set -e

echo "🔧 Setting up NeuroVision linting environment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required but not installed.${NC}"
    echo "Please install Python 3 and try again."
    exit 1
fi

echo -e "${GREEN}✅ Python 3 found${NC}"

# Install gdtoolkit
echo -e "\n${YELLOW}📦 Installing gdtoolkit...${NC}"
pip3 install --user gdtoolkit || {
    echo -e "${RED}❌ Failed to install gdtoolkit${NC}"
    echo "Try: pip3 install --user --upgrade gdtoolkit"
    exit 1
}

# Install pre-commit
echo -e "\n${YELLOW}📦 Installing pre-commit...${NC}"
pip3 install --user pre-commit || {
    echo -e "${RED}❌ Failed to install pre-commit${NC}"
    echo "Try: pip3 install --user --upgrade pre-commit"
    exit 1
}

# Verify installations
echo -e "\n${YELLOW}🔍 Verifying installations...${NC}"

if command -v gdformat &> /dev/null; then
    echo -e "${GREEN}✅ gdformat installed$(gdformat --version)${NC}"
else
    echo -e "${RED}❌ gdformat not found in PATH${NC}"
    echo "Add ~/.local/bin to your PATH:"
    echo 'export PATH="$PATH:$HOME/.local/bin"'
fi

if command -v gdlint &> /dev/null; then
    echo -e "${GREEN}✅ gdlint installed${NC}"
else
    echo -e "${RED}❌ gdlint not found in PATH${NC}"
fi

if command -v pre-commit &> /dev/null; then
    echo -e "${GREEN}✅ pre-commit installed$(pre-commit --version)${NC}"
else
    echo -e "${RED}❌ pre-commit not found in PATH${NC}"
fi

# Install pre-commit hooks
echo -e "\n${YELLOW}🪝 Installing pre-commit hooks...${NC}"
pre-commit install || {
    echo -e "${RED}❌ Failed to install pre-commit hooks${NC}"
    exit 1
}

echo -e "${GREEN}✅ Pre-commit hooks installed${NC}"

# Run initial checks
echo -e "\n${YELLOW}🏃 Running initial linting checks...${NC}"
echo "This may take a few minutes on first run..."

# Create a sample file to test
TEST_FILE=$(mktemp /tmp/test_linting.XXXXXX.gd)
cat > "$TEST_FILE" << 'EOF'
extends Node

func _ready() -> void:
	print("Linting test successful!")
EOF

# Test gdformat
echo -e "\n${YELLOW}Testing gdformat...${NC}"
if gdformat --check "$TEST_FILE"; then
    echo -e "${GREEN}✅ gdformat working correctly${NC}"
else
    echo -e "${RED}❌ gdformat test failed${NC}"
fi

# Test gdlint
echo -e "\n${YELLOW}Testing gdlint...${NC}"
if gdlint "$TEST_FILE"; then
    echo -e "${GREEN}✅ gdlint working correctly${NC}"
else
    echo -e "${RED}❌ gdlint test failed${NC}"
fi

# Cleanup
rm -f "$TEST_FILE"

# Summary
echo -e "\n${GREEN}🎉 Linting setup complete!${NC}"
echo -e "\nNext steps:"
echo "1. Run 'pre-commit run --all-files' to check all files"
echo "2. Linting will run automatically before each commit"
echo "3. VS Code will format on save (if configured)"
echo -e "\nFor help, see: ${YELLOW}.vscode/LINTING_QUICK_REFERENCE.md${NC}"

# Check if in git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "\n${YELLOW}💡 Tip: Stage your changes before running pre-commit${NC}"
else
    echo -e "\n${YELLOW}⚠️  Warning: Not in a git repository${NC}"
fi