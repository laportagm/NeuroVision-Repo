## LOD Lighting Manager for NeuroVision
##
## Performance-optimized Level of Detail lighting system that adjusts
## lighting complexity based on distance, performance, and educational context.

class_name LODLightingManager
extends Node3D

# === SIGNALS ===
signal lod_level_changed(node: Node3D, old_level: int, new_level: int)
signal lighting_quality_adjusted(performance_fps: float, target_fps: float)
signal lod_system_optimized(total_lights: int, active_lights: int)

# === CONSTANTS ===
const LOD_LEVELS = {
	0: {  # Maximum detail - closest
		"description": "Maximum detail for close examination",
		"max_lights": 8,
		"shadow_lights": 3,
		"area_light_quality": "high",
		"shadow_resolution": 2048,
		"distance_threshold": 5.0
	},
	1: {  # High detail
		"description": "High detail for normal viewing",
		"max_lights": 6,
		"shadow_lights": 2,
		"area_light_quality": "medium",
		"shadow_resolution": 1024,
		"distance_threshold": 15.0
	},
	2: {  # Medium detail
		"description": "Medium detail for distant viewing",
		"max_lights": 4,
		"shadow_lights": 1,
		"area_light_quality": "low",
		"shadow_resolution": 512,
		"distance_threshold": 30.0
	},
	3: {  # Low detail - furthest
		"description": "Low detail for far distances",
		"max_lights": 2,
		"shadow_lights": 0,
		"area_light_quality": "disabled",
		"shadow_resolution": 256,
		"distance_threshold": float("inf")
	}
}

const PERFORMANCE_THRESHOLDS = {
	"excellent": {"min_fps": 60.0, "lod_bias": -1},  # Use higher quality
	"good": {"min_fps": 45.0, "lod_bias": 0},        # Normal quality
	"acceptable": {"min_fps": 30.0, "lod_bias": 1},  # Reduce quality
	"poor": {"min_fps": 20.0, "lod_bias": 2}         # Minimal quality
}

# === EXPORTS ===
@export_group("LOD Configuration")
@export var enabled: bool = true
@export var adaptive_performance: bool = true
@export var update_frequency: float = 0.1  # Update LOD every 100ms
@export var distance_bias: float = 1.0

@export_group("Performance Settings")
@export var target_fps: float = 60.0
@export var max_total_lights: int = 12
@export var shadow_distance_multiplier: float = 1.5
@export var emergency_optimization: bool = true

@export_group("Educational Context")
@export var learning_mode_bias: Dictionary = {
	"beginner": -1,     # Higher quality for beginners
	"intermediate": 0,  # Normal quality
	"advanced": 1       # Can tolerate lower quality
}

# === PRIVATE VARIABLES ===
var camera_3d: Camera3D
var brain_models: Array[Node3D] = []
var managed_lights: Dictionary = {}  # Node3D -> LODLightData
var performance_monitor = null
var medical_lighting_manager: MedicalGradeLightingManager

# Performance tracking
var frame_time_samples: Array[float] = []
var performance_category: String = "good"
var global_lod_bias: int = 0

# Update timing
var lod_update_timer: float = 0.0
var performance_check_timer: float = 0.0

# LOD data structure
class LODLightData:
	var node: Node3D
	var lights: Array[Light3D] = []
	var current_lod_level: int = 1
	var distance_to_camera: float = 0.0
	var base_light_settings: Array[Dictionary] = []
	var is_active: bool = true
	var educational_priority: bool = false
	
	func _init(target_node: Node3D):
		node = target_node

# === INITIALIZATION ===

func _ready():
	_initialize_lod_system()
	_connect_to_systems()
	_discover_brain_models()
	print("[LODLighting] LOD lighting manager initialized")

func _initialize_lod_system():
	"""Initialize the LOD lighting system"""
	camera_3d = get_viewport().get_camera_3d()
	if not camera_3d:
		push_error("[LODLighting] No 3D camera found")
		enabled = false
		return
	
	# Set up update timer
	lod_update_timer = 0.0
	performance_check_timer = 0.0

