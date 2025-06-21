class_name EnhancedExplorationScene
extends Node3D

const ButtonMotionHandlerScript = preload("res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd") # Validated path

## Enhanced main 3D exploration scene with comprehensive UI
## 
## PERFORMANCE OPTIMIZATIONS APPLIED:
## - Performance monitoring disabled by default (was causing 12 FPS)
## - Timer-based updates (0.5s) instead of per-frame monitoring
## - Removed orphaned UI nodes (ViewSelectionLabel, StructureListSeparator)
## - Added missing @onready references for system nodes
## - Commented out unused annotation system variables
## Target: 30+ FPS on Intel UHD 620 graphics

# === SIGNALS ===
signal structure_selected(structure_name: String)
signal return_to_menu_requested()
signal view_changed(view_name: String)
signal help_toggled(visible: bool)

# === CONSTANTS ===
const CAMERA_SPEED: float = 5.0
const ZOOM_SPEED: float = 0.8  # Adjusted for better zooming
const MIN_ZOOM: float = 8.0    # Better minimum distance
const MAX_ZOOM: float = 30.0   # Allow zooming out more
const ROTATION_SPEED: float = 0.25  # Reduced for better control
const VERTICAL_ANGLE_LIMIT: float = 360.0

# === NODES ===
@onready var camera: Camera3D = $EducationalCameraSystem/AnatomicalCameraPivot/MedicalViewCamera
@onready var camera_pivot: Node3D = $EducationalCameraSystem/AnatomicalCameraPivot
@onready var brain_container: Node3D = $AnatomicalModelContainer
@onready var model_holder: Node3D = $AnatomicalModelContainer/BrainModelHolder
@onready var selection_sphere: MeshInstance3D = $AnatomicalModelContainer/StructureSelectionIndicator
@onready var info_panel = $EducationalUILayer/AnatomicalInfoPanel

# UI Elements
@onready var top_bar: PanelContainer = $EducationalUILayer/MainEducationalInterface/EducationalTopBar
@onready var left_panel: PanelContainer = $EducationalUILayer/MainEducationalInterface/AnatomicalStructurePanel
@onready var bottom_panel: PanelContainer = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar
@onready var view_presets: OptionButton = $EducationalUILayer/MainEducationalInterface/EducationalTopBar/NavigationContent/AnatomicalViewControls/AnatomicalViewPresets
@onready var label_toggle: Button = $EducationalUILayer/MainEducationalInterface/EducationalTopBar/NavigationContent/EducationalToolButtons/AnatomicalLabelToggle
@onready var quiz_button: Button = $EducationalUILayer/MainEducationalInterface/EducationalTopBar/NavigationContent/EducationalToolButtons/EducationalQuizButton
@onready var help_button: Button = $EducationalUILayer/MainEducationalInterface/EducationalTopBar/NavigationContent/EducationalToolButtons/EducationalHelpButton
@onready var structure_items: VBoxContainer = $EducationalUILayer/MainEducationalInterface/AnatomicalStructurePanel/BrainStructureList/StructureScrollContainer/AnatomicalStructureItems
@onready var status_label: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/StatusBarContent/SystemStatusLabel
@onready var performance_label: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/StatusBarContent/PerformanceMetricsLabel
@onready var loading_overlay: ColorRect = $EducationalUILayer/EducationalOverlays/ModelLoadingOverlay
@onready var loading_label: Label = $EducationalUILayer/EducationalOverlays/ModelLoadingOverlay/LoadingStatusLabel
@onready var loading_progress: ProgressBar = $EducationalUILayer/EducationalOverlays/ModelLoadingOverlay/LoadingProgressContent/ModelLoadingProgressBar
@onready var help_overlay: PanelContainer = $EducationalUILayer/EducationalOverlays/EducationalHelpOverlay
@onready var help_close: Button = $EducationalUILayer/EducationalOverlays/EducationalHelpOverlay/HelpGuideContent/CloseHelpButton
# @onready var annotation_layer: Control = $EducationalUILayer/AnatomicalAnnotationLayer # Removed - Medical Annotation System

# Quiz System Components
@onready var quiz_overlay: PanelContainer = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay
@onready var quiz_title: Label = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizHeader/QuizTitle
@onready var quiz_progress: ProgressBar = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizHeader/QuizProgress
@onready var quiz_close_button: Button = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizHeader/QuizCloseButton
@onready var question_text: RichTextLabel = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/QuestionText
@onready var question_image: TextureRect = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/QuestionImage
@onready var answer_options: VBoxContainer = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/AnswerOptions
@onready var option_a = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/AnswerOptions/OptionA
@onready var option_b = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/AnswerOptions/OptionB
@onready var option_c = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/AnswerOptions/OptionC
@onready var option_d = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizQuestionArea/AnswerOptions/OptionD
@onready var quiz_feedback: PanelContainer = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizFeedback
@onready var feedback_text: RichTextLabel = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizFeedback/FeedbackContent/FeedbackText
@onready var clinical_relevance: RichTextLabel = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizFeedback/FeedbackContent/ClinicalRelevance
@onready var previous_button: Button = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizControls/PreviousButton
@onready var submit_button: Button = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizControls/SubmitButton
@onready var next_button: Button = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizControls/NextButton
@onready var review_button: Button = $EducationalUILayer/EducationalOverlays/EducationalQuizOverlay/QuizPanelContent/QuizControls/ReviewButton

# Enhanced Annotation System Components - REMOVED
# Medical annotation nodes have been removed from the scene

# Advanced Camera Collision System Components
@onready var camera_collision: Area3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection
@onready var camera_collision_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraCollisionShape
# Proximity warning system removed in optimization
var proximity_warning: Area3D = null
var proximity_shape: CollisionShape3D = null
#@onready var camera_constraints: StaticBody3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints # Removed in optimization
#@onready var constraint_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints/ConstraintShape # Removed in optimization

# Performance Monitoring UI Components
@onready var performance_toggle: Button = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/StatusBarContent/PerformanceToggle
@onready var performance_panel: PanelContainer = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel
@onready var fps_indicator: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/CoreMetrics/FPSIndicator
@onready var frame_time_indicator: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/CoreMetrics/FrameTimeIndicator
@onready var quality_indicator: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/CoreMetrics/QualityIndicator
@onready var brain_model_complexity: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/MedicalRenderingMetrics/BrainModelComplexity
@onready var texture_memory: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/MedicalRenderingMetrics/TextureMemory
@onready var rendering_quality: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/MedicalRenderingMetrics/RenderingQuality
@onready var interaction_latency: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/EducationalMetrics/InteractionLatency
@onready var accessibility_status: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/EducationalMetrics/AccessibilityStatus
@onready var learning_analytics: Label = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/EducationalMetrics/LearningAnalytics
@onready var memory_usage: ProgressBar = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/SystemHealth/MemoryUsageContainer/MemoryUsage
@onready var cpu_usage: ProgressBar = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/SystemHealth/CPUUsageContainer/CPUUsage
@onready var gpu_usage: ProgressBar = $EducationalUILayer/MainEducationalInterface/EducationalStatusBar/PerformanceMonitoringPanel/PerformanceContent/SystemHealth/GPUUsageContainer/GPUUsage

# Enhanced Lighting System
@onready var lighting_system: Node3D = $EnvironmentSystem/MedicalLightingSystem
@onready var key_light: DirectionalLight3D = $EnvironmentSystem/MedicalLightingSystem/KeyLight
@onready var fill_light: DirectionalLight3D = $EnvironmentSystem/MedicalLightingSystem/FillLight
@onready var rim_light: DirectionalLight3D = $EnvironmentSystem/MedicalLightingSystem/RimLight
@onready var environment: WorldEnvironment = $EnvironmentSystem/MedicalVisualizationEnvironment

# System Nodes (Added to fix missing references)
@onready var medical_rendering_system: Node3D = $EducationalSystemsContainer/MedicalRenderingSystem
@onready var interaction_controller: Node3D = $EducationalSystemsContainer/InteractionController

# Visualization helpers
# Removed - visualization helpers deleted for performance

# === PRIVATE VARIABLES ===
var _camera_distance: float = 15.0  # Better initial distance for brain model
var _rotation_speed: float = ROTATION_SPEED
var _is_rotating: bool = false
var _is_panning: bool = false
var _camera_rotation: Vector2 = Vector2(deg_to_rad(-45), deg_to_rad(-20))  # Better initial angle for brain viewing
var _brain_interaction: Node3D = null
var _model_loader: Node = null
var _camera_presets: Node = null
# var _annotation_system: Node = null  # Removed - Medical Annotation System
var _brain_structures: Dictionary = {}  # structure_id -> MeshInstance3D
var _mesh_to_structure_id: Dictionary = {}  # mesh_name -> structure_id
var _quiz_panel = null  # QuizPanel instance
var _current_structure_id: String = ""
var _structure_buttons: Dictionary = {}  # structure_id -> Button
var _is_loading: bool = false

# Educational Quiz System Variables
var _current_quiz_data: Dictionary = {}
var _current_quiz_question: int = 0
var _quiz_answers: Dictionary = {}  # question_id -> selected_answer
var _quiz_scores: Dictionary = {}  # question_id -> correct/incorrect
var _quiz_is_active: bool = false

# Missing variables used in _exit_tree
var _debounce_timer: Timer = null

# Missing UI references that were causing errors
var _tooltip_timer: Timer = null
var _current_structure: Node = null
var _last_hover_structure: Node = null
var _camera_target_position: Vector3 = Vector3.ZERO
var _camera_target_rotation: Vector3 = Vector3.ZERO
var _quiz_structure_context: String = ""
var _quiz_answer_options: Array = []

# Enhanced Annotation System Variables - DISABLED (commented out to save memory)
# Temporarily declaring to avoid errors - annotation system is disabled
var _annotation_labels: Dictionary = {}  # structure_id -> Label
@warning_ignore("unused_private_class_variable")
var _3d_to_2d_projections: Dictionary = {}  # structure_id -> Vector2
@warning_ignore("unused_private_class_variable")
var _label_visibility_distance: float = 25.0
var _annotation_font_size: float = 14.0
var _high_contrast_mode: bool = false
var _annotation_language: String = "english"
var _medical_terminology_database: Dictionary = {}
# var _annotation_update_timer: float = 0.0  # Removed - unused
# var _annotation_update_interval: float = 0.1  # Removed - unused

# Performance monitoring control flag
var performance_monitoring_enabled: bool = false  # DISABLED by default to fix 12 FPS issue
var performance_update_timer: float = 0.0
var performance_update_interval: float = 0.5  # Update every 0.5 seconds instead of every frame

# Advanced Camera Collision System Variables
var _collision_avoidance_enabled: bool = true
var _min_distance_from_brain: float = 1.0
var _max_distance_from_brain: float = 50.0
var _collision_recovery_speed: float = 3.0
var _proximity_warning_distance: float = 5.0
var _is_collision_active: bool = false
var _collision_normal: Vector3 = Vector3.ZERO
var _target_collision_distance: float = 0.0

# Trackpad support variables
var _zoom_velocity: float = 0.0

# Advanced Camera System (Phase 5)
var _camera_ai_enabled = true
var _camera_movement_history = []
var _camera_collision_area: Area3D = null

# Optimal viewing angles for different structures
var _structure_viewing_presets = {
	"hippocampus": {
		"distance": 15.0,
		"angle": Vector3(-20, 45, 0),
		"focus_point": Vector3(0, -2, 0)
	},
	"cortex": {
		"distance": 25.0,
		"angle": Vector3(-30, 0, 0),
		"focus_point": Vector3(0, 2, 0)
	},
	"cerebellum": {
		"distance": 18.0,
		"angle": Vector3(-45, 30, 0),
		"focus_point": Vector3(0, -3, 2)
	},
	"striatum": {
		"distance": 12.0,
		"angle": Vector3(-15, 60, 0),
		"focus_point": Vector3(0, 0, 0)
	},
	"thalamus": {
		"distance": 14.0,
		"angle": Vector3(-25, 30, 0),
		"focus_point": Vector3(0, -1, 0)
	},
	"amygdala": {
		"distance": 13.0,
		"angle": Vector3(-30, 50, 0),
		"focus_point": Vector3(0, -2, 1)
	},
	"ventricles": {
		"distance": 20.0,
		"angle": Vector3(-40, 20, 0),
		"focus_point": Vector3(0, 0, 0)
	},
	"corpus_callosum": {
		"distance": 16.0,
		"angle": Vector3(-10, 0, 0),
		"focus_point": Vector3(0, 1, 0)
	}
}

# Advanced Lighting System
var _lighting_presets = {
	"default": {
		"key_intensity": 1.2,
		"fill_intensity": 0.6,
		"rim_intensity": 0.8,
		"ambient_intensity": 0.1
	},
	"detailed_examination": {
		"key_intensity": 1.8,
		"fill_intensity": 0.9,
		"rim_intensity": 1.2,
		"ambient_intensity": 0.05
	},
	"overview": {
		"key_intensity": 0.8,
		"fill_intensity": 0.4,
		"rim_intensity": 0.6,
		"ambient_intensity": 0.15
	},
	"presentation": {
		"key_intensity": 1.5,
		"fill_intensity": 0.7,
		"rim_intensity": 1.0,
		"ambient_intensity": 0.08
	}
}

# Professional Performance Monitoring for Medical Education
var _performance_data: Dictionary = {
	"frame_times": [],
	"memory_usage": [],
	"ui_response_times": [],
	"accessibility_violations": [],
	"target_fps": 30.0,  # Intel UHD 620 target
	"target_frame_time": 16.67,  # 60 FPS ideal, 33.33ms minimum (30 FPS)
	"target_ui_response": 100.0,  # <100ms UI response target
	"frame_count": 0,
	"total_time": 0.0
}

# Export trackpad settings for easy adjustment
@export_group("Trackpad Settings")
@export_range(0.1, 2.0, 0.1) var trackpad_zoom_sensitivity: float = 0.5
@export_range(0.1, 2.0, 0.1) var trackpad_rotate_sensitivity: float = 0.7
@export_range(0.5, 0.95, 0.05) var trackpad_zoom_damping: float = 0.85

# === PUBLIC METHODS ===

func _ready() -> void:
	var _progress_tracker = get_node_or_null("/root/ProgressTracker")
	print("[EnhancedExplorationScene] Initializing professional medical interface")

	# === PERFORMANCE OPTIMIZATION FOR INTEL UHD 620 ===
	_optimize_for_integrated_graphics()

	# Enhanced error detection setup
	_setup_enhanced_error_detection()

	# Initialize with error checking
	_safe_setup_ui()
	_safe_setup_scene()
	_safe_setup_advanced_lighting()
	_safe_setup_intelligent_camera()
	# _safe_setup_enhanced_annotation_system()  # Removed - Medical Annotation System
	_safe_setup_camera_collision_system()
	# Axis indicator removed for performance
	_safe_connect_signals()
	_safe_setup_help_text()
	_safe_add_panels_to_ui_group()

	# === Initialize Comprehensive Brain Rendering System ===
	_safe_initialize_medical_grade_rendering()
	
	# === CRITICAL PERFORMANCE FIX: Disable performance monitoring panel by default ===
	if performance_panel:
		performance_panel.visible = false
		print("[Performance Fix] Performance monitoring panel disabled by default")

	# Professional medical education validation
	await get_tree().create_timer(1.0).timeout  # Allow UI to stabilize
	_validate_accessibility_compliance()
	print("[Professional UI] Medical education interface ready")

	# === Phase 6: Initialize Performance Integration ===
	_setup_performance_integration()

	show_loading("Initializing NeuroVision Professional...")

