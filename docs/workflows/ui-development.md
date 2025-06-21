# UI Development Workflow

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You complete UI development tasks and discover better approaches
- New UI patterns are implemented successfully
- Performance optimizations for UI are found
- Accessibility improvements are implemented

HOW TO UPDATE:
1. Add new steps to workflow sections
2. Update Recent Improvements with date and changes
3. Document new patterns in Templates section
4. Keep examples current with project structure
-->

## UI Component Development Workflow

### Step 1: Determine Component Type and Location

**Decision Tree:**
```
Is it a basic element (button, label, input)?
├─ YES → Create in src/ui_atomic/atoms/
└─ NO → Is it a combination of elements?
    ├─ YES → Create in src/ui_atomic/molecules/
    └─ NO → Create in src/ui_atomic/organisms/
```

**File Structure:**
```
src/ui_atomic/
├── atoms/           # Basic UI elements
│   ├── buttons/     # Educational buttons
│   ├── inputs/      # Form inputs
│   └── displays/    # Text displays, labels
├── molecules/       # Combined elements
│   ├── panels/      # Simple panels
│   ├── forms/       # Input combinations
│   └── navigation/  # Navigation elements
└── organisms/       # Complex systems
    ├── dialogs/     # Modal dialogs
    ├── layouts/     # Page layouts
    └── specialized/ # Educational-specific components
```

### Step 2: Create Component Files

**For All Components:**
1. Create main script file: `ComponentName.gd`
2. Use template from `docs/templates/ui-component-template.md`
3. Replace template placeholders with actual values

**For Visual Components:**
1. Create scene file: `ComponentName.tscn`
2. Set root node type based on component needs
3. Configure initial theme and styling

**Template Usage:**
```bash
# Copy and customize template
cp docs/templates/ui-component-template.md src/ui_atomic/[type]/ComponentName.gd
# Replace {{COMPONENT_NAME}}, {{BASE_CLASS}}, {{PURPOSE}}
```

### Step 3: Implement Educational Integration

**Required Educational Features:**
- [ ] Extend `BaseEducationalPanel` (if applicable)
- [ ] Support both Enhanced and Minimal themes
- [ ] Implement accessibility features (WCAG AAA)
- [ ] Add learning analytics tracking
- [ ] Use `UnifiedColorSystem` for all colors
- [ ] Support keyboard navigation

**Code Pattern:**
```gdscript
class_name YourComponent
extends BaseEducationalPanel

func _ready() -> void:
    super._ready()  # Call parent ready
    _setup_educational_features()

func _setup_educational_features() -> void:
    # Educational configuration
    target_audience = EducationalAudience.MEDICAL_STUDENT
    accessibility_mode = true
    
    # Register with educational platform
    if EducationalPlatformManager:
        EducationalPlatformManager.register_educational_component(self)
```

### Step 4: Theme Integration

**Theme-Aware Styling:**
```gdscript
func _update_component_theme(theme_variant: String) -> void:
    match theme_variant:
        "enhanced":
            # Student-friendly styling
            var primary = UnifiedColorSystem.get_color("primary")
            var surface = UnifiedColorSystem.get_color("surface")
            _apply_enhanced_styling(primary, surface)
        "minimal":
            # Professional/clinical styling
            var clinical_primary = UnifiedColorSystem.get_color("clinical_primary")
            var clinical_surface = UnifiedColorSystem.get_color("clinical_surface")
            _apply_minimal_styling(clinical_primary, clinical_surface)
```

**Color Usage Rules:**
- ✅ DO: `UnifiedColorSystem.get_color("primary")`
- ❌ DON'T: `Color(0.5, 0.7, 1.0)` (hardcoded colors)

### Step 5: Accessibility Implementation

