# VSCode Configuration Guide for NeuroVision

## Overview
The `.vscode/launch.json` and `.vscode/tasks.json` files have been optimized for NeuroVision development. Here's how to use them effectively.

## Quick Start

### Running the Application
1. **F5** - Run the full application (starts from Main Menu)
2. **Ctrl/Cmd + Shift + D** - Open Debug panel
3. Select a configuration from the dropdown
4. Click the green play button

### Most Useful Configurations

#### 🎮 Run NeuroVision
- Default configuration
- Starts from Main Menu
- Full debugging capabilities

#### 🧠 Brain Explorer (Enhanced)
- Skips menu, goes directly to 3D brain
- Useful for testing interaction features
- Uses the enhanced scene with full UI

#### ▶️ Debug Current Scene
- Debugs whatever scene is open in Godot
- Great for quick testing

#### 📊 Performance Test
- Shows FPS counter
- Displays collision shapes
- Verbose output for optimization

## VSCode Shortcuts

### Launch Configurations
- **F5** - Start debugging with selected config
- **Shift + F5** - Stop debugging
- **Ctrl/Cmd + Shift + F5** - Restart debugging
- **F10** - Step over
- **F11** - Step into
- **Shift + F11** - Step out

### Tasks
- **Ctrl/Cmd + Shift + B** - Run default build task (Run NeuroVision)
- **Ctrl/Cmd + Shift + P** → "Tasks: Run Task" - See all tasks

## Key Features

### Debugging
- Set breakpoints in `.gd` files by clicking line numbers
- Inspect variables in Debug panel
- Use Debug Console for GDScript expressions

### Performance Testing
```bash
# Use "📊 Performance Test" configuration
# Shows:
- FPS counter
- Collision shapes
- Memory usage
```

### Quick Scene Testing
The configurations allow testing individual components:
- Main Menu only
- Info Panel only
- Quiz Panel only
- Model loading test

## Common Workflows

### 1. Testing Brain Interaction
```
1. Select "🧠 Brain Explorer (Enhanced)"
2. Press F5
3. Set breakpoints in BrainInteractionController.gd
4. Interact with the brain model
```

### 2. Performance Optimization
```
1. Select "📊 Performance Test"
2. Press F5
3. Monitor FPS while interacting
4. Check console for performance warnings
```

### 3. UI Development
```
1. Select component (e.g., "🎨 Test Info Panel")
2. Press F5
3. Make changes to the .tscn or .gd file
4. Press Shift + F5 to stop
5. Press F5 to restart with changes
```

### 4. Full Testing
```
1. Open Terminal in VSCode
2. Run: Tasks → "🧪 Complete Test Suite"
3. Check output for test results
```

## Tasks Available

### Build Tasks
- **🎮 Run NeuroVision** - Run the full app
- **🔧 Open in Godot Editor** - Open project in Godot
- **🚀 Quick Run (Skip Menu)** - Direct to brain scene

### Test Tasks
- **✅ Verify Assets** - Check all required files exist
- **🧪 Run Tests** - Run unit tests
- **🔍 Validate GDScript** - Check for syntax errors

### Utility Tasks
- **🧹 Clean Build Cache** - Clear .godot folder
- **📊 Show Performance Stats** - Run with performance monitoring
- **🔄 Refresh Autoloads** - Reload autoload scripts

## Troubleshooting

### "Cannot connect to Godot debugger"
1. Make sure Godot is not already running
2. Check port 6007 is not in use
3. Restart VSCode

### Breakpoints not working
1. Ensure you're running a debug configuration
2. Check breakpoint is in a `.gd` file
3. Make sure the code path reaches the breakpoint

### Performance issues in VSCode
1. Use "🐌 Low-End Device Test" to simulate constraints
2. Close unnecessary panels
3. Disable unused extensions

## Tips

1. **Use Compound Configurations** to run multiple scenes simultaneously
2. **Set conditional breakpoints** by right-clicking a breakpoint
3. **Use the Debug Console** to evaluate expressions during debugging
4. **Create custom configurations** by copying and modifying existing ones

## Custom Configuration Example

To add a new configuration for testing a specific feature:

```json
{
    "name": "🔬 Test My Feature",
    "type": "godot",
    "request": "launch",
    "project": "${workspaceFolder}",
    "port": 6007,
    "scene": "res://path/to/my/test_scene.tscn",
    "address": "127.0.0.1",
    "args": ["--my-custom-arg"]
}
```

Add this to the `configurations` array in `launch.json`.
