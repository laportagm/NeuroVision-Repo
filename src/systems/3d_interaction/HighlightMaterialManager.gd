extends Node

## Highlight Material Manager
##
## Manages material instances and state transitions for structure highlighting.
## Provides optimized material switching with pooling and caching.

signal material_transition_started(mesh: MeshInstance3D, state: HighlightState)
signal material_transition_completed(mesh: MeshInstance3D, state: HighlightState)

# === ENUMS ===
enum HighlightState {
	IDLE,
	HOVERING,
	SELECTED,
	MULTI_SELECTED,
	FOCUSED,
	DISABLED
}

# === CONSTANTS ===
const TRANSITION_DURATION: float = 0.2
const HOVER_TRANSITION: float = 0.15
const PULSE_SPEED: float = 1.0
const CACHE_SIZE: int = 20

# State colors using M3DesignTokens
var STATE_COLORS: Dictionary = {}

# State rim intensities
const STATE_INTENSITIES: Dictionary = {
	HighlightState.IDLE: 0.0,
	HighlightState.HOVERING: 0.8,
	HighlightState.SELECTED: 1.2,
	HighlightState.MULTI_SELECTED: 1.0,
	HighlightState.FOCUSED: 1.5,
	HighlightState.DISABLED: 0.0
}

# === PRIVATE VARIABLES ===
var _rim_shader: Shader
var _material_pool: Array[Material] = []
var _active_materials: Dictionary = {}  # MeshInstance3D -> MaterialState
var _transition_tweens: Dictionary = {}  # MeshInstance3D -> Tween
var _original_materials: Dictionary = {}  # MeshInstance3D -> Array[Material]
var _fallback_material: Material

# Material state tracking
class MaterialState:
	var material: Material
	var current_state: HighlightState = HighlightState.IDLE
	var target_state: HighlightState = HighlightState.IDLE
	var transition_progress: float = 0.0
	var mesh_instance: MeshInstance3D

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[HighlightManager] Initializing material system")
	
	# Initialize state colors from M3DesignTokens
	_initialize_state_colors()
	
	# Check if running in headless mode
	var is_headless = OS.has_feature("headless") or DisplayServer.get_name() == "headless"
	if is_headless:
		print("[HighlightManager] Running in headless mode - shader features limited")
	
	_load_shaders()
	_initialize_material_pool()
	set_process(true)

func set_highlight_state(mesh: MeshInstance3D, state: HighlightState) -> void:
	"""Set the highlight state for a mesh"""
	if not mesh:
		return
	
	# Get or create material state
	var mat_state = _get_or_create_material_state(mesh)
	
	# Skip if already in target state
	if mat_state.target_state == state and mat_state.transition_progress >= 1.0:
		return
	
	# Update target state
	mat_state.target_state = state
	mat_state.transition_progress = 0.0
	
	# Start transition
	_start_transition(mesh, mat_state)
	material_transition_started.emit(mesh, state)

func remove_highlight(mesh: MeshInstance3D) -> void:
	"""Remove highlighting from a mesh and restore original materials"""
	if not mesh or not mesh in _active_materials:
		return
	
	# Stop any active transition
	if mesh in _transition_tweens:
		_transition_tweens[mesh].kill()
		_transition_tweens.erase(mesh)
	
	# Restore original materials
	if mesh in _original_materials:
		for i in range(mesh.get_surface_override_material_count()):
			if i < _original_materials[mesh].size():
				mesh.set_surface_override_material(i, _original_materials[mesh][i])
		_original_materials.erase(mesh)
	
	# Return material to pool
	var mat_state = _active_materials[mesh]
	if mat_state.material:
		_return_to_pool(mat_state.material)
	
	_active_materials.erase(mesh)

func get_current_state(mesh: MeshInstance3D) -> HighlightState:
	"""Get the current highlight state of a mesh"""
	if mesh in _active_materials:
		return _active_materials[mesh].current_state
	return HighlightState.IDLE

func is_transitioning(mesh: MeshInstance3D) -> bool:
	"""Check if a mesh is currently transitioning"""
	return mesh in _transition_tweens and _transition_tweens[mesh].is_running()

# === PRIVATE METHODS ===

func _initialize_state_colors() -> void:
	"""Initialize state colors from M3DesignTokens"""
	STATE_COLORS = {
		HighlightState.IDLE: UnifiedColorSystem.get_color("surface_variant"),
		HighlightState.HOVERING: UnifiedColorSystem.get_color("primary"),
		HighlightState.SELECTED: UnifiedColorSystem.get_color("tertiary"),
		HighlightState.MULTI_SELECTED: UnifiedColorSystem.get_color("secondary"),
		HighlightState.FOCUSED: UnifiedColorSystem.get_color("primary_container"),
		HighlightState.DISABLED: UnifiedColorSystem.get_color("on_surface_variant").darkened(0.5)
	}

