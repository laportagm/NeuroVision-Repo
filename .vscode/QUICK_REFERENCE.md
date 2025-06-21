# NeuroVision VSCode Quick Reference

## 🚀 Quick Start
```bash
# Open project in VSCode
code /Users/gagelaporta/Desktop/NeuroVision-Repo

# Or from project directory
cd /Users/gagelaporta/Desktop/NeuroVision-Repo
code .
```

## ⌨️ Essential Shortcuts

### Running & Debugging
- **F5** - Run with selected configuration
- **Shift + F5** - Stop debugging
- **Ctrl/Cmd + Shift + F5** - Restart
- **F9** - Toggle breakpoint
- **F10** - Step over
- **F11** - Step into

### Navigation
- **Ctrl/Cmd + P** - Quick file open
- **Ctrl/Cmd + Shift + P** - Command palette
- **Ctrl/Cmd + Shift + D** - Debug panel
- **Ctrl/Cmd + Shift + B** - Run build task

## 🎮 Launch Configurations

### Most Used
1. **🎮 Run NeuroVision** - Full app from menu
2. **🧠 Brain Explorer (Enhanced)** - Skip to 3D scene
3. **▶️ Debug Current Scene** - Test open scene
4. **📊 Performance Test** - Check FPS

### Quick Access
```
1. Press Ctrl/Cmd + Shift + D
2. Select configuration from dropdown
3. Press F5
```

## 📝 Code Snippets

Type these prefixes and press Tab:

- `nvclass` - NeuroVision class template
- `nvui` - UI component template
- `nvbrain` - Brain interaction handler
- `nvperf` - Performance check
- `nverror` - Error handling
- `ready` - _ready function
- `onready` - @onready variable
- `dprint` - Debug print

## 🔧 Common Tasks

### Run Tests
```bash
Tasks: Run Task → 🧪 Run Tests
```

### Clean Build
```bash
Tasks: Run Task → 🧹 Clean Build Cache
```

### Verify Assets
```bash
Tasks: Run Task → ✅ Verify Assets
```

## 🐛 Debugging Tips

### Set Conditional Breakpoint
1. Right-click breakpoint
2. "Edit Breakpoint"
3. Add condition: `structure_name == "hippocampus"`

### Debug Console
While debugging, use console for:
```gdscript
# Evaluate expressions
print(_brain_structures.keys())

# Call functions
_update_camera_position()

# Inspect variables
camera.global_position
```

## 📁 File Navigation

### Quick Find
- **Ctrl/Cmd + P** then:
  - `@` - Symbol in file
  - `#` - Symbol in workspace
  - `:` - Go to line

### Project Files
```
BrainInt → BrainInteractionController.gd
Enhanced → EnhancedExplorationScene
MainMenu → MainMenu.gd
```

## 🎨 UI Development

### Test Individual Components
1. Select "🎨 Test Info Panel" or "❓ Test Quiz Panel"
2. Press F5
3. Make changes
4. Shift + F5 to stop
5. F5 to restart

### Live Reload
Currently not supported in Godot, but:
1. Use "▶️ Debug Current Scene"
2. Keep scene open in Godot
3. Make changes
4. Quick restart with Shift + F5, F5

## 🔍 Performance Testing

### Check FPS
1. Select "📊 Performance Test"
2. Run (F5)
3. Watch console for FPS reports
4. Check collision shapes visibility

### Low-End Testing
1. Select "🐌 Low-End Device Test"
2. Simulates 30 FPS cap
3. Uses compatibility renderer

## 💡 Pro Tips

1. **Multi-cursor**: Alt + Click
2. **Rename symbol**: F2
3. **Format document**: Shift + Alt + F
4. **Fold all**: Ctrl/Cmd + K, Ctrl/Cmd + 0
5. **Terminal**: Ctrl/Cmd + ` (backtick)

## 🆘 Troubleshooting

### "Cannot connect to debugger"
```bash
# Kill any running Godot processes
pkill godot  # macOS/Linux
# or
taskkill /IM godot.exe /F  # Windows
```

### Breakpoints not hit
- Ensure debug configuration (not release)
- Check code path reaches breakpoint
- Try "Clean Build Cache" task

### Slow performance
- Close other applications
- Use "Performance Test" config
- Check Activity Monitor/Task Manager

## 📚 Resources

- [Godot Docs](https://docs.godotengine.org)
- [GDScript Reference](https://docs.godotengine.org/en/stable/classes/index.html)
- Project docs in `/docs` folder

---
**Remember**: F5 to run, F9 for breakpoints, Ctrl+P for files!