func _connect_to_systems():
	"""Connect to other rendering systems"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("UIThemeManager"):
		performance_monitor = tree.root.get_node("UIThemeManager")
		print("[LODLighting] Connected to performance monitoring")
	
	# Connect to medical lighting manager
	medical_lighting_manager = get_node_or_null("../MedicalGradeLightingManager")
	if medical_lighting_manager:
		print("[LODLighting] Connected to medical lighting manager")

func _discover_brain_models():
	"""Discover brain models in the scene for LOD management"""
	# Find all brain model nodes
	var scene_root = get_tree().current_scene
	_find_brain_models_recursive(scene_root)
	
	print("[LODLighting] Discovered %d brain models for LOD management" % brain_models.size())

func _find_brain_models_recursive(node: Node):
	"""Recursively find brain model nodes"""
	# Check if this node is a brain model (by name patterns or metadata)
	if _is_brain_model_node(node):
		brain_models.append(node)
		_register_brain_model_for_lod(node)
	
	# Check children
	for child in node.get_children():
		_find_brain_models_recursive(child)

func _is_brain_model_node(node: Node) -> bool:
	"""Check if a node is a brain model that should use LOD lighting"""
	if not node is Node3D:
		return false
	
	var node_name = node.name.to_lower()
	var brain_keywords = [
		"brain", "hippocampus", "amygdala", "thalamus", "striatum",
		"cerebellum", "brainstem", "cortex", "neuron"
	]
	
	for keyword in brain_keywords:
		if keyword in node_name:
			return true
	
	# Check metadata
	if node.has_meta("is_brain_model") and node.get_meta("is_brain_model"):
		return true
	
	return false

func _register_brain_model_for_lod(brain_node: Node3D):
	"""Register a brain model for LOD lighting management"""
	var lod_data = LODLightData.new(brain_node)
	
	# Find lights associated with this brain model
	_find_associated_lights(brain_node, lod_data)
	
	# Store base settings for all lights
	_store_base_light_settings(lod_data)
	
	# Check if this is educationally important
	lod_data.educational_priority = _is_educationally_important(brain_node)
	
	managed_lights[brain_node] = lod_data
	print("[LODLighting] Registered brain model: %s with %d lights" % [brain_node.name, lod_data.lights.size()])

func _find_associated_lights(brain_node: Node3D, lod_data: LODLightData):
	"""Find lights associated with a brain model"""
	# Method 1: Lights as children of the brain node
	_find_lights_in_children(brain_node, lod_data.lights)
	
	# Method 2: Lights that target this brain node (by name or proximity)
	_find_lights_by_proximity(brain_node, lod_data.lights)

func _find_lights_in_children(node: Node, lights_array: Array[Light3D]):
	"""Find lights in children of a node"""
	for child in node.get_children():
		if child is Light3D:
			lights_array.append(child)
		_find_lights_in_children(child, lights_array)

func _find_lights_by_proximity(brain_node: Node3D, lights_array: Array[Light3D]):
	"""Find lights by proximity to brain node"""
	var scene_root = get_tree().current_scene
	var all_lights = []
	_find_all_lights_recursive(scene_root, all_lights)
	
	var brain_position = brain_node.global_position
	var max_distance = 20.0  # Maximum distance to consider a light "associated"
	
	for light in all_lights:
		if light in lights_array:
			continue  # Already found
		
		var distance = brain_position.distance_to(light.global_position)
		if distance <= max_distance:
			lights_array.append(light)

func _find_all_lights_recursive(node: Node, lights_array: Array):
	"""Recursively find all lights in the scene"""
	if node is Light3D:
		lights_array.append(node)
	
	for child in node.get_children():
		_find_all_lights_recursive(child, lights_array)

func _store_base_light_settings(lod_data: LODLightData):
	"""Store base settings for all lights"""
	for light in lod_data.lights:
		var settings = {
			"energy": light.light_energy,
			"indirect_energy": light.light_indirect_energy,
			"range": 0.0,
			"shadow_enabled": light.shadow_enabled
		}
		
		# Store range for omni/spot lights
		if light is OmniLight3D:
			settings.range = light.omni_range
		elif light is SpotLight3D:
			settings.range = light.spot_range
		
		lod_data.base_light_settings.append(settings)

func _is_educationally_important(brain_node: Node3D) -> bool:
	"""Check if a brain model is educationally important"""
	# Check metadata
	if brain_node.has_meta("educational_priority"):
		return brain_node.get_meta("educational_priority")
	
	# Check name patterns for important structures
	var node_name = brain_node.name.to_lower()
	var important_structures = [
		"hippocampus", "amygdala", "prefrontal", "motor_cortex"
	]
	
	for structure in important_structures:
		if structure in node_name:
			return true
	
	return false

# === LOD UPDATE LOGIC ===

func _process(delta):
	"""Main LOD update loop"""
	if not enabled or not camera_3d:
		return
	
	lod_update_timer += delta
	performance_check_timer += delta
	
	# Update performance metrics
	if performance_check_timer >= 1.0:  # Check performance every second
		_update_performance_metrics()
		performance_check_timer = 0.0
	
	# Update LOD levels
	if lod_update_timer >= update_frequency:
		_update_lod_levels()
		lod_update_timer = 0.0

func _update_performance_metrics():
	"""Update performance metrics and adjust global LOD bias"""
	var current_fps = Engine.get_frames_per_second()
	frame_time_samples.append(current_fps)
	
	if frame_time_samples.size() > 10:
		frame_time_samples.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in frame_time_samples:
		avg_fps += fps
	avg_fps /= frame_time_samples.size()
	
	# Determine performance category
	var old_category = performance_category
	for category in PERFORMANCE_THRESHOLDS:
		if avg_fps >= PERFORMANCE_THRESHOLDS[category].min_fps:
			performance_category = category
			break
	
	# Update global LOD bias based on performance
	if adaptive_performance:
		var old_bias = global_lod_bias
		global_lod_bias = PERFORMANCE_THRESHOLDS[performance_category].lod_bias
		
		if old_bias != global_lod_bias or old_category != performance_category:
			print("[LODLighting] Performance: %s (%.1f fps), LOD bias: %d" % [performance_category, avg_fps, global_lod_bias])
			lighting_quality_adjusted.emit(avg_fps, target_fps)

func _update_lod_levels():
	"""Update LOD levels for all managed brain models"""
	var camera_position = camera_3d.global_position
	var active_lights = 0
	var total_lights = 0
	
	for brain_node in managed_lights:
		var lod_data = managed_lights[brain_node] as LODLightData
		if not lod_data or not is_instance_valid(lod_data.node):
			continue
		
		# Calculate distance to camera
		lod_data.distance_to_camera = camera_position.distance_to(brain_node.global_position)
		
		# Determine appropriate LOD level
		var new_lod_level = _calculate_lod_level(lod_data)
		
		# Apply LOD level if changed
		if new_lod_level != lod_data.current_lod_level:
			var old_level = lod_data.current_lod_level
			_apply_lod_level(lod_data, new_lod_level)
			lod_level_changed.emit(brain_node, old_level, new_lod_level)
		
		# Count active lights
		total_lights += lod_data.lights.size()
		if lod_data.is_active:
			active_lights += _count_active_lights(lod_data)
	
	# Emit optimization signal
	lod_system_optimized.emit(total_lights, active_lights)

func _calculate_lod_level(lod_data: LODLightData) -> int:
	"""Calculate appropriate LOD level for a brain model"""
	var distance = lod_data.distance_to_camera * distance_bias
	var base_lod = 0
	
	# Determine base LOD level from distance
	for level in LOD_LEVELS:
		if distance <= LOD_LEVELS[level].distance_threshold:
			base_lod = level
			break
		base_lod = level
	
	# Apply global performance bias
	var performance_adjusted_lod = base_lod + global_lod_bias
	
	# Apply educational priority bias
	if lod_data.educational_priority:
		performance_adjusted_lod -= 1  # Higher quality for important structures
	
	# Apply learning mode bias
	var learning_mode = _get_current_learning_mode()
	if learning_mode in learning_mode_bias:
		performance_adjusted_lod += learning_mode_bias[learning_mode]
	
	# Clamp to valid range
	return clamp(performance_adjusted_lod, 0, LOD_LEVELS.size() - 1)

func _apply_lod_level(lod_data: LODLightData, lod_level: int):
	"""Apply LOD level to a brain model's lighting"""
	lod_data.current_lod_level = lod_level
	var lod_settings = LOD_LEVELS[lod_level]
	
	# Limit number of active lights
	var max_lights = lod_settings.max_lights
	var shadow_lights = lod_settings.shadow_lights
	var current_light_count = 0
	var current_shadow_count = 0
	
	for i in range(lod_data.lights.size()):
		var light = lod_data.lights[i]
		var base_settings = lod_data.base_light_settings[i]
		
		if current_light_count < max_lights:
			# Light is active
			light.visible = true
			
			# Adjust light intensity based on LOD
			var intensity_multiplier = _get_lod_intensity_multiplier(lod_level)
			light.light_energy = base_settings.energy * intensity_multiplier
			light.light_indirect_energy = base_settings.indirect_energy * intensity_multiplier
			
			# Handle shadows
			if current_shadow_count < shadow_lights:
				light.shadow_enabled = base_settings.shadow_enabled
				_configure_shadow_quality(light, lod_settings)
				if light.shadow_enabled:
					current_shadow_count += 1
			else:
				light.shadow_enabled = false
			
			# Adjust range for omni/spot lights
			if light is OmniLight3D:
				light.omni_range = base_settings.range * _get_lod_range_multiplier(lod_level)
			elif light is SpotLight3D:
				light.spot_range = base_settings.range * _get_lod_range_multiplier(lod_level)
			
			current_light_count += 1
		else:
			# Light is disabled for this LOD level
			light.visible = false
			light.shadow_enabled = false
	
	lod_data.is_active = current_light_count > 0