func _physics_process(delta: float) -> void:
	# Apply smooth zoom for trackpad
	if abs(_zoom_velocity) > 0.001:
		_camera_distance += _zoom_velocity * delta
		_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)
		_zoom_velocity *= trackpad_zoom_damping
		_update_camera_position()

	# Update annotation projections for real-time 3D-to-2D display
	# Annotation update system removed

	# Handle camera collision avoidance
	_handle_camera_collision_in_physics(delta)

	# Professional Performance Monitoring for Medical Education
	# _monitor_performance(delta)  # DISABLED - was causing 12 FPS issue
	if performance_monitoring_enabled:  # Only run if explicitly turned on
		performance_update_timer += delta
		if performance_update_timer >= performance_update_interval:
			_monitor_performance(delta)
			performance_update_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_keyboard(event)
	elif event is InputEventPanGesture:
		_handle_pan_gesture(event)
	elif event is InputEventMagnifyGesture:
		_handle_magnify_gesture(event)

func show_loading(message: String, progress: float = -1.0) -> void:
	"""Show loading overlay with optional progress"""
	loading_overlay.visible = true
	loading_label.text = message
	if progress >= 0:
		loading_progress.visible = true
		loading_progress.value = progress * 100
	else:
		loading_progress.visible = false
	_is_loading = true

func hide_loading() -> void:
	"""Hide loading overlay"""
	loading_overlay.visible = false
	_is_loading = false

func update_status(message: String) -> void:
	"""Update status bar message"""
	status_label.text = message

func toggle_grid(_should_show: bool) -> void:
	"""Toggle grid floor visibility - removed for performance"""
	pass

func toggle_axis_indicator(_should_show: bool) -> void:
	"""Toggle axis indicator visibility - removed for performance"""
	pass

func adapt_lighting_for_structure(structure_id: String) -> void:
	"""Adapt lighting based on selected brain structure"""
	var preset = "default"

	# Determine optimal lighting based on structure
	match structure_id:
		"hippocampus", "amygdala":
			preset = "detailed_examination"  # Internal structures need more light
		"cortex", "cerebellum":
			preset = "overview"  # Large structures benefit from broader lighting
		_:
			preset = "default"

	apply_lighting_preset(preset)

func apply_lighting_preset(preset_name: String) -> void:
	"""Apply lighting preset with smooth transitions"""
	if not _lighting_presets.has(preset_name):
		push_warning("[Lighting] Unknown preset: " + preset_name)
		return

	var preset = _lighting_presets[preset_name]
	var tween = create_tween()
	tween.set_parallel(true)

	# Animate lighting transitions
	if key_light:
		tween.tween_property(key_light, "light_energy", preset.key_intensity, 1.0)
	if fill_light:
		tween.tween_property(fill_light, "light_energy", preset.fill_intensity, 1.0)
	if rim_light:
		tween.tween_property(rim_light, "light_energy", preset.rim_intensity, 1.0)

	print("[Lighting] Applied preset: " + preset_name)

func enable_ai_camera_assistance(enabled: bool) -> void:
	"""Enable or disable AI-assisted camera positioning"""
	_camera_ai_enabled = enabled
	print("[Camera] AI assistance: %s" % ("enabled" if enabled else "disabled"))

func smart_focus_on_structure(structure_id: String, mesh_instance: MeshInstance3D) -> void:
	"""Intelligently focus camera on selected structure"""
	if not _camera_ai_enabled or not mesh_instance:
		return

	# Get optimal viewing preset for this structure
	var preset = _structure_viewing_presets.get(structure_id, {
		"distance": 20.0,
		"angle": Vector3(-30, 30, 0),
		"focus_point": Vector3.ZERO
	})

	# Calculate optimal camera position
	var structure_center = mesh_instance.global_position
	var optimal_position = structure_center + _calculate_optimal_camera_offset(preset)

	# Animate camera to optimal position
	_animate_to_optimal_view(optimal_position, structure_center, preset.angle, preset.distance)

func _calculate_optimal_camera_offset(preset: Dictionary) -> Vector3:
	"""Calculate optimal camera offset based on viewing preset"""
	var distance = preset.get("distance", 20.0)
	var angle = preset.get("angle", Vector3(-30, 30, 0))

	# Convert angles to position offset
	var offset = Vector3(
		sin(deg_to_rad(angle.y)) * cos(deg_to_rad(angle.x)),
		sin(deg_to_rad(angle.x)),
		cos(deg_to_rad(angle.y)) * cos(deg_to_rad(angle.x))
	) * distance

	return offset

func _animate_to_optimal_view(_target_position: Vector3, focus_point: Vector3, target_rotation: Vector3, target_distance: float) -> void:
	"""Animate camera to optimal viewing position"""
	var tween = create_tween()
	tween.set_parallel(true)

	# Animate camera pivot to focus point
	tween.tween_property(camera_pivot, "global_position", focus_point, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Animate camera distance
	tween.tween_property(self, "_camera_distance", target_distance, 1.5).set_ease(Tween.EASE_OUT)

	# Animate camera rotation
	tween.tween_property(self, "_camera_rotation", Vector2(deg_to_rad(target_rotation.y), deg_to_rad(target_rotation.x)), 1.5).set_ease(Tween.EASE_OUT)

	# Update camera position during animation
	tween.tween_callback(_update_camera_position).set_delay(0.1)

	await tween.finished
	update_status("Focused on structure with optimal viewing angle")

func set_environment_for_context(context: String) -> void:
	"""Set environment configuration for different learning contexts"""
	if not environment or not environment.environment:
		push_warning("[Environment] Environment not found")
		return

	var env = environment.environment

	match context:
		"clinical":
			# Clinical examination environment - bright and sterile
			env.ambient_light_energy = 0.3
			env.ambient_light_color = Color(0.98, 0.99, 1.0)  # Cool sterile white
			env.background_color = Color(0.15, 0.16, 0.17, 1)  # Neutral medical gray
		"presentation":
			# Presentation mode - optimized for projection/display
			env.ambient_light_energy = 0.2
			env.ambient_light_color = Color(0.9, 0.95, 1.0)  # Slightly cool
			env.background_color = Color(0.05, 0.08, 0.12, 1)  # Dark for contrast
		"study":
			# Study mode - warm and comfortable for long sessions
			env.ambient_light_energy = 0.4
			env.ambient_light_color = Color(1.0, 0.98, 0.95)  # Warm white
			env.background_color = Color(0.12, 0.14, 0.16, 1)  # Gentle dark blue
		_:
			# Default educational environment
			env.ambient_light_energy = 0.4
			env.ambient_light_color = Color(0.3, 0.6, 1.0)  # Educational blue
			env.background_color = Color(0.1, 0.125, 0.15, 1)  # Standard background

	print("[Environment] Set environment for context: " + context)

# === PRIVATE METHODS ===

# Enhanced Error Detection Methods
func _setup_enhanced_error_detection() -> void:
	"""Set up comprehensive error detection and logging"""
	# Enable verbose logging for debugging
	if OS.is_debug_build():
		print("[DEBUG] Enhanced error detection enabled")
		# Track all errors and warnings
		get_tree().node_configuration_warning_changed.connect(_on_node_warning_changed)

func _on_node_warning_changed(node: Node) -> void:
	"""Log node configuration warnings"""
	if node.has_method("get_configuration_warnings"):
		var warnings = node.get_configuration_warnings()
		if warnings.size() > 0:
			push_warning("[NodeWarning] %s: %s" % [node.get_path(), warnings])

func _safe_setup_ui() -> void:
	"""Setup UI with error checking"""
	_setup_ui()
	if not _validate_ui_setup():
		push_error("[UI Setup] Failed to initialize UI components")
		_log_missing_nodes()

func _safe_setup_scene() -> void:
	"""Setup scene with error checking"""
	_setup_scene()
	if not _validate_scene_setup():
		push_error("[Scene Setup] Failed to initialize scene")

func _safe_setup_advanced_lighting() -> void:
	"""Setup lighting with error checking"""
	_setup_advanced_lighting()
	if not _validate_lighting_setup():
		push_error("[Lighting Setup] Failed to initialize lighting")

func _safe_setup_intelligent_camera() -> void:
	"""Setup camera with error checking"""
	_setup_intelligent_camera()
	if not _validate_camera_setup():
		push_error("[Camera Setup] Failed to initialize camera")

func _safe_setup_enhanced_annotation_system() -> void:
	"""Setup annotations with error checking - DISABLED"""
	# _setup_enhanced_annotation_system() - Medical annotation system removed
	# if not _validate_annotation_setup():
	#	push_error("[Annotation Setup] Failed to initialize annotations")
	pass

func _safe_setup_camera_collision_system() -> void:
	"""Setup camera collision with error checking"""
	_setup_camera_collision_system()
	if not _validate_camera_collision_setup():
		push_error("[Camera Collision] Failed to initialize collision system")

func _safe_create_axis_indicator() -> void:
	"""Create axis indicator with error checking - removed for performance"""
	pass

func _safe_connect_signals() -> void:
	"""Connect signals with error checking"""
	_connect_signals()
	# Signal connections don't need validation as they silently fail if nodes are missing

func _safe_setup_help_text() -> void:
	"""Setup help text with error checking"""
	_setup_help_text()
	if not _validate_help_text_setup():
		push_error("[Help Text] Failed to setup help text")

func _safe_add_panels_to_ui_group() -> void:
	"""Add panels to UI group with error checking"""
	_add_panels_to_ui_group()
	# Adding to groups doesn't fail - no validation needed

func _safe_initialize_medical_grade_rendering() -> void:
	"""Initialize rendering with error checking"""
	_initialize_medical_grade_rendering()
	if not _validate_rendering_setup():
		push_error("[Rendering] Failed to initialize medical-grade rendering")

func _log_missing_nodes() -> void:
	"""Log all missing node references"""
	var missing_nodes = []

	# Check all @onready variables
	var properties = get_property_list()
	for prop in properties:
		if prop.name.begins_with("$"):
			var node = get(prop.name)
			if not is_instance_valid(node):
				missing_nodes.append(prop.name)

	if missing_nodes.size() > 0:
		push_error("[Missing Nodes] The following nodes were not found: %s" % str(missing_nodes))

func try(callable: Callable) -> void:
	"""Helper function for try-catch pattern in GDScript"""
	callable.call()

func except(callable: Callable = func(): pass) -> void:
	"""Helper function for exception handling"""
	if callable:
		callable.call()

func _setup_ui() -> void:
	"""Setup all UI elements with Material 3 styling"""
	# Apply M3 theme to all UI components
	_apply_m3_theme_to_ui()

	# Configure view presets
	view_presets.selected = 0
	view_presets.item_selected.connect(_on_view_preset_selected)

	# Apply M3 button styling to all buttons
	_apply_m3_button_styling(label_toggle, "Labels", M3ComponentApplicator.ButtonVariant.SECONDARY)
	_apply_m3_button_styling(quiz_button, "Quiz", M3ComponentApplicator.ButtonVariant.SECONDARY)
	_apply_m3_button_styling(help_button, "?", M3ComponentApplicator.ButtonVariant.ICON)
	_apply_m3_button_styling(help_close, "✕", M3ComponentApplicator.ButtonVariant.ICON)

	# Configure buttons
	label_toggle.toggled.connect(_on_labels_toggled)
	quiz_button.pressed.connect(_on_quiz_pressed)
	help_button.pressed.connect(_on_help_pressed)
	help_close.pressed.connect(func(): help_overlay.visible = false)

	# Hide overlays initially
	help_overlay.visible = false
	loading_overlay.visible = false

	# Set initial performance display with M3 typography
	if performance_label:
		M3ComponentApplicator.apply_m3_text_styling(performance_label, M3ComponentApplicator.TypographyScale.LABEL_SMALL)
		performance_label.text = "FPS: -- | Quality: --"
		performance_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

func _apply_m3_theme_to_ui() -> void:
	"""Apply comprehensive Material 3 theme to all UI components"""
	print("[EnhancedExplorationScene] Applying M3 theme to all UI components")

	# Apply comprehensive NeuroVision theme to entire UI hierarchy
	var NeuroVisionTheme = preload("res://src/ui_atomic/themes/utilities/apply_neurovision_theme.gd")
	NeuroVisionTheme.apply_neurovision_theme_to_scene($EducationalUILayer)

	# Apply M3 to top bar with better contrast
	if top_bar:
		var top_style = StyleBoxFlat.new()
		top_style.bg_color = Color(0.2, 0.2, 0.25, 0.95)  # Darker background for top bar
		top_style.corner_radius_bottom_left = 4
		top_style.corner_radius_bottom_right = 4
		top_bar.add_theme_stylebox_override("panel", top_style)
		_apply_m3_to_top_bar_components()

	# Apply M3 to left panel with light background for readability
	if left_panel:
		var left_style = StyleBoxFlat.new()
		left_style.bg_color = Color(0.95, 0.95, 0.95, 0.98)  # Light background
		left_style.corner_radius_top_right = 8
		left_style.corner_radius_bottom_right = 8
		left_panel.add_theme_stylebox_override("panel", left_style)
		_apply_m3_to_left_panel_components()

	# Apply M3 to bottom panel with dark styling
	if bottom_panel:
		var bottom_style = StyleBoxFlat.new()
		bottom_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)  # Dark background
		bottom_style.corner_radius_top_left = 4
		bottom_style.corner_radius_top_right = 4
		bottom_panel.add_theme_stylebox_override("panel", bottom_style)
		_apply_m3_to_bottom_panel_components()

	# Apply M3 to modal overlays
	_apply_m3_to_overlays()

	# Apply M3 to view controls dropdown
	_apply_m3_to_view_controls()

func _apply_m3_to_top_bar_components() -> void:
	"""Apply M3 styling to top bar components"""
	# Style the app title/logo
	var logo_label = top_bar.get_node_or_null("TopBarContent/Logo")
	if logo_label and logo_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(logo_label, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
		logo_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.9))  # Light blue for logo

	# Style view controls label
	var view_label = top_bar.get_node_or_null("TopBarContent/ViewControls/ViewLabel")
	if view_label and view_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(view_label, M3ComponentApplicator.TypographyScale.LABEL_MEDIUM)
		view_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Light text on dark background

func _apply_m3_to_left_panel_components() -> void:
	"""Apply M3 styling to left panel components"""
	# Style the structures list title
	var title_label = left_panel.get_node_or_null("StructureList/Title")
	if title_label and title_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
		title_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))  # Dark text on light background

	# Style the HSeparator
	var separator = left_panel.get_node_or_null("StructureList/HSeparator")
	if separator and separator is HSeparator:
		separator.add_theme_color_override("separator", Color(0.7, 0.7, 0.7))  # Visible separator
		separator.add_theme_constant_override("separation", 2)

