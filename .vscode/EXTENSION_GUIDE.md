# NeuroVision Extension Configuration Guide

This guide explains how to use the configured VS Code/Cursor extensions for the NeuroVision project.

## 🎯 Quick Setup Checklist

1. **Install Required Extensions**
   - Open Command Palette (`Cmd+Shift+P`)
   - Run: `Extensions: Show Recommended Extensions`
   - Install all workspace recommendations

2. **Reload VS Code/Cursor**
   - Command Palette → `Developer: Reload Window`

## 🧠 Godot Development Extensions

### Godot Tools (`geequlim.godot-tools`)
- **Auto-configured**: Editor path and LSP port set
- **Features**:
  - GDScript IntelliSense
  - Go to definition (`F12`)
  - Find references (`Shift+F12`)
  - Auto-completion
- **Troubleshooting**:
  - Ensure Godot editor is closed when using LSP
  - Check port 6008 is not in use

### Godot Files (`alfish.godot-files`)
- **Auto-configured**: File associations set
- **Features**:
  - Proper icons for `.gd`, `.tscn`, `.tres` files
  - Quick file creation templates

## 📝 Code Quality Extensions

### TODO Tree (`Gruntfuggly.todo-tree`)
- **Custom Tags Configured**:
  - `TODO:` - General tasks (blue)
  - `FIXME:` - Bugs to fix (red)
  - `BUG:` - Known bugs (dark red)
  - `MEDICAL:` - Medical accuracy notes (pink)
  - `EDUCATIONAL:` - Educational features (green)
  - `ACCESSIBILITY:` - WCAG compliance (purple)
  - `PERFORMANCE:` - Performance optimizations (orange)
  - `NEUROVIS:` - Project-specific (cyan)
- **Usage**: Click TODO icon in activity bar to see all tags

### Error Lens (`usernamehw.errorlens`)
- **Auto-configured**: Shows inline errors with custom styling
- **Features**:
  - Inline error/warning display
  - Excludes spell check warnings
  - Status bar integration

### Code Spell Checker (`streetsidesoftware.code-spell-checker`)
- **Custom Dictionaries**:
  - Medical terms: `.vscode/dictionaries/medical.txt`
  - Neuroscience terms: `.vscode/dictionaries/neuroscience.txt`
- **Adding Words**: Right-click → "Add to workspace dictionary"

## 🔍 Git Extensions

### GitLens (`eamodio.gitlens`)
- **Configured Features**:
  - Current line blame (hover over line)
  - File history view
  - Line history view
  - Repository view
- **Disabled**: Code lens (for performance)
- **Usage**: 
  - `Alt+B` - Toggle line blame
  - Click status bar item for file history

### Git Graph (`mhutchie.git-graph`)
- **View Branch Graph**: Click Git Graph icon in source control
- **Features**:
  - Visual branch history
  - Cherry-pick commits
  - Create branches/tags

## 🚀 Productivity Extensions

### Bookmarks (`alefragnani.Bookmarks`)
- **Shortcuts**:
  - `Cmd+Alt+K` - Toggle bookmark
  - `Cmd+Alt+J` - Jump to previous
  - `Cmd+Alt+L` - Jump to next
- **Features**: Bookmarks saved in project

### Path Intellisense (`christian-kohler.path-intellisense`)
- **Custom Mappings**:
  - `res://` → Project root (Godot style)
  - `src/` → Source directory
  - `scenes/` → Scenes directory
  - `assets/` → Assets directory
- **Usage**: Start typing path in strings

### Trailing Spaces (`shardulm94.trailing-spaces`)
- **Auto-configured**: Removes trailing spaces on save
- **Visual**: Highlights trailing spaces in red

## 🎨 Visual Enhancements

### Material Icon Theme
- **Custom Icons**:
  - `.gd` files → Godot icon
  - `.tscn` files → Scene icon
  - `.tres` files → Resource icon
  - `CLAUDE.md` → Robot icon
- **Folder Icons**:
  - `autoload` → Core icon
  - `ui_atomic` → Components icon
  - `3d_models` → 3D icon

### Color Highlight (`naumovs.color-highlight`)
- **Features**: Shows color preview for hex/rgb values
- **Usage**: Hover over color values to see preview

## 🤖 AI Assistants

### GitHub Copilot
- **Enabled for**: GDScript, Markdown, JSON
- **Usage**: 
  - `Tab` - Accept suggestion
  - `Alt+]` - Next suggestion
  - `Alt+[` - Previous suggestion

### Claude Code (Anthropic)
- **Integrated**: Uses `.cursorrules` for context
- **Usage**: Natural language code generation

## 📚 Documentation

### Markdown All in One
- **Features**:
  - TOC generation
  - Preview (`Cmd+K V`)
  - Format tables
  - List editing

### Markdown Lint
- **Disabled Rules**:
  - MD033 (HTML allowed)
  - MD024 (Duplicate headers allowed)

## ⚡ Performance Tips

1. **Large Files**: GitLens may slow down - disable for specific files
2. **TODO Tree**: Limit search scope if slow
3. **Error Lens**: Exclude sources causing noise
4. **Spell Checker**: Add medical terms to dictionary to reduce false positives

## 🔧 Troubleshooting

### Extension Not Working?
1. Check extension is installed and enabled
2. Reload window: `Cmd+Shift+P` → `Developer: Reload Window`
3. Check Output panel for extension errors

### Godot LSP Issues?
1. Ensure Godot editor is closed
2. Check port 6008 is free
3. Verify Godot path in settings

### Performance Issues?
1. Disable GitLens code lens
2. Reduce TODO Tree file watching
3. Limit Error Lens to errors only

## 📋 Keyboard Shortcuts Summary

| Action | Shortcut |
|--------|----------|
| Go to Definition | `F12` |
| Find References | `Shift+F12` |
| Toggle Bookmark | `Cmd+Alt+K` |
| Next Bookmark | `Cmd+Alt+L` |
| Previous Bookmark | `Cmd+Alt+J` |
| Show TODO Tree | Click activity bar icon |
| Git Graph | Click source control icon |
| Toggle Line Blame | `Alt+B` |
| Preview Markdown | `Cmd+K V` |

## 🎯 Project-Specific Usage

### Medical Accuracy
- Use `MEDICAL:` tags for accuracy notes
- Add medical terms to dictionary
- Use spell checker for terminology

### Educational Features
- Tag with `EDUCATIONAL:` for learning features
- Use `ACCESSIBILITY:` for WCAG compliance
- Track with `PERFORMANCE:` for optimization needs

### Brain Structure Work
- Bookmark important brain structures
- Use path mappings for asset references
- Track medical accuracy with custom tags