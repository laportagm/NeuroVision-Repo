#!/bin/bash
# NeuroVision Launch Helper Script
# Works around VSCode Godot debugger limitations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project path
PROJECT_PATH="/Users/gagelaporta/Desktop/NeuroVision-Repo"

# Find Godot executable
if [ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
elif [ -x "/usr/local/bin/godot" ]; then
    GODOT="/usr/local/bin/godot"
elif command -v godot &> /dev/null; then
    GODOT="godot"
else
    echo -e "${RED}Error: Godot not found!${NC}"
    echo "Please ensure Godot is installed in /Applications/Godot.app"
    echo "Or create a symlink: ln -s /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot"
    exit 1
fi

echo -e "${BLUE}NeuroVision Launch Helper${NC}"
echo "Using Godot at: $GODOT"
echo "=========================="
echo ""
echo "Select launch option:"
echo "1) 🎮 Run Full Application (from Main Menu)"
echo "2) 🧠 Skip to Brain Explorer (Enhanced)"
echo "3) 📚 Skip to Brain Explorer (Standard)"
echo "4) 📊 Performance Test Mode"
echo "5) 🧪 Run Tests"
echo "6) 🐛 Debug with Verbose Output"
echo "7) 🔧 Open in Godot Editor"
echo "8) 🧹 Clean and Run"
echo ""
read -p "Enter choice (1-8): " choice

case $choice in
    1)
        echo -e "${GREEN}Starting NeuroVision...${NC}"
        "$GODOT" --path "$PROJECT_PATH"
        ;;
    2)
        echo -e "${GREEN}Starting Enhanced Brain Explorer...${NC}"
        "$GODOT" --path "$PROJECT_PATH" "res://scenes/3d/EnhancedExplorationScene.tscn"
        ;;
    3)
        echo -e "${GREEN}Starting Standard Brain Explorer...${NC}"
        "$GODOT" --path "$PROJECT_PATH" "res://scenes/main_menu.tscn"
        ;;
    4)
        echo -e "${GREEN}Starting Performance Test Mode...${NC}"
        "$GODOT" --path "$PROJECT_PATH" --print-fps --verbose --debug-collisions
        ;;
    5)
        echo -e "${GREEN}Running Tests...${NC}"
        "$GODOT" --path "$PROJECT_PATH" --script res://scripts/run_tests.gd --headless
        ;;
    6)
        echo -e "${GREEN}Starting Debug Mode...${NC}"
        "$GODOT" --path "$PROJECT_PATH" --verbose --debug
        ;;
    7)
        echo -e "${GREEN}Opening Godot Editor...${NC}"
        "$GODOT" --path "$PROJECT_PATH" --editor
        ;;
    8)
        echo -e "${YELLOW}Cleaning build cache...${NC}"
        rm -rf "$PROJECT_PATH/.godot"
        echo -e "${GREEN}Starting fresh...${NC}"
        "$GODOT" --path "$PROJECT_PATH"
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac