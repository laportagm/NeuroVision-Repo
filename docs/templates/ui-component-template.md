# Educational UI Component Template

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You create new UI components and discover better patterns
- You find more efficient educational integration methods
- New accessibility requirements are implemented
- Performance optimizations are discovered

HOW TO UPDATE:
1. Read current template
2. Add new patterns to appropriate sections
3. Update "Recent Improvements" section with date
4. Keep template backwards compatible
-->

## Educational UI Component Template

```gdscript
class_name {{COMPONENT_NAME}}
extends {{BASE_CLASS}}  # Usually BaseEducationalPanel or Control

@export_group("Educational Settings")
@export var target_audience: EducationalAudience = EducationalAudience.MEDICAL_STUDENT
@export var accessibility_mode: bool = true
@export var learning_analytics_enabled: bool = true
@export var educational_theme_support: bool = true

# Educational progression signals
signal educational_interaction(component: String, action: String, context: Dictionary)
signal learning_milestone_achieved(milestone: String, completion_time: float)
signal accessibility_action_performed(action: String, context: Dictionary)

# Core variables
var _current_theme_variant: String = ""
var _accessibility_features_active: bool = false

func _ready() -> void:
    # Validate educational systems
    if not _validate_educational_systems():
        push_error("[{{COMPONENT_NAME}}] Educational systems not available")
        return
    
    # Register with educational platform
    _register_with_educational_platform()
    
    # Apply current educational theme
    _apply_current_educational_theme()
    
    # Initialize accessibility features
    if accessibility_mode:
        _setup_accessibility_features()
    
    # Initialize learning analytics
    if learning_analytics_enabled and ProgressTracker:
        ProgressTracker.track_component_initialized(get_class(), target_audience)

func _validate_educational_systems() -> bool:
    var missing_systems = []
    
    if not CoreSystemManager:
        missing_systems.append("CoreSystemManager")
    if not UISystemManager:
        missing_systems.append("UISystemManager")
    if not EducationalPlatformManager:
        missing_systems.append("EducationalPlatformManager")
    
    if missing_systems.size() > 0:
        push_error("[{{COMPONENT_NAME}}] Missing systems: " + str(missing_systems))
        return false
    
    return true

func _register_with_educational_platform() -> void:
    if EducationalPlatformManager:
        EducationalPlatformManager.register_educational_component(self)
        
    if UISystemManager:
        UISystemManager.register_ui_component(self)

func _apply_current_educational_theme() -> void:
    if not UnifiedColorManager:
        return
        
    # Connect to theme changes
    if not UnifiedColorManager.theme_changed.is_connected(_on_educational_theme_changed):
        UnifiedColorManager.theme_changed.connect(_on_educational_theme_changed)
    
    # Apply current theme
    _current_theme_variant = UnifiedColorManager.get_current_theme_variant()
    _update_component_theme(_current_theme_variant)

func _setup_accessibility_features() -> void:
    # Implement WCAG AAA compliance
    accessible_name = "{{COMPONENT_NAME}}"
    accessible_description = "Educational component for {{PURPOSE}}"
    
    # Ensure minimum touch targets (44px medical education standard)
    custom_minimum_size = Vector2(44, 44)
    
    # Setup keyboard navigation
    focus_mode = Control.FOCUS_ALL
    
    _accessibility_features_active = true

func _on_educational_theme_changed(theme_variant: String) -> void:
    _current_theme_variant = theme_variant
    _update_component_theme(theme_variant)

func _update_component_theme(theme_variant: String) -> void:
    # Implement theme-specific styling
    match theme_variant:
        "enhanced":
            # Gaming/engaging style for medical students
            _apply_enhanced_educational_styling()
        "minimal":
            # Professional/clinical style for healthcare professionals
            _apply_minimal_clinical_styling()
        _:
            push_warning("[{{COMPONENT_NAME}}] Unknown theme: " + theme_variant)

func _apply_enhanced_educational_styling() -> void:
    # Use UnifiedColorSystem for all colors
    var primary_color = UnifiedColorSystem.get_color("primary")
    var surface_color = UnifiedColorSystem.get_color("surface")
    
    # Apply enhanced educational styling
    # TODO: Implement enhanced theme styling

func _apply_minimal_clinical_styling() -> void:
    # Use UnifiedColorSystem for clinical colors
    var clinical_primary = UnifiedColorSystem.get_color("clinical_primary")
    var clinical_surface = UnifiedColorSystem.get_color("clinical_surface")
    
    # Apply minimal clinical styling
    # TODO: Implement minimal theme styling

# Educational interaction tracking
func track_educational_interaction(action: String, context: Dictionary = {}) -> void:
    if learning_analytics_enabled and ProgressTracker:
        ProgressTracker.track_component_interaction(get_class(), action, context)
    
    educational_interaction.emit(get_class(), action, context)

# Accessibility support
func announce_to_screen_reader(message: String) -> void:
    if _accessibility_features_active:
        # Implement screen reader announcement
        accessible_description = message

# Performance optimization
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_VISIBILITY_CHANGED:
            # Optimize performance when not visible
            if not visible:
                _pause_expensive_operations()
            else:
                _resume_expensive_operations()

func _pause_expensive_operations() -> void:
    # Implement performance optimizations when hidden
    pass

func _resume_expensive_operations() -> void:
    # Resume normal operations when visible
    pass
```

## Usage Example

```gdscript
# Create new educational component
class_name BrainStructureInfoPanel
extends BaseEducationalPanel

# Replace {{COMPONENT_NAME}} with BrainStructureInfoPanel
# Replace {{BASE_CLASS}} with BaseEducationalPanel
# Replace {{PURPOSE}} with "displaying brain structure information"

func display_structure_info(structure_data: Dictionary) -> void:
    # Validate medical accuracy
    if not _validate_medical_content(structure_data):
        return
    
    # Track educational interaction
    track_educational_interaction("structure_viewed", {"structure": structure_data.get("name", "unknown")})
    
    # Update display
    _update_structure_display(structure_data)
```

## Integration Checklist

- [ ] Replace template placeholders ({{COMPONENT_NAME}}, {{BASE_CLASS}}, {{PURPOSE}})
- [ ] Implement theme-specific styling methods
- [ ] Add component-specific educational functionality
- [ ] Test accessibility compliance
- [ ] Verify learning analytics integration
- [ ] Test with both Enhanced and Minimal themes
- [ ] Add to appropriate test scene
- [ ] Register with UISystemManager if needed

## Recent Improvements (Claude Code Updates)

<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: Created initial template with educational platform integration
- [CLAUDE CODE: Add new patterns discovered during development]

## Performance Notes

- Component optimizes performance when not visible
- Uses UnifiedColorSystem for all color access
- Implements lazy loading for expensive operations
- Tracks educational interactions efficiently

## Accessibility Features

- WCAG AAA compliance built-in
- Screen reader support
- Keyboard navigation
- Minimum 44px touch targets for medical education
- High contrast theme support

---
**Last Updated**: 2025-06-21 by Claude Code
**Template Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0