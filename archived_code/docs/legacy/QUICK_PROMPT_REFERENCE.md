# NeuroVis Quick Prompt Reference

## Copy-Paste Templates

### 🎮 New System/Manager
```
Implement [SYSTEM_NAME] for NeuroVis Phase [1/2/3].
File: src/[PATH]/[SYSTEM_NAME].gd
Requirements: [LIST]
Must integrate with: [AUTOLOADS]
Performance: 30+ FPS on Intel UHD 620
Accessibility: Full keyboard + screen reader support
Update PROJECT_PROGRESS.md when complete.
```

### 🖼️ UI Component
```
Create [COMPONENT] UI for NeuroVis.
Files: src/ui/components/[NAME].gd and .tscn
Educational purpose: [WHAT STUDENTS LEARN]
Accessibility: Keyboard nav, screen reader, high contrast
Age-appropriate for high school+
Emit signals: [SIGNAL_LIST]
```

### 🧠 3D Feature
```
Add [FEATURE] to 3D brain interaction.
File: src/systems/3d_interaction/[NAME].gd
Enable students to: [LEARNING ACTIVITY]
Controls: Mouse + keyboard fallback
Performance: Work with 10K polygon models
Announce interactions to AccessibilityManager
```

### ✅ Assessment/Quiz
```
Create [QUESTION_TYPE] for assessments.
File: src/systems/assessment/QuestionTypes/[TYPE].gd
Test knowledge of: [CONCEPTS]
Features: Randomization, feedback, progress tracking
Offline-first with ContentManager
Keyboard shortcuts for answers
```

## 🔧 Essential Code Snippets

### Error Handling
```gdscript
ErrorRecoveryManager.handle_error(
    ErrorRecoveryManager.ErrorType.ERROR_TYPE,
    {"context": "what happened"}
)
```

### Performance Check
```gdscript
if PerformanceMonitor.get_average_fps() < 30:
    # Reduce quality
```

### Accessibility Setup
```gdscript
control.accessible_name = "Name"
AccessibilityManager.register(control)
```

### Signal Pattern
```gdscript
signal action_completed(param: Type)
action_completed.emit(value)
```

## 📋 Always Remember

1. **Check** PROJECT_PROGRESS.md first
2. **Reference** PROJECT_OUTLINE.md for specs  
3. **Test** accessibility with keyboard only
4. **Verify** 30+ FPS performance
5. **Update** progress tracker after completion
6. **Include** error handling everywhere
7. **Work** offline-first (no internet required)

## 🚀 Quick Commands

```bash
# Update progress
./scripts/update_progress.sh "Task name" "done"

# Run project
godot --path .

# Quick test
godot --script test_[component].gd
```

## 📁 Key File Locations

- **Autoloads**: `src/autoload/`
- **3D Systems**: `src/systems/3d_interaction/`
- **UI Components**: `src/ui/components/`
- **Assessments**: `src/systems/assessment/`
- **Tests**: `tests/unit/`
- **Docs**: `docs/`

## ⚡ Phase Focus

- **Phase 1** (Current): Core 3D, Performance, UI Framework
- **Phase 2**: Teacher tools, Assessment, Basic cloud
- **Phase 3**: Deployment, Polish, Documentation

Keep this open while working!
