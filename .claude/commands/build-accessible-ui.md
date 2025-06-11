# Build NeuroVis Accessible UI Component

You are creating $ARGUMENTS for the NeuroVis educational interface with full accessibility compliance.

**Files to Create:**
- `src/ui/components/$ARGUMENTS.gd`
- `src/ui/components/$ARGUMENTS.tscn`

**Educational Context:** This component will help students learn neuroanatomy through [describe the educational purpose]
**Target Users:** High school and university students studying neuroanatomy
**Accessibility Level:** WCAG AAA compliance required

## Design Requirements

**Visual Design:**
- Clean, educational aesthetic appropriate for academic use
- Age-appropriate for high school through graduate students
- Professional appearance suitable for classroom presentation
- Responsive layout supporting 720p to 4K displays

**Educational Effectiveness:**
- Clear visual hierarchy guiding student attention
- Immediate feedback for all interactions
- Progress indicators showing learning advancement
- Error states that educate rather than frustrate

## Accessibility Implementation (WCAG AAA)

**Keyboard Navigation:**
```gdscript
# Complete keyboard support example
func _ready():
    # Set up focus chain
    setup_focus_navigation()
    
    # Register keyboard shortcuts
    register_accessibility_keys()
    
    # Connect to AccessibilityManager
    AccessibilityManager.register_component(self)

func setup_focus_navigation():
    # Define logical tab order
    set_focus_neighbor(SIDE_RIGHT, next_element)
    set_focus_neighbor(SIDE_LEFT, previous_element)
    
    # Handle focus events
    focus_entered.connect(_on_focus_entered)
    focus_exited.connect(_on_focus_exited)

func _on_focus_entered():
    # Visual focus indicator
    show_focus_outline()
    
    # Screen reader announcement
    var announcement = accessible_name + ". " + accessible_description
    AccessibilityManager.announce(announcement)
```

**Screen Reader Support:**
```gdscript
func setup_screen_reader_support():
    # Essential accessibility properties
    accessible_name = "Descriptive component name"
    accessible_description = "Detailed explanation of purpose and usage"
    accessible_role = AccessibilityRole.BUTTON  # or appropriate role
    
    # Dynamic content updates
    if has_dynamic_content:
        accessible_live_region = AccessibilityManager.LIVE_POLITE
```

**Visual Accessibility:**
- High contrast mode compatibility
- Minimum 4.5:1 color contrast ratio (AAA: 7:1 for normal text)
- No color-only information conveyance
- Scalable fonts (12pt to 24pt minimum)
- Clear focus indicators (2px minimum outline)

## Educational Integration

**Learning Feedback System:**
```gdscript
func provide_educational_feedback(interaction_type: String, success: bool):
    if success:
        # Positive reinforcement with educational value
        var feedback = "Correct! " + get_educational_explanation()
        display_success_feedback(feedback)
        ProgressTracker.record_success(interaction_type)
    else:
        # Constructive guidance without discouragement
        var hint = get_contextual_hint()
        display_guidance_feedback(hint)
        ProgressTracker.record_attempt(interaction_type)
```

**Progress Tracking:**
```gdscript
func track_educational_progress():
    var interaction_data = {
        "component": get_class(),
        "learning_objective": current_learning_objective,
        "interaction_time": get_interaction_duration(),
        "accessibility_features_used": get_accessibility_usage(),
        "success_rate": calculate_success_rate()
    }
    
    ProgressTracker.record_component_interaction(interaction_data)
```

## Performance Optimization

**Responsive Design:**
```gdscript
func _ready():
    # Adapt to different screen sizes
    get_viewport().size_changed.connect(_on_viewport_resized)
    optimize_for_current_resolution()

func optimize_for_current_resolution():
    var viewport_size = get_viewport().size
    
    if viewport_size.x < 1280:  # Small screens
        use_compact_layout()
        reduce_animation_complexity()
    elif viewport_size.x > 2560:  # Large screens
        use_expanded_layout()
        enable_enhanced_visuals()
```

