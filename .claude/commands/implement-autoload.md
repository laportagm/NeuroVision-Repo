# Command: /implement-autoload
# Purpose: Implement autoload manager for NeuroVision platform
# Arguments:
#   - $AUTOLOAD_NAME: Name of the autoload service to implement
#   - $SERVICE_TYPE: Type of service (core_manager, specialized_service, ui_enhancement)
#   - $DEPENDENCIES: Required dependencies (comma-separated)
# Example: /implement-autoload AUTOLOAD_NAME="LearningProgressManager" SERVICE_TYPE="specialized_service" DEPENDENCIES="ProgressTracker,ContentManager"
---

You are implementing $AUTOLOAD_NAME autoload manager for the NeuroVision medical education platform using Godot 4.4.1.

**File Location:** Based on $SERVICE_TYPE:
- core_manager: `src/core/managers/$AUTOLOAD_NAME.gd`
- specialized_service: `src/autoload/$AUTOLOAD_NAME.gd`
- ui_enhancement: `src/autoload/$AUTOLOAD_NAME.gd`

**Project Phase:** Phase 2 - Educational Features Enhancement
**Educational Context:** Supporting medical education through robust global systems

**Core Requirements:**
1. **Single Responsibility:** Focus on one specific domain area
2. **Medical Education Support:** Enable effective neuroanatomy learning
3. **Performance Excellence:** Maintain 120+ FPS performance standard
4. **WCAG AAA Accessibility:** Support screen readers and keyboard navigation
5. **Production Stability:** Graceful degradation and recovery

**Implementation Standards:**
```gdscript
extends Node
class_name $AUTOLOAD_NAME

# Medical education-focused signals
signal service_initialized(service_name: String)
signal error_occurred(error_context: Dictionary)

# Dependencies: ${DEPENDENCIES:="none"}
var _is_initialized: bool = false
var _error_recovery_manager: Node

# Core lifecycle
func _ready() -> void:
    # Initialize with dependency checking
    _error_recovery_manager = get_node_or_null("/root/ErrorRecoveryManager")
    if not _validate_dependencies():
        _handle_dependency_error()
        return
    
    if initialize():
        service_initialized.emit($AUTOLOAD_NAME)
        _is_initialized = true

# Required interface
func initialize() -> bool:
    # Setup with comprehensive error checking
    pass

func get_status() -> Dictionary:
    # Return current state for debugging
    pass

func handle_error(error_context: Dictionary) -> void:
    # Graceful error handling
    pass
```

**Integration Requirements:**
- Connect with existing 10 core autoload managers appropriately
- Support offline-first functionality (production requirement)
- Provide clear medical educational value through feedback
- Maintain 120+ FPS performance standard (Intel UHD 620 optimized)
- Ensure WCAG AAA accessibility compliance (7:1+ contrast ratios)
- Use unified color system for any UI components

**Educational Considerations:**
- How does this manager support neuroanatomy learning objectives?
- What feedback does it provide to students and teachers?
- How does it handle errors without disrupting learning flow?
- Does it support different learning styles and accessibility needs?

**Testing Requirements:**
- Unit tests for core functionality
- Integration tests with other autoloads
- Performance validation under load
- Accessibility compliance verification
- Educational effectiveness validation

**Error Recovery Patterns:**
- Graceful degradation when dependencies unavailable
- Clear, educational error messages for students
- Automatic recovery attempts where appropriate
- Comprehensive logging for teacher/developer debugging

**Performance Optimization:**
- Minimal CPU overhead during normal operation
- Efficient memory usage patterns
- No blocking operations on main thread
- Respectful of minimum hardware limitations

Remember to update PROJECT_PROGRESS.md after implementation completion.
