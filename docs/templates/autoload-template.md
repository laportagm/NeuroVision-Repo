# Educational Autoload Template

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You create new autoload services
- You discover better autoload patterns
- Educational platform requirements change
- Performance optimizations are found

HOW TO UPDATE:
1. Add new patterns to template
2. Update initialization sequences
3. Document new educational integration methods
4. Update Recent Improvements section
-->

## Educational Autoload Service Template

```gdscript
class_name {{AUTOLOAD_NAME}}
extends Node

# Educational service configuration
@export_group("Educational Service Settings")
@export var educational_mode_enabled: bool = true
@export var target_audience: EducationalAudience = EducationalAudience.MEDICAL_STUDENT
@export var performance_monitoring_enabled: bool = true
@export var accessibility_support_enabled: bool = true

# Service state management
enum ServiceState {
    UNINITIALIZED,
    INITIALIZING,
    READY,
    ERROR,
    SHUTTING_DOWN
}

var _service_state: ServiceState = ServiceState.UNINITIALIZED
var _initialization_time: float = 0.0
var _error_count: int = 0
var _max_errors: int = 5

# Educational platform integration
var _educational_platform_ready: bool = false
var _performance_monitor_active: bool = false

# Signals for educational platform coordination
signal service_initialized(service_name: String, initialization_time: float)
signal service_ready(service_name: String)
signal service_error(service_name: String, error_message: String)
signal educational_event(event_type: String, data: Dictionary)

func _ready() -> void:
    _service_state = ServiceState.INITIALIZING
    var start_time = Time.get_time_dict_from_system()
    
    # Set service name for debugging
    set_name("{{AUTOLOAD_NAME}}")
    
    # Initialize with error handling
    var initialization_result = await _initialize_service()
    
    if initialization_result:
        _service_state = ServiceState.READY
        _initialization_time = Time.get_time_dict_from_system()["unix"] - start_time["unix"]
        _on_service_ready()
    else:
        _service_state = ServiceState.ERROR
        _on_service_error("Failed to initialize {{AUTOLOAD_NAME}}")

func _initialize_service() -> bool:
    try:
        # 1. Validate dependencies
        if not _validate_dependencies():
            push_error("[{{AUTOLOAD_NAME}}] Dependency validation failed")
            return false
        
        # 2. Initialize core functionality
        if not await _initialize_core_functionality():
            push_error("[{{AUTOLOAD_NAME}}] Core initialization failed")
            return false
        
        # 3. Register with educational platform
        if educational_mode_enabled:
            _register_with_educational_platform()
        
        # 4. Setup performance monitoring
        if performance_monitoring_enabled:
            _setup_performance_monitoring()
        
        # 5. Initialize accessibility features
        if accessibility_support_enabled:
            _setup_accessibility_support()
        
        return true
        
    except:
        push_error("[{{AUTOLOAD_NAME}}] Exception during initialization")
        return false

func _validate_dependencies() -> bool:
    # Check for required autoload dependencies
    var required_dependencies = _get_required_dependencies()
    
    for dependency in required_dependencies:
        if not has_node("/root/" + dependency):
            push_error("[{{AUTOLOAD_NAME}}] Missing dependency: " + dependency)
            return false
    
    return true

func _get_required_dependencies() -> Array[String]:
    # Override this method to specify required dependencies
    # Example: return ["CoreSystemManager", "UISystemManager"]
    return []

func _initialize_core_functionality() -> bool:
    # Override this method to implement service-specific initialization
    # Example: Load configuration, setup data structures, etc.
    return true

func _register_with_educational_platform() -> void:
    # Register with core educational systems
    if CoreSystemManager:
        CoreSystemManager.register_service(self)
    
    if EducationalPlatformManager:
        EducationalPlatformManager.register_educational_service(self)
    
    _educational_platform_ready = true

func _setup_performance_monitoring() -> void:
    if PerformanceMonitor:
        PerformanceMonitor.register_service_for_monitoring(self)
        _performance_monitor_active = true

func _setup_accessibility_support() -> void:
    # Implement accessibility features specific to this service
    # Example: Screen reader announcements, keyboard shortcuts, etc.
    pass

func _on_service_ready() -> void:
    print("[{{AUTOLOAD_NAME}}] Service ready in ", _initialization_time, "ms")
    service_initialized.emit(get_name(), _initialization_time)
    service_ready.emit(get_name())
    
    # Emit educational platform event
    if _educational_platform_ready:
        educational_event.emit("service_ready", {
            "service": get_name(),
            "initialization_time": _initialization_time
        })

func _on_service_error(error_message: String) -> void:
    _error_count += 1
    push_error("[{{AUTOLOAD_NAME}}] Error: " + error_message)
    service_error.emit(get_name(), error_message)
    
    # Attempt recovery if under error threshold
    if _error_count < _max_errors:
        print("[{{AUTOLOAD_NAME}}] Attempting error recovery...")
        call_deferred("_attempt_recovery")
    else:
        push_error("[{{AUTOLOAD_NAME}}] Max errors reached, service disabled")

func _attempt_recovery() -> void:
    # Implement service-specific recovery logic
    # Example: Reset state, reload configuration, etc.
    pass

# Service status and health checking
func is_service_ready() -> bool:
    return _service_state == ServiceState.READY

func get_service_state() -> ServiceState:
    return _service_state

func get_service_health() -> Dictionary:
    return {
        "state": ServiceState.keys()[_service_state],
        "initialization_time": _initialization_time,
        "error_count": _error_count,
        "educational_platform_ready": _educational_platform_ready,
        "performance_monitoring": _performance_monitor_active
    }

# Educational service interface
func track_educational_interaction(interaction_type: String, data: Dictionary = {}) -> void:
    if not _educational_platform_ready:
        return
    
    educational_event.emit("interaction", {
        "service": get_name(),
        "type": interaction_type,
        "data": data,
        "timestamp": Time.get_unix_time_from_system()
    })

# Performance monitoring interface
func report_performance_metric(metric_name: String, value: float) -> void:
    if _performance_monitor_active and PerformanceMonitor:
        PerformanceMonitor.report_service_metric(get_name(), metric_name, value)

# Cleanup and shutdown
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_WM_CLOSE_REQUEST:
            _shutdown_service()

func _shutdown_service() -> void:
    _service_state = ServiceState.SHUTTING_DOWN
    
    # Cleanup service-specific resources
    _cleanup_resources()
    
    # Unregister from systems
    if CoreSystemManager:
        CoreSystemManager.unregister_service(self)
    
    if EducationalPlatformManager:
        EducationalPlatformManager.unregister_educational_service(self)

func _cleanup_resources() -> void:
    # Override this method to implement service-specific cleanup
    pass

# Utility methods for educational services
func get_educational_config(key: String, default_value = null):
    # Access educational configuration
    if EducationalPlatformManager:
        return EducationalPlatformManager.get_config(get_name(), key, default_value)
    return default_value

func log_educational_event(event: String, context: Dictionary = {}) -> void:
    if _educational_platform_ready:
        educational_event.emit("log", {
            "service": get_name(),
            "event": event,
            "context": context,
            "timestamp": Time.get_unix_time_from_system()
        })
```

