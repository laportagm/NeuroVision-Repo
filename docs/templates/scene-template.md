# Educational Scene Template

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You create new educational scenes and discover better patterns
- New 3D interaction patterns are implemented
- Educational workflow improvements are found
- Performance optimizations for scenes are discovered

HOW TO UPDATE:
1. Add new scene patterns to template
2. Update 3D interaction sequences
3. Document new educational integration methods
4. Update Recent Improvements section
-->

## Educational Scene Template

### Scene Structure Pattern

```
{{SCENE_NAME}} (Node3D)
├── Environment (Node3D)
│   ├── WorldEnvironment
│   ├── DirectionalLight3D (Main lighting)
│   └── DirectionalLight3D (Fill lighting)
├── CameraSystem (Node3D)
│   ├── CameraController3D (Main camera with orbit controls)
│   └── CameraPresets (Node3D with preset positions)
├── Educational3DContent (Node3D)
│   ├── BrainModel (MeshInstance3D)
│   ├── InteractionAreas (Node3D)
│   └── HighlightEffects (Node3D)
├── EducationalUILayer (CanvasLayer)
│   ├── InfoPanels (Control)
│   ├── DebugOverlay (Control)
│   └── AccessibilityInterface (Control)
└── EducationalSystems (Node)
    ├── InteractionController
    ├── EducationalContentManager
    └── PerformanceMonitor
```

### Scene Script Template

```gdscript
class_name {{SCENE_NAME}}
extends Node3D

# Educational scene configuration
@export_group("Educational Settings")
@export var target_audience: EducationalAudience = EducationalAudience.MEDICAL_STUDENT
@export var educational_mode: EducationalMode = EducationalMode.EXPLORATION
@export var accessibility_features_enabled: bool = true
@export var performance_monitoring_enabled: bool = true
@export var learning_analytics_enabled: bool = true

# Scene components - use @onready for node references
@onready var camera_controller := $CameraSystem/CameraController3D as CameraController3D
@onready var brain_model := $Educational3DContent/BrainModel as MeshInstance3D
@onready var interaction_controller := $EducationalSystems/InteractionController as BrainInteractionController
@onready var ui_layer := $EducationalUILayer as CanvasLayer
@onready var info_panel := $EducationalUILayer/InfoPanels/StructureInfoPanel as StructureInfoPanel

# Educational scene state
var _scene_initialized: bool = false
var _current_selected_structure: String = ""
var _educational_session_data: Dictionary = {}
var _accessibility_mode_active: bool = false

# Performance tracking
var _performance_data: Dictionary = {
    "frame_time_average": 0.0,
    "interaction_response_time": 0.0,
    "memory_usage_mb": 0.0
}

# Educational progression signals
signal educational_structure_selected(structure_name: String, educational_data: Dictionary)
signal learning_objective_completed(objective: String, completion_time: float)
signal educational_milestone_reached(milestone: String, session_data: Dictionary)
signal accessibility_action_performed(action: String, context: Dictionary)

func _ready() -> void:
    # Initialize educational scene
    await _initialize_educational_scene()

func _initialize_educational_scene() -> bool:
    print("[{{SCENE_NAME}}] Initializing educational scene...")
    
    # 1. Validate educational systems
    if not _validate_educational_systems():
        push_error("[{{SCENE_NAME}}] Educational systems validation failed")
        return false
    
    # 2. Setup 3D environment
    _setup_3d_environment()
    
    # 3. Initialize brain model and interactions
    await _initialize_brain_model()
    
    # 4. Setup educational UI
    _setup_educational_ui()
    
    # 5. Configure accessibility features
    if accessibility_features_enabled:
        _setup_accessibility_features()
    
    # 6. Initialize learning analytics
    if learning_analytics_enabled:
        _initialize_learning_analytics()
    
    # 7. Setup performance monitoring
    if performance_monitoring_enabled:
        _setup_performance_monitoring()
    
    # 8. Connect educational signals
    _connect_educational_signals()
    
    _scene_initialized = true
    print("[{{SCENE_NAME}}] Educational scene initialization complete")
    return true

func _validate_educational_systems() -> bool:
    var missing_systems = []
    
    # Check required autoload systems
    if not CoreSystemManager:
        missing_systems.append("CoreSystemManager")
    if not EducationalPlatformManager:
        missing_systems.append("EducationalPlatformManager")
    if not HighlightMaterialManager:
        missing_systems.append("HighlightMaterialManager")
    
    # Check scene components
    if not camera_controller:
        missing_systems.append("CameraController3D")
    if not interaction_controller:
        missing_systems.append("InteractionController")
    
    if missing_systems.size() > 0:
        push_error("[{{SCENE_NAME}}] Missing systems: " + str(missing_systems))
        return false
    
    return true

func _setup_3d_environment() -> void:
    # Configure lighting for medical visualization
    var main_light = $Environment/DirectionalLight3D
    if main_light:
        main_light.light_energy = 1.0
        main_light.shadow_enabled = true
        
    # Setup environment for brain visualization
    var world_env = $Environment/WorldEnvironment
    if world_env and world_env.environment:
        world_env.environment.ambient_light_energy = 0.3
        world_env.environment.background_mode = Environment.BG_COLOR
        world_env.environment.background_color = Color(0.1, 0.125, 0.15, 1.0)

func _initialize_brain_model() -> void:
    if not brain_model:
        push_error("[{{SCENE_NAME}}] Brain model not found")
        return
    
    # Load brain model asynchronously
    if ResourceManager:
        var brain_resource = await ResourceManager.load_brain_model_async("default_brain")
        if brain_resource:
            brain_model.mesh = brain_resource
    
    # Setup brain interaction areas
    _setup_brain_interaction_areas()

func _setup_brain_interaction_areas() -> void:
    # Configure interaction areas for brain structures
    if interaction_controller:
        interaction_controller.setup_brain_interactions(brain_model)
        interaction_controller.structure_selected.connect(_on_brain_structure_selected)
        interaction_controller.structure_deselected.connect(_on_brain_structure_deselected)

func _setup_educational_ui() -> void:
    # Configure UI for educational content
    if info_panel:
        info_panel.target_audience = target_audience
        info_panel.accessibility_mode = accessibility_features_enabled
    
    # Setup UI theme based on target audience
    if UISystemManager:
        match target_audience:
            EducationalAudience.MEDICAL_STUDENT:
                UISystemManager.set_theme_variant("enhanced")
            EducationalAudience.HEALTHCARE_PROFESSIONAL:
                UISystemManager.set_theme_variant("minimal")

func _setup_accessibility_features() -> void:
    # Implement WCAG AAA compliance
    _accessibility_mode_active = true
    
    # Setup keyboard navigation
    _setup_keyboard_navigation()
    
    # Configure screen reader support
    _setup_screen_reader_support()
    
    # Setup high contrast mode
    _setup_high_contrast_mode()

func _setup_keyboard_navigation() -> void:
    # Implement keyboard controls for 3D navigation
    # Example: WASD for camera movement, Tab for structure selection
    pass

func _setup_screen_reader_support() -> void:
    # Implement screen reader announcements for brain structure selection
    pass

func _setup_high_contrast_mode() -> void:
    # Implement high contrast mode for visual accessibility
    pass

func _initialize_learning_analytics() -> void:
    if not ProgressTracker:
        return
    
    # Initialize educational session
    _educational_session_data = {
        "scene_name": get_scene_file_path(),
        "target_audience": EducationalAudience.keys()[target_audience],
        "start_time": Time.get_unix_time_from_system(),
        "structures_explored": [],
        "learning_objectives_completed": []
    }
    
    ProgressTracker.start_educational_session(_educational_session_data)

func _setup_performance_monitoring() -> void:
    if not PerformanceMonitor:
        return
    
    # Register scene for performance monitoring
    PerformanceMonitor.register_scene_for_monitoring(self)
    
    # Setup performance targets for educational scene
    PerformanceMonitor.set_performance_targets({
        "min_fps": 30.0,  # Intel UHD 620 target
        "max_frame_time": 33.33,  # 30 FPS in milliseconds
        "max_memory_mb": 500.0
    })

func _connect_educational_signals() -> void:
    # Connect educational progression signals
    educational_structure_selected.connect(_on_educational_structure_selected)
    learning_objective_completed.connect(_on_learning_objective_completed)
    
    # Connect to educational platform events
    if EducationalPlatformManager:
        EducationalPlatformManager.educational_event.connect(_on_educational_platform_event)

# Educational interaction handlers
func _on_brain_structure_selected(structure_name: String) -> void:
    _current_selected_structure = structure_name
    
    # Get educational content for structure
    var educational_data = {}
    if KnowledgeService:
        educational_data = KnowledgeService.get_structure(structure_name)
    
    # Display educational information
    if info_panel and not educational_data.is_empty():
        info_panel.display_structure_info(educational_data)
    
    # Track educational interaction
    _track_educational_interaction("structure_selected", {
        "structure": structure_name,
        "selection_time": Time.get_unix_time_from_system()
    })
    
    # Emit educational signal
    educational_structure_selected.emit(structure_name, educational_data)

func _on_brain_structure_deselected() -> void:
    if _current_selected_structure.is_empty():
        return
    
    # Track structure exploration time
    _track_educational_interaction("structure_deselected", {
        "structure": _current_selected_structure,
        "deselection_time": Time.get_unix_time_from_system()
    })
    
    _current_selected_structure = ""
    
    # Hide educational information
    if info_panel:
        info_panel.hide_info()

func _on_educational_structure_selected(structure_name: String, educational_data: Dictionary) -> void:
    # Handle educational structure selection
    if learning_analytics_enabled and ProgressTracker:
        ProgressTracker.track_structure_exploration(structure_name, educational_data)

func _on_learning_objective_completed(objective: String, completion_time: float) -> void:
    # Handle learning objective completion
    _educational_session_data.learning_objectives_completed.append({
        "objective": objective,
        "completion_time": completion_time,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    if learning_analytics_enabled and ProgressTracker:
        ProgressTracker.track_learning_objective_completed(objective, completion_time)

func _on_educational_platform_event(event_type: String, data: Dictionary) -> void:
    # Handle educational platform events
    match event_type:
        "theme_changed":
            _update_scene_theme(data.get("theme_variant", "enhanced"))
        "accessibility_mode_toggled":
            _toggle_accessibility_mode(data.get("enabled", false))

# Performance monitoring
func _process(_delta: float) -> void:
    if not performance_monitoring_enabled:
        return
    
    # Update performance metrics
    _performance_data.frame_time_average = Engine.get_frames_per_second()
    
    # Check performance targets
    if _performance_data.frame_time_average < 30.0:
        _handle_performance_degradation()

func _handle_performance_degradation() -> void:
    # Implement performance optimization strategies
    if IntelOptimizer:
        IntelOptimizer.optimize_for_low_performance()

# Educational analytics tracking
func _track_educational_interaction(interaction_type: String, data: Dictionary) -> void:
    if not learning_analytics_enabled or not ProgressTracker:
        return
    
    ProgressTracker.track_scene_interaction(get_scene_file_path(), interaction_type, data)

# Scene state management
func get_educational_session_data() -> Dictionary:
    return _educational_session_data.duplicate()

func is_scene_initialized() -> bool:
    return _scene_initialized

# Cleanup
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_WM_CLOSE_REQUEST:
            _cleanup_educational_scene()

func _cleanup_educational_scene() -> void:
    # Finalize educational session
    if learning_analytics_enabled and ProgressTracker:
        _educational_session_data.end_time = Time.get_unix_time_from_system()
        ProgressTracker.end_educational_session(_educational_session_data)
    
    # Cleanup performance monitoring
    if performance_monitoring_enabled and PerformanceMonitor:
        PerformanceMonitor.unregister_scene_from_monitoring(self)
```

## Usage Example

```gdscript
# Create new educational scene
class_name HippocampusExplorationScene
extends Node3D

# Replace {{SCENE_NAME}} with HippocampusExplorationScene

func _initialize_brain_model() -> void:
    # Load hippocampus-specific model
    if ResourceManager:
        var hippocampus_model = await ResourceManager.load_brain_model_async("hippocampus_detailed")
        if hippocampus_model:
            brain_model.mesh = hippocampus_model
    
    # Setup hippocampus-specific interactions
    _setup_hippocampus_interaction_areas()

func _setup_hippocampus_interaction_areas() -> void:
    # Configure interaction areas specific to hippocampus subregions
    var hippocampus_regions = ["CA1", "CA2", "CA3", "dentate_gyrus"]
    
    for region in hippocampus_regions:
        _setup_region_interaction(region)
```

## Scene Creation Checklist

- [ ] Replace template placeholders ({{SCENE_NAME}})
- [ ] Configure scene node structure
- [ ] Setup 3D environment and lighting
- [ ] Implement brain model loading
- [ ] Configure educational UI components
- [ ] Setup accessibility features
- [ ] Implement learning analytics tracking
- [ ] Test performance targets
- [ ] Add to main scene navigation
- [ ] Create educational content for scene

## Recent Improvements (Claude Code Updates)

<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: Created initial template with educational platform integration
- [CLAUDE CODE: Add new scene patterns discovered during development]

## Performance Guidelines

- Target 30+ FPS on Intel UHD 620
- Implement LOD (Level of Detail) for complex models
- Use performance monitoring for optimization
- Implement graceful performance degradation
- Monitor memory usage during scene operation

## Educational Integration Features

- Learning analytics integration
- Accessibility compliance (WCAG AAA)
- Multi-audience support (students/professionals)
- Theme-aware UI integration
- Educational progression tracking

---
**Last Updated**: 2025-06-21 by Claude Code
**Template Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0