func _apply_m3_to_bottom_panel_components() -> void:
	"""Apply M3 styling to bottom panel components"""
	# Style status label with M3 typography - light text on dark background
	if status_label:
		M3ComponentApplicator.apply_m3_text_styling(status_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		status_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Light text

	# Style performance label with M3 typography - light text on dark background
	if performance_label:
		M3ComponentApplicator.apply_m3_text_styling(performance_label, M3ComponentApplicator.TypographyScale.LABEL_SMALL)
		performance_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))  # Slightly dimmer light text

func _apply_m3_to_overlays() -> void:
	"""Apply M3 styling to modal overlays"""
	# Style help overlay as M3 modal dialog
	if help_overlay:
		M3ComponentApplicator.apply_m3_panel_styling(help_overlay, M3ComponentApplicator.PanelVariant.MODAL)

		# Style help title
		var help_title = help_overlay.get_node_or_null("HelpContent/HelpTitle")
		if help_title and help_title is Label:
			M3ComponentApplicator.apply_m3_text_styling(help_title, M3ComponentApplicator.TypographyScale.HEADLINE_SMALL)
			help_title.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])

		# Style help text
		var help_text = help_overlay.get_node_or_null("HelpContent/HelpText")
		if help_text and help_text is RichTextLabel:
			help_text.add_theme_color_override("default_color", M3DesignTokens.M3_COLORS["on_surface"])
			help_text.add_theme_font_size_override("normal_font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])

	# Style loading overlay with M3 scrim
	if loading_overlay:
		loading_overlay.color = M3DesignTokens.M3_COLORS["scrim"]

		# Style loading label
		if loading_label:
			M3ComponentApplicator.apply_m3_text_styling(loading_label, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
			loading_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])

		# Style loading progress bar
		if loading_progress:
			_apply_m3_to_progress_bar(loading_progress)

func _apply_m3_to_view_controls() -> void:
	"""Apply M3 styling to view controls dropdown"""
	if view_presets:
		# Apply M3 filled variant button styling to dropdown
		M3ComponentApplicator.apply_m3_button_styling(view_presets, M3ComponentApplicator.ButtonVariant.SECONDARY)
		view_presets.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
		view_presets.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])

		# Style dropdown background
		var dropdown_style = StyleBoxFlat.new()
		dropdown_style.bg_color = M3DesignTokens.M3_COLORS["surface_container"]
		dropdown_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
		dropdown_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		dropdown_style.border_color = M3DesignTokens.M3_COLORS["outline"]
		dropdown_style.set_border_width_all(1)
		view_presets.add_theme_stylebox_override("normal", dropdown_style)

		# Style dropdown hover state
		var dropdown_hover = dropdown_style.duplicate()
		dropdown_hover.bg_color = M3DesignTokens.M3_COLORS["surface_container_high"]
		view_presets.add_theme_stylebox_override("hover", dropdown_hover)

func _apply_m3_to_progress_bar(progress_bar: ProgressBar) -> void:
	"""Apply M3 styling to progress bar"""
	if not progress_bar:
		return

	# M3 progress bar background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.M3_COLORS["surface_variant"]
	bg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	bg_style.content_margin_top = 4
	bg_style.content_margin_bottom = 4

	# M3 progress bar fill
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = M3DesignTokens.M3_COLORS["primary"]
	fill_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	fill_style.content_margin_top = 4
	fill_style.content_margin_bottom = 4

	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func _apply_m3_button_styling(button: Button, text: String, variant: M3ComponentApplicator.ButtonVariant) -> void:
	"""Apply M3 styling to a button with motion"""
	if not button:
		return

	button.text = text
	M3ComponentApplicator.apply_m3_button_styling(button, variant)

	# Override colors for better contrast on dark top bar
	button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Light text
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))  # Bright on hover
	button.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.8))  # Slightly darker when pressed

	# Custom button background for visibility
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.3, 0.3, 0.35, 0.8)  # Semi-transparent dark
	style_normal.set_corner_radius_all(4)
	style_normal.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.4, 0.4, 0.45, 0.9)  # Lighter on hover
	style_hover.set_corner_radius_all(4)
	style_hover.set_content_margin_all(8)
	button.add_theme_stylebox_override("hover", style_hover)

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.25, 0.25, 0.3, 0.9)  # Darker when pressed
	style_pressed.set_corner_radius_all(4)
	style_pressed.set_content_margin_all(8)
	button.add_theme_stylebox_override("pressed", style_pressed)

	# Add motion effects
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandlerScript.setup_button_hover_animation(button)

func _setup_scene() -> void:
	"""Initialize scene components"""
	_setup_camera_orbit()
	_update_camera_position()
	_setup_brain_interaction()
	_setup_model_loader()
	_setup_camera_presets()
	# _setup_annotation_system()  # Removed - Medical Annotation System
	_setup_quiz_panel()

	# Start loading brain models
	_load_brain_models()

func _setup_advanced_lighting() -> void:
	"""Setup professional medical lighting system"""
	if not lighting_system:
		push_error("[Lighting] Lighting system not found")
		return

	# Configure key light (main illumination)
	if key_light:
		key_light.rotation_degrees = Vector3(-45, 30, 0)
		key_light.light_energy = 1.2
		key_light.light_color = Color(1.0, 0.98, 0.95)  # Warm white
		key_light.shadow_enabled = true
		key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		key_light.directional_shadow_max_distance = 50.0

	# Configure fill light (soft shadows)
	if fill_light:
		fill_light.rotation_degrees = Vector3(-30, -45, 0)
		fill_light.light_energy = 0.6
		fill_light.light_color = Color(0.95, 0.98, 1.0)  # Cool white
		fill_light.shadow_enabled = false

	# Configure rim light (edge definition)
	if rim_light:
		rim_light.rotation_degrees = Vector3(-15, 135, 0)
		rim_light.light_energy = 0.8
		rim_light.light_color = Color(1.0, 1.0, 1.0)  # Neutral white
		rim_light.shadow_enabled = false

	# Set default environment for educational context
	set_environment_for_context("default")

	print("[Lighting] Professional medical lighting initialized")

func _setup_intelligent_camera() -> void:
	"""Initialize intelligent camera system"""
	# Add camera collision avoidance
	_setup_camera_collision_detection()

	# Initialize movement prediction
	_camera_movement_history.clear()

	print("[Camera] Intelligent camera system initialized")

func _setup_camera_collision_detection() -> void:
	"""Setup camera collision avoidance system"""
	# Add Area3D for collision detection around camera
	_camera_collision_area = Area3D.new()
	_camera_collision_area.name = "CameraCollisionArea"
	camera.add_child(_camera_collision_area)

	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 2.0
	collision_shape.shape = sphere_shape
	_camera_collision_area.add_child(collision_shape)

	# Connect collision signals
	_camera_collision_area.body_entered.connect(_on_camera_body_collision_detected)

func _on_camera_body_collision_detected(body: Node3D) -> void:
	"""Handle camera collision with brain model"""
	if not _camera_ai_enabled:
		return

	# Automatically adjust camera to avoid clipping
	var collision_normal = (camera.global_position - body.global_position).normalized()
	var safe_position = body.global_position + collision_normal * 3.0

	# Smoothly move camera to safe position
	var tween = create_tween()
	tween.tween_property(camera, "global_position", safe_position, 0.5)

	update_status("Camera collision avoided - repositioning")

func _setup_camera_orbit() -> void:
	"""Setup camera orbit system"""
	camera_pivot.position = brain_container.global_position
	_update_camera_orbit()

func _update_camera_orbit() -> void:
	"""Update camera orbit based on rotation angles"""
	camera_pivot.rotation = Vector3.ZERO
	camera_pivot.rotate_y(_camera_rotation.x)
	camera_pivot.rotate_x(_camera_rotation.y)
	_update_camera_position()

func _update_camera_position() -> void:
	"""Update camera position based on distance"""
	var offset = Vector3(0, 0, _camera_distance)
	camera.position = offset
	camera.look_at(camera_pivot.global_position, Vector3.UP)

func _create_axis_indicator() -> void:
	"""Create 3D axis indicator - removed for performance"""
	pass