func _load_shaders() -> void:
	"""Load shader resources"""
	# Try to load the shader
	var shader_path = "res://assets/shaders/structure_highlight/fresnel_rim.gdshader"
	
	# In headless mode, we might need to use a fallback approach
	if OS.has_feature("headless") or DisplayServer.get_name() == "headless":
		# For headless mode, we'll create materials without shaders
		# They won't render, but won't crash either
		print("[HighlightManager] Headless mode - using fallback materials")
		_rim_shader = null
		return
	
	_rim_shader = load(shader_path)
	if not _rim_shader:
		push_error("[HighlightManager] Failed to load rim shader from: " + shader_path)
	else:
		print("[HighlightManager] Shader loaded successfully")

func _initialize_material_pool() -> void:
	"""Pre-create materials for pooling"""
	var is_headless = OS.has_feature("headless") or DisplayServer.get_name() == "headless"
	
	for i in range(CACHE_SIZE):
		var mat: Material
		
		if is_headless or not _rim_shader:
			# Use StandardMaterial3D as fallback for headless mode
			var std_mat = StandardMaterial3D.new()
			std_mat.emission_enabled = true
			std_mat.emission = UnifiedColorSystem.get_color("primary")
			std_mat.emission_energy_multiplier = 0.5
			std_mat.rim_enabled = true
			std_mat.rim = 1.0
			std_mat.rim_tint = 0.5
			mat = std_mat
		else:
			# Use shader material in normal mode
			var shader_mat = ShaderMaterial.new()
			shader_mat.shader = _rim_shader
			mat = shader_mat
		
		_material_pool.append(mat)
	
	print("[HighlightManager] Created material pool with %d materials" % _material_pool.size())

func _get_from_pool() -> Material:
	"""Get a material from the pool"""
	var is_headless = OS.has_feature("headless") or DisplayServer.get_name() == "headless"
	
	if _material_pool.is_empty():
		# Create new if pool is empty
		if is_headless or not _rim_shader:
			var std_mat = StandardMaterial3D.new()
			std_mat.emission_enabled = true
			std_mat.emission = UnifiedColorSystem.get_color("primary")
			std_mat.emission_energy_multiplier = 0.5
			std_mat.rim_enabled = true
			std_mat.rim = 1.0
			std_mat.rim_tint = 0.5
			return std_mat
		else:
			var shader_mat = ShaderMaterial.new()
			shader_mat.shader = _rim_shader
			return shader_mat
	
	return _material_pool.pop_back()

func _return_to_pool(material: Material) -> void:
	"""Return a material to the pool"""
	if _material_pool.size() < CACHE_SIZE:
		# Reset material to default state
		if material is ShaderMaterial:
			material.set_shader_parameter("rim_intensity", 0.0)
			material.set_shader_parameter("rim_color", UnifiedColorSystem.get_color("on_primary"))
		elif material is StandardMaterial3D:
			material.emission_energy_multiplier = 0.0
			material.albedo_color = UnifiedColorSystem.get_color("on_primary")
		_material_pool.append(material)

func _get_or_create_material_state(mesh: MeshInstance3D) -> MaterialState:
	"""Get existing or create new material state for a mesh"""
	if mesh in _active_materials:
		return _active_materials[mesh]
	
	# Store original materials
	if not mesh in _original_materials:
		_original_materials[mesh] = []
		for i in range(mesh.get_surface_override_material_count()):
			_original_materials[mesh].append(mesh.get_surface_override_material(i))
	
	# Create new material state
	var mat_state = MaterialState.new()
	mat_state.material = _get_from_pool()
	mat_state.mesh_instance = mesh
	_active_materials[mesh] = mat_state
	
	# Apply material to all surfaces
	if mesh.mesh:
		var surface_count = mesh.mesh.get_surface_count()
		if surface_count == 0:
			# Some meshes report 0 surfaces but still have 1
			mesh.set_surface_override_material(0, mat_state.material)
		else:
			for i in range(surface_count):
				mesh.set_surface_override_material(i, mat_state.material)
	
	return mat_state

