## Comprehensive Brain Rendering System for NeuroVision
##
## Master system that coordinates all brain rendering components including
## materials, lighting, post-processing, and LOD for medical-grade visualization.

class_name ComprehensiveBrainRenderingSystem
extends Node3D

# === SIGNALS ===
signal rendering_quality_changed(quality: String)
signal educational_context_applied(context: Dictionary)
signal brain_model_registered(model: Node3D, structure_name: String)
signal lighting_optimization_complete(performance_gain: float)

# === CONSTANTS ===
const RENDERING_PRESETS = {
	"medical_maximum": {
		"description": "Maximum quality for medical diagnosis",
		"material_quality": "maximum",
		"lighting_preset": "examination",
		"post_processing": "medical_maximum",
		"lod_enabled": true,
		"hdri_environment": "medical_lab",
		"performance_target": 45.0
	},
	"clinical_standard": {
		"description": "Standard clinical visualization",
		"material_quality": "high",
		"lighting_preset": "surgical",
		"post_processing": "clinical_high",
		"lod_enabled": true,
		"hdri_environment": "anatomy_room",
		"performance_target": 60.0
	},
	"educational_enhanced": {
		"description": "Enhanced educational experience",
		"material_quality": "high",
		"lighting_preset": "anatomical",
		"post_processing": "educational_balanced",
		"lod_enabled": true,
		"hdri_environment": "neutral_studio",
		"performance_target": 60.0
	},
	"educational_accessible": {
		"description": "Accessible educational viewing",
		"material_quality": "medium",
		"lighting_preset": "research",
		"post_processing": "performance_optimized",
		"lod_enabled": true,
		"hdri_environment": "soft_ambient",
		"performance_target": 60.0
	},
	"intel_uhd_620": {
		"description": "Optimized for Intel UHD 620 graphics",
		"material_quality": "low",
		"lighting_preset": "simplified",
		"post_processing": "minimal",
		"lod_enabled": true,
		"lod_bias": 2.0,
		"texture_quality": "low",
		"hdri_environment": "none",
		"performance_target": 60.0
	},
	"performance_optimized": {
		"description": "Optimized for lower-end systems",
		"material_quality": "low",
		"lighting_preset": "research",
		"post_processing": "performance_optimized",
		"lod_enabled": true,
		"hdri_environment": "soft_ambient",
		"performance_target": 30.0
	}
}

const BRAIN_STRUCTURE_MAPPINGS = {
	"hippocampus": {"tissue_type": 0, "educational_priority": true, "pathology_prone": true},
	"amygdala": {"tissue_type": 0, "educational_priority": true, "pathology_prone": false},
	"thalamus": {"tissue_type": 0, "educational_priority": true, "pathology_prone": false},
	"striatum": {"tissue_type": 0, "educational_priority": false, "pathology_prone": true},
	"cerebellum": {"tissue_type": 0, "educational_priority": true, "pathology_prone": false},
	"brainstem": {"tissue_type": 1, "educational_priority": true, "pathology_prone": true},
	"corpus_callosum": {"tissue_type": 1, "educational_priority": false, "pathology_prone": false},
	"blood_vessels": {"tissue_type": 2, "educational_priority": false, "pathology_prone": true},
	"ventricles": {"tissue_type": 3, "educational_priority": false, "pathology_prone": false}
}

# === EXPORTS ===
@export_group("System Configuration")
@export var current_preset: String = "educational_enhanced"
@export var auto_optimize_performance: bool = true
@export var educational_mode_active: bool = true
@export var medical_accuracy_required: bool = false

@export_group("Educational Context")
@export var learning_level: String = "intermediate"  # beginner, intermediate, advanced
@export var target_audience: String = "medical_student"  # medical_student, researcher, clinician
@export var clinical_focus_enabled: bool = false
@export var pathology_visualization: bool = false

@export_group("Performance Settings")
@export var target_fps: float = 60.0
@export var quality_adjustment_enabled: bool = true
@export var emergency_fallback_enabled: bool = true

# === COMPONENT MANAGERS ===
var material_manager: RealisticBrainMaterialManager
var lighting_manager: MedicalGradeLightingManager
var hdri_manager: HDRIEnvironmentManager
var post_processing_manager: AdvancedPostProcessingManager
var lod_manager: LODLightingManager

# === PRIVATE VARIABLES ===
var registered_brain_models: Dictionary = {}  # Node3D -> BrainModelData
var current_educational_context: Dictionary = {}
var performance_monitor = null
var system_initialized: bool = false

# Performance tracking
var frame_time_samples: Array[float] = []
var last_performance_check: float = 0.0
var optimization_in_progress: bool = false

# Brain model data structure
class BrainModelData:
	var node: Node3D
	var structure_name: String
	var tissue_type: int
	var educational_priority: bool
	var pathology_prone: bool
	var current_material: Material
	var base_material_settings: Dictionary
	
	func _init(brain_node: Node3D, name: String):
		node = brain_node
		structure_name = name

# === INITIALIZATION ===

func _ready():
	_initialize_rendering_system()
	_connect_component_managers()
	_apply_initial_preset()
	print("[ComprehensiveBrainRendering] Comprehensive brain rendering system initialized")

func _initialize_rendering_system():
	"""Initialize the comprehensive rendering system"""
	# Create component managers
	material_manager = RealisticBrainMaterialManager.new()
	add_child(material_manager)
	
	lighting_manager = MedicalGradeLightingManager.new()
	add_child(lighting_manager)
	
	hdri_manager = HDRIEnvironmentManager.new()
	add_child(hdri_manager)
	
	post_processing_manager = AdvancedPostProcessingManager.new()
	add_child(post_processing_manager)
	
	lod_manager = LODLightingManager.new()
	add_child(lod_manager)
	
	# Set up initial educational context
	_update_educational_context()

func _connect_component_managers():
	"""Connect signals between component managers"""
	# Connect material manager signals
	if material_manager:
		material_manager.material_applied.connect(_on_material_applied)
		material_manager.quality_level_changed.connect(_on_material_quality_changed)
	
	# Connect lighting manager signals
	if lighting_manager:
		lighting_manager.lighting_preset_changed.connect(_on_lighting_preset_changed)
		lighting_manager.quality_level_changed.connect(_on_lighting_quality_changed)
	
	# Connect HDRI manager signals
	if hdri_manager:
		hdri_manager.environment_changed.connect(_on_environment_changed)
		hdri_manager.reflection_quality_changed.connect(_on_reflection_quality_changed)
	
	# Connect post-processing manager signals
	if post_processing_manager:
		post_processing_manager.post_processing_quality_changed.connect(_on_post_processing_quality_changed)
		post_processing_manager.performance_adjusted.connect(_on_post_processing_performance_adjusted)
	
	# Connect LOD manager signals
	if lod_manager:
		lod_manager.lod_level_changed.connect(_on_lod_level_changed)
		lod_manager.lighting_quality_adjusted.connect(_on_lod_performance_adjusted)
	
	# Connect to performance monitoring
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("UIThemeManager"):
		performance_monitor = tree.root.get_node("UIThemeManager")
		print("[ComprehensiveBrainRendering] Connected to performance monitoring")

func _apply_initial_preset():
	"""Apply the initial rendering preset"""
	apply_rendering_preset(current_preset)
	system_initialized = true

# === PRESET MANAGEMENT ===

func apply_rendering_preset(preset_name: String):
	"""Apply a comprehensive rendering preset"""
	if not preset_name in RENDERING_PRESETS:
		push_error("[ComprehensiveBrainRendering] Unknown preset: " + preset_name)
		return
	
	current_preset = preset_name
	var preset = RENDERING_PRESETS[preset_name]
	
	print("[ComprehensiveBrainRendering] Applying preset: %s - %s" % [preset_name, preset.description])
	
	# Apply material quality
	if material_manager:
		material_manager.set_quality_level(preset.material_quality)
	
	# Apply lighting preset
	if lighting_manager:
		lighting_manager.apply_lighting_preset(preset.lighting_preset)
		lighting_manager.target_fps = preset.performance_target
	
	# Apply HDRI environment
	if hdri_manager:
		hdri_manager.load_hdri_environment(preset.hdri_environment)
	
	# Apply post-processing
	if post_processing_manager:
		post_processing_manager.apply_preset(preset.post_processing)
		post_processing_manager.target_fps = preset.performance_target
	
	# Configure LOD system
	if lod_manager:
		lod_manager.enabled = preset.lod_enabled
		lod_manager.target_fps = preset.performance_target
	
	# Update target FPS
	target_fps = preset.performance_target
	
	rendering_quality_changed.emit(preset_name)

# === BRAIN MODEL REGISTRATION ===