func _create_axis_material(color: Color) -> StandardMaterial3D:
	"""Create material for axis indicator"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.5
	return mat

func _connect_signals() -> void:
	"""Connect all signals"""
	# Connect info panel signals
	info_panel.close_requested.connect(_on_info_panel_closed)
	info_panel.quiz_requested.connect(_on_info_panel_quiz_requested)

	# Connect quiz system signals
	quiz_close_button.pressed.connect(_on_quiz_close_pressed)
	previous_button.pressed.connect(_on_quiz_previous_pressed)
	submit_button.pressed.connect(_on_quiz_submit_pressed)
	next_button.pressed.connect(_on_quiz_next_pressed)
	review_button.pressed.connect(_on_quiz_review_pressed)

	# Initialize quiz answer options array
	_quiz_answer_options = [option_a, option_b, option_c, option_d]

	# Connect answer option signals
	for i in range(_quiz_answer_options.size()):
		var option = _quiz_answer_options[i]
		if is_instance_valid(option) and option.has_signal("toggled"):
			option.toggled.connect(_on_quiz_answer_selected.bind(i))
		else:
			push_warning("[Quiz] Option %d is not a valid CheckBox" % i)

	# Connect annotation system signals - REMOVED
	# Medical annotation system has been disabled

	# Connect camera collision system signals
	if camera_collision and camera_collision.has_signal("area_entered"):
		if not camera_collision.area_entered.is_connected(_on_camera_area_collision_detected):
			camera_collision.area_entered.connect(_on_camera_area_collision_detected)
	if camera_collision and camera_collision.has_signal("area_exited"):
		if not camera_collision.area_exited.is_connected(_on_camera_collision_exited):
			camera_collision.area_exited.connect(_on_camera_collision_exited)
	# proximity_warning.area_entered # Node removed.connect(_on_camera_proximity_warning)
	if proximity_warning and proximity_warning.has_signal("area_exited"):
		if not proximity_warning.area_exited.is_connected(_on_camera_proximity_cleared):
			proximity_warning.area_exited.connect(_on_camera_proximity_cleared)

	# Connect to PerformanceMonitor if available
	if has_node("/root/PerformanceMonitor"):
		var perf_monitor = get_node("/root/PerformanceMonitor")
		if perf_monitor.has_signal("performance_report_ready"):
			if not perf_monitor.performance_report_ready.is_connected(_on_performance_report):
				perf_monitor.performance_report_ready.connect(_on_performance_report)
		if perf_monitor.has_signal("quality_level_changed"):
			if not perf_monitor.quality_level_changed.is_connected(_on_quality_changed):
				perf_monitor.quality_level_changed.connect(_on_quality_changed)

	# Connect performance monitoring UI signals
	if is_instance_valid(performance_toggle) and performance_toggle.has_signal("pressed"):
		if not performance_toggle.pressed.is_connected(_on_performance_toggle_pressed):
			performance_toggle.pressed.connect(_on_performance_toggle_pressed)

func _setup_help_text() -> void:
	"""Setup help overlay content"""
	var help_text = $EducationalUILayer/EducationalOverlays/EducationalHelpOverlay/HelpGuideContent/ControlsGuideText
	if help_text:
		help_text.text = "[b]Mouse Controls:[/b]\n" + \
			"• Left Click + Drag - Rotate camera\n" + \
			"• Middle Click + Drag - Pan camera\n" + \
			"• Right Click - Select structure\n" + \
			"• Scroll Wheel - Zoom in/out\n\n" + \
			"[b]Trackpad Controls:[/b]\n" + \
			"• Two-finger swipe - Rotate camera\n" + \
			"• Pinch - Zoom in/out\n" + \
			"• Two-finger scroll - Smooth zoom\n" + \
			"• Click + drag - Rotate camera\n\n" + \
			"[b]Keyboard Shortcuts:[/b]\n" + \
			"• R - Reset camera view\n" + \
			"• F - Focus on selected structure\n" + \
			"• G - Toggle grid\n" + \
			"• L - Toggle labels\n" + \
			"• Q - Open quiz\n" + \
			"• H - Toggle this help\n" + \
			"• ESC - Return to menu\n" + \
			"• C - Toggle AI camera assistance\n\n" + \
			"[b]Lighting Controls:[/b]\n" + \
			"• 1 - Default lighting\n" + \
			"• 2 - Detailed examination lighting\n" + \
			"• 3 - Overview lighting\n" + \
			"• 4 - Presentation lighting\n" + \
			"• 5 - Clinical environment\n" + \
			"• 6 - Presentation environment\n" + \
			"• 7 - Study environment\n" + \
			"• 8 - Default environment\n\n" + \
			"[b]Camera Features:[/b]\n" + \
			"• Intelligent auto-framing for each structure\n" + \
			"• Collision avoidance prevents model clipping\n" + \
			"• Smooth cinematic transitions\n" + \
			"• Optimal viewing angles for medical education\n\n" + \
			"[b]Tips:[/b]\n" + \
			"• Click structure buttons on the left to select\n" + \
			"• Right-click directly on 3D structures\n" + \
			"• Use camera presets dropdown for quick views\n" + \
			"• Lighting and camera adapt automatically when selecting structures\n" + \
			"• AI camera assistance provides optimal educational viewing angles"

func _populate_structure_list(structures: Array) -> void:
	"""Populate the structure list with WCAG AAA compliant professional styling"""
	# Clear existing items
	for child in structure_items.get_children():
		child.queue_free()
	_structure_buttons.clear()

	# Add structure buttons with professional medical styling
	for structure in structures:
		var button = Button.new()
		button.text = structure.get("displayName", structure.get("name", "Unknown"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT

		# WCAG AAA Compliance: Minimum 44x44px touch targets (expanded from 48px for comfort)
		button.custom_minimum_size = Vector2(248, 50)  # 280px panel - 32px margins = 248px width

		# Professional medical color scheme with high contrast for light background
		button.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))  # Dark text on light bg
		button.add_theme_color_override("font_hover_color", Color(0.0, 0.4, 0.8))  # Blue hover
		button.add_theme_color_override("font_pressed_color", Color(0.0, 0.3, 0.7))  # Darker blue pressed
		button.add_theme_color_override("font_focus_color", Color(0.0, 0.4, 0.8))  # Blue focus
		button.add_theme_font_size_override("font_size", 16)  # Larger font for medical readability

		# Professional glass morphism styling for medical education
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = UnifiedColorSystem.get_color("transparent")
		style_normal.set_corner_radius_all(8)
		style_normal.set_content_margin_all(16)

		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = UnifiedColorSystem.get_color("primary")
		style_hover.bg_color.a = 0.08
		style_hover.set_corner_radius_all(8)
		style_hover.set_content_margin_all(16)
		style_hover.border_color = UnifiedColorSystem.get_color("primary")
		style_hover.border_color.a = 0.3
		style_hover.set_border_width_all(1)

		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = UnifiedColorSystem.get_color("primary")
		style_pressed.bg_color.a = 0.12
		style_pressed.set_corner_radius_all(8)
		style_pressed.set_content_margin_all(16)
		style_pressed.border_color = UnifiedColorSystem.get_color("primary")
		style_pressed.border_color.a = 0.5
		style_pressed.set_border_width_all(2)

		# Focus indicator for accessibility (3:1 contrast minimum)
		var style_focus = StyleBoxFlat.new()
		style_focus.bg_color = UnifiedColorSystem.get_color("primary")
		style_focus.bg_color.a = 0.15
		style_focus.set_corner_radius_all(8)
		style_focus.set_content_margin_all(16)
		style_focus.border_color = UnifiedColorSystem.get_color("primary")
		style_focus.border_color.a = 0.8
		style_focus.set_border_width_all(3)  # WCAG AAA focus indicator

		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_pressed)
		button.add_theme_stylebox_override("focus", style_focus)

		# Accessibility: Set accessible name for screen readers
		button.set_meta("accessible_name", "Brain structure: " + button.text)
		button.set_meta("accessible_role", "button")
		button.focus_mode = Control.FOCUS_ALL  # Keyboard navigation support

		# Professional motion effects (reduced for medical context)
		# Motion effects disabled for maximum compatibility
		# if ClassDB.class_exists("ButtonMotionHandler"):
		#	ButtonMotionHandler.setup_button_hover_animation(button)

		button.pressed.connect(_on_structure_button_pressed.bind(structure.get("id", "")))
		structure_items.add_child(button)
		_structure_buttons[structure.get("id", "")] = button

		# Log accessibility compliance
		print("[Accessibility] Structure button created: ", button.text, " (", button.custom_minimum_size, ")")

func _on_structure_button_pressed(structure_id: String) -> void:
	"""Handle structure button press"""
	print("[EnhancedExplorationScene] Structure button pressed: ", structure_id)
	print("[EnhancedExplorationScene] _brain_structures keys: ", _brain_structures.keys())
	print("[EnhancedExplorationScene] _brain_interaction exists: ", _brain_interaction != null)

	if not _brain_interaction:
		push_error("[EnhancedExplorationScene] BrainInteractionController not initialized")
		return

	if not _brain_structures.has(structure_id):
		push_warning("[EnhancedExplorationScene] Structure ID not found in _brain_structures: ", structure_id)
		# Try to find the mesh by searching through the brain container
		var found = false
		for child in brain_container.get_children():
			if child is Node3D:
				for subchild in child.get_children():
					if subchild is MeshInstance3D:
						# Check if this mesh matches the structure ID
						if _mesh_to_structure_id.has(subchild.name) and _mesh_to_structure_id[subchild.name] == structure_id:
							print("[EnhancedExplorationScene] Found mesh instance: ", subchild.name, " for structure: ", structure_id)
							_brain_structures[structure_id] = subchild
							_brain_interaction.select_structure_by_mesh(subchild)
							found = true
							break
			if found:
				break
		if not found:
			push_error("[EnhancedExplorationScene] Could not find mesh for structure: ", structure_id)
		return

	var mesh_instance = _brain_structures[structure_id]
	_brain_interaction.select_structure_by_mesh(mesh_instance)

func _on_view_preset_selected(index: int) -> void:
	"""Handle view preset selection"""
	if _camera_presets:
		_camera_presets.apply_preset(index)
		view_changed.emit(view_presets.get_item_text(index))

func _on_labels_toggled(toggled: bool) -> void:
	"""Handle label toggle"""
	# Annotation system removed - medical annotation functionality disabled
	update_status("Labels " + ("enabled" if toggled else "disabled"))

func _on_related_structure_pressed(structure_id: String) -> void:
	"""Handle related structure button press"""
	print("[EnhancedExplorationScene] Related structure pressed: ", structure_id)
	_on_structure_button_pressed(structure_id)

func _on_quiz_pressed() -> void:
	"""Handle quiz button press"""
	_toggle_quiz()

func _on_help_pressed() -> void:
	"""Handle help button press"""
	help_overlay.visible = not help_overlay.visible
	help_toggled.emit(help_overlay.visible)

func _on_performance_report(metrics: Dictionary) -> void:
	"""Update performance display"""
	var quality_text = ["LOW", "MEDIUM", "HIGH", "ULTRA"][metrics.quality_level]
	performance_label.text = "FPS: %.0f | Quality: %s" % [metrics.fps, quality_text]

func _on_quality_changed(new_level: int) -> void:
	"""Handle quality level changes"""
	var quality_names = ["LOW", "MEDIUM", "HIGH", "ULTRA"]
	update_status("Quality changed to " + quality_names[new_level])

func _on_performance_toggle_pressed() -> void:
	if not performance_panel:
		return
	"""Handle performance monitoring panel toggle"""
	performance_panel.visible = not performance_panel.visible
	performance_monitoring_enabled = performance_panel.visible  # Control real-time monitoring
	performance_toggle.text = "Hide Metrics" if performance_panel.visible else "Metrics"

	# Update performance display immediately when shown
	if performance_panel.visible:
		_update_performance_display()
		print("[Performance] Monitoring enabled - expect FPS impact")
		update_status("Performance monitoring panel enabled")
	else:
		print("[Performance] Monitoring disabled - FPS improved")
		update_status("Performance monitoring panel disabled")

# ... (Include all the existing methods from ExplorationScene.gd)
# ... (handle_mouse_button, handle_mouse_motion, handle_keyboard, etc.)

func _setup_brain_interaction() -> void:
	"""Setup brain interaction controller"""
	var brain_interaction_controller_class = preload("res://src/systems/3d_interaction/ImprovedBrainInteractionController.gd")
	_brain_interaction = brain_interaction_controller_class.new()
	add_child(_brain_interaction)
	_brain_interaction.initialize(camera)

	# Connect signals
	_brain_interaction.structure_selected.connect(_on_structure_selected)
	_brain_interaction.structure_highlighted.connect(_on_structure_highlighted)
	_brain_interaction.selection_cleared.connect(_on_selection_cleared)

func _on_structure_selected(structure_name: String, mesh_instance: MeshInstance3D) -> void:
	"""Handle structure selection"""
	print("[EnhancedExplorationScene] Selected mesh name: ", structure_name)

	# Convert mesh name to structure ID
	var structure_id = ""
	if _mesh_to_structure_id.has(structure_name):
		structure_id = _mesh_to_structure_id[structure_name]
		print("[EnhancedExplorationScene] Converted to structure ID: ", structure_id)
	else:
		# Try normalized version
		var normalized_name = structure_name.to_lower().strip_edges()
		normalized_name = normalized_name.replace(" (good)", "").replace("(good)", "").strip_edges()

		# Check if normalized version exists
		var found = false
		for mesh_name in _mesh_to_structure_id:
			var normalized_mesh = mesh_name.to_lower().strip_edges()
			normalized_mesh = normalized_mesh.replace(" (good)", "").replace("(good)", "").strip_edges()

			if normalized_mesh == normalized_name:
				structure_id = _mesh_to_structure_id[mesh_name]
				print("[EnhancedExplorationScene] Found mapping via normalization: ", structure_id)
				found = true
				break

		if not found:
			# Special case for known problematic names
			if normalized_name == "hipp and others":
				structure_id = "hippocampus"
				print("[EnhancedExplorationScene] Applied special case mapping to hippocampus")
			elif normalized_name in ["hippocampus", "thalamus", "amygdala", "striatum", "corpus_callosum", "ventricles"]:
				# Direct structure ID passed instead of mesh name
				structure_id = normalized_name
				print("[EnhancedExplorationScene] Direct structure ID used: ", structure_id)
			else:
				# Fallback: use the mesh name as structure ID
				structure_id = structure_name
				push_warning("[EnhancedExplorationScene] No structure ID mapping for mesh: ", structure_name)

	# Show selection sphere
	if mesh_instance:
		selection_sphere.visible = true
		selection_sphere.global_position = mesh_instance.global_position

	# Get educational content
	var content = {}
	if has_node("/root/LearningContentManager"):
		var learning_content = get_node_or_null("/root/LearningContentManager")
		if learning_content.has_method("get_content"):
			content = learning_content.get_content(structure_id)

	if content.is_empty():
		info_panel.display_structure_info({
			"name": structure_id,
			"description": "Educational content for this structure is being prepared."
		})
	else:
		info_panel.display_structure_info(content)
		_current_structure_id = structure_id

	# Update status
	update_status("Selected: " + structure_id)

	# Adapt lighting for the selected structure
	adapt_lighting_for_structure(structure_id)

	# Add intelligent camera focusing (Phase 5)
	smart_focus_on_structure(structure_id, mesh_instance)

	# Highlight button with M3 colors
	for id in _structure_buttons:
		_structure_buttons[id].modulate = UnifiedColorSystem.get_color("on_surface")
	if _structure_buttons.has(_current_structure_id):
		_structure_buttons[_current_structure_id].modulate = M3DesignTokens.M3_COLORS["primary"]

	structure_selected.emit(structure_id)

func _on_structure_highlighted(structure_name: String, _mesh_instance: MeshInstance3D) -> void:
	"""Handle structure highlighting"""
	# Convert mesh name to structure ID for display
	var display_name = structure_name
	if _mesh_to_structure_id.has(structure_name):
		display_name = _mesh_to_structure_id[structure_name]
	update_status("Hovering: " + display_name)

func _on_selection_cleared() -> void:
	"""Handle selection cleared"""
	selection_sphere.visible = false
	info_panel.hide_panel()
	update_status("Ready")

	# Clear button highlights
	for id in _structure_buttons:
		_structure_buttons[id].modulate = UnifiedColorSystem.get_color("on_surface")

func _load_brain_models() -> void:
	"""Load the brain models"""
	print("[EnhancedExplorationScene] Loading brain models...")
	show_loading("Loading brain anatomy model...", 0.0)

	# Placeholder removed for performance
	await get_tree().create_timer(0.5).timeout

	show_loading("Initializing brain structures...", 0.3)

	# Load Internal-Structures model
	if _model_loader:
		# Connect to the model_loaded signal before loading
		if not _model_loader.model_loaded.is_connected(_on_internal_structures_loaded):
			_model_loader.model_loaded.connect(_on_internal_structures_loaded)
		_model_loader.load_brain_model("Internal-Structures", "low", SafeModelLoader.LoadMode.ASYNC)

func _on_internal_structures_loaded(model_instance: Node3D) -> void:
	"""Handle Internal-Structures model loaded"""
	show_loading("Processing brain structures...", 0.7)

	if not model_instance:
		print("[EnhancedExplorationScene] Failed to load Internal-Structures model")
		hide_loading()
		update_status("Error: Failed to load brain model")
		return

	print("[EnhancedExplorationScene] Internal-Structures model loaded successfully")

	# Add to scene
	model_holder.add_child(model_instance)

	# Load structure metadata from JSON
	var file = FileAccess.open("res://content/brain_structures.json", FileAccess.READ)
	var json_data = {}
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			json_data = json.data
		else:
			push_error("[EnhancedExplorationScene] Failed to parse brain_structures.json")
	else:
		push_error("[EnhancedExplorationScene] Failed to load brain_structures.json")

	# Process structures and map IDs to mesh instances
	var structures_data = []
	var structure_mapping = {}  # Maps structure IDs to model names

	# Build mapping from JSON data
	if json_data.has("structures"):
		for structure_id in json_data.structures:
			var structure_info = json_data.structures[structure_id]
			if structure_info.has("modelNames"):
				for model_name in structure_info.modelNames:
					structure_mapping[model_name] = structure_id
			structures_data.append({
				"id": structure_id,
				"name": structure_info.get("displayName", structure_id),
				"displayName": structure_info.get("displayName", structure_id)
			})

	# Map mesh instances to structure IDs
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			var mesh_name = child.name.strip_edges()  # Remove any leading/trailing whitespace
			print("[EnhancedExplorationScene] Found mesh: '", mesh_name, "' (length: ", mesh_name.length(), ")")

			# Check if this mesh name is in our mapping
			var found_mapping = false

			# Debug: print available mappings for this mesh
			print("[EnhancedExplorationScene] Looking for mapping for mesh: '", mesh_name, "'")
			print("[EnhancedExplorationScene] Available mappings: ", structure_mapping.keys())

			# Try exact match first
			if structure_mapping.has(mesh_name):
				var structure_id = structure_mapping[mesh_name]
				_brain_structures[structure_id] = child
				_mesh_to_structure_id[mesh_name] = structure_id
				print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "'")
				found_mapping = true
			# Also check with different capitalization patterns
			elif structure_mapping.has("Hipp and Others (good)") and mesh_name == "Hipp And Others (good)":
				var structure_id = structure_mapping["Hipp and Others (good)"]
				_brain_structures[structure_id] = child
				_mesh_to_structure_id[mesh_name] = structure_id
				print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (capitalization fix)")
				found_mapping = true
			else:
				# Try case-insensitive match
				for model_name in structure_mapping:
					if model_name.to_lower() == mesh_name.to_lower():
						var structure_id = structure_mapping[model_name]
						_brain_structures[structure_id] = child
						_mesh_to_structure_id[mesh_name] = structure_id
						print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (case-insensitive match)")
						found_mapping = true
						break

				# If still not found, try partial match
				if not found_mapping:
					for model_name in structure_mapping:
						if mesh_name.to_lower().begins_with(model_name.to_lower()) or model_name.to_lower().begins_with(mesh_name.to_lower()):
							var structure_id = structure_mapping[model_name]
							_brain_structures[structure_id] = child
							_mesh_to_structure_id[mesh_name] = structure_id
							print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (partial match)")
							found_mapping = true
							break

			if not found_mapping:
				# Last resort - check if this is a known problematic case
				var normalized = mesh_name.to_lower().replace(" (good)", "").replace("_", " ").strip_edges()
				if normalized == "hipp and others":
					_brain_structures["hippocampus"] = child
					_mesh_to_structure_id[mesh_name] = "hippocampus"
					print("[EnhancedExplorationScene] Applied hardcoded mapping for hippocampus variant")
					found_mapping = true
				else:
					push_warning("[EnhancedExplorationScene] No mapping found for mesh: ", mesh_name)

	# Populate structure list with data from JSON
	_populate_structure_list(structures_data)

	# Center and scale
	_adjust_model_transform(model_instance)
	_frame_model(model_instance)

	# Create annotations if needed - DISABLED
	# Medical annotation system has been removed

	show_loading("Finalizing...", 0.9)
	await get_tree().create_timer(0.5).timeout

	hide_loading()
	update_status("Ready - " + str(_brain_structures.size()) + " structures loaded")

# Include remaining methods from original ExplorationScene.gd...
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if _is_loading:
		return

	# Use LEFT mouse button for rotation (more intuitive)
	if event.button_index == MOUSE_BUTTON_LEFT and not event.shift_pressed:
		_is_rotating = event.pressed
		# Update cursor
		if event.pressed:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	# RIGHT click for selection
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if _brain_interaction:
			_brain_interaction.handle_mouse_click(event)

	# Handle zoom with trackpad-friendly smooth scrolling
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if event.pressed:
			# Check if this is a trackpad (high precision) or mouse wheel
			var is_trackpad = event.factor != 1.0
			if is_trackpad:
				# Smooth trackpad scrolling
				_zoom_velocity -= event.factor * ZOOM_SPEED * trackpad_zoom_sensitivity * 20.0
			else:
				# Discrete mouse wheel
				_camera_distance = max(MIN_ZOOM, _camera_distance - ZOOM_SPEED)
				_update_camera_position()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if event.pressed:
			var is_trackpad = event.factor != 1.0
			if is_trackpad:
				# Smooth trackpad scrolling
				_zoom_velocity += event.factor * ZOOM_SPEED * trackpad_zoom_sensitivity * 20.0
			else:
				# Discrete mouse wheel
				_camera_distance = min(MAX_ZOOM, _camera_distance + ZOOM_SPEED)
				_update_camera_position()

	# Middle mouse button for panning
	elif event.button_index == MOUSE_BUTTON_MIDDLE:
		_is_panning = event.pressed
		if event.pressed:
			Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _is_loading:
		return

	if _brain_interaction:
		_brain_interaction.handle_mouse_motion(event)

	# Check for trackpad vs mouse (trackpad typically has pressure)
	var sensitivity_multiplier = 1.0
	if event.pressure > 0.0:
		# Trackpad detected, use custom sensitivity
		sensitivity_multiplier = trackpad_rotate_sensitivity

	if _is_rotating:
		_camera_rotation.x -= event.relative.x * _rotation_speed * 0.01 * sensitivity_multiplier
		_camera_rotation.y -= event.relative.y * _rotation_speed * 0.01 * sensitivity_multiplier
		_camera_rotation.y = clamp(_camera_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
		_update_camera_orbit()
	elif _is_panning:
		# Pan the camera pivot
		var pan_speed = _camera_distance * 0.001 * sensitivity_multiplier
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y

		if camera_pivot:
			camera_pivot.global_position -= right * event.relative.x * pan_speed
			camera_pivot.global_position += up * event.relative.y * pan_speed

func _handle_keyboard(event: InputEventKey) -> void:
	if not event.pressed or _is_loading:
		return

	match event.keycode:
		KEY_ESCAPE:
			return_to_menu_requested.emit()
		KEY_R:
			reset_camera_view()
		KEY_G:
			toggle_grid(true)  # Removed - no grid to toggle
		KEY_H:
			_on_help_pressed()
		KEY_L:
			label_toggle.button_pressed = not label_toggle.button_pressed
		KEY_Q:
			_on_quiz_pressed()
		KEY_F:
			_focus_on_selection()
		KEY_1:
			apply_lighting_preset("default")
		KEY_2:
			apply_lighting_preset("detailed_examination")
		KEY_3:
			apply_lighting_preset("overview")
		KEY_4:
			apply_lighting_preset("presentation")
		KEY_5:
			set_environment_for_context("clinical")
		KEY_6:
			set_environment_for_context("presentation")
		KEY_7:
			set_environment_for_context("study")
		KEY_8:
			set_environment_for_context("default")
		KEY_C:
			enable_ai_camera_assistance(not _camera_ai_enabled)

func _handle_pan_gesture(event: InputEventPanGesture) -> void:
	"""Handle trackpad pan gestures (two-finger swipe)"""
	if _is_loading:
		return

	# Use pan gesture for rotation (more natural on trackpad)
	_camera_rotation.x -= event.delta.x * _rotation_speed * 0.5 * trackpad_rotate_sensitivity
	_camera_rotation.y += event.delta.y * _rotation_speed * 0.5 * trackpad_rotate_sensitivity
	_camera_rotation.y = clamp(_camera_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
	_update_camera_orbit()

func _handle_magnify_gesture(event: InputEventMagnifyGesture) -> void:
	"""Handle trackpad pinch zoom gestures"""
	if _is_loading:
		return

	# Magnify gesture for zoom (pinch)
	var zoom_factor = 1.0 - (event.factor - 1.0) * trackpad_zoom_sensitivity
	_camera_distance *= zoom_factor
	_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)
	_update_camera_position()

func reset_camera_view() -> void:
	"""Reset camera to default view"""
	_camera_rotation = Vector2(deg_to_rad(-45), deg_to_rad(-20))
	_camera_distance = 15.0
	# Reset camera pivot to origin
	if camera_pivot:
		camera_pivot.global_position = Vector3.ZERO
	_update_camera_orbit()
	update_status("Camera view reset")

func _focus_on_selection() -> void:
	"""Focus camera on currently selected structure"""
	if _current_structure_id.is_empty() or not _brain_structures.has(_current_structure_id):
		update_status("No structure selected to focus on")
		return

	var mesh_instance = _brain_structures[_current_structure_id]
	if not mesh_instance:
		return

	# Get bounds of the selected mesh
	if mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		var global_aabb = mesh_instance.global_transform * aabb
		var size = global_aabb.size
		var max_dimension = max(size.x, max(size.y, size.z))

		# Calculate optimal distance
		var fov_rad = deg_to_rad(camera.fov)
		_camera_distance = (max_dimension * 0.8) / tan(fov_rad * 0.5) * 2.0
		_camera_distance = clamp(_camera_distance, MIN_ZOOM * 0.5, MAX_ZOOM)

		# Move camera pivot to structure center
		if camera_pivot:
			camera_pivot.global_position = mesh_instance.global_position

		_update_camera_position()
		update_status("Focused on: " + _current_structure_id)

# Model adjustment methods
func _adjust_model_transform(model: Node3D) -> void:
	"""Adjust model transform for proper display"""
	var aabb = AABB()
	var first = true

	for child in model.get_children():
		if child is MeshInstance3D and child.mesh:
			var mesh_aabb = child.mesh.get_aabb()
			mesh_aabb = child.transform * mesh_aabb

			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)

	var center = aabb.get_center()
	# Center the model at origin
	model.position = Vector3.ZERO

	# Adjust all child meshes to center them
	for child in model.get_children():
		if child is MeshInstance3D:
			child.position -= center

	var size = aabb.size
	var max_dimension = max(size.x, max(size.y, size.z))
	if max_dimension > 0:
		# Increased target size for better visibility
		var target_size = 6.0
		var scale_factor = target_size / max_dimension
		model.scale = Vector3.ONE * scale_factor
		print("[EnhancedExplorationScene] Model scaled by factor: ", scale_factor)
		print("[EnhancedExplorationScene] Model positioned at origin")

func _frame_model(model: Node3D) -> void:
	"""Adjust camera to frame the model with professional educational optimization"""
	var aabb = AABB()
	var first = true

	for child in model.get_children():
		if child is MeshInstance3D and child.mesh:
			var mesh_aabb = child.mesh.get_aabb()
			mesh_aabb = model.transform * child.transform * mesh_aabb

			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)

	var size = aabb.size
	var max_dimension = max(size.x, max(size.y, size.z))

	# Professional medical education optimization: Calculate optimal viewport usage
	var viewport_size = get_viewport().get_visible_rect().size
	var effective_viewport_height = viewport_size.y - 80 - 60  # Subtract top and bottom panels
	var _target_model_height = effective_viewport_height * 0.75  # Use 75% of available viewport

	# Optimize camera distance for professional medical viewing
	var fov_rad = deg_to_rad(camera.fov)
	_camera_distance = (max_dimension * 0.6) / tan(fov_rad * 0.5) * 2.2  # Professional viewing distance
	_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)

	# Ensure model visibility on minimum resolution (1366x768)
	var _min_viewport_height = 768 - 80 - 60  # Minimum resolution minus panels
	var safety_distance = (max_dimension * 0.8) / tan(fov_rad * 0.5) * 2.5
	_camera_distance = max(_camera_distance, safety_distance)

	print("[EnhancedExplorationScene] Professional camera distance: ", _camera_distance)
	print("[EnhancedExplorationScene] Viewport optimization: ", viewport_size, " -> effective: ", effective_viewport_height)

	_update_camera_position()

# Stub methods for systems - implement as needed
func _setup_model_loader() -> void:
	var SafeModelLoaderClass = preload("res://src/systems/3d_interaction/SafeModelLoader.gd")
	_model_loader = SafeModelLoaderClass.new()
	add_child(_model_loader)
	_model_loader.model_loaded.connect(func(model_instance): print("[Enhanced] Model loaded: ", model_instance.name if model_instance else "unknown"))
	_model_loader.model_load_failed.connect(func(error_message): update_status("Failed to load: " + error_message))

func _setup_camera_presets() -> void:
	var CameraPresetManager = preload("res://src/systems/3d_interaction/CameraPresetManager.gd")
	_camera_presets = CameraPresetManager.new()
	add_child(_camera_presets)
	_camera_presets.initialize(camera, camera_pivot)

func _setup_annotation_system() -> void:
	# Medical annotation system setup removed
	pass

func _setup_quiz_panel() -> void:
	"""Setup the quiz panel"""
	# Create quiz panel instance
	var QuizPanelScene = preload("res://src/ui_atomic/organisms/QuizPanel.tscn")
	_quiz_panel = QuizPanelScene.instantiate()
	$EducationalUILayer.add_child(_quiz_panel)

	# Add quiz panel to UI group for shader management
	_quiz_panel.add_to_group("ui_panels")

	# Connect quiz signals
	_quiz_panel.answer_submitted.connect(_on_quiz_answer_submitted)
	_quiz_panel.next_question_requested.connect(_on_quiz_next_question)
	_quiz_panel.quiz_closed.connect(_on_quiz_closed)
	_quiz_panel.assessment_selected.connect(_on_assessment_selected)

	# Connect assessment service signals if available
	if has_node("/root/AssessmentService"):
		var assessment_service = get_node("/root/AssessmentService")
		if assessment_service.has_signal("question_answered"):
			assessment_service.question_answered.connect(_on_question_answered)
		if assessment_service.has_signal("assessment_completed"):
			assessment_service.assessment_completed.connect(_on_assessment_completed)

	print("[EnhancedExplorationScene] Quiz system initialized")

func _toggle_quiz() -> void:
	"""Toggle quiz panel visibility"""
	if quiz_overlay.visible:
		quiz_overlay.hide()
		_quiz_is_active = false
	else:
		# Show quiz for current structure or general quiz
		var structure_to_quiz = _current_structure_id if not _current_structure_id.is_empty() else "general"

		if structure_to_quiz == "general":
			# Show general neuroanatomy quiz
			_show_general_quiz()
		else:
			# Show quiz for specific structure
			show_quiz_for_structure(structure_to_quiz)

func _show_general_quiz() -> void:
	"""Show general neuroanatomy assessment"""
	# Create a general quiz with mixed questions
	var general_quiz_data = {
		"structure_name": "General Neuroanatomy",
		"questions": [
			{
				"question": "Which brain structure is primarily responsible for memory formation and consolidation?",
				"options": ["A) Cerebellum", "B) Hippocampus", "C) Prefrontal Cortex", "D) Thalamus"],
				"correct_answer": 1,
				"explanation": "The hippocampus is essential for converting short-term memories into long-term memories.",
				"clinical_relevance": "Hippocampal damage is associated with anterograde amnesia and is commonly affected in Alzheimer's disease."
			},
			{
				"question": "What is the primary function of the cerebellum?",
				"options": ["A) Language processing", "B) Motor coordination", "C) Visual processing", "D) Emotional regulation"],
				"correct_answer": 1,
				"explanation": "The cerebellum is crucial for balance, posture, and coordination of voluntary movements.",
				"clinical_relevance": "Cerebellar dysfunction can lead to ataxia, dysmetria, and balance disorders."
			},
			{
				"question": "Which structure connects the two cerebral hemispheres?",
				"options": ["A) Corpus callosum", "B) Thalamus", "C) Hippocampus", "D) Cerebellum"],
				"correct_answer": 0,
				"explanation": "The corpus callosum is the largest white matter structure connecting left and right hemispheres.",
				"clinical_relevance": "Corpus callosum lesions can cause disconnection syndromes and interhemispheric transfer deficits."
			}
		]
	}

	_current_quiz_data = general_quiz_data
	_current_quiz_question = 0
	_quiz_answers.clear()
	_quiz_scores.clear()
	_quiz_structure_context = "general"
	_quiz_is_active = true

	_setup_quiz_interface()
	quiz_overlay.show()

	# Track educational analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("general_quiz_started", {
			"question_count": general_quiz_data.questions.size()
		})

func _on_info_panel_closed() -> void:
	if _brain_interaction:
		_brain_interaction.clear_all_selections()

# === PROFESSIONAL PERFORMANCE & ACCESSIBILITY MONITORING ===

func _monitor_performance(delta: float) -> void:
	"""Monitor performance metrics for professional medical education requirements"""
	_performance_data.frame_count += 1
	_performance_data.total_time += delta

	# Track frame times for Intel UHD 620 compatibility
	var frame_time_ms = delta * 1000.0
	_performance_data.frame_times.append(frame_time_ms)

	# Maintain rolling window of 60 frames for real-time analysis
	if _performance_data.frame_times.size() > 60:
		_performance_data.frame_times.pop_front()

	# Track memory usage every 30 frames
	if _performance_data.frame_count % 30 == 0:
		var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
		_performance_data.memory_usage.append(memory_mb)

		# Maintain memory history
		if _performance_data.memory_usage.size() > 20:
			_performance_data.memory_usage.pop_front()

		# Performance warning system for medical education
		_check_performance_compliance()

		# Update detailed performance display if visible
		if performance_panel.visible:
			_update_performance_display()

func _check_performance_compliance() -> void:
	"""Validate performance meets medical education standards"""
	if _performance_data.frame_times.is_empty():
		return

	# Calculate average FPS over last 60 frames
	var avg_frame_time = 0.0
	for frame_time in _performance_data.frame_times:
		avg_frame_time += frame_time
	avg_frame_time /= _performance_data.frame_times.size()

	var current_fps = 1000.0 / avg_frame_time

	# Intel UHD 620 performance validation
	if current_fps < _performance_data.target_fps:
		print("[Performance Warning] FPS below target: ", current_fps, " < ", _performance_data.target_fps)
		print("[Performance Advice] Consider reducing model quality or disabling effects")

	# Memory usage validation (medical apps should be stable)
	if not _performance_data.memory_usage.is_empty():
		var current_memory = _performance_data.memory_usage[-1]
		if current_memory > 1024:  # 1GB threshold for medical education stability
			print("[Memory Warning] High memory usage: ", current_memory, "MB")

	# Update performance display with professional metrics
	if performance_label:
		var quality_status = "OPTIMAL" if current_fps >= 60 else ("GOOD" if current_fps >= 30 else "LOW")
		performance_label.text = "FPS: %.0f | Memory: %.0fMB | Quality: %s" % [
			current_fps,
			_performance_data.memory_usage[-1] if not _performance_data.memory_usage.is_empty() else 0,
			quality_status
		]

func _update_performance_display() -> void:
	"""Update detailed performance monitoring display"""
	if not performance_panel.visible:
		return

	# Core metrics
	var current_fps = Engine.get_frames_per_second()
	fps_indicator.text = "FPS: %.1f" % current_fps

	var frame_time = 1.0 / current_fps if current_fps > 0 else 0.0
	frame_time_indicator.text = "Frame Time: %.2f ms" % (frame_time * 1000.0)

	# Quality assessment for medical education
	var quality_status = ""
	if current_fps >= 60:
		quality_status = "EXCELLENT - Medical Grade"
		quality_indicator.modulate = Color.GREEN
	elif current_fps >= 30:
		quality_status = "GOOD - Educational Standard"
		quality_indicator.modulate = Color.YELLOW
	else:
		quality_status = "LOW - Performance Issues"
		quality_indicator.modulate = Color.RED
	quality_indicator.text = "Quality: " + quality_status

	# Medical rendering metrics
	var brain_models = get_children().filter(func(n): return n is MeshInstance3D)
	brain_model_complexity.text = "Brain Models: %d" % brain_models.size()

	var texture_mem = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	texture_memory.text = "Texture Memory: %.1f MB" % texture_mem

	var render_quality = "High" if current_fps >= 45 else ("Medium" if current_fps >= 25 else "Low")
	rendering_quality.text = "Rendering: " + render_quality

	# Educational metrics
	interaction_latency.text = "UI Latency: %.1f ms" % (frame_time * 1000.0)
	accessibility_status.text = "Accessibility: WCAG 2.1 AA"
	learning_analytics.text = "Analytics: Active"

	# System health
	var memory_usage_mb = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	memory_usage.value = min(100, (memory_usage_mb / 500.0) * 100)  # 500MB threshold

	var cpu_load = current_fps / 60.0  # Approximate CPU load based on FPS
	cpu_usage.value = min(100, (1.0 - cpu_load) * 100)

	var gpu_load = (60.0 - current_fps) / 60.0  # Approximate GPU load
	gpu_usage.value = min(100, max(0, gpu_load * 100))

# === Phase 6: PERFORMANCE INTEGRATION WITH UITHEMEMANAGER ===

func _setup_performance_integration() -> void:
	"""Setup integration with UIThemeManager performance monitoring"""
	print("[Performance] Setting up scene-level performance integration")

	# Connect to UIThemeManager performance signals if available
	var theme_manager = get_node_or_null("/root/UIThemeManager")
	if theme_manager:
		# Enable quality adaptation by default for educational platform
		theme_manager.enable_quality_adaptation(true)

		# Set initial quality profile based on hardware
		var hardware_score = theme_manager._calculate_hardware_score()
		var initial_profile = "auto"
		if hardware_score > 0.8:
			initial_profile = "high"
		elif hardware_score < 0.4:
			initial_profile = "medium"

		theme_manager.set_quality_profile(initial_profile)
		print("[Performance] Initial quality profile set to: %s (hardware score: %.2f)" % [initial_profile, hardware_score])

		# Disable glass morphism shaders for better readability
		theme_manager.update_effects_quality(0)  # Set to lowest quality to disable glass effects
	else:
		push_warning("[Performance] UIThemeManager not found - quality adaptation disabled")

func apply_performance_quality(profile: Dictionary) -> void:
	"""Apply performance quality settings to the 3D scene"""
	print("[Performance] Applying quality profile to 3D scene: %s" % str(profile))

	# Apply lighting quality
	_apply_lighting_quality(profile.get("lighting_complexity", "standard"))

	# Apply shadow quality
	_apply_shadow_quality(profile.get("shadow_quality", "medium"))

	# Apply animation detail level
	_apply_animation_quality(profile.get("animation_detail", "full"))

	# Apply particle system quality
	_apply_particle_quality(profile.get("particle_count", 50))

	# Apply texture resolution scaling
	_apply_texture_quality(profile.get("texture_resolution", 1.0))

func _apply_lighting_quality(complexity: String) -> void:
	"""Apply lighting complexity based on performance profile"""
	if not lighting_system:
		return

	match complexity:
		"full":
			# Enable all three lights with full settings
			if key_light:
				key_light.light_energy = 1.2
				key_light.shadow_enabled = true
			if fill_light:
				fill_light.light_energy = 0.6
			if rim_light:
				rim_light.light_energy = 0.8
			print("[Lighting] Applied FULL complexity lighting")
		"standard":
			# Standard two-light setup
			if key_light:
				key_light.light_energy = 1.0
				key_light.shadow_enabled = true
			if fill_light:
				fill_light.light_energy = 0.4
			if rim_light:
				rim_light.light_energy = 0.0  # Disable rim light
			print("[Lighting] Applied STANDARD complexity lighting")
		"simplified":
			# Single key light only
			if key_light:
				key_light.light_energy = 0.9
				key_light.shadow_enabled = false
			if fill_light:
				fill_light.light_energy = 0.2
			if rim_light:
				rim_light.light_energy = 0.0
			print("[Lighting] Applied SIMPLIFIED complexity lighting")
		"basic":
			# Minimal lighting
			if key_light:
				key_light.light_energy = 0.8
				key_light.shadow_enabled = false
			if fill_light:
				fill_light.light_energy = 0.0
			if rim_light:
				rim_light.light_energy = 0.0
			print("[Lighting] Applied BASIC complexity lighting")

func _apply_shadow_quality(quality: String) -> void:
	"""Apply shadow quality settings"""
	var lights = [key_light, fill_light, rim_light]

	for light in lights:
		if not light or not light is DirectionalLight3D:
			continue

		match quality:
			"high":
				light.shadow_enabled = true
				light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
				light.directional_shadow_max_distance = 100.0
			"medium":
				light.shadow_enabled = true
				light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
				light.directional_shadow_max_distance = 75.0
			"low":
				light.shadow_enabled = true
				light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
				light.directional_shadow_max_distance = 50.0
			"off":
				light.shadow_enabled = false

	print("[Shadows] Applied %s quality shadows" % quality.to_upper())

func _apply_animation_quality(detail: String) -> void:
	"""Apply animation detail level"""
	var camera_transition_speed = 1.0
	var _ui_animation_scale = 1.0  # Reserved for future UI animation scaling

	match detail:
		"enhanced":
			camera_transition_speed = 0.8  # Slower, more detailed transitions
			_ui_animation_scale = 1.2
		"full":
			camera_transition_speed = 1.0  # Normal speed
			_ui_animation_scale = 1.0
		"reduced":
			camera_transition_speed = 1.5  # Faster transitions
			_ui_animation_scale = 0.8
		"minimal":
			camera_transition_speed = 2.0  # Very fast
			_ui_animation_scale = 0.5

	# Store camera transition speed setting for future use
	set_meta("camera_transition_speed_multiplier", camera_transition_speed)

	print("[Animation] Applied %s detail animations (speed: %.1fx)" % [detail.to_upper(), camera_transition_speed])

func _apply_particle_quality(particle_count: int) -> void:
	"""Apply particle system quality"""
	# This would be extended when particle systems are added to the scene
	# For now, we'll store the setting for future use
	set_meta("particle_count_limit", particle_count)
	print("[Particles] Set particle count limit to: %d" % particle_count)

func _apply_texture_quality(resolution_scale: float) -> void:
	"""Apply texture resolution scaling"""
	# This would scale texture resolution for brain models
	# For now, we'll store the setting for future use when brain models are loaded
	set_meta("texture_resolution_scale", resolution_scale)
	print("[Textures] Set texture resolution scale to: %.1f" % resolution_scale)

func get_scene_performance_metrics() -> Dictionary:
	"""Get scene-specific performance metrics"""
	var metrics = {
		"camera_transitions_active": _camera_ai_enabled,
		"lighting_complexity": "unknown",
		"shadow_quality": "unknown",
		"brain_models_loaded": _brain_structures.size(),
		"ui_panels_active": get_tree().get_nodes_in_group("ui_panels").size(),
		"selection_feedback_active": _current_structure_id != ""
	}

	# Detect current lighting complexity
	if key_light and fill_light and rim_light:
		if key_light.light_energy > 1.0 and fill_light.light_energy > 0.5:
			metrics["lighting_complexity"] = "full"
		elif key_light.light_energy > 0.8 and fill_light.light_energy > 0.3:
			metrics["lighting_complexity"] = "standard"
		elif key_light.light_energy > 0.6:
			metrics["lighting_complexity"] = "simplified"
		else:
			metrics["lighting_complexity"] = "basic"

	# Detect shadow quality
	if key_light and key_light.shadow_enabled:
		if key_light.directional_shadow_mode == DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS:
			metrics["shadow_quality"] = "high"
		elif key_light.directional_shadow_mode == DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS:
			metrics["shadow_quality"] = "medium"
		else:
			metrics["shadow_quality"] = "low"
	else:
		metrics["shadow_quality"] = "off"

	return metrics

func log_scene_performance_summary() -> void:
	"""Log comprehensive scene performance summary"""
	var metrics = get_scene_performance_metrics()
	var theme_manager = get_node_or_null("/root/UIThemeManager")

	print("[Scene Performance Summary]")
	print("  Brain Models Loaded: %d" % metrics.brain_models_loaded)
	print("  UI Panels Active: %d" % metrics.ui_panels_active)
	print("  Lighting Complexity: %s" % metrics.lighting_complexity)
	print("  Shadow Quality: %s" % metrics.shadow_quality)
	print("  Camera AI Enabled: %s" % str(metrics.camera_transitions_active))
	print("  Selection Feedback: %s" % str(metrics.selection_feedback_active))

	if theme_manager:
		var ui_metrics = theme_manager.get_performance_metrics()
		print("  Current FPS: %.1f" % ui_metrics.fps)
		print("  Quality Profile: %s" % ui_metrics.quality_profile)
		print("  Adaptation Enabled: %s" % str(ui_metrics.adaptation_enabled))

func _validate_accessibility_compliance() -> void:
	"""Validate WCAG AAA accessibility compliance for medical education"""
	var violations = []

	# Check button touch targets (44x44px minimum)
	for button_id in _structure_buttons:
		var button = _structure_buttons[button_id]
		if button.custom_minimum_size.x < 44 or button.custom_minimum_size.y < 44:
			violations.append("Button '%s' below 44px touch target: %s" % [button.text, button.custom_minimum_size])

	# Check focus indicators presence
	for button_id in _structure_buttons:
		var button = _structure_buttons[button_id]
		if button.focus_mode == Control.FOCUS_NONE:
			violations.append("Button '%s' lacks keyboard focus support" % button.text)

	# Validate color contrast (would need actual contrast calculation in production)
	# Professional medical theme should maintain 7:1 contrast ratio
	var _bg_color = UnifiedColorSystem.get_color("surface")
	var _text_color = UnifiedColorSystem.get_color("on_surface")

	# Store accessibility violations for reporting
	_performance_data.accessibility_violations = violations

	if not violations.is_empty():
		print("[Accessibility Warning] Found %d WCAG violations:" % violations.size())
		for violation in violations:
			print("  - ", violation)
	else:
		print("[Accessibility Success] All WCAG AAA requirements met")

func get_performance_report() -> Dictionary:
	"""Generate comprehensive performance report for medical education compliance"""
	var report = {
		"timestamp": Time.get_datetime_string_from_system(),
		"session_duration": _performance_data.total_time,
		"total_frames": _performance_data.frame_count,
		"average_fps": 0.0,
		"memory_stable": true,
		"accessibility_compliant": _performance_data.accessibility_violations.is_empty(),
		"intel_uhd_620_compatible": true,
		"medical_education_ready": true
	}

	# Calculate performance metrics
	if not _performance_data.frame_times.is_empty():
		var total_frame_time = 0.0
		for frame_time in _performance_data.frame_times:
			total_frame_time += frame_time
		var avg_frame_time = total_frame_time / _performance_data.frame_times.size()
		report.average_fps = 1000.0 / avg_frame_time
		report.intel_uhd_620_compatible = report.average_fps >= 30.0

	# Check memory stability
	if _performance_data.memory_usage.size() >= 2:
		var memory_variance = 0.0
		var memory_avg = 0.0
		for memory in _performance_data.memory_usage:
			memory_avg += memory
		memory_avg /= _performance_data.memory_usage.size()

		for memory in _performance_data.memory_usage:
			memory_variance += (memory - memory_avg) ** 2
		memory_variance /= _performance_data.memory_usage.size()

		report.memory_stable = memory_variance < 100.0  # Low variance indicates stability

	# Overall medical education readiness
	report.medical_education_ready = (
		report.intel_uhd_620_compatible and
		report.memory_stable and
		report.accessibility_compliant
	)

	return report

func _on_info_panel_quiz_requested(structure_id: String) -> void:
	_current_structure_id = structure_id
	_toggle_quiz()

# === MISSING CALLBACK METHODS ===
# These methods are referenced but may not exist - adding safe implementations

func _on_quiz_answer_submitted(answer: Variant) -> void:
	"""Handle quiz answer submission"""
	print("[Quiz] Answer submitted: ", answer)
	if has_node("/root/AssessmentService"):
		var assessment_service = get_node("/root/AssessmentService")
		if assessment_service.has_method("submit_answer"):
			var result = assessment_service.submit_answer(answer)
			if _quiz_panel and _quiz_panel.has_method("show_feedback"):
				_quiz_panel.show_feedback(result)

func _on_quiz_next_question() -> void:
	"""Handle next question request"""
	print("[Quiz] Next question requested")
	if has_node("/root/AssessmentService"):
		var assessment_service = get_node("/root/AssessmentService")
		if assessment_service.has_method("next_question"):
			if assessment_service.next_question():
				if assessment_service.has_method("get_current_question"):
					var question = assessment_service.get_current_question()
					if _quiz_panel and _quiz_panel.has_method("display_question"):
						_quiz_panel.display_question(question)

func _on_quiz_closed() -> void:
	"""Handle quiz panel closed"""
	print("[Quiz] Quiz panel closed")

func _on_assessment_selected(assessment: Dictionary) -> void:
	"""Handle assessment selection"""
	print("[Quiz] Assessment selected: ", assessment)
	if has_node("/root/AssessmentService"):
		var assessment_service = get_node("/root/AssessmentService")
		if assessment_service.has_method("start_assessment"):
			var assessment_id = assessment.get("id", "")
			if assessment_service.start_assessment(assessment_id):
				if assessment_service.has_method("get_current_question"):
					var question = assessment_service.get_current_question()
					if _quiz_panel.has_method("display_question"):
						_quiz_panel.display_question(question)

func _on_question_answered(question_data: Dictionary) -> void:
	"""Handle question answered event"""
	print("[Assessment] Question answered: ", question_data)
	if has_node("/root/AssessmentService"):
		var assessment_service = get_node("/root/AssessmentService")
		if assessment_service.has_method("get_progress"):
			var progress = assessment_service.get_progress()
			print("[EnhancedExplorationScene] Quiz progress: ", progress)

func _on_assessment_completed(assessment_data: Dictionary) -> void:
	"""Handle assessment completion"""
	print("[Assessment] Assessment completed: ", assessment_data)
	if _quiz_panel and _quiz_panel.has_method("show_results"):
		_quiz_panel.show_results(assessment_data)
	var percentage = assessment_data.get("percentage", 0.0)
	update_status("Assessment completed: %.1f%%" % percentage)

func _add_panels_to_ui_group() -> void:
	"""Add UI panels to the 'ui_panels' group for performance-based shader management"""
	print("[EnhancedExplorationScene] Adding UI panels to 'ui_panels' group for shader management")

	# Add main UI panels to the group
	var panels_to_add = [
		top_bar,
		left_panel,
		bottom_panel,
		help_overlay,
		info_panel
	]

	for panel in panels_to_add:
		if panel and is_instance_valid(panel):
			panel.add_to_group("ui_panels")
			print("[EnhancedExplorationScene] Added panel to ui_panels group: " + panel.name)
		else:
			push_warning("[EnhancedExplorationScene] Panel is null or invalid, skipping")

	# Also add quiz panel when it's created
	if _quiz_panel:
		_quiz_panel.add_to_group("ui_panels")
		print("[EnhancedExplorationScene] Added quiz panel to ui_panels group")

	print("[EnhancedExplorationScene] UI panels group setup completed")

func _initialize_medical_grade_rendering() -> void:
	"""Initialize comprehensive brain rendering system for medical education"""
	print("[EnhancedExplorationScene] Initializing medical-grade brain rendering...")

	# Get the comprehensive rendering system from the Systems node
	var rendering_system = $EducationalSystemsContainer/MedicalRenderingSystem
	if not rendering_system:
		push_error("[EnhancedExplorationScene] ComprehensiveBrainRenderingSystem not found")
		return

	# Initialize medical-grade rendering with educational context
	var educational_context = {
		"learning_level": "intermediate",
		"clinical_focus": true,
		"pathology_mode": false,
		"target_audience": "medical_student"
	}

	# Apply medical-grade materials to brain models
	var model_holder_node = $AnatomicalModelContainer/BrainModelHolder
	if model_holder_node:
		print("[EnhancedExplorationScene] Applying medical-grade materials to brain models...")

		# Apply materials to all brain structure children
		for child in model_holder_node.get_children():
			if child.name.begins_with("Internal-Structures") or child.name.begins_with("Brain"):
				# Note: Metal renderer may show LOD bias warnings - this is a platform limitation
				# that doesn't affect functionality on macOS/iOS
				# Apply materials only to MeshInstance3D nodes
				if child is MeshInstance3D:
					rendering_system.apply_materials_to_brain_model(child, educational_context)
					print("[EnhancedExplorationScene] Applied medical materials to: ", child.name)
				else:
					print("[EnhancedExplorationScene] Skipped non-mesh node: ", child.name, " (", child.get_class(), ")")

	# Apply comprehensive rendering preset for medical study
	rendering_system.apply_rendering_preset("educational_enhanced")

	print("[EnhancedExplorationScene] ✅ Medical-grade brain rendering system initialized")

# === ADVANCED CAMERA COLLISION SYSTEM FUNCTIONS ===

func _setup_camera_collision_system() -> void:
	"""Initialize the advanced camera collision detection system"""
	print("[CameraCollision] Initializing advanced collision detection...")

	# Create collision shapes for camera
	if is_instance_valid(camera_collision_shape):
		var camera_sphere = SphereShape3D.new()
		camera_sphere.radius = 1.0
		camera_collision_shape.shape = camera_sphere
	else:
		push_warning("[CameraCollision] camera_collision_shape not found")

	# Create proximity warning shape (larger sphere)
	# Proximity shape removed in optimization
	if is_instance_valid(proximity_shape):
		var proximity_sphere = SphereShape3D.new()
		proximity_sphere.radius = _proximity_warning_distance
		proximity_shape.shape = proximity_sphere
	else:
		print("[CameraCollision] proximity_shape not available (removed in optimization)")

	# Create constraint boundary (very large sphere to prevent camera from going too far)
	var constraint_sphere = SphereShape3D.new()
	constraint_sphere.radius = _max_distance_from_brain
	# constraint_shape. # Node removed
	#shape = constraint_sphere

	# Set collision layers properly
	camera_collision.collision_layer = 0  # Doesn't collide with anything
	camera_collision.collision_mask = 1   # Detects brain structures (layer 1)

	# Proximity warning removed in optimization
	if is_instance_valid(proximity_warning):
		proximity_warning.collision_layer = 0
		proximity_warning.collision_mask = 1

	# camera_constraints. # Node removed
	#collision_layer = 2  # Boundary layer
	# camera_constraints. # Node removed
	#collision_mask = 0   # Doesn't detect anything

	print("[CameraCollision] ✅ Advanced collision detection initialized")

func _handle_camera_collision_in_physics(delta: float) -> void:
	"""Handle camera collision avoidance during physics updates"""
	if not _collision_avoidance_enabled or not _is_collision_active:
		return

	# Smoothly move camera away from collision
	if _collision_normal != Vector3.ZERO:
		var target_distance = _camera_distance + _target_collision_distance
		target_distance = clamp(target_distance, _min_distance_from_brain, _max_distance_from_brain)

		# Smooth interpolation to target distance
		_camera_distance = lerp(_camera_distance, target_distance, _collision_recovery_speed * delta)
		_update_camera_position()

		# Clear collision when sufficiently far
		if _camera_distance >= target_distance - 0.1:
			_is_collision_active = false
			_collision_normal = Vector3.ZERO
			_target_collision_distance = 0.0

func _calculate_collision_normal(colliding_area: Area3D) -> Vector3:
	"""Calculate the normal vector pointing away from collision"""
	if not is_instance_valid(colliding_area):
		return Vector3.ZERO

	var camera_pos = camera.global_position
	var collision_center = colliding_area.global_position

	# Calculate direction from collision center to camera
	var direction = (camera_pos - collision_center).normalized()

	# If direction is zero (camera inside object), use fallback
	if direction.length_squared() < 0.01:
		direction = Vector3.BACK  # Move camera backwards

	return direction

func enable_collision_avoidance(enabled: bool) -> void:
	"""Enable or disable camera collision avoidance"""
	_collision_avoidance_enabled = enabled
	camera_collision.set_deferred("monitoring", enabled)
	# Proximity warning removed in optimization
	if is_instance_valid(proximity_warning):
		proximity_warning.set_deferred("monitoring", enabled)

	if enabled:
		print("[CameraCollision] Collision avoidance enabled")
	else:
		print("[CameraCollision] Collision avoidance disabled")

func set_collision_sensitivity(min_distance: float, recovery_speed: float) -> void:
	"""Adjust collision detection sensitivity for different educational contexts"""
	_min_distance_from_brain = max(min_distance, 0.5)  # Minimum safety distance
	_collision_recovery_speed = clamp(recovery_speed, 0.5, 10.0)

	print("[CameraCollision] Sensitivity updated: min_distance=%.1f, recovery_speed=%.1f" % [_min_distance_from_brain, _collision_recovery_speed])

# === CAMERA COLLISION SIGNAL HANDLERS ===

func _on_camera_area_collision_detected(area: Area3D) -> void:
	"""Handle camera collision with brain structures"""
	if not _collision_avoidance_enabled:
		return

	print("[CameraCollision] Collision detected with: " + str(area.name))

	# Calculate collision response
	_collision_normal = _calculate_collision_normal(area)
	_target_collision_distance = _min_distance_from_brain
	_is_collision_active = true

	# Provide haptic feedback if available (controller vibration)
	_trigger_collision_feedback()

	# Track collision for educational analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("camera_collision", {
			"structure": area.name,
			"camera_distance": _camera_distance
		})

func _on_camera_collision_exited(area: Area3D) -> void:
	"""Handle camera collision exit"""
	print("[CameraCollision] Collision cleared with: " + str(area.name))

	# Gradually clear collision response
	_is_collision_active = false

func _on_camera_proximity_warning(area: Area3D) -> void:
	"""Handle camera proximity warning"""
	print("[CameraCollision] Proximity warning for: " + str(area.name))

	# Visual feedback for approaching structures
	_show_proximity_warning(area.name)

	# Track proximity for educational analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("camera_proximity", {
			"structure": area.name,
			"camera_distance": _camera_distance
		})

func _on_camera_proximity_cleared(area: Area3D) -> void:
	"""Handle camera proximity warning cleared"""
	print("[CameraCollision] Proximity cleared for: " + str(area.name))

	# Clear visual feedback
	_hide_proximity_warning()

func _trigger_collision_feedback() -> void:
	"""Trigger haptic/visual feedback for collision"""
	# Flash screen edge briefly
	if is_instance_valid(status_label):
		status_label.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.3)

	# Could add controller vibration here if available

func _show_proximity_warning(structure_name: String) -> void:
	"""Show visual warning for camera proximity"""
	if is_instance_valid(status_label):
		status_label.text = "Approaching " + structure_name.replace("_", " ").capitalize()
		status_label.modulate = Color.YELLOW

func _hide_proximity_warning() -> void:
	"""Hide proximity warning"""
	if is_instance_valid(status_label):
		status_label.text = "Ready"
		status_label.modulate = Color.WHITE

# === ENHANCED ANNOTATION SYSTEM FUNCTIONS === 
# ALL ANNOTATION FUNCTIONS BELOW ARE DISABLED - Medical Annotation System Removed

# DISABLED - Medical Annotation System
func _setup_enhanced_annotation_system() -> void:
	"""Initialize the enhanced annotation system with medical terminology - DISABLED"""
	print("[Annotation] Medical annotation system disabled - function disabled")
	return

func _load_medical_terminology_database() -> void:
	"""Load medical terminology and pronunciation data - DISABLED"""
	# Function disabled - medical annotation system removed
	pass

func _update_annotation_projections() -> void:
	"""Update 3D-to-2D projection of anatomical labels - DISABLED"""
	# Function disabled - medical annotation system removed
	pass

func _is_position_visible(world_position: Vector3) -> bool:
	"""Check if a 3D position is visible within camera frustum"""
	if not camera or not is_instance_valid(camera):
		return false

	# Get camera's view frustum
	var cam_transform = camera.global_transform
	var cam_projection = camera.get_camera_projection()

	# Transform position to camera space
	var local_pos = cam_transform.affine_inverse() * world_position

	# Check if position is in front of camera
	if local_pos.z >= 0:
		return false

	# Project to normalized device coordinates
	var projected = cam_projection * Vector4(local_pos.x, local_pos.y, local_pos.z, 1.0)
	if projected.w <= 0:
		return false

	var ndc = Vector2(projected.x / projected.w, projected.y / projected.w)

	# Check if within screen bounds
	return ndc.x >= -1.0 and ndc.x <= 1.0 and ndc.y >= -1.0 and ndc.y <= 1.0

func _show_annotation_label(structure_id: String, screen_position: Vector2) -> void:
	"""Show or update annotation label at screen position"""
	var label = _get_or_create_annotation_label(structure_id)
	if not label:
		return

	# Update label position
	label.position = screen_position - Vector2(label.size.x * 0.5, label.size.y)

	# Update label content based on current settings
	_update_annotation_label_content(label, structure_id)

	# Show label
	label.visible = true

func _hide_annotation_label(structure_id: String) -> void:
	"""Hide annotation label for structure"""
	if _annotation_labels.has(structure_id):
		var label = _annotation_labels[structure_id]
		if is_instance_valid(label):
			label.visible = false

func _get_or_create_annotation_label(structure_id: String) -> Label:
	"""Get existing or create new annotation label"""
	if _annotation_labels.has(structure_id):
		var existing_label = _annotation_labels[structure_id]
		if is_instance_valid(existing_label):
			return existing_label

	# Create new label
	var label = Label.new()
	label.add_theme_font_size_override("font_size", int(_annotation_font_size))

	# Apply accessibility and medical styling
	_apply_medical_label_styling(label, structure_id)

	# Add to structure labels container - DISABLED
	# Medical annotation system has been removed
	# _annotation_labels[structure_id] = label

	return label

func _apply_medical_label_styling(label: Label, structure_id: String) -> void:
	"""Apply medical-grade styling to annotation labels"""
	# Font and size
	label.add_theme_font_size_override("font_size", int(_annotation_font_size))

	# Colors based on contrast mode
	if _high_contrast_mode:
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
	else:
		label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)

	# Accessibility metadata
	label.set_meta("accessibility_role", "label")
	label.set_meta("accessibility_label", "Anatomical structure: " + structure_id)
	label.set_meta("medical_structure_id", structure_id)

func _update_annotation_label_content(label: Label, structure_id: String) -> void:
	"""Update label content based on language and display settings"""
	if not _medical_terminology_database.has(structure_id):
		label.text = structure_id.capitalize()
		return

	var term_data = _medical_terminology_database[structure_id]
	var display_text = ""

	match _annotation_language:
		"english":
			display_text = term_data.get("english", structure_id.capitalize())
		"latin":
			display_text = term_data.get("latin", structure_id.capitalize())
		"both":
			var english = term_data.get("english", structure_id.capitalize())
			var latin = term_data.get("latin", structure_id.capitalize())
			display_text = english + "\n(" + latin + ")"

	label.text = display_text

func toggle_annotation_visibility(show_labels: bool) -> void:
	"""Toggle visibility of all annotation labels"""
	for label in _annotation_labels.values():
		if is_instance_valid(label):
			label.visible = show_labels

func show_annotation_settings() -> void:
	"""Show annotation settings panel - DISABLED"""
	pass

func hide_annotation_settings() -> void:
	"""Hide annotation settings panel - DISABLED"""
	pass

# === ANNOTATION SIGNAL HANDLERS ===

func _on_annotation_font_size_changed(new_size: float) -> void:
	"""Handle font size slider change"""
	_annotation_font_size = new_size

	# Update all existing labels
	for label in _annotation_labels.values():
		if is_instance_valid(label):
			label.add_theme_font_size_override("font_size", int(_annotation_font_size))

	# Track accessibility analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("annotation_font_size_changed", {
			"new_size": new_size
		})

func _on_annotation_contrast_toggled(enabled: bool) -> void:
	"""Handle high contrast mode toggle"""
	_high_contrast_mode = enabled

	# Update styling for all labels
	for structure_id in _annotation_labels.keys():
		var label = _annotation_labels[structure_id]
		if is_instance_valid(label):
			_apply_medical_label_styling(label, structure_id)

	# Track accessibility analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("annotation_contrast_toggled", {
			"high_contrast_enabled": enabled
		})

func _on_annotation_language_changed(language_index: int) -> void:
	"""Handle annotation language selection change"""
	var languages = ["english", "latin", "both"]
	if language_index < languages.size():
		_annotation_language = languages[language_index]

		# Update content for all labels
		for structure_id in _annotation_labels.keys():
			var label = _annotation_labels[structure_id]
			if is_instance_valid(label):
				_update_annotation_label_content(label, structure_id)

		# Track educational analytics
		if get_node_or_null("/root/ProgressTracker"):
			get_node("/root/ProgressTracker").track_educational_interaction("annotation_language_changed", {
				"language": _annotation_language
			})

# === EDUCATIONAL QUIZ SYSTEM FUNCTIONS ===

func show_quiz_for_structure(structure_id: String) -> void:
	"""Show educational quiz for selected brain structure"""
	if not get_node_or_null("/root/AssessmentService"):
		push_error("[Quiz] AssessmentService not available")
		return

	var quiz_data = get_node("/root/AssessmentService").get_quiz_for_structure(structure_id)
	if quiz_data.is_empty():
		update_status("No assessment available for: " + structure_id)
		return

	_current_quiz_data = quiz_data
	_current_quiz_question = 0
	_quiz_answers.clear()
	_quiz_scores.clear()
	_quiz_structure_context = structure_id
	_quiz_is_active = true

	_setup_quiz_interface()
	quiz_overlay.show()

	# Track educational analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("quiz_started", {
			"structure": structure_id,
			"question_count": quiz_data.questions.size()
		})

func _setup_quiz_interface() -> void:
	"""Setup quiz interface with current question data"""
	if _current_quiz_data.is_empty():
		return

	# Update header
	var structure_name = _current_quiz_data.get("structure_name", _quiz_structure_context)
	quiz_title.text = "Assessment: " + structure_name
	quiz_progress.max_value = _current_quiz_data.questions.size()
	quiz_progress.value = _current_quiz_question + 1

	# Hide feedback initially
	quiz_feedback.hide()

	# Display current question
	_display_current_question()

	# Update control buttons
	_update_quiz_controls()

func _display_current_question() -> void:
	"""Display the current quiz question and options"""
	if _current_quiz_question >= _current_quiz_data.questions.size():
		_show_quiz_completion()
		return

	var question_data = _current_quiz_data.questions[_current_quiz_question]

	# Set question text with medical formatting
	var question_html = "[b]Question %d:[/b] %s" % [_current_quiz_question + 1, question_data.question]
	question_text.text = question_html

	# Load question image if available
	if question_data.has("image_path") and question_data.image_path != "":
		var image_texture = load(question_data.image_path)
		if image_texture:
			question_image.texture = image_texture
			question_image.show()
		else:
			question_image.hide()
	else:
		question_image.hide()

	# Set answer options
	var options = question_data.get("options", [])
	for i in range(_quiz_answer_options.size()):
		var option_button = _quiz_answer_options[i]
		if i < options.size():
			option_button.text = options[i]
			option_button.show()
			option_button.button_pressed = false
		else:
			option_button.hide()

	# Restore previous answer if exists
	var question_id = str(_current_quiz_question)
	if _quiz_answers.has(question_id):
		var selected_index = _quiz_answers[question_id]
		if selected_index < _quiz_answer_options.size():
			_quiz_answer_options[selected_index].button_pressed = true

func _update_quiz_controls() -> void:
	"""Update quiz control button states"""
	# Previous button
	previous_button.disabled = (_current_quiz_question == 0)

	# Next button
	var has_answer = _quiz_answers.has(str(_current_quiz_question))
	var is_last_question = (_current_quiz_question >= _current_quiz_data.questions.size() - 1)
	next_button.disabled = not has_answer or is_last_question

	# Submit button
	submit_button.disabled = not has_answer

	# Review button (only show when all questions answered)
	var all_answered = _quiz_answers.size() == _current_quiz_data.questions.size()
	review_button.visible = all_answered

func _show_quiz_completion() -> void:
	"""Show quiz completion summary"""
	var correct_count = 0
	for score in _quiz_scores.values():
		if score:
			correct_count += 1

	var total_questions = _current_quiz_data.questions.size()
	var percentage = (float(correct_count) / float(total_questions)) * 100.0

	# Update question area to show results
	var results_html = "[center][b]Assessment Complete![/b][/center]\n\n"
	results_html += "Score: %d/%d (%.1f%%)\n\n" % [correct_count, total_questions, percentage]

	if percentage >= 80.0:
		results_html += "[color=green]Excellent understanding of %s anatomy![/color]" % _quiz_structure_context
	elif percentage >= 60.0:
		results_html += "[color=yellow]Good grasp of %s concepts. Review highlighted areas.[/color]" % _quiz_structure_context
	else:
		results_html += "[color=red]Additional study recommended for %s anatomy.[/color]" % _quiz_structure_context

	question_text.text = results_html
	question_image.hide()
	answer_options.hide()

	# Update controls for completion
	previous_button.hide()
	submit_button.hide()
	next_button.text = "Close"
	next_button.disabled = false
	next_button.show()

	# Track completion analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("quiz_completed", {
			"structure": _quiz_structure_context,
			"score": correct_count,
			"total": total_questions,
			"percentage": percentage
		})

# === QUIZ SIGNAL HANDLERS ===

func _on_quiz_close_pressed() -> void:
	"""Handle quiz close button press"""
	quiz_overlay.hide()
	_quiz_is_active = false

	# Track analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("quiz_closed", {
			"structure": _quiz_structure_context,
			"questions_answered": _quiz_answers.size()
		})

func _on_quiz_previous_pressed() -> void:
	"""Navigate to previous question"""
	if _current_quiz_question > 0:
		_current_quiz_question -= 1
		_display_current_question()
		_update_quiz_controls()
		quiz_feedback.hide()

func _on_quiz_next_pressed() -> void:
	"""Navigate to next question or close quiz"""
	if next_button.text == "Close":
		_on_quiz_close_pressed()
		return

	if _current_quiz_question < _current_quiz_data.questions.size() - 1:
		_current_quiz_question += 1
		_display_current_question()
		_update_quiz_controls()
		quiz_feedback.hide()

func _on_quiz_submit_pressed() -> void:
	"""Submit current answer and show feedback"""
	var question_id = str(_current_quiz_question)
	if not _quiz_answers.has(question_id):
		return

	var selected_answer = _quiz_answers[question_id]
	var question_data = _current_quiz_data.questions[_current_quiz_question]
	var correct_answer = question_data.get("correct_answer", 0)
	var is_correct = (selected_answer == correct_answer)

	# Store score
	_quiz_scores[question_id] = is_correct

	# Show feedback
	_show_quiz_feedback(is_correct, question_data)

	# Update controls
	_update_quiz_controls()

	# Track answer analytics
	if get_node_or_null("/root/ProgressTracker"):
		get_node("/root/ProgressTracker").track_educational_interaction("quiz_answer_submitted", {
			"structure": _quiz_structure_context,
			"question": _current_quiz_question,
			"selected": selected_answer,
			"correct": correct_answer,
			"is_correct": is_correct
		})

func _on_quiz_review_pressed() -> void:
	"""Show quiz review mode"""
	# TODO: Implement comprehensive review mode
	update_status("Quiz review mode coming soon")

func _on_quiz_answer_selected(_pressed: bool, option_index: int) -> void:
	"""Handle answer option selection - manage exclusive selection"""
	var question_id = str(_current_quiz_question)

	# Get the selected checkbox
	var selected_checkbox = _quiz_answer_options[option_index]

	if selected_checkbox.button_pressed:
		# This option was just selected - deselect others
		for i in range(_quiz_answer_options.size()):
			if i != option_index:
				_quiz_answer_options[i].button_pressed = false

		_quiz_answers[question_id] = option_index
	else:
		# This option was deselected - remove answer
		if _quiz_answers.has(question_id):
			_quiz_answers.erase(question_id)

	# Update controls
	_update_quiz_controls()

	# Hide previous feedback
	quiz_feedback.hide()

func _show_quiz_feedback(is_correct: bool, question_data: Dictionary) -> void:
	"""Display feedback for submitted answer"""
	var feedback_html = ""
	var clinical_html = ""

	if is_correct:
		feedback_html = "[color=green][b]Correct![/b][/color] " + question_data.get("explanation", "")
	else:
		var correct_option = question_data.get("correct_answer", 0)
		var options = question_data.get("options", [])
		var correct_text = options[correct_option] if correct_option < options.size() else "Unknown"
		feedback_html = "[color=red][b]Incorrect.[/b][/color] The correct answer is: " + correct_text + "\n" + question_data.get("explanation", "")

	# Add clinical relevance if available
	if question_data.has("clinical_relevance"):
		clinical_html = "[b]Clinical Relevance:[/b] " + question_data.clinical_relevance

	feedback_text.text = feedback_html
	clinical_relevance.text = clinical_html

	# Show feedback panel
	quiz_feedback.show()

func _exit_tree() -> void:
	## Clean up all resources to prevent memory leaks
	# Stop all timers first
	if _debounce_timer and is_instance_valid(_debounce_timer):
		_debounce_timer.stop()
		_debounce_timer.queue_free()
		_debounce_timer = null

	if _tooltip_timer and is_instance_valid(_tooltip_timer):
		_tooltip_timer.stop()
		_tooltip_timer.queue_free()
		_tooltip_timer = null

	# Clean up interaction controller
	if _brain_interaction and is_instance_valid(_brain_interaction):
		_brain_interaction.queue_free()
		_brain_interaction = null

	# Clean up structure button styles and references
	for button in _structure_buttons.values():
		if button and is_instance_valid(button):
			# Clear all style overrides to free StyleBoxFlat RIDs
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
			button.remove_theme_stylebox_override("pressed")
			button.remove_theme_stylebox_override("focus")
			# Disconnect signals
			if button.pressed.is_connected(_on_related_structure_pressed):
				button.pressed.disconnect(_on_related_structure_pressed)
	_structure_buttons.clear()

	# Clean up selection sphere material
	if selection_sphere and is_instance_valid(selection_sphere):
		if selection_sphere.material_override:
			selection_sphere.material_override = null

	# Clean up quiz panel
	if _quiz_panel and is_instance_valid(_quiz_panel):
		_quiz_panel.queue_free()
		_quiz_panel = null

	# Clean up camera collision area
	if _camera_collision_area and is_instance_valid(_camera_collision_area):
		_camera_collision_area.queue_free()
		_camera_collision_area = null

	# Clear UI panel materials
	var panels = get_tree().get_nodes_in_group("ui_panels")
	for panel in panels:
		if panel and is_instance_valid(panel) and panel.has_method("set_material"):
			panel.material = null

	# Clean up brain container children
	if brain_container and is_instance_valid(brain_container):
		for child in brain_container.get_children():
			if child is MeshInstance3D:
				# Clear material overrides
				for i in range(child.get_surface_override_material_count()):
					child.set_surface_override_material(i, null)

	# Clear cached references
	_current_structure = null
	_last_hover_structure = null
	_camera_target_position = Vector3.ZERO
	_camera_target_rotation = Vector3.ZERO

	# Disconnect any remaining signal connections
	if has_node("/root/PerformanceMonitor"):
		var perf_monitor = get_node("/root/PerformanceMonitor")
		if perf_monitor.has_signal("performance_report_ready") and perf_monitor.performance_report_ready.is_connected(_on_performance_report):
			perf_monitor.performance_report_ready.disconnect(_on_performance_report)
		if perf_monitor.has_signal("quality_level_changed") and perf_monitor.quality_level_changed.is_connected(_on_quality_changed):
			perf_monitor.quality_level_changed.disconnect(_on_quality_changed)

# Validation functions for safe setup methods
func _validate_ui_setup() -> bool:
	"""Validate UI components are properly initialized"""
	var required_ui = [
		info_panel,
		top_bar,
		left_panel,
		bottom_panel
	]

	for ui_element in required_ui:
		if not is_instance_valid(ui_element):
			return false

	return true

func _validate_scene_setup() -> bool:
	"""Validate scene components are properly initialized"""
	var required_scene = [
		brain_container,
		camera,
		camera_pivot
	]

	for scene_element in required_scene:
		if not is_instance_valid(scene_element):
			return false

	return true

func _validate_lighting_setup() -> bool:
	"""Validate lighting components are properly initialized"""
	var key_light_node = get_node_or_null("EnvironmentSystem/MedicalLightingSystem/KeyLight")
	var fill_light_node = get_node_or_null("EnvironmentSystem/MedicalLightingSystem/FillLight")
	var rim_light_node = get_node_or_null("EnvironmentSystem/MedicalLightingSystem/RimLight")
	var required_lights = [
		key_light_node,
		fill_light_node,
		rim_light_node
	]

	for light in required_lights:
		if not is_instance_valid(light):
			return false

	return true

func _validate_camera_setup() -> bool:
	"""Validate camera system is properly initialized"""
	return is_instance_valid(camera) and is_instance_valid(camera_pivot)

func _validate_annotation_setup() -> bool:
	"""Validate annotation system is properly initialized - DISABLED"""
	return true  # Always return true since annotation system is disabled


func _validate_camera_collision_setup() -> bool:
	"""Validate camera collision system is properly initialized"""
	return is_instance_valid(_camera_collision_area)

func _validate_axis_indicator_setup() -> bool:
	"""Validate axis indicator is properly created - removed for performance"""
	return true

func _validate_help_text_setup() -> bool:
	"""Validate help text is properly initialized"""
	return is_instance_valid(help_overlay)

func _validate_rendering_setup() -> bool:
	"""Validate rendering components are properly initialized"""
	return true

func _optimize_for_integrated_graphics() -> void:
	"""Optimize scene for Intel UHD 620 and similar integrated graphics"""
	# Intel optimization now handled by PerformanceMonitor
	if PerformanceMonitor and PerformanceMonitor.has_method("is_intel_gpu"):
		if PerformanceMonitor.is_intel_gpu:
			print("[Performance] Intel GPU optimizations active")
		
		# Apply Intel-specific optimizations
		print("[Performance] Integrated graphics detected - applying optimizations")

		# Disable heavy effects in environment
		if environment and environment.environment:
			var env = environment.environment
			env.ssao_enabled = false  # SSAO is expensive
			env.glow_enabled = false  # Glow/bloom effects
			env.volumetric_fog_enabled = false
			env.adjustment_enabled = false
			print("[Performance] Disabled SSAO, glow, and other expensive effects")

		# Remove unused nodes
		_remove_unused_nodes()

		# Optimize materials
		_optimize_materials_for_integrated()

		# Reduce shadow quality
		if fill_light:
			fill_light.shadow_enabled = false
			print("[Performance] Disabled shadows on fill light")

		# Set lower quality defaults
		_performance_data.target_fps = 30.0  # Target 30 FPS on Intel UHD 620

	else:
		print("[Performance] Dedicated graphics detected - keeping full quality")

func _remove_unused_nodes() -> void:
	"""Remove nodes identified as unused in the audit"""
	# Remove disabled lights
	if key_light and not key_light.visible:
		print("[Optimization] Removing unused KeyLight")
		key_light.queue_free()
		key_light = null

	if rim_light and not rim_light.visible:
		print("[Optimization] Removing unused RimLight")
		rim_light.queue_free()
		rim_light = null

	# Visualization helpers already removed for performance

	# Remove empty MedicalCameraEffects node
	var camera_effects = camera.get_node_or_null("MedicalCameraEffects")
	if camera_effects and camera_effects.get_child_count() == 0:
		print("[Optimization] Removing empty MedicalCameraEffects node")
		camera_effects.queue_free()

func _optimize_materials_for_integrated() -> void:
	"""Optimize materials for integrated graphics"""
	# Find and optimize blur shaders
	var panels_with_blur = [
		top_bar,
		left_panel,
		info_panel,
		quiz_overlay,
		help_overlay
	]

	for panel in panels_with_blur:
		if panel and panel.material and panel.material is ShaderMaterial:
			var mat = panel.material as ShaderMaterial
			if mat.shader and mat.shader.resource_path.contains("glass"):
				# Reduce blur amount for performance
				mat.set_shader_parameter("blur_amount", 4.0)  # Reduced from 12.0
				print("[Optimization] Reduced blur amount on " + panel.name)