## Usage Example

```gdscript
# Create new educational autoload
class_name BrainDataManager
extends Node

# Replace {{AUTOLOAD_NAME}} with BrainDataManager

func _get_required_dependencies() -> Array[String]:
    return ["CoreSystemManager", "ResourceManager"]

func _initialize_core_functionality() -> bool:
    # Load brain structure data
    var data_loaded = await _load_brain_structure_database()
    if not data_loaded:
        return false
    
    # Initialize 3D model cache
    _initialize_model_cache()
    
    return true

func _load_brain_structure_database() -> bool:
    # Implementation specific to brain data loading
    return true

func _initialize_model_cache() -> void:
    # Implementation specific to model caching
    pass
```

## Integration Steps

1. **Create Autoload File**: Place in `src/autoload/{{AUTOLOAD_NAME}}.gd`
2. **Register in project.godot**: Add to [autoload] section
3. **Replace Template Placeholders**: Update {{AUTOLOAD_NAME}} throughout
4. **Implement Required Methods**: Override virtual methods as needed
5. **Add Dependencies**: Specify required dependencies in `_get_required_dependencies()`
6. **Test Initialization**: Verify service starts correctly
7. **Add Educational Integration**: Implement educational platform features
8. **Performance Testing**: Ensure service meets performance requirements

## Project.godot Registration

```ini
[autoload]
{{AUTOLOAD_NAME}}="*res://src/autoload/{{AUTOLOAD_NAME}}.gd"
```

## Recent Improvements (Claude Code Updates)

<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: Created initial template with educational platform integration
- [CLAUDE CODE: Add new autoload patterns discovered during development]

## Performance Guidelines

- Initialize asynchronously when possible
- Report initialization time for monitoring
- Implement error recovery mechanisms
- Use performance monitoring for optimization
- Cleanup resources properly on shutdown

## Educational Integration Features

- Automatic registration with educational platform
- Learning analytics event tracking
- Accessibility support framework
- Configuration management
- Health monitoring and reporting

---
**Last Updated**: 2025-06-21 by Claude Code
**Template Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0