func register_brain_model(brain_node: Node3D, structure_name: String = ""):
	"""Register a brain model for comprehensive rendering management"""
	if not brain_node:
		push_error("[ComprehensiveBrainRendering] Invalid brain node")
		return
	
	# Determine structure name if not provided
	if structure_name.is_empty():
		structure_name = _determine_structure_name(brain_node)
	
	# Create brain model data
	var model_data = BrainModelData.new(brain_node, structure_name)
	
	# Get structure configuration
	var structure_config = BRAIN_STRUCTURE_MAPPINGS.get(structure_name, {
		"tissue_type": 0,
		"educational_priority": false,
		"pathology_prone": false
	})
	
	model_data.tissue_type = structure_config.tissue_type
	model_data.educational_priority = structure_config.educational_priority
	model_data.pathology_prone = structure_config.pathology_prone
	
	# Apply appropriate materials
	_apply_brain_material(model_data)
	
	# Register with LOD system
	if lod_manager:
		lod_manager.register_brain_model(brain_node, model_data.educational_priority)
	
	registered_brain_models[brain_node] = model_data
	
	brain_model_registered.emit(brain_node, structure_name)
	print("[ComprehensiveBrainRendering] Registered brain model: %s (%s)" % [brain_node.name, structure_name])

func _determine_structure_name(brain_node: Node3D) -> String:
	"""Determine structure name from node properties"""
	# Check metadata first
	if brain_node.has_meta("structure_name"):
		return brain_node.get_meta("structure_name")
	
	# Check node name patterns
	var node_name = brain_node.name.to_lower()
	for structure in BRAIN_STRUCTURE_MAPPINGS:
		if structure in node_name:
			return structure
	
	return "unknown_structure"

func _apply_brain_material(model_data: BrainModelData):
	"""Apply appropriate brain material to a model"""
	if not material_manager:
		return
	
	var region_type = ""
	match model_data.tissue_type:
		0: region_type = "gray_matter"
		1: region_type = "white_matter"
		2: region_type = "blood_vessels"
		3: region_type = "cerebrospinal_fluid"
		4: region_type = "dura_mater"
		5: region_type = "pia_mater"
		_: region_type = "gray_matter"
	
	# Apply material to structure
	material_manager.apply_material_to_structure(
		model_data.node,
		model_data.structure_name,
		region_type
	)
	
	# Apply educational context if active
	if educational_mode_active:
		material_manager.apply_educational_context(current_educational_context)

# === EDUCATIONAL CONTEXT MANAGEMENT ===

func set_educational_context(context: Dictionary):
	"""Set educational context for all rendering components"""
	current_educational_context = context
	_update_educational_context()
	educational_context_applied.emit(context)

func _update_educational_context():
	"""Update educational context across all managers"""
	var context = {
		"learning_level": learning_level,
		"target_audience": target_audience,
		"clinical_focus": clinical_focus_enabled,
		"pathology_mode": pathology_visualization,
		"medical_accuracy": medical_accuracy_required
	}
	
	current_educational_context = context
	
	# Apply to material manager
	if material_manager:
		material_manager.apply_educational_context(context)
	
	# Apply to lighting manager
	if lighting_manager:
		lighting_manager.set_learning_mode(learning_level)
		lighting_manager.set_clinical_focus(clinical_focus_enabled)
	
	# Apply to post-processing
	if post_processing_manager:
		post_processing_manager.medical_accuracy_mode = medical_accuracy_required

func set_learning_level(level: String):
	"""Set learning level (beginner, intermediate, advanced)"""
	if level in ["beginner", "intermediate", "advanced"]:
		learning_level = level
		_update_educational_context()

func set_target_audience(audience: String):
	"""Set target audience (medical_student, researcher, clinician)"""
	if audience in ["medical_student", "researcher", "clinician"]:
		target_audience = audience
		_update_educational_context()

func enable_clinical_focus(enabled: bool):
	"""Enable or disable clinical focus mode"""
	clinical_focus_enabled = enabled
	_update_educational_context()

func enable_pathology_visualization(enabled: bool):
	"""Enable or disable pathology visualization"""
	pathology_visualization = enabled
	_update_educational_context()

# === PERFORMANCE OPTIMIZATION ===

func _process(delta):
	"""Main performance monitoring and optimization loop"""
	if not auto_optimize_performance or not system_initialized:
		return
	
	last_performance_check += delta
	if last_performance_check < 1.0:  # Check every second
		return
	
	last_performance_check = 0.0
	
	# Collect performance metrics
	var current_fps = Engine.get_frames_per_second()
	frame_time_samples.append(current_fps)
	
	if frame_time_samples.size() > 10:
		frame_time_samples.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in frame_time_samples:
		avg_fps += fps
	avg_fps /= frame_time_samples.size()
	
	# Optimize if needed
	_optimize_for_performance(avg_fps)

