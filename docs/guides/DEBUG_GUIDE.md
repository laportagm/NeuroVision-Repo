# NeuroVision Debug Guide

## Overview
This guide provides comprehensive debugging tools and techniques for the NeuroVision educational platform.

## Quick Start

### 1. Enhanced Debug Script
```bash
# Run the enhanced debug script
./debug_neurovision_enhanced.sh

# Options:
# 1) Quick error scan - Scans codebase for common issues
# 2) Run with full debug output - Launches Godot with verbose logging
# 3) Analyze existing logs - Reviews previous debug sessions
# 4) Run comprehensive test suite - Full system check
# 5) Check specific file for errors - Target specific files
# 6) Monitor real-time debug output - Live error monitoring
```

### 2. Comprehensive Error Check
```bash
# Run comprehensive error detection
./tools/scripts/comprehensive_error_check.sh

# This checks for:
# - Python-style syntax (try/except)
# - Missing node references
# - Resource loading issues
# - Signal connection problems
# - Shader compilation errors
# - Scene file dependencies
# - Performance concerns
# - Memory leaks
# - TODO/FIXME comments
```

## In-Game Debug Tools

### Debug System (Autoload)
The DebugSystem provides real-time monitoring and logging:

```gdscript
# Access from any script
if has_node("/root/DebugSystem"):
    var debug = get_node("/root/DebugSystem")
    
    # Log messages
    debug.log_debug("CATEGORY", "Debug message")
    debug.log_warning("CATEGORY", "Warning message")
    debug.log_error("CATEGORY", "Error message")
    
    # Performance profiling
    debug.start_profiling("my_function")
    # ... code to profile ...
    var time_ms = debug.end_profiling("my_function")
    
    # Check resources
    debug.check_resource_exists("res://path/to/resource.tres")
    
    # Check node paths
    var node = debug.check_node_path(self, "UI/Panel", "for UI setup")
```

### Debug Console (Press ` to toggle)
In-game console with comprehensive commands:

#### System Commands
- `help` - Show available commands
- `clear` - Clear console output
- `exit`/`quit` - Close console

#### Debug Commands
- `fps` - Show current FPS
- `memory` - Display memory usage
- `nodes` - Count active nodes
- `errors` - Show error summary
- `autoloads` - Check autoload status
- `performance` - Display performance metrics

#### Scene Commands
- `scene [name]` - Load scene or show current
- `reload` - Reload current scene
- `screenshot` - Take screenshot

#### Educational Commands
- `brain [structure]` - Show brain structure info
- `theme [enhanced|minimal]` - Change theme
- `knowledge [query]` - Search knowledge base
- `validate` - Validate educational content

#### Testing Commands
- `test [autoloads|ui|performance|all]` - Run tests
- `stress [nodes|memory|rendering]` - Run stress tests
- `profile [function_name]` - Profile function performance

## Debug Overlay
When DebugSystem is active, a debug overlay appears showing:
- FPS and frame time
- Memory usage
- Error count
- Active node count
- System status

## Common Debugging Patterns

### 1. Null Reference Prevention
```gdscript
# Instead of:
node.do_something()

# Use:
if is_instance_valid(node):
    node.do_something()
else:
    push_error("Node is null or freed")
```

### 2. Resource Loading Validation
```gdscript
# Instead of:
var resource = load("res://path/to/resource.tres")

# Use:
if ResourceLoader.exists("res://path/to/resource.tres"):
    var resource = load("res://path/to/resource.tres")
else:
    push_error("Resource not found: res://path/to/resource.tres")
```

### 3. Signal Connection Safety
```gdscript
# Instead of:
node.signal_name.connect(_on_signal)

# Use:
if node.has_signal("signal_name"):
    if not node.signal_name.is_connected(_on_signal):
        node.signal_name.connect(_on_signal)
```

### 4. Node Path Validation
```gdscript
# Instead of:
var panel = get_node("UI/Panel")

# Use:
var panel = get_node_or_null("UI/Panel")
if not panel:
    push_error("Panel node not found at path: UI/Panel")
    return
```

## Performance Debugging

### 1. Monitor Frame Time
```gdscript
func _process(delta):
    if delta > 0.02:  # More than 20ms (50 FPS)
        push_warning("Frame took %.2fms" % (delta * 1000))
```

### 2. Track Memory Growth
```gdscript
func _ready():
    if has_node("/root/DebugSystem"):
        var debug = get_node("/root/DebugSystem")
        debug.memory_tracking = true
```

