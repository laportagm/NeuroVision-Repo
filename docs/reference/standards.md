# Development Standards

<!-- CLAUDE CODE: Keep this file current with project standards -->

## Educational Platform Development Standards

### Code Quality and Style

**GDScript Naming Conventions:**
- **Classes**: PascalCase (`EducationalBrainExplorer`)
- **Functions**: snake_case (`display_structure_info`)
- **Variables**: snake_case (`current_brain_structure`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_EDUCATIONAL_COMPONENTS`)
- **Signals**: snake_case with descriptive names (`structure_selected`, `learning_milestone_achieved`)

**File Organization:**
```
# Autoload Services
src/autoload/ServiceName.gd          # Educational services
src/core/managers/ManagerName.gd     # Platform managers

# UI Components (Atomic Design)
src/ui_atomic/atoms/ComponentName.gd      # Basic elements
src/ui_atomic/molecules/ComponentName.gd  # Combined elements  
src/ui_atomic/organisms/ComponentName.gd  # Complex systems

# Educational Systems
src/systems/category/SystemName.gd   # Specialized systems

# Scenes
scenes/ui/SceneName.tscn             # UI scenes
scenes/3d/SceneName.tscn             # 3D educational scenes
```

### Educational Integration Requirements

**All Educational Components Must:**
- Extend `BaseEducationalPanel` (if UI component)
- Support both Enhanced and Minimal themes
- Implement WCAG AAA accessibility features
- Use `UnifiedColorSystem` for all colors (no hardcoded colors)
- Track educational interactions with `ProgressTracker`
- Validate medical accuracy where applicable

**Required Educational Features:**
```gdscript
class_name YourEducationalComponent
extends BaseEducationalPanel

@export_group("Educational Settings")
@export var target_audience: EducationalAudience = EducationalAudience.MEDICAL_STUDENT
@export var accessibility_mode: bool = true
@export var learning_analytics_enabled: bool = true

# Educational progression signals (required)
signal educational_interaction(component: String, action: String, context: Dictionary)
signal learning_milestone_achieved(milestone: String, completion_time: float)

func _ready() -> void:
    # Required educational system validation
    if not _validate_educational_systems():
        return
    
    # Required educational platform registration
    _register_with_educational_platform()
    
    # Required theme integration
    _apply_current_educational_theme()
```

### Theme and Color System Requirements

**Color Usage Rules:**
```gdscript
# ✅ CORRECT - Use UnifiedColorSystem
var primary_color = UnifiedColorSystem.get_color("primary")
var surface_color = UnifiedColorSystem.get_color("surface")
var educational_accent = UnifiedColorSystem.get_educational_color("primary")

# ❌ INCORRECT - No hardcoded colors
var bad_color = Color(0.5, 0.7, 1.0)  # Never do this
var bad_hex = Color("#3498db")         # Never do this
```

**Theme Support Requirements:**
- All components must respond to `UnifiedColorManager.theme_changed` signal
- Support Enhanced theme (student-friendly, engaging)
- Support Minimal theme (professional/clinical)
- Maintain WCAG AAA contrast ratios (7:1+) in all themes

### Performance Standards

**Intel UHD 620 Compatibility (Primary Target):**
- **Minimum FPS**: 30 FPS (33.33ms frame time)
- **Target FPS**: 60 FPS (16.67ms frame time)
- **Memory Budget**: <500MB total application usage
- **UI Response Time**: <100ms for all interactions
- **Scene Load Time**: <3 seconds from launch to interaction

**Performance Implementation Requirements:**
```gdscript
# Required performance monitoring integration
func _ready() -> void:
    if PerformanceMonitor:
        PerformanceMonitor.register_component_for_monitoring(self)

# Required visibility-based optimization
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_VISIBILITY_CHANGED:
            if not visible:
                _pause_expensive_operations()
            else:
                _resume_expensive_operations()
```

### Accessibility Standards (WCAG AAA)

**Required Accessibility Features:**
```gdscript
func _setup_accessibility_features() -> void:
    # Screen reader support (required)
    accessible_name = "Component Name"
    accessible_description = "Educational purpose and function"
    
    # Keyboard navigation (required)
    focus_mode = Control.FOCUS_ALL
    
    # Touch targets (minimum 44px for medical education)
    custom_minimum_size = Vector2(44, 44)
    
    # High contrast support (required)
    _setup_high_contrast_mode()
```

**Accessibility Validation:**
- All interactive elements must have `accessible_name` and `accessible_description`
- Keyboard navigation must work for all UI elements
- Color contrast ratios must be 7:1+ (WCAG AAA)
- Touch targets must be minimum 44x44px
- Screen reader announcements for important educational events

### Educational Content Standards

**Medical Accuracy Requirements:**
- Educational content must be medically accurate (textbook level)
- Anatomical terminology must be consistent and correct
- Clinical relevance must be included where applicable
- Content must be appropriate for target audience (students vs professionals)

**Content Validation Pattern:**
```gdscript
func validate_medical_content(content: Dictionary) -> bool:
    # 1. Medical terminology validation
    if not MedicalTerminologyValidator.validate(content):
        push_error("[Medical] Terminology validation failed")
        return false
    
    # 2. Educational level appropriateness
    if not EducationalLevelValidator.check_appropriateness(content, target_audience):
        push_error("[Educational] Content not appropriate for target learning level")
        return false
    
    # 3. Clinical relevance validation (if required)
    if requires_clinical_relevance and not content.has("clinical_relevance"):
        push_error("[Clinical] Missing required clinical relevance information")
        return false
    
    return true
```

### Error Handling and Debugging

**Required Error Handling:**
```gdscript
# Educational system validation pattern
func _validate_educational_systems() -> bool:
    var missing_systems = []
    
    if not CoreSystemManager:
        missing_systems.append("CoreSystemManager")
    if not UISystemManager:
        missing_systems.append("UISystemManager") 
    if not EducationalPlatformManager:
        missing_systems.append("EducationalPlatformManager")
    
    if missing_systems.size() > 0:
        push_error("[Educational] Missing systems: " + str(missing_systems))
        return false
    
    return true

# Educational error recovery pattern
func handle_educational_error(error_type: EducationalError, context: String) -> void:
    match error_type:
        EducationalError.MEDICAL_INACCURACY:
            disable_feature_for_medical_review(context)
            medical_review_logger.log_accuracy_issue(context)
        EducationalError.ACCESSIBILITY_VIOLATION:
            accessibility_manager.apply_fallback_mode()
        EducationalError.PERFORMANCE_DEGRADATION:
            performance_manager.switch_to_simplified_mode()
```

### Testing Requirements

**All Educational Components Must Pass:**
- Autoload validation: `test autoloads` command
- UI safety validation: `test ui_safety` command  
- Performance validation: `performance` command
- Accessibility testing: keyboard navigation and screen reader testing
- Theme testing: verify functionality in Enhanced and Minimal themes
- Educational workflow testing: verify learning analytics integration

**Debug Console Validation:**
```bash
# Required validation commands
test autoloads              # Validate all educational systems
test ui_safety             # Validate UI and theme integration
performance               # Check performance targets
memory                   # Validate memory usage
accessibility            # Check accessibility compliance
```

### Documentation Requirements

**All New Code Must Include:**
- Clear educational purpose and learning objectives
- Medical accuracy validation documentation
- Performance impact assessment
- Accessibility compliance verification
- Integration testing results

**Comment Standards:**
```gdscript
# Educational functionality comments
# Purpose: Displays hippocampus structure information for medical students
# Medical Accuracy: Validated against neuroanatomy textbooks
# Accessibility: WCAG AAA compliant with screen reader support
func display_hippocampus_info(structure_data: Dictionary) -> void:
    # Validate medical content accuracy
    if not validate_medical_content(structure_data):
        return
    
    # Track educational interaction for learning analytics
    track_educational_interaction("hippocampus_viewed", structure_data)
```

### Git and Version Control Standards

**Commit Message Format:**
```
type: brief description

- Educational context and learning objectives
- Medical accuracy validation performed
- Performance impact assessment
- Accessibility compliance verified

🤖 Generated with Claude Code
```

**Required Pre-commit Validation:**
- GDScript syntax validation
- Performance regression testing
- Accessibility compliance checking
- Educational system integration testing

### Security and Privacy Standards

**Educational Data Protection:**
- No personal student information in logs
- FERPA compliance for educational data
- Secure authentication for professional access
- Privacy-first learning analytics

**Code Security:**
- No hardcoded secrets or API keys
- Secure educational content validation
- Safe error handling without information disclosure
- Medical data privacy protection

---
**Last Updated**: 2025-06-21  
**Standards Version**: 2.1.0  
**Compliance**: WCAG AAA, FERPA, Medical Education Standards