**Memory Efficiency:**
```gdscript
func optimize_memory_usage():
    # Object pooling for frequently created elements
    if elements_pool.is_empty():
        create_element_pool()
    
    # Lazy loading of educational content
    if not content_visible:
        defer_content_loading()
    
    # Clean up resources when not needed
    if not is_visible_in_tree():
        release_expensive_resources()
```

## Integration with NeuroVis Systems

**Required System Integration:**
```gdscript
func integrate_with_neurovis_systems():
    # Performance monitoring
    PerformanceMonitor.register_ui_component(self)
    
    # Accessibility management
    AccessibilityManager.register(self)
    
    # Error handling
    setup_error_recovery()
    
    # Settings management
    SettingsManager.ui_settings_changed.connect(_on_settings_changed)
    
    # Content management
    ContentManager.content_updated.connect(_on_content_updated)
```

**Error Handling:**
```gdscript
func setup_error_recovery():
    # Graceful handling of content loading failures
    ContentManager.content_load_failed.connect(_on_content_load_failed)
    
func _on_content_load_failed(content_id: String):
    ErrorRecoveryManager.handle_error(
        ErrorRecoveryManager.ErrorType.CONTENT_NOT_FOUND,
        {
            "component": get_class(),
            "content_id": content_id,
            "fallback_available": has_fallback_content()
        }
    )
    
    # Show educational fallback content
    display_fallback_content()
```

## Component-Specific Patterns

**For Interactive Elements:**
- Touch targets: Minimum 44px (iOS) / 48dp (Android)
- Button states: Default, hover, active, disabled, focused
- Animation duration: 200-300ms for feedback, respect user motion preferences
- Loading states: Show progress for operations >500ms

**For Educational Content:**
- Immediate feedback: <200ms response to interactions
- Progress indicators: Clear advancement visualization
- Hint systems: Progressive disclosure without giving away answers
- Error messages: Educational and encouraging, not punitive

**For Data Display:**
- Responsive tables: Horizontal scroll on small screens
- Chart accessibility: Text alternatives for visual data
- Progressive enhancement: Core functionality without JavaScript/animations
- Loading states: Skeleton screens or progress indicators

## Testing Requirements

**Accessibility Testing:**
```gdscript
# Automated accessibility validation
func test_accessibility_compliance():
    assert(accessible_name != "", "Component must have accessible name")
    assert(accessible_description != "", "Component must have description")
    assert(can_receive_focus() == is_interactive, "Focus handling must match interactivity")
    
    # Test keyboard navigation
    test_tab_navigation()
    test_keyboard_shortcuts()
    
    # Test screen reader compatibility
    test_screen_reader_announcements()
```

**Educational Testing:**
- Validate learning objectives are achievable
- Test with target age group (high school/university)
- Verify accessibility accommodations work correctly
- Confirm component supports diverse learning styles

**Performance Testing:**
- 60fps animations on target hardware
- Responsive layout on all supported resolutions
- Memory usage remains stable during extended use
- Fast loading even with slow educational content

## Code Quality Standards

**Documentation:**
```gdscript
"""
[Component Name] - Educational neuroanatomy interface component

Educational Purpose:
- [Specific learning objective]
- [How it supports student understanding]
- [Assessment or exploration capability]

Accessibility Features:
- Full keyboard navigation support
- Screen reader compatibility
- High contrast mode support
- Scalable interface elements

Usage:
var component = $ARGUMENTS.new()
component.setup_for_learning_objective("identify_hippocampus")
add_child(component)
"""
```

**Code Organization:**
- Educational logic separate from UI logic
- Accessibility features built-in, not added afterward
- Performance optimization integrated throughout
- Error handling comprehensive and user-friendly

Remember: This component is a learning tool first. Every design decision should support effective neuroanatomy education while being accessible to all students.

Update PROJECT_PROGRESS.md after implementation and accessibility validation testing.
