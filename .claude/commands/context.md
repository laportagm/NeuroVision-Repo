---
allowed-tools: filesystem, sequential-thinking, memory, codecmcp, github
description: Pre-loads comprehensive project context for more accurate and relevant responses to any NeuroVision query
---

# Context-Aware Response for NeuroVision

## 🔍 Automatic Context Gathering

### Project Overview
- **Project Type**: !`grep "config_version" project.godot | head -1`
- **Project Name**: !`grep "config/name" project.godot | head -1`
- **Main Scene**: !`grep "run/main_scene" project.godot | head -1`
- **Rendering Settings**: !`grep -A 5 "\[rendering\]" project.godot | grep -E "(driver|quality|shading|anti_aliasing)"`

### Current Development State
- **Recent Changes**: !`git log --oneline -10 2>/dev/null || echo "Git not initialized"`
- **Modified Files**: !`git status --porcelain 2>/dev/null | head -20 || echo "No git status available"`
- **Current Branch**: !`git branch --show-current 2>/dev/null || echo "No git branch"`
- **TODO/FIXME**: !`grep -r "TODO\|FIXME\|HACK\|BUG" --include="*.gd" . 2>/dev/null | head -10 || echo "No pending items found"`

### Performance & Issues
- **Error Log**: !`grep -i "error\|warning" *.log 2>/dev/null | tail -10 || echo "No error logs found"`
- **Performance Files**: !`find . -name "*Performance*" -o -name "*Optimizer*" -o -name "*FPS*" | grep -v ".godot"`
- **Current FPS Target**: !`grep -r "fps\|FPS\|frame" --include="*.gd" . | grep -i "target\|goal\|requirement" | head -5`

### Architecture & Structure
- **Core Systems**: !`ls -la core/ 2>/dev/null | grep -E "\.gd$" | awk '{print $9}' | head -10 || echo "No core directory"`
- **Autoload Services**: !`grep -A 30 "\[autoload\]" project.godot | grep -v "^$" | grep -v "^\["`
- **Scene Count**: !`find . -name "*.tscn" | wc -l`
- **Script Count**: !`find . -name "*.gd" | wc -l`
- **Educational Modules**: !`ls -la educational/ 2>/dev/null | head -10 || echo "No educational directory"`

### Memory & Context Files
- **CLAUDE.md**: !`head -20 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md memory file"`
- **Recent Commands**: !`tail -5 ~/.claude/history 2>/dev/null || echo "No command history"`

## 📋 Query Context

**Your Query**: $ARGUMENTS

## 🧠 Contextual Awareness Instructions

You are Claude, working on the NeuroVision educational neuroscience platform. Based on the context gathered above, provide a response that is:

1. **Project-Aware**: Consider the current state, recent changes, and development focus
2. **Performance-Conscious**: Remember the 30+ FPS target on Intel UHD 620 graphics
3. **Education-Focused**: This is for medical students learning neuroanatomy
4. **Accessibility-Minded**: WCAG AAA compliance is required
5. **Context-Relevant**: Use the information gathered above to inform your response

### Key Project Details to Remember:
- **Platform**: Godot 4.4.1 educational 3D visualization
- **Audience**: Medical students and educators
- **Constraints**: Must work offline, low-end hardware support
- **Current Focus**: Based on recent commits and modified files above
- **Known Issues**: As shown in TODO/FIXME items and error logs

### Response Guidelines:

1. **If the query is about code**: 
   - Reference the specific files shown in the context
   - Consider recent changes that might affect the answer
   - Account for the project's modular architecture

2. **If the query is about performance**:
   - Remember current FPS issues if shown in logs
   - Consider Intel UHD 620 constraints
   - Reference performance-related files found above

3. **If the query is about features**:
   - Check if related systems exist in core/ or educational/
   - Consider the autoload services available
   - Think about offline-first requirements

4. **If the query is about bugs/issues**:
   - Reference any relevant TODO/FIXME items
   - Check error logs for related problems
   - Consider recent git changes that might be related

5. **If the query is general**:
   - Still maintain awareness of the project type
   - Keep responses relevant to educational game development
   - Consider the medical/scientific accuracy requirement

### Smart File Loading

Based on the query "$ARGUMENTS", also examine these potentially relevant files:

- If about UI: @ui/theme/glass_panel.gdshader @ui/panels/
- If about performance: @core/managers/PerformanceOptimizer.gd
- If about brain models: @core/models/ @educational/anatomy/
- If about interaction: @core/interaction/BrainInteractionController.gd
- If about education: @educational/ @assessment/
- If about data: @core/services/UserDataService.gd

### Response Quality Checklist:
- ✓ Uses actual project structure (not generic examples)
- ✓ References real files from the context scan
- ✓ Considers recent development activity
- ✓ Maintains focus on educational effectiveness
- ✓ Provides actionable, specific guidance
- ✓ Remembers performance constraints
- ✓ Keeps medical accuracy in mind

Now, with full awareness of the NeuroVision project context, provide a highly relevant and accurate response to: **$ARGUMENTS**