func _get_lod_intensity_multiplier(lod_level: int) -> float:
	"""Get intensity multiplier for LOD level"""
	match lod_level:
		0: return 1.0      # Full intensity
		1: return 0.9      # Slight reduction
		2: return 0.7      # Moderate reduction
		3: return 0.5      # Significant reduction
		_: return 0.3      # Minimal

func _get_lod_range_multiplier(lod_level: int) -> float:
	"""Get range multiplier for LOD level"""
	match lod_level:
		0: return 1.0      # Full range
		1: return 0.8      # Slight reduction
		2: return 0.6      # Moderate reduction
		3: return 0.4      # Significant reduction
		_: return 0.2      # Minimal

func _configure_shadow_quality(light: Light3D, lod_settings: Dictionary):
	"""Configure shadow quality based on LOD settings"""
	var shadow_resolution = lod_settings.shadow_resolution
	
	if light is DirectionalLight3D:
		var directional_light = light as DirectionalLight3D
		# Adjust shadow splits based on resolution
		if shadow_resolution >= 2048:
			directional_light.directional_shadow_split_1 = 0.1
			directional_light.directional_shadow_split_2 = 0.3
			directional_light.directional_shadow_split_3 = 0.6
		elif shadow_resolution >= 1024:
			directional_light.directional_shadow_split_1 = 0.15
			directional_light.directional_shadow_split_2 = 0.35
			directional_light.directional_shadow_split_3 = 0.65
		else:
			directional_light.directional_shadow_split_1 = 0.2
			directional_light.directional_shadow_split_2 = 0.5
			directional_light.directional_shadow_split_3 = 0.8
	
	# Adjust shadow bias based on quality
	if shadow_resolution >= 1024:
		light.shadow_bias = 0.1
		light.shadow_normal_bias = 1.0
	else:
		light.shadow_bias = 0.2
		light.shadow_normal_bias = 2.0