### 3. Profile Critical Functions
```gdscript
func expensive_operation():
    var debug = get_node("/root/DebugSystem")
    debug.start_profiling("expensive_operation")
    
    # ... expensive code ...
    
    var time = debug.end_profiling("expensive_operation")
    if time > 5.0:  # More than 5ms
        push_warning("Operation took %.2fms" % time)
```

## Error Recovery Patterns

### 1. Autoload Fallbacks
```gdscript
func get_unified_color_manager():
    var manager = get_node_or_null("/root/UnifiedColorManager")
    if not manager:
        push_error("UnifiedColorManager not available")
        # Return default implementation
        return preload("res://src/fallbacks/DefaultColorManager.gd").new()
    return manager
```

### 2. Scene Loading Recovery
```gdscript
func safe_change_scene(path: String):
    if not ResourceLoader.exists(path):
        push_error("Scene not found: " + path)
        # Load fallback scene
        get_tree().change_scene_to_file("res://scenes/ui/ErrorScene.tscn")
        return
    
    var result = get_tree().change_scene_to_file(path)
    if result != OK:
        push_error("Failed to load scene: " + path)
```

## Debugging Shortcuts

### Editor Shortcuts
- `F1` - Open debug console (in-game)
- `` ` `` - Toggle debug console (with DebugConsole)
- `F6` - Run current scene
- `F5` - Run project
- `Ctrl+Shift+D` - Open debugger

### Console Commands Quick Reference
```bash
# In debug console (`)
fps                    # Check FPS
memory                 # Check memory usage
errors                 # Show error summary
test all              # Run all tests
stress nodes          # Stress test with 1000 nodes
validate              # Validate system state
brain hippocampus     # Get brain structure info
theme minimal         # Switch to minimal theme
```

## Troubleshooting Common Issues

### 1. Parse Errors
```bash
# Check for Python syntax
grep -n "try:\|except:" scenes/3d/EnhancedExplorationScene.gd
```

### 2. Missing Autoloads
```bash
# In debug console
autoloads
# Or in GDScript
test autoloads
```

### 3. Performance Issues
```bash
# In debug console
performance
# Or use debug overlay to monitor in real-time
```

### 4. Memory Leaks
```bash
# Run memory stress test
stress memory
# Monitor with debug overlay
```

## Advanced Debugging

### 1. Remote Debugging
```bash
# Start Godot with remote debugging
godot --remote-debug tcp://127.0.0.1:6007
```

### 2. Profiler Integration
Use Godot's built-in profiler:
- Debug → Start Profiling
- Monitor function calls and execution time
- Identify performance bottlenecks

### 3. Custom Debug Markers
```gdscript
# Add custom debug markers
if OS.is_debug_build():
    RenderingServer.canvas_item_add_debug_rect(
        get_canvas_item(),
        Rect2(Vector2.ZERO, size),
        Color.RED
    )
```

## Best Practices

1. **Always validate external references** (nodes, resources, signals)
2. **Use debug builds** for development (`--debug` flag)
3. **Monitor performance metrics** regularly
4. **Log meaningful error messages** with context
5. **Implement error recovery** mechanisms
6. **Profile critical code paths**
7. **Use version control** to track error introduction
8. **Document known issues** and workarounds

## Debug Output Files

Generated debug files are saved to:
- `user://debug_log_[timestamp].txt` - Debug system logs
- `user://debug_report_[timestamp].txt` - Debug reports
- `user://screenshot_[timestamp].png` - Debug screenshots
- `error_report_[timestamp].txt` - Comprehensive error reports

Access user directory:
- Windows: `%APPDATA%/Godot/app_userdata/NeuroVision/`
- macOS: `~/Library/Application Support/Godot/app_userdata/NeuroVision/`
- Linux: `~/.local/share/godot/app_userdata/NeuroVision/`

## Testing Debug Systems

To verify all debug systems are working:

```bash
# 1. Run the debug systems test
godot --path /Users/gagelaporta/Desktop/NeuroVision-Repo res://test_debug_systems.tscn

# 2. Or from Godot editor
# Open test_debug_systems.tscn and run it (F6)
```

This will test:
- DebugSystem autoload functionality
- DebugConsole availability
- All autoloads status
- Performance monitoring
- Debug command execution

---

Remember: Good debugging is about **prevention** (validation), **detection** (monitoring), and **recovery** (error handling).