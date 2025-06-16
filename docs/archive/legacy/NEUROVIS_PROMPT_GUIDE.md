# NeuroVis Prompt Engineering Guide

## Quick Reference - 7 Core Principles

1. **Godot-First Implementation** - All code must be GDScript for Godot 4.x
2. **Educational Context** - Always consider learning objectives and age-appropriateness
3. **Offline-First Design** - Core features work without internet
4. **Accessibility Mandatory** - Screen reader + keyboard support required
5. **Performance Constraints** - Must maintain 30+ FPS on Intel UHD 620
6. **Error Recovery** - Graceful handling with user-friendly messages
7. **Progress Tracking** - Update PROJECT_PROGRESS.md after each task

## The NeuroVis Prompt Formula

```
[Godot Context] + [Educational Purpose] + [Technical Requirements] + 
[Accessibility] + [Integration Points] = Effective NeuroVis Prompt
```

## Standard Prompt Templates

### 1. Core System Implementation
```
You are implementing [SYSTEM_NAME] for the NeuroVis educational neuroanatomy application.

File: src/autoload/[SYSTEM_NAME].gd

Context: 
- Phase: [1/2/3] - [Phase Description]
- Educational Purpose: [What students will learn]
- Dependencies: [Required systems]

Requirements:
1. [Core functionality]
2. Performance: [Specific metrics]
3. Accessibility: [Specific features]
4. Error Handling: [Specific scenarios]

Integration:
- [System 1]: [How it integrates]
- [System 2]: [How it integrates]

Signals to emit:
- signal_name(params) - When [condition]

Include comprehensive error handling and progress tracking.
```

### 2. UI Component Creation
```
Create [COMPONENT_NAME] for NeuroVis student interface.

Files:
- src/ui/components/[COMPONENT_NAME].gd
- src/ui/components/[COMPONENT_NAME].tscn

Educational Purpose: [Learning objective]

Requirements:
- Responsive design (720p to 4K)
- Full keyboard navigation
- Screen reader announcements
- High contrast mode support
- Age-appropriate for high school+

Accessibility:
- Tab order: [Specify order]
- Announcements: [What to announce]
- Focus indicators: [Visual design]

Test with: AccessibilityManager.test_component()
```

### 3. 3D Interaction Feature
```
Implement [FEATURE_NAME] for 3D brain exploration.

File: src/systems/3d_interaction/[FEATURE_NAME].gd

Educational Goal: Enable students to [learning activity]

Technical Requirements:
- [Interaction method]
- Performance: 30+ FPS with 10K polygon models
- LOD support for quality adaptation
- Touch and mouse input support

Accessibility:
- Keyboard controls: [Key mappings]
- Audio feedback: [When to play]
- Visual indicators: [What to show]

Error Cases:
- Missing 3D models: [Fallback]
- Performance issues: [Adaptation]
```

## Example Prompts

### Example 1: PerformanceMonitor Completion
```
You are implementing the PerformanceMonitor autoload for NeuroVis.

File: src/autoload/PerformanceMonitor.gd

Context: This is a Phase 1 core system that monitors FPS and automatically adjusts rendering quality to maintain 30+ FPS on low-end hardware (Intel UHD 620).

Requirements:
1. Track FPS with 60-sample rolling average
2. Monitor memory usage via OS.get_static_memory_usage()
3. Implement quality presets: 'low', 'medium', 'high'
4. Auto-adjust when average FPS < 30 for 3 seconds
5. Emit signals: performance_warning(metric, value), quality_changed(preset)
6. Provide manual override: set_quality_preset(preset)

Integration:
- Work with LODManager for model quality
- Coordinate with RenderingServer for post-processing
- Log performance issues via ErrorRecoveryManager

Include comprehensive error handling and user-friendly notifications.
```

### Example 2: Quiz Question Component
```
Create MultipleChoiceQuestion component for neuroanatomy assessments.

Files:
- src/systems/assessment/QuestionTypes/MultipleChoice.gd
- src/systems/assessment/QuestionTypes/MultipleChoice.tscn

Educational Purpose: Test student recognition of brain structures and functions with immediate feedback.

Requirements:
- Display question with 4 answer options
- Randomize answer order
- Show correct/incorrect feedback
- Track attempt count
- Support images in questions
- Work offline with local content

Accessibility:
- Number keys 1-4 for answer selection
- Clear focus indicators
- Announce: "Question 1 of 10: [question text]"
- Success/failure audio cues

Integration:
- QuizBuilder: Register question type
- ProgressTracker: Record results
- ContentManager: Load question data

Emit signals:
- answer_selected(answer_index, is_correct)
- question_completed(score, attempts)
```

## Autoload Manager Reference

Always consider these global systems in your implementations:

- **ErrorRecoveryManager** - Handle all errors through this system
- **PerformanceMonitor** - Check FPS before expensive operations  
- **AccessibilityManager** - Register all UI components
- **ContentManager** - Load educational content
- **ProgressTracker** - Record student progress
- **SettingsManager** - Respect user preferences
- **NetworkManager** - Check online status (Phase 2+)
- **AuthenticationManager** - User login (Phase 2+)

## Common Patterns

### Error Handling
```gdscript
if not resource:
    ErrorRecoveryManager.handle_error(
        ErrorRecoveryManager.ErrorType.CONTENT_NOT_FOUND,
        {"resource": resource_path, "fallback": "default"}
    )
    return null
```

### Accessibility
```gdscript
func setup_accessibility(control: Control) -> void:
    control.accessible_name = "Descriptive name"
    control.accessible_description = "What this does"
    AccessibilityManager.register(control)
```

### Performance Check
```gdscript
if PerformanceMonitor.get_average_fps() < 30:
    use_low_quality_mode()
else:
    use_high_quality_mode()
```

## Validation Checklist

Before considering any component complete:

- [ ] Follows GDScript naming conventions
- [ ] Includes educational context in comments
- [ ] Has comprehensive error handling
- [ ] Includes accessibility features
- [ ] Maintains 30+ FPS
- [ ] Works completely offline
- [ ] Has unit tests
- [ ] Updated PROJECT_PROGRESS.md
- [ ] Committed with descriptive message

## Progress Workflow

1. Check `PROJECT_PROGRESS.md` for next task
2. Find or create appropriate prompt template
3. Include all context from PROJECT_OUTLINE.md
4. Implement with validation checklist in mind
5. Test on simulated low-end hardware
6. Update progress: `./scripts/update_progress.sh "task" "done"`
7. Commit and move to next task

## Remember

**NeuroVis is an educational tool first.** Every line of code should serve the learning experience. When making technical decisions:

1. Will this help students learn neuroanatomy better?
2. Can a student with disabilities use this feature?
3. Will this work on a school's older computers?
4. Does this work without internet in a classroom?
5. Is the error message helpful to a teacher?

These questions should guide every implementation decision.