func _optimize_for_performance(avg_fps: float):
	"""Optimize rendering for current performance"""
	if optimization_in_progress:
		return
	
	var performance_ratio = avg_fps / target_fps
	var optimization_needed = false
	
	if performance_ratio < 0.8:  # Performance is poor
		optimization_needed = true
		_reduce_rendering_quality()
	elif performance_ratio > 1.2:  # Performance is excellent
		optimization_needed = true
		_increase_rendering_quality()
	
	if optimization_needed:
		var performance_gain = avg_fps - (frame_time_samples[-2] if frame_time_samples.size() > 1 else avg_fps)
		lighting_optimization_complete.emit(performance_gain)

func _reduce_rendering_quality():
	"""Reduce rendering quality for better performance"""
	print("[ComprehensiveBrainRendering] Reducing quality for performance")
	optimization_in_progress = true
	
	# Reduce material quality
	if material_manager:
		var current_index = ["low", "medium", "high", "maximum"].find(material_manager.current_quality_level)
		if current_index > 0:
			material_manager.set_quality_level(["low", "medium", "high", "maximum"][current_index - 1])
	
	# Reduce lighting quality
	if lighting_manager:
		var current_index = ["low", "medium", "high", "maximum"].find(lighting_manager.lighting_quality)
		if current_index > 0:
			lighting_manager.set_lighting_quality(["low", "medium", "high", "maximum"][current_index - 1])
	
	# Enable LOD emergency optimization
	if lod_manager:
		lod_manager.enable_emergency_optimization()
	
	optimization_in_progress = false

func _increase_rendering_quality():
	"""Increase rendering quality when performance allows"""
	print("[ComprehensiveBrainRendering] Increasing quality due to good performance")
	optimization_in_progress = true
	
	# Increase material quality
	if material_manager:
		var current_index = ["low", "medium", "high", "maximum"].find(material_manager.current_quality_level)
		if current_index < 3:
			material_manager.set_quality_level(["low", "medium", "high", "maximum"][current_index + 1])
	
	# Increase lighting quality
	if lighting_manager:
		var current_index = ["low", "medium", "high", "maximum"].find(lighting_manager.lighting_quality)
		if current_index < 3:
			lighting_manager.set_lighting_quality(["low", "medium", "high", "maximum"][current_index + 1])
	
	# Disable LOD emergency optimization
	if lod_manager:
		lod_manager.disable_emergency_optimization()
	
	optimization_in_progress = false

# === SIGNAL HANDLERS ===

func _on_material_applied(_node: Node3D, _material_name: String):
	"""Handle material application"""
	pass

func _on_material_quality_changed(new_level: String):
	"""Handle material quality change"""
	print("[ComprehensiveBrainRendering] Material quality changed to: " + new_level)

func _on_lighting_preset_changed(preset_name: String):
	"""Handle lighting preset change"""
	# Sync HDRI environment with lighting preset
	if hdri_manager:
		hdri_manager.sync_with_lighting_preset(preset_name)

func _on_lighting_quality_changed(new_level: String):
	"""Handle lighting quality change"""
	print("[ComprehensiveBrainRendering] Lighting quality changed to: " + new_level)

func _on_environment_changed(environment_name: String):
	"""Handle HDRI environment change"""
	print("[ComprehensiveBrainRendering] HDRI environment changed to: " + environment_name)

func _on_reflection_quality_changed(quality: String):
	"""Handle reflection quality change"""
	print("[ComprehensiveBrainRendering] Reflection quality changed to: " + quality)

func _on_post_processing_quality_changed(quality: String):
	"""Handle post-processing quality change"""
	print("[ComprehensiveBrainRendering] Post-processing quality changed to: " + quality)

func _on_post_processing_performance_adjusted(fps: float, preset: String):
	"""Handle post-processing performance adjustment"""
	print("[ComprehensiveBrainRendering] Post-processing adapted to performance: %.1f fps, preset: %s" % [fps, preset])

func _on_lod_level_changed(node: Node3D, old_level: int, new_level: int):
	"""Handle LOD level change"""
	if node in registered_brain_models:
		var model_data = registered_brain_models[node]
		print("[ComprehensiveBrainRendering] LOD changed for %s: %d -> %d" % [model_data.structure_name, old_level, new_level])

func _on_lod_performance_adjusted(performance_fps: float, target_fps_param: float):
	"""Handle LOD performance adjustment"""
	print("[ComprehensiveBrainRendering] LOD system adapted: %.1f fps (target: %.1f)" % [performance_fps, target_fps_param])

# === PUBLIC API ===

func get_available_presets() -> Array:
	"""Get list of available rendering presets"""
	return RENDERING_PRESETS.keys()

func get_preset_description(preset_name: String) -> String:
	"""Get description of a rendering preset"""
	var preset = RENDERING_PRESETS.get(preset_name, {})
	return preset.get("description", "Unknown preset")

