# 🔍 NeuroVision Linting Quick Reference

## 🚀 Most Common Commands

```bash
# Before committing - run all checks
pre-commit run

# Format current file (VS Code)
Cmd+S (auto-formats on save)

# Format all GDScript files
gdformat **/*.gd

# Check for linting errors
gdlint **/*.gd
```

## ✅ GDScript Checklist

### Naming
- ✅ Classes: `PascalCase` → `BrainExplorer`
- ✅ Functions: `snake_case` → `load_brain_model()`
- ✅ Variables: `snake_case` → `hippocampus_size`
- ✅ Constants: `UPPER_SNAKE_CASE` → `MAX_STRUCTURES`
- ✅ Signals: `snake_case` → `structure_selected`

### Formatting
- ✅ Indentation: **TABS** (size 4)
- ✅ Line length: **100 characters max**
- ✅ File ending: **Newline at EOF**
- ✅ Trailing spaces: **None**

## 🔧 Quick Fixes

### Line too long?
```gdscript
# Split with backslash
var long_text: String = \
    "First part " + \
    "Second part"
```

### Wrong indentation?
```gdscript
# VS Code: Select all → Shift+Tab → Tab
# Or: gdformat filename.gd
```

### Trailing whitespace?
```bash
# Auto-removed on save in VS Code
# Or: pre-commit run trailing-whitespace --all-files
```

## 📁 File Types

| Extension | Indent | Size | Style |
|-----------|--------|------|-------|
| `.gd` | Tab | 4 | GDScript |
| `.tscn` | Tab | 4 | Godot |
| `.json` | Space | 2 | JSON |
| `.yml` | Space | 2 | YAML |
| `.md` | Space | 2 | Markdown |

## 🚨 Common Errors

### `gdlint: line too long (X > 100)`
→ Break the line at operators or commas

### `gdformat: invalid syntax`
→ Check for missing colons, parentheses

### `trailing-whitespace: Found trailing whitespace`
→ Save file in VS Code or run pre-commit

### `mixed-line-ending: Found mixed line endings`
→ File uses both CRLF and LF (fixed automatically)

## 🛠️ VS Code Shortcuts

- **Format Document**: `Shift+Alt+F`
- **Format Selection**: `Cmd+K Cmd+F`
- **Show Problems**: `Cmd+Shift+M`
- **Quick Fix**: `Cmd+.` on error

## 📝 Disable Linting

```gdscript
# Single line
# gdlint: disable=line-length
var very_long_line = "..."

# Entire file (at top)
# gdlint: skip-file

# Specific rule
# gdlint: disable=function-name
```

## 🔗 Resources

- [Full Linting Guide](../docs/LINTING_GUIDE.md)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [gdtoolkit Documentation](https://github.com/Scony/godot-gdscript-toolkit)

---

**Remember**: Linting keeps our medical education platform reliable and maintainable! 🏥🧠