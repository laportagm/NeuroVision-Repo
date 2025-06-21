# VSCode Godot Debugger Limitations & Workarounds

## The Problem

The VSCode Godot debugger extension has significant limitations:

1. **Cannot specify scene paths** - Only accepts "main", "current", or "pinned"
2. **No command-line arguments** - Cannot pass --print-fps, --verbose, etc.
3. **No environment variables** - Cannot set custom environment vars
4. **No advanced debug features** - Limited compared to other language debuggers

The errors you saw are because the extension strictly validates the launch.json schema and rejects many standard VSCode debug properties.

## Solutions

### 1. **Simplified launch.json**
We now have a minimal launch.json with only what the extension supports:
- Run from main scene
- Debug current scene
- Alternative port configuration

### 2. **Launch Helper Script**
Use the `launch_helper.sh` script for advanced launching:

```bash
# Make it executable
chmod +x launch_helper.sh

# Run it
./launch_helper.sh
```

This provides all the launch options we wanted:
- Skip to specific scenes
- Performance testing mode
- Debug with verbose output
- Clean and run

### 3. **In-Game Debug Menu**
Add the debug menu to your scenes for runtime control:

```gdscript
# In your main scene or as an autoload:
func _ready():
    var debug_menu = preload("res://src/ui/debug/DebugMenu.tscn").instantiate()
    add_child(debug_menu)
```

Press **F12** in-game to:
- Switch between scenes instantly
- Change quality settings
- Monitor performance
- Toggle debug visualizations

### 4. **Terminal Commands**
For specific needs, run directly from terminal:

```bash
# Skip to brain explorer
godot --path . res://src/scenes/EnhancedExplorationScene.tscn

# Performance testing
godot --path . --print-fps --verbose

# Run tests
godot --path . --script res://scripts/run_tests.gd --headless
```

## Quick Usage Guide

### For Quick Scene Testing:
1. Open the scene in Godot Editor
2. In VSCode, select "Debug Current Scene"
3. Press F5

### For Performance Testing:
```bash
./launch_helper.sh
# Select option 4
```

### For Different Entry Points:
Use the in-game debug menu (F12) to switch scenes without restarting

### For Debugging with Breakpoints:
1. Use the simple "Run NeuroVision" config
2. Set breakpoints in .gd files
3. Navigate to the code you want to debug

## Why These Limitations Exist

The Godot VSCode extension is relatively new and focuses on basic debugging rather than advanced features. Unlike mature debuggers (like for Python or JavaScript), it doesn't support the full Debug Adapter Protocol.

## Future Improvements

When the Godot extension improves, we can:
- Add back scene-specific configurations
- Use command-line arguments
- Set environment variables
- Have better debugging features

For now, the combination of:
- Simple launch.json (for basic debugging)
- Launch helper script (for advanced scenarios)
- In-game debug menu (for runtime control)

Provides all the functionality we need!