**Required Accessibility Features:**
```gdscript
func _setup_accessibility_features() -> void:
    # Screen reader support
    accessible_name = "Component Name"
    accessible_description = "Component purpose and function"
    
    # Keyboard navigation
    focus_mode = Control.FOCUS_ALL
    
    # Touch targets (minimum 44px for medical education)
    custom_minimum_size = Vector2(44, 44)
    
    # High contrast support
    _setup_high_contrast_mode()
```

### Step 6: Testing and Validation

**Testing Checklist:**
- [ ] Test in both Enhanced and Minimal themes
- [ ] Verify accessibility with keyboard navigation
- [ ] Test screen reader announcements
- [ ] Validate color contrast ratios (7:1+ for WCAG AAA)
- [ ] Test on Intel UHD 620 performance target
- [ ] Verify educational analytics tracking

**Test Scene Creation:**
```bash
# Create test scene in scenes/test_components/
# Add component to test scene
# Run performance validation
```

### Step 7: Integration with Main Scenes

**Registration with UISystemManager:**
```gdscript
# In main scene or autoload
if UISystemManager:
    UISystemManager.register_ui_component(your_component)
```

**Educational Scene Integration:**
```gdscript
# In educational scenes
@onready var your_component := $UILayer/YourComponent as YourComponent

func _ready() -> void:
    your_component.educational_interaction.connect(_on_component_interaction)
```

### Step 8: Performance Optimization

**Performance Guidelines:**
- Target 60+ FPS during UI interactions
- Minimize draw calls and overdraw
- Use object pooling for frequently created/destroyed components
- Implement visibility-based optimization

**Performance Validation:**
```gdscript
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_VISIBILITY_CHANGED:
            if not visible:
                _pause_expensive_operations()
            else:
                _resume_expensive_operations()
```

## Common UI Patterns

### Educational Info Panel Pattern
```gdscript
class_name EducationalInfoPanel
extends BaseEducationalPanel

func display_educational_content(content: Dictionary) -> void:
    # Validate medical accuracy
    if not _validate_medical_content(content):
        return
    
    # Track educational interaction
    track_educational_interaction("content_displayed", content)
    
    # Update display
    _update_panel_content(content)
```

### Interactive Brain Structure Panel
```gdscript
class_name BrainStructurePanel
extends BaseEducationalPanel

signal structure_selected(structure_name: String)

func _on_structure_button_pressed(structure_name: String) -> void:
    # Highlight in 3D
    if HighlightMaterialManager:
        HighlightMaterialManager.highlight_structure(structure_name)
    
    # Track learning interaction
    track_educational_interaction("structure_selected", {"structure": structure_name})
    
    # Emit signal
    structure_selected.emit(structure_name)
```

## Recent Improvements (Claude Code Updates)

<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: Created initial workflow with educational platform integration
- [CLAUDE CODE: Document new UI patterns and optimizations discovered]

## Troubleshooting Common Issues

### Theme Not Applying
**Problem**: Component doesn't respond to theme changes
**Solution**: Ensure `UnifiedColorManager.theme_changed.connect(_on_theme_changed)` is called

### Accessibility Issues
**Problem**: Component not accessible via keyboard
**Solution**: Set `focus_mode = Control.FOCUS_ALL` and implement `_gui_input()` for custom controls

### Performance Problems
**Problem**: UI causing frame rate drops
**Solution**: Implement visibility-based optimization and use UI pooling

### Educational Integration Not Working
**Problem**: Learning analytics not tracking
**Solution**: Verify `EducationalPlatformManager` registration and `track_educational_interaction()` calls

## Best Practices

1. **Always Use Templates**: Start with documented templates for consistency
2. **Theme Awareness**: Test in all theme variants (Enhanced/Minimal)
3. **Accessibility First**: Implement accessibility features from the start
4. **Performance Monitoring**: Use built-in performance monitoring tools
5. **Educational Context**: Include learning objectives and medical accuracy validation
6. **Documentation**: Update this workflow when you discover better approaches

---
**Last Updated**: 2025-06-21 by Claude Code
**Workflow Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0