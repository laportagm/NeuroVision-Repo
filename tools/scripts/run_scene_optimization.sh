#!/bin/bash

# Run Scene Optimization Script
# This script applies all Priority 1 optimizations to the EnhancedExploration scene

echo "=================================="
echo "NeuroVision Scene Optimization"
echo "=================================="
echo ""

# Set project path
PROJECT_PATH="/Users/gagelaporta/Desktop/NeuroVision-Repo"
GODOT_PATH="godot"  # Adjust if Godot is not in PATH

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project not found at $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

# Check if optimization script exists
if [ ! -f "tools/scripts/apply_scene_optimizations.gd" ]; then
    echo "❌ Error: Optimization script not found"
    exit 1
fi

echo "📁 Project: $PROJECT_PATH"
echo "🎮 Godot: $GODOT_PATH"
echo ""

# Create backup directory
mkdir -p backups/scenes
BACKUP_NAME="EnhancedExplorationScene_$(date +%Y%m%d_%H%M%S).tscn"
cp scenes/3d/EnhancedExplorationScene.tscn "backups/scenes/$BACKUP_NAME" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backup created: backups/scenes/$BACKUP_NAME"
else
    echo "⚠️  Warning: Could not create backup"
fi

echo ""
echo "🔧 Running optimization script..."
echo ""

# Run the optimization script
$GODOT_PATH --headless --script tools/scripts/apply_scene_optimizations.gd

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Optimization complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Open Godot and load the project"
    echo "2. Open scenes/3d/EnhancedExplorationScene.tscn"
    echo "3. Verify the changes:"
    echo "   - KeyLight and RimLight should be visible"
    echo "   - New nodes should exist (BrainModelLoader, etc.)"
    echo "   - Redundant nodes should be removed"
    echo "4. Run the scene with F6 to test"
    echo ""
    echo "💡 If issues occur, restore from: backups/scenes/$BACKUP_NAME"
else
    echo ""
    echo "❌ Optimization failed!"
    echo "Check the error messages above for details."
fi

echo ""
echo "=================================="