func _count_active_lights(lod_data: LODLightData) -> int:
	"""Count active lights for a LOD data"""
	var count = 0
	for light in lod_data.lights:
		if light.visible:
			count += 1
	return count

func _get_current_learning_mode() -> String:
	"""Get current learning mode from educational systems"""
	# Try to get from medical lighting manager
	if medical_lighting_manager and medical_lighting_manager.has_method("get_learning_mode"):
		return medical_lighting_manager.learning_mode
	
	return "intermediate"  # Default

# === PUBLIC API ===

func register_brain_model(brain_node: Node3D, educational_priority: bool = false):
	"""Manually register a brain model for LOD management"""
	if brain_node in managed_lights:
		return
	
	brain_models.append(brain_node)
	_register_brain_model_for_lod(brain_node)
	
	var lod_data = managed_lights[brain_node]
	lod_data.educational_priority = educational_priority

func unregister_brain_model(brain_node: Node3D):
	"""Unregister a brain model from LOD management"""
	if brain_node in managed_lights:
		managed_lights.erase(brain_node)
		brain_models.erase(brain_node)

func set_educational_priority(brain_node: Node3D, priority: bool):
	"""Set educational priority for a brain model"""
	if brain_node in managed_lights:
		var lod_data = managed_lights[brain_node]
		lod_data.educational_priority = priority