func get_registered_brain_models() -> Array:
	"""Get list of registered brain models"""
	return registered_brain_models.keys()

func get_brain_model_info(brain_node: Node3D) -> Dictionary:
	"""Get information about a registered brain model"""
	if brain_node in registered_brain_models:
		var model_data = registered_brain_models[brain_node]
		return {
			"structure_name": model_data.structure_name,
			"tissue_type": model_data.tissue_type,
			"educational_priority": model_data.educational_priority,
			"pathology_prone": model_data.pathology_prone
		}
	return {}

func get_system_diagnostics() -> Dictionary:
	"""Get comprehensive system diagnostics"""
	var diagnostics = {
		"system_initialized": system_initialized,
		"current_preset": current_preset,
		"educational_context": current_educational_context,
		"registered_models": registered_brain_models.size(),
		"performance_target": target_fps,
		"current_fps": Engine.get_frames_per_second(),
		"optimization_active": optimization_in_progress
	}
	
	# Add component diagnostics
	if material_manager:
		diagnostics.material_system = material_manager.get_diagnostics()
	if lighting_manager:
		diagnostics.lighting_system = lighting_manager.get_diagnostics()
	if hdri_manager:
		diagnostics.hdri_system = hdri_manager.get_diagnostics()
	if post_processing_manager:
		diagnostics.post_processing_system = post_processing_manager.get_diagnostics()
	if lod_manager:
		diagnostics.lod_system = lod_manager.get_diagnostics()
	
	return diagnostics

func reset_to_defaults():
	"""Reset all systems to default settings"""
	apply_rendering_preset("educational_enhanced")
	set_learning_level("intermediate")
	set_target_audience("medical_student")
	enable_clinical_focus(false)
	enable_pathology_visualization(false)
	
	# Reset individual managers
	if material_manager:
		material_manager.clear_material_cache()
	if lighting_manager:
		lighting_manager.reset_to_defaults()
	if post_processing_manager:
		post_processing_manager.reset_to_defaults()
	if lod_manager:
		lod_manager.reset_to_defaults()
	
	print("[ComprehensiveBrainRendering] Reset to defaults")

# === BRAIN MODEL MATERIAL APPLICATION ===

func apply_materials_to_brain_model(brain_model_node: Node3D, educational_context: Dictionary = {}):
	"""Apply medical-grade materials to brain model structures"""
	if not material_manager:
		push_error("[ComprehensiveBrainRendering] Material manager not initialized")
		return
	
	print("[ComprehensiveBrainRendering] Applying medical-grade materials to brain model...")
	
	# Apply educational context to material manager
	if not educational_context.is_empty():
		material_manager.apply_educational_context(educational_context)
	
	# Apply materials to brain structure recursively
	_apply_materials_recursive(brain_model_node)
	
	print("[ComprehensiveBrainRendering] Medical-grade materials applied successfully")

func _apply_materials_recursive(node: Node):
	"""Recursively apply appropriate materials to brain structures"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		var structure_name = node.name.to_lower()
		
		# Determine brain region type based on structure name
		var region_type = _determine_brain_region_type(structure_name)
		
		# Apply appropriate material
		var material = material_manager.get_material_for_region(region_type)
		if material:
			mesh_instance.material_override = material
			print("[ComprehensiveBrainRendering] Applied %s material to %s" % [region_type, node.name])
	
	# Process children recursively
	for child in node.get_children():
		_apply_materials_recursive(child)

func _determine_brain_region_type(structure_name: String) -> String:
	"""Determine appropriate brain tissue type based on structure name"""
	# Convert to lowercase for easier matching
	var structure_name_lower = structure_name.to_lower()
	
	# Blood vessels and vascular structures
	if "vessel" in structure_name_lower or "artery" in structure_name_lower or "vein" in structure_name_lower or "vascular" in structure_name_lower:
		return "blood_vessels"
	
	# Ventricular system and CSF spaces
	if "ventricle" in structure_name_lower or "csf" in structure_name_lower or "fluid" in structure_name_lower or "space" in structure_name_lower:
		return "cerebrospinal_fluid"
	
	# White matter structures
	if "corpus_callosum" in structure_name_lower or "white" in structure_name_lower or "fiber" in structure_name_lower or "tract" in structure_name_lower:
		return "white_matter"
	
	# Meningeal layers
	if "dura" in structure_name_lower or "meninges" in structure_name_lower or "membrane" in structure_name_lower:
		return "dura_mater"
	
	if "pia" in structure_name_lower:
		return "pia_mater"
	
	# Default to gray matter for most brain structures
	# (cortex, subcortical nuclei, etc.)
	return "gray_matter"