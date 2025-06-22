---
allowed-tools: filesystem, sequential-thinking, memory, codecmcp, github
description: Pre-loads comprehensive NeuroVision project context for accurate educational platform responses
---

# Context-Aware Response for NeuroVision Educational Platform

## 🔍 Automatic Context Gathering

### Project Overview
- **Project Type**: !`grep "config_version" project.godot | head -1`
- **Project Name**: !`grep "config/name" project.godot | head -1`
- **Main Scene**: !`grep "run/main_scene" project.godot | head -1`
- **Godot Version**: !`grep "config/features" project.godot | grep -o '"[0-9]\.[0-9]"' | head -1`

### Educational Platform State
- **Educational Components**: !`find src/core/knowledge src/core/educational -name "*.gd" 2>/dev/null | head -10 || echo "No educational components found"`
- **Assessment Tools**: !`find scenes -name "*assessment*" -o -name "*quiz*" -o -name "*test*" | head -10`
- **Knowledge Base Status**: !`grep -A 5 "KnowledgeService" project.godot`
- **Medical Data**: !`ls -la assets/data/*.json 2>/dev/null | grep -E "(anatomical|medical|brain)" | head -5`

### Current Development State
- **Recent Changes**: !`git log --oneline -10 2>/dev/null || echo "Git not initialized"`
- **Modified Files**: !`git status --porcelain 2>/dev/null | head -20 || echo "No git status available"`
- **Current Branch**: !`git branch --show-current 2>/dev/null || echo "No git branch"`
- **TODO/FIXME**: !`grep -r "TODO\|FIXME\|HACK\|BUG" --include="*.gd" src/ 2>/dev/null | head -10 || echo "No pending items"`

### Performance & Accessibility
- **Performance Settings**: !`grep -A 10 "\[rendering\]" project.godot | grep -E "(driver|quality|fps|memory)"`
- **Accessibility Status**: !`find src/ui -name "*access*" -o -name "*wcag*" -o -name "*a11y*" | head -10`
- **Current FPS Target**: !`grep -r "60.*fps\|fps.*60" --include="*.gd" src/ | head -3`
- **Memory Budget**: !`grep -r "memory.*budget\|500.*MB" --include="*.gd" src/ | head -3`

### Architecture & Systems
- **Core Systems**: !`ls -la src/core/ 2>/dev/null | grep -E "/$" | awk '{print $9}' | head -10`
- **Autoload Services**: !`grep -A 30 "\[autoload\]" project.godot | grep -E "Manager|Service|System" | head -15`
- **UI Architecture**: !`ls -la src/ui/ 2>/dev/null | head -10`
- **3D Models**: !`find assets -name "*.glb" -o -name "*.gltf" | grep -i brain | head -10`

### Educational Features
- **Learning Pathways**: !`grep -r "learning.*path\|educational.*level" --include="*.gd" src/ | head -5`
- **Medical Accuracy**: !`grep -r "medical.*accuracy\|anatomical.*data" --include="*.gd" src/ | head -5`
- **Student Progress**: !`grep -r "ProgressTracker\|student.*progress" --include="*.gd" src/ | head -5`
- **Theme System**: !`grep -r "Enhanced.*Theme\|Minimal.*Theme" --include="*.gd" src/ui/ | head -5`

### Debug & Testing
- **Debug Commands**: !`grep -r "console_command\|debug_command" --include="*.gd" src/ | head -10`
- **Test Results**: !`find . -name "*test*results*" -o -name "*test*log*" | head -5`
- **Quality Scripts**: !`ls -la tools/scripts/*.sh 2>/dev/null | head -5`

### Memory & Context Files
- **CLAUDE.md**: !`grep -A 10 "Educational Mission" CLAUDE.md 2>/dev/null || echo "No CLAUDE.md found"`
- **Project Path**: !`pwd`

## 📋 Query Context

**Your Query**: $ARGUMENTS

## 🧠 NeuroVision-Specific Context Instructions

You are Claude, working on the **NeuroVision Educational Platform** - an interactive 3D brain visualization tool for medical education. Based on the context gathered above, provide responses that are:

### Core Principles:
1. **Educational Excellence**: Focus on medical student learning outcomes
2. **Medical Accuracy**: Ensure anatomical terminology is correct
3. **Performance-Aware**: 60 FPS on Intel UHD 620 graphics
4. **Accessibility-First**: WCAG 2.1 AA compliance required
5. **Offline-Capable**: Must work without internet connection

### Key Technical Context:
- **Engine**: Godot 4.4.1 with GDScript
- **Architecture**: Modular autoload system with educational managers
- **UI System**: Dual theme (Enhanced for students, Minimal for professionals)
- **Data Format**: JSON-based anatomical knowledge base
- **3D Pipeline**: GLTF/GLB brain models with medical accuracy

### Response Guidelines by Query Type:

#### 🎓 Educational Features:
- Reference KnowledgeService for content
- Consider learning pathway progression
- Include assessment integration points
- Mention accessibility requirements

#### 🧠 3D Brain Visualization:
- Reference BrainInteractionController
- Consider medical accuracy requirements
- Include performance optimization needs
- Mention camera preset system (1, 3, 7 keys)

#### 💻 Code Architecture:
- Use autoload pattern for services
- Follow GDScript naming conventions
- Reference existing managers/services
- Consider pre-commit hooks

#### 🎨 UI Development:
- Use UIThemeManager for theming
- Reference InfoPanelFactory pattern
- Consider dual theme requirements
- Include accessibility features

#### 🔧 Performance:
- Target 60 FPS consistently
- Consider 500MB memory budget
- Reference PerformanceOptimizer
- Test on Intel UHD 620

### Smart Context Loading:

Based on "$ARGUMENTS", examine these specific areas:

- **If about brain interaction**: @src/core/interaction/BrainInteractionController.gd
- **If about UI panels**: @src/ui/panels/ @src/ui/components/
- **If about educational content**: @src/core/knowledge/KnowledgeService.gd @assets/data/anatomical_data.json
- **If about themes**: @src/ui/theme/ @src/ui/UnifiedColorManager.gd
- **If about performance**: @src/core/systems/PerformanceOptimizer.gd
- **If about autoloads**: @project.godot [autoload] section
- **If about assessment**: @src/core/educational/assessment/
- **If about accessibility**: @src/ui/accessibility/

### Educational Platform Checklist:
- ✓ Maintains medical terminology accuracy
- ✓ Supports both student and professional users
- ✓ Includes learning progression tracking
- ✓ Ensures offline functionality
- ✓ Follows Godot 4.4.1 best practices
- ✓ Integrates with existing autoload systems
- ✓ Respects performance constraints
- ✓ Implements accessibility features

### Common NeuroVision Patterns:
```gdscript
# Autoload integration pattern
if not is_instance_valid(KnowledgeService):
    push_error("[Component] KnowledgeService not available")
    return

# Theme-aware UI pattern
UnifiedColorManager.theme_changed.connect(_on_theme_changed)

# Educational error handling
func handle_educational_error(error: EducationalError):
    match error:
        EducationalError.MEDICAL_INACCURACY:
            medical_review_logger.log_issue()
```

Now, with full NeuroVision educational platform context, provide an accurate response to: **$ARGUMENTS**