func _start_transition(mesh: MeshInstance3D, mat_state: MaterialState) -> void:
	"""Start a material transition"""
	# Kill existing tween if any
	if mesh in _transition_tweens:
		_transition_tweens[mesh].kill()
	
	# Create new tween
	var tween = create_tween()
	_transition_tweens[mesh] = tween
	
	# Get transition duration based on state
	var duration = HOVER_TRANSITION if mat_state.target_state == HighlightState.HOVERING else TRANSITION_DURATION
	
	# Tween the transition progress
	tween.tween_method(
		_update_material_transition.bind(mat_state),
		0.0,
		1.0,
		duration
	)
	
	# Cleanup on completion
	tween.finished.connect(_on_transition_complete.bind(mesh, mat_state))

func _update_material_transition(progress: float, mat_state: MaterialState) -> void:
	"""Update material parameters during transition"""
	mat_state.transition_progress = progress
	
	# Interpolate between states
	var from_color = STATE_COLORS[mat_state.current_state]
	var to_color = STATE_COLORS[mat_state.target_state]
	var from_intensity = STATE_INTENSITIES[mat_state.current_state]
	var to_intensity = STATE_INTENSITIES[mat_state.target_state]
	
	# Apply easing
	var eased_progress = ease(progress, -1.5)  # Ease in-out
	
	# Update material parameters based on type
	var material = mat_state.material
	
	if material is ShaderMaterial:
		# Update shader parameters
		material.set_shader_parameter("rim_color", from_color.lerp(to_color, eased_progress))
		material.set_shader_parameter("rim_intensity", lerp(from_intensity, to_intensity, eased_progress))
		material.set_shader_parameter("rim_power", 2.0)
		material.set_shader_parameter("rim_blend", 0.8)
		
		# Add pulse animation for selected states
		if mat_state.target_state in [HighlightState.SELECTED, HighlightState.FOCUSED]:
			material.set_shader_parameter("pulse_speed", PULSE_SPEED)
			material.set_shader_parameter("pulse_amplitude", 0.2 * eased_progress)
		else:
			material.set_shader_parameter("pulse_amplitude", 0.0)
			
	elif material is StandardMaterial3D:
		# Update standard material properties for fallback
		var blended_color = from_color.lerp(to_color, eased_progress)
		var blended_intensity = lerp(from_intensity, to_intensity, eased_progress)
		
		material.albedo_color = blended_color
		material.emission = blended_color
		material.emission_energy_multiplier = blended_intensity * 0.5
		
		# Use rim for edge highlighting
		if blended_intensity > 0.1:
			material.rim_enabled = true
			material.rim = blended_intensity
			material.rim_tint = 0.5
		else:
			material.rim_enabled = false

func _on_transition_complete(mesh: MeshInstance3D, mat_state: MaterialState) -> void:
	"""Handle transition completion"""
	mat_state.current_state = mat_state.target_state
	mat_state.transition_progress = 1.0
	
	# Remove tween reference
	if mesh in _transition_tweens:
		_transition_tweens.erase(mesh)
	
	material_transition_completed.emit(mesh, mat_state.current_state)
	
	# If idle, consider removing highlight entirely
	if mat_state.current_state == HighlightState.IDLE:
		remove_highlight(mesh)

func _process(_delta: float) -> void:
	"""Update any ongoing material animations"""
	# This can be used for continuous effects like pulsing
	# Currently handled by the shader itself
	pass

# === DEBUG METHODS ===

func get_active_highlight_count() -> int:
	"""Get number of actively highlighted meshes"""
	return _active_materials.size()

func get_pool_size() -> int:
	"""Get current material pool size"""
	return _material_pool.size()

func debug_print_state() -> void:
	"""Print debug information"""
	print("[HighlightManager] Debug Info:")
	print("  Active highlights: ", get_active_highlight_count())
	print("  Pool size: ", get_pool_size())
	print("  Active transitions: ", _transition_tweens.size())

func _exit_tree() -> void:
	"""Clean up resources to prevent RID leaks"""
	print("[HighlightManager] Cleaning up materials...")
	
	# Clean up all active materials
	for mesh in _active_materials:
		if is_instance_valid(mesh):
			remove_highlight(mesh)
	_active_materials.clear()
	
	# Clean up material pool
	for material in _material_pool:
		if is_instance_valid(material):
			# Materials are resources, not nodes - just clear the reference
			pass
	_material_pool.clear()
	
	# Clean up fallback material
	if is_instance_valid(_fallback_material):
		# Materials are resources, not nodes - just clear the reference
		_fallback_material = null
	
	# Stop all tweens
	for tween in _transition_tweens.values():
		if is_instance_valid(tween):
			tween.kill()
	_transition_tweens.clear()
	
	print("[HighlightManager] Cleanup complete")