func force_lod_level(brain_node: Node3D, lod_level: int):
	"""Force a specific LOD level for a brain model"""
	if brain_node in managed_lights:
		var lod_data = managed_lights[brain_node]
		_apply_lod_level(lod_data, clamp(lod_level, 0, LOD_LEVELS.size() - 1))

func set_distance_bias(bias: float):
	"""Set distance bias for LOD calculations"""
	distance_bias = clamp(bias, 0.1, 5.0)

func enable_emergency_optimization():
	"""Enable emergency optimization for very poor performance"""
	if emergency_optimization:
		global_lod_bias = 3  # Force minimal LOD
		print("[LODLighting] Emergency optimization enabled")

func disable_emergency_optimization():
	"""Disable emergency optimization"""
	global_lod_bias = PERFORMANCE_THRESHOLDS[performance_category].lod_bias
	print("[LODLighting] Emergency optimization disabled")

func get_lod_statistics() -> Dictionary:
	"""Get LOD system statistics"""
	var stats = {
		"total_brain_models": brain_models.size(),
		"managed_models": managed_lights.size(),
		"performance_category": performance_category,
		"global_lod_bias": global_lod_bias,
		"current_fps": Engine.get_frames_per_second(),
		"target_fps": target_fps,
		"lod_distribution": {},
		"total_lights": 0,
		"active_lights": 0
	}
	
	# Calculate LOD distribution
	for level in LOD_LEVELS:
		stats.lod_distribution[level] = 0
	
	for brain_node in managed_lights:
		var lod_data = managed_lights[brain_node]
		stats.lod_distribution[lod_data.current_lod_level] += 1
		stats.total_lights += lod_data.lights.size()
		if lod_data.is_active:
			stats.active_lights += _count_active_lights(lod_data)
	
	return stats

func get_diagnostics() -> Dictionary:
	"""Get detailed diagnostic information"""
	var diagnostics = get_lod_statistics()
	diagnostics.merge({
		"enabled": enabled,
		"adaptive_performance": adaptive_performance,
		"update_frequency": update_frequency,
		"distance_bias": distance_bias,
		"emergency_optimization": emergency_optimization,
		"learning_mode_bias": learning_mode_bias,
		"frame_time_samples": frame_time_samples.size()
	})
	
	return diagnostics

func reset_to_defaults():
	"""Reset LOD system to default settings"""
	enabled = true
	adaptive_performance = true
	update_frequency = 0.1
	distance_bias = 1.0
	global_lod_bias = 0
	performance_category = "good"
	print("[LODLighting] Reset to defaults")