#!/bin/bash

# Test performance optimizations for NeuroVision
# Specifically tests Intel UHD 620 optimizations

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."

echo "=== NeuroVision Performance Optimization Test ==="
echo "Testing GPU detection and optimization features"
echo

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to run Godot with performance testing
test_performance() {
    echo -e "${YELLOW}Starting performance test scene...${NC}"
    
    # Create a temporary test scene that logs optimization info
    cat > "$PROJECT_ROOT/test_performance_optimization.gd" << 'EOF'
extends Node3D

func _ready():
    print("\n=== PERFORMANCE OPTIMIZATION TEST ===")
    
    # Test GPU detection
    if IntelOptimizer:
        var gpu_info = IntelOptimizer.get_gpu_info()
        print("GPU Detected: " + gpu_info.name)
        print("Is Integrated: " + str(IntelOptimizer.is_integrated_graphics()))
        print("Recommended Quality: " + str(IntelOptimizer.get_recommended_quality_level()))
    
    # Test Graphics Optimization Manager
    if GraphicsOptimizationManager:
        print("\nGraphics Optimization Manager:")
        GraphicsOptimizationManager.debug_print_current_settings()
        
        print("\nAvailable Presets:")
        var presets = GraphicsOptimizationManager.get_preset_names()
        for preset in presets:
            print("  - " + preset)
    
    # Test scene optimization
    print("\nLoading Enhanced Exploration Scene...")
    var scene = load("res://scenes/3d/EnhancedExplorationScene.tscn")
    if scene:
        var instance = scene.instantiate()
        add_child(instance)
        
        # Wait a bit for optimizations to apply
        await get_tree().create_timer(2.0).timeout
        
        # Check performance metrics
        if PerformanceMonitor:
            print("\nPerformance Metrics:")
            print("  FPS: " + str(Engine.get_frames_per_second()))
            print("  Frame Time: " + str(1000.0 / Engine.get_frames_per_second()) + "ms")
            print("  Draw Calls: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
            print("  Memory: " + str(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024) + "MB")
    
    # Exit after test
    await get_tree().create_timer(3.0).timeout
    print("\n=== TEST COMPLETE ===")
    get_tree().quit()
EOF

    # Create test scene file
    cat > "$PROJECT_ROOT/test_performance_optimization.tscn" << 'EOF'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://test_performance_optimization.gd" id="1"]

[node name="PerformanceTest" type="Node3D"]
script = ExtResource("1")
EOF

    # Run the test
    godot --headless --path "$PROJECT_ROOT" "res://test_performance_optimization.tscn" 2>&1 | while IFS= read -r line; do
        if [[ $line == *"ERROR"* ]]; then
            echo -e "${RED}$line${NC}"
        elif [[ $line == *"WARNING"* ]]; then
            echo -e "${YELLOW}$line${NC}"
        elif [[ $line == *"GPU Detected"* ]] || [[ $line == *"Is Integrated"* ]] || [[ $line == *"FPS:"* ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo "$line"
        fi
    done
    
    # Cleanup
    rm -f "$PROJECT_ROOT/test_performance_optimization.gd"
    rm -f "$PROJECT_ROOT/test_performance_optimization.tscn"
}

# Function to check shader optimizations
check_shaders() {
    echo -e "\n${YELLOW}Checking shader optimizations...${NC}"
    
    # Check for optimized shaders
    if [ -f "$PROJECT_ROOT/src/ui_atomic/effects/shaders/glass_panel_optimized.gdshader" ]; then
        echo -e "${GREEN}✓ Optimized glass panel shader found${NC}"
    else
        echo -e "${RED}✗ Optimized glass panel shader missing${NC}"
    fi
    
    # Count shader files
    SHADER_COUNT=$(find "$PROJECT_ROOT" -name "*.gdshader" | wc -l)
    echo "Total shader files: $SHADER_COUNT"
}

# Function to analyze scene files for optimization
analyze_scenes() {
    echo -e "\n${YELLOW}Analyzing scene files for optimization opportunities...${NC}"
    
    # Check EnhancedExplorationScene for disabled nodes
    if [ -f "$PROJECT_ROOT/scenes/3d/EnhancedExplorationScene.tscn" ]; then
        echo "Checking EnhancedExplorationScene.tscn:"
        
        # Count visible=false nodes
        HIDDEN_COUNT=$(grep -c "visible = false" "$PROJECT_ROOT/scenes/3d/EnhancedExplorationScene.tscn" || echo 0)
        echo "  Hidden nodes: $HIDDEN_COUNT"
        
        # Check for expensive effects
        if grep -q "ssao_enabled = true" "$PROJECT_ROOT/scenes/3d/EnhancedExplorationScene.tscn"; then
            echo -e "  ${YELLOW}⚠ SSAO enabled in scene (will be disabled on integrated graphics)${NC}"
        fi
        
        if grep -q "glow_enabled = true" "$PROJECT_ROOT/scenes/3d/EnhancedExplorationScene.tscn"; then
            echo -e "  ${YELLOW}⚠ Glow enabled in scene (will be disabled on integrated graphics)${NC}"
        fi
    fi
}

# Main execution
echo "1. Checking shader optimizations..."
check_shaders

echo -e "\n2. Analyzing scene files..."
analyze_scenes

echo -e "\n3. Running performance test..."
test_performance

echo -e "\n${GREEN}Performance optimization test complete!${NC}"
echo "Check the output above for GPU detection and optimization results."