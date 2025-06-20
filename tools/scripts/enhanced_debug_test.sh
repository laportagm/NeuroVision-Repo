#!/bin/bash
# Enhanced debugging and testing script for NeuroVision

echo "🧠 NeuroVision Enhanced Debug Testing"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test 1: Check for parse errors
echo -e "\n${YELLOW}1. Checking for parse errors...${NC}"
godot --headless --script res://src/debug/check_parse_errors.gd --quit 2>&1 | grep -E "(ERROR|Parse Error)" || echo -e "${GREEN}✅ No parse errors found${NC}"

# Test 2: Check autoloads
echo -e "\n${YELLOW}2. Checking autoload status...${NC}"
godot --headless --debug <<EOF 2>&1 | grep -A 20 "autoload"
test autoloads
quit
EOF

# Test 3: Memory leak detection
echo -e "\n${YELLOW}3. Checking for memory leaks...${NC}"
godot --verbose --headless --quit 2>&1 | grep -E "(leaked|Leak)" || echo -e "${GREEN}✅ No obvious memory leaks${NC}"

# Test 4: Performance baseline
echo -e "\n${YELLOW}4. Running performance test...${NC}"
timeout 5s godot --print-fps --headless 2>&1 | grep "FPS" | tail -5

# Test 5: Scene validation
echo -e "\n${YELLOW}5. Validating main scenes...${NC}"
for scene in "scenes/ui/MainMenu.tscn" "scenes/3d/EnhancedExplorationScene.tscn"; do
    echo -n "  Checking $scene... "
    if godot --headless --check-only --quit "res://$scene" 2>&1 | grep -q "ERROR"; then
        echo -e "${RED}❌ Errors found${NC}"
    else
        echo -e "${GREEN}✅ Valid${NC}"
    fi
done

# Test 6: Shader compilation
echo -e "\n${YELLOW}6. Checking shader compilation...${NC}"
godot --headless --quit 2>&1 | grep -E "(Shader.*error|shader.*failed)" || echo -e "${GREEN}✅ All shaders compiled${NC}"

# Test 7: Node configuration warnings
echo -e "\n${YELLOW}7. Checking for node warnings...${NC}"
godot --verbose --headless --quit 2>&1 | grep -E "configuration.*warning" || echo -e "${GREEN}✅ No configuration warnings${NC}"

echo -e "\n${GREEN}Debug testing complete!${NC}"
echo "For detailed debugging, run: ./debug_neurovision.sh"