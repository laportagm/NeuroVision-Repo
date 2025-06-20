#!/bin/bash
# Enhanced NeuroVision Debug Script with Comprehensive Error Detection

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== NeuroVision Enhanced Debug Mode ===${NC}"
echo -e "${YELLOW}This script provides comprehensive error detection and debugging${NC}"
echo ""

# Project path
PROJECT_PATH="/Users/gagelaporta/Desktop/NeuroVision-Repo"

# Function to check for common errors
check_common_errors() {
    echo -e "${BLUE}[1/6] Checking for parse errors...${NC}"
    grep -n "try:\|except:" "$PROJECT_PATH"/**/*.gd 2>/dev/null | head -20
    
    echo -e "${BLUE}[2/6] Checking for missing node references...${NC}"
    grep -n "has node:" "$PROJECT_PATH"/**/*.gd 2>/dev/null | head -20
    
    echo -e "${BLUE}[3/6] Checking for null references...${NC}"
    grep -n "is_instance_valid\|!= null\|== null" "$PROJECT_PATH"/**/*.gd 2>/dev/null | head -20
    
    echo -e "${BLUE}[4/6] Checking for shader errors...${NC}"
    find "$PROJECT_PATH" -name "*.gdshader" -exec grep -l "error\|ERROR" {} \; 2>/dev/null
    
    echo -e "${BLUE}[5/6] Checking for resource path errors...${NC}"
    grep -n "res://" "$PROJECT_PATH"/**/*.gd 2>/dev/null | grep -v "ResourceLoader.exists" | head -20
    
    echo -e "${BLUE}[6/6] Checking for signal connection errors...${NC}"
    grep -n "\.connect(" "$PROJECT_PATH"/**/*.gd 2>/dev/null | head -20
}

# Function to run Godot with maximum verbosity
run_godot_verbose() {
    echo -e "${GREEN}Starting Godot with maximum verbosity...${NC}"
    cd "$PROJECT_PATH"
    
    # Run with all debug flags
    godot --verbose \
          --debug-collisions \
          --debug-navigation \
          --print-fps \
          --gpu-abort \
          --remote-debug "tcp://127.0.0.1:6007" \
          --debug-stringnames \
          2>&1 | tee godot_debug_full.log
}

# Function to analyze log files
analyze_logs() {
    echo -e "${BLUE}Analyzing debug logs...${NC}"
    
    if [ -f "godot_debug_full.log" ]; then
        echo -e "${YELLOW}=== Errors Found ===${NC}"
        grep -i "error\|fail\|warning\|critical" godot_debug_full.log | sort | uniq
        
        echo -e "${YELLOW}=== Performance Issues ===${NC}"
        grep -i "fps\|frame\|performance\|slow" godot_debug_full.log | tail -20
        
        echo -e "${YELLOW}=== Resource Loading Issues ===${NC}"
        grep -i "load\|resource\|asset\|missing" godot_debug_full.log | tail -20
    fi
}

# Main menu
echo "Select debug option:"
echo "1) Quick error scan"
echo "2) Run with full debug output"
echo "3) Analyze existing logs"
echo "4) Run comprehensive test suite"
echo "5) Check specific file for errors"
echo "6) Monitor real-time debug output"

read -p "Enter option (1-6): " option

case $option in
    1)
        check_common_errors
        ;;
    2)
        run_godot_verbose
        ;;
    3)
        analyze_logs
        ;;
    4)
        echo -e "${GREEN}Running comprehensive tests...${NC}"
        check_common_errors
        echo ""
        echo -e "${GREEN}Starting Godot for live testing...${NC}"
        run_godot_verbose
        ;;
    5)
        read -p "Enter file path to check: " filepath
        echo -e "${BLUE}Checking $filepath...${NC}"
        grep -n "error\|warning\|TODO\|FIXME\|HACK" "$filepath" 2>/dev/null || echo "No issues found"
        ;;
    6)
        echo -e "${GREEN}Starting real-time debug monitor...${NC}"
        godot --path "$PROJECT_PATH" --verbose 2>&1 | while read line; do
            if [[ $line == *"ERROR"* ]]; then
                echo -e "${RED}$line${NC}"
            elif [[ $line == *"WARNING"* ]]; then
                echo -e "${YELLOW}$line${NC}"
            elif [[ $line == *"[Performance]"* ]]; then
                echo -e "${PURPLE}$line${NC}"
            else
                echo "$line"
            fi
        done
        ;;
    *)
        echo "Invalid option"
        ;;
esac