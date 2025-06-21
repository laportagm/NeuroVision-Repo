# NeuroVision Documentation - Claude Code Navigation Hub

🤖 **Optimized for Claude Code Autonomous Operation**

## 🎯 Quick Navigation for Claude Code

### Primary Development Guide
📖 **[CLAUDE.md](./CLAUDE.md)** - Your main development instructions and project overview

### Self-Updating Architecture
🔄 **[Current Architecture](./auto-generated/current-architecture.md)** - Live project structure (auto-updated)  
📂 **[File Index](./auto-generated/file-index.md)** - Quick file location reference (auto-updated)

### Code Templates (Use These!)
📋 **[UI Component Template](./templates/ui-component-template.md)** - For creating new UI components  
🔧 **[Autoload Template](./templates/autoload-template.md)** - For creating new services  
🎬 **[Scene Template](./templates/scene-template.md)** - For creating new educational scenes

### Development Workflows
🎨 **[UI Development Workflow](./workflows/ui-development.md)** - Step-by-step UI creation  
⚡ **[Performance Optimization](./workflows/performance-optimization.md)** - Intel UHD 620 optimization  
🐛 **[Debugging Workflow](./workflows/debugging.md)** - Comprehensive debugging guide

### Reference Documentation
📏 **[Development Standards](./reference/standards.md)** - Coding standards and requirements  
🎯 **[Performance Targets](./reference/performance-targets.md)** - Performance requirements  
♿ **[Accessibility Guidelines](./reference/accessibility-guidelines.md)** - WCAG AAA compliance

## 🤖 Claude Code Operation Guide

### When Starting Any Task:
1. **Read CLAUDE.md first** - Contains current project context and instructions
2. **Check auto-generated docs** - Current architecture and file locations
3. **Use templates** - Don't write from scratch, customize existing patterns
4. **Follow workflows** - Step-by-step procedures for common tasks

### For UI Development:
```bash
1. Read: docs/workflows/ui-development.md
2. Use: docs/templates/ui-component-template.md  
3. Location: src/ui_atomic/[atoms|molecules|organisms]/
4. Test: Create in scenes/test_components/
5. Integrate: Register with UISystemManager
```

### For Autoload Creation:
```bash
1. Read: docs/workflows/autoload-development.md (if exists)
2. Use: docs/templates/autoload-template.md
3. Location: src/autoload/ or src/core/managers/
4. Register: Add to project.godot [autoload] section
5. Test: Use debug console validation commands
```

### For Performance Work:
```bash
1. Read: docs/workflows/performance-optimization.md
2. Target: Intel UHD 620 compatibility (30+ FPS minimum)
3. Monitor: Use PerformanceMonitor autoload
4. Validate: Run performance debug commands
```

### For Debugging Issues:
```bash
1. Read: docs/workflows/debugging.md
2. Use: F1 debug console commands
3. Check: Autoload status, UI safety, performance
4. Report: Update debugging workflow with solutions
```

## 📁 Documentation Structure

```
docs/
├── README.md                    # 🎯 This navigation hub
├── CLAUDE.md                    # 📖 Main development guide
├── auto-generated/              # 🔄 Self-updating documentation
│   ├── current-architecture.md  # 🏗️  Live project structure
│   └── file-index.md           # 📂 File location reference
├── templates/                   # 📋 Code generation templates
│   ├── ui-component-template.md # 🎨 UI component pattern
│   ├── autoload-template.md     # 🔧 Service pattern
│   └── scene-template-template.md # 🎬 Scene pattern
├── workflows/                   # 📋 Development procedures
│   ├── ui-development.md        # 🎨 UI creation workflow
│   ├── performance-optimization.md # ⚡ Optimization workflow
│   └── debugging.md             # 🐛 Debugging workflow
├── reference/                   # 📖 Reference documentation
│   ├── standards.md             # 📏 Development standards
│   ├── performance-targets.md   # 🎯 Performance requirements
│   └── accessibility-guidelines.md # ♿ Accessibility standards
└── archived/                    # 📦 Historical documentation
    ├── implementations/         # ✅ Completed work
    ├── reports/                 # 📊 Historical reports
    └── legacy/                  # 📜 Outdated documentation
```

## 🔄 Self-Updating Documentation

**These files update automatically as you work:**
- `auto-generated/current-architecture.md` - Scans project structure
- `auto-generated/file-index.md` - Tracks file locations
- `workflows/*.md` - Add improvements and new patterns
- `templates/*.md` - Enhance templates with discovered patterns

**How to Update Documentation:**
1. **Templates**: Add new patterns when you discover better approaches
2. **Workflows**: Document improved procedures in "Recent Improvements" sections
3. **Architecture**: Regenerate when autoloads or structure changes
4. **File Index**: Update when creating/moving important files

## 🎯 Common Tasks - Quick Reference

### "Create new UI component"
→ `workflows/ui-development.md` + `templates/ui-component-template.md`

### "Add new autoload service"  
→ `templates/autoload-template.md` + register in `project.godot`

### "Optimize performance"
→ `workflows/performance-optimization.md` + Intel UHD 620 targets

### "Debug educational system"
→ `workflows/debugging.md` + F1 console commands

### "Check architecture"
→ `auto-generated/current-architecture.md` (live project scan)

### "Find specific file"
→ `auto-generated/file-index.md` (71 GDScript files indexed)

## 📊 Project Status Summary

**Autoload Services**: 13 active educational systems  
**Performance**: 120+ FPS stable (exceeds 30+ FPS Intel UHD 620 target)  
**UI Components**: 3-tier atomic design structure  
**Educational Features**: Assessment, progress tracking, accessibility  
**Theme System**: Enhanced/Minimal modes for different audiences  
**Architecture**: Mature educational platform operational  

## 🚀 Recent Updates

**2025-06-21**: Complete documentation reorganization  
- ✅ Self-updating documentation structure created  
- ✅ Code templates for autonomous development  
- ✅ Workflows for common development tasks  
- ✅ Auto-generated architecture and file indexing  
- ✅ Archived historical documentation (preserving 35+ files)  

## 🎯 For New Claude Code Sessions

1. **Start Here**: Read this README for navigation
2. **Project Context**: Review `CLAUDE.md` for current project state  
3. **Architecture**: Check `auto-generated/current-architecture.md` for system overview
4. **File Locations**: Use `auto-generated/file-index.md` for quick file access
5. **Templates**: Always use templates from `templates/` for new code
6. **Workflows**: Follow step-by-step procedures in `workflows/`
7. **Update Documentation**: Add improvements to relevant files as you work

---

**Documentation System**: Self-updating for Claude Code autonomous operation  
**Last Updated**: 2025-06-21  
**Project**: NeuroVision Educational Platform 2.1.0  
**Architecture**: 13 autoloads, 71 GDScript files, Educational focus