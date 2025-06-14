extends Node

## Theme Effects Manager for NeuroVision
## Manages visual effects including glass morphism, transitions, and particle effects

# Signals
signal effect_applied(control: Control, effect_type: String)
signal transition_started(duration: float)
signal transition_completed()
signal particle_effect_spawned(position: Vector2, type: String)

# Preload shaders
const GLASS_MORPHISM_SHADER = preload("res://src/ui/effects/shaders/glass_morphism_ui.gdshader")
const THEME_TRANSITION_SHADER = preload("res://src/ui/effects/shaders/theme_transition.gdshader")

# Effect settings
var glass_morphism_settings = {
	"blur_amount": 8.0,
	"glass_opacity": 0.3,
	"tint_color": Color(1.0, 1.0, 1.0, 0.1),
	"noise_amount": 0.02,
	"saturation_boost": 1.2,
	"brightness": 1.1,
	"enable_chromatic_aberration": false,
	"aberration_amount": 0.003,
	"blur_quality": 2  # 1=low, 2=medium, 3=high
}

var transition_settings = {
	"default_duration": 0.3,
	"default_type": 0,  # 0=fade
	"transition_center": Vector2(0.5, 0.5),
	"ripple_frequency": 10.0,
	"pixelate_size": 20.0,
	"spiral_rotations": 2.0,
	"enable_glow": true,
	"glow_intensity": 0.5
}

# Active effects tracking
var _active_glass_effects: Dictionary = {}  # Control -> ShaderMaterial
var _active_transitions: Array = []
var _particle_pools: Dictionary = {}  # String -> Array[CPUParticles2D]

# === PUBLIC METHODS ===

## Apply glass morphism effect to a control
func apply_glass_morphism(control: Control, intensity: float = 0.5) -> void:
	"""Apply glass morphism shader to control with specified intensity"""
	if not control:
		push_error("[ThemeEffectsManager] Cannot apply glass morphism to null control")
		return
	
	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = GLASS_MORPHISM_SHADER
	
	# Apply settings with intensity adjustment
	shader_material.set_shader_parameter("blur_amount", glass_morphism_settings.blur_amount * intensity)
	shader_material.set_shader_parameter("glass_opacity", glass_morphism_settings.glass_opacity * intensity)
	shader_material.set_shader_parameter("tint_color", glass_morphism_settings.tint_color)
	shader_material.set_shader_parameter("noise_amount", glass_morphism_settings.noise_amount)
	shader_material.set_shader_parameter("saturation_boost", glass_morphism_settings.saturation_boost)
	shader_material.set_shader_parameter("brightness", glass_morphism_settings.brightness)
	shader_material.set_shader_parameter("enable_chromatic_aberration", glass_morphism_settings.enable_chromatic_aberration)
	shader_material.set_shader_parameter("aberration_amount", glass_morphism_settings.aberration_amount)
	shader_material.set_shader_parameter("blur_quality", glass_morphism_settings.blur_quality)
	
	# Apply to control
	control.material = shader_material
	_active_glass_effects[control] = shader_material
	
	effect_applied.emit(control, "glass_morphism")

## Remove glass morphism effect from a control
func remove_glass_morphism(control: Control) -> void:
	"""Remove glass morphism effect from control"""
	if control in _active_glass_effects:
		control.material = null
		_active_glass_effects.erase(control)

## Animate theme transition between two themes
func animate_theme_transition(from_theme: Theme, to_theme: Theme, duration: float = 0.3, transition_type: int = 0) -> void:
	"""Animate transition between two themes with configurable effect"""
	
	# Create transition overlay
	var transition_overlay = _create_transition_overlay()
	var tween = create_tween()
	
	transition_started.emit(duration)
	
	# Set up transition shader
	var shader_material = ShaderMaterial.new()
	shader_material.shader = THEME_TRANSITION_SHADER
	
	# Configure transition parameters
	shader_material.set_shader_parameter("transition_type", transition_type)
	shader_material.set_shader_parameter("transition_center", transition_settings.transition_center)
	shader_material.set_shader_parameter("ripple_frequency", transition_settings.ripple_frequency)
	shader_material.set_shader_parameter("pixelate_size", transition_settings.pixelate_size)
	shader_material.set_shader_parameter("spiral_rotations", transition_settings.spiral_rotations)
	shader_material.set_shader_parameter("enable_glow", transition_settings.enable_glow)
	shader_material.set_shader_parameter("glow_intensity", transition_settings.glow_intensity)
	
	# Extract representative colors from themes
	var from_color = _get_theme_primary_color(from_theme)
	var to_color = _get_theme_primary_color(to_theme)
	shader_material.set_shader_parameter("from_color", from_color)
	shader_material.set_shader_parameter("to_color", to_color)
	
	transition_overlay.material = shader_material
	
	# Animate transition progress
	tween.tween_method(
		func(progress: float):
			shader_material.set_shader_parameter("transition_progress", progress),
		0.0, 1.0, duration
	)
	
	# Clean up after transition
	tween.tween_callback(func():
		transition_overlay.queue_free()
		_active_transitions.erase(transition_overlay)
		transition_completed.emit()
	)
	
	_active_transitions.append(transition_overlay)

## Create selection particle effect
func create_selection_particles(position: Vector2, config: Dictionary = {}) -> void:
	"""Create particle effect for structure selection"""
	
	var default_config = {
		"particle_count": 30,
		"emission_shape": "sphere",
		"initial_velocity": 100.0,
		"angular_velocity": 45.0,
		"color": Color.CYAN,
		"lifetime": 1.0,
		"size": 4.0
	}
	
	# Merge with provided config
	for key in config:
		default_config[key] = config[key]
	
	var particles = _get_or_create_particles("selection")
	_configure_particles(particles, default_config)
	
	# Position and emit
	particles.global_position = position
	particles.emitting = true
	
	particle_effect_spawned.emit(position, "selection")

## Create success feedback particles
func create_success_particles(position: Vector2, intensity: float = 1.0) -> void:
	"""Create radial burst particle effect for success feedback"""
	
	var config = {
		"particle_count": 50,
		"emission_shape": "sphere",
		"initial_velocity": 200.0 * intensity,
		"angular_velocity": 90.0,
		"color": Color.GREEN,
		"lifetime": 0.5,
		"size": 6.0,
		"scale_curve": _create_fade_out_curve()
	}
	
	var particles = _get_or_create_particles("success")
	_configure_particles(particles, config)
	
	particles.global_position = position
	particles.emitting = true
	
	particle_effect_spawned.emit(position, "success")

## Update glass morphism quality settings
func set_glass_quality(quality_level: int) -> void:
	"""Set glass morphism quality level (1=low, 2=medium, 3=high)"""
	glass_morphism_settings.blur_quality = clamp(quality_level, 1, 3)
	
	# Update all active glass effects
	for control in _active_glass_effects:
		var material = _active_glass_effects[control] as ShaderMaterial
		if material:
			material.set_shader_parameter("blur_quality", glass_morphism_settings.blur_quality)

## Configure transition settings
func configure_transition(settings: Dictionary) -> void:
	"""Update transition settings"""
	for key in settings:
		if key in transition_settings:
			transition_settings[key] = settings[key]

## Apply hover glow effect
func apply_hover_glow(control: Control, color: Color = Color.CYAN, strength: float = 0.5) -> void:
	"""Apply animated glow effect for hover state"""
	
	# Create glow using a border with animated opacity
	if control is Panel or control is Button:
		var stylebox = control.get_theme_stylebox("normal", control.get_class())
		if stylebox is StyleBoxFlat:
			var glow_style = stylebox.duplicate()
			glow_style.border_color = color
			glow_style.border_width_left = 2
			glow_style.border_width_top = 2
			glow_style.border_width_right = 2
			glow_style.border_width_bottom = 2
			
			# Animate glow
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(glow_style, "border_color:a", strength, 1.0)
			tween.tween_property(glow_style, "border_color:a", strength * 0.5, 1.0)
			
			control.add_theme_stylebox_override("hover", glow_style)

## Create ripple effect at position
func create_ripple_effect(position: Vector2, color: Color = Color.WHITE, duration: float = 0.5) -> void:
	"""Create expanding ripple effect"""
	
	var ripple = Panel.new()
	ripple.size = Vector2(10, 10)
	ripple.position = position - ripple.size / 2
	ripple.modulate = color
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create circular style
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_left = 999
	style.corner_radius_bottom_right = 999
	style.bg_color = Color.TRANSPARENT
	style.border_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	
	ripple.add_theme_stylebox_override("panel", style)
	
	# Add to scene
	if get_viewport():
		get_viewport().add_child(ripple)
	
	# Animate ripple
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ripple, "size", Vector2(100, 100), duration)
	tween.tween_property(ripple, "position", position - Vector2(50, 50), duration)
	tween.tween_property(ripple, "modulate:a", 0.0, duration)
	
	tween.chain().tween_callback(ripple.queue_free)

# === PRIVATE METHODS ===

func _create_transition_overlay() -> ColorRect:
	"""Create fullscreen overlay for transitions"""
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color.TRANSPARENT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if get_viewport():
		get_viewport().add_child(overlay)
	
	return overlay

func _get_theme_primary_color(theme: Theme) -> Color:
	"""Extract primary color from theme"""
	# Try common color properties
	if theme.has_color("font_color", "Button"):
		return theme.get_color("font_color", "Button")
	elif theme.has_color("font_color", "Label"):
		return theme.get_color("font_color", "Label")
	else:
		return Color.WHITE

func _get_or_create_particles(pool_name: String) -> CPUParticles2D:
	"""Get particle instance from pool or create new one"""
	if not pool_name in _particle_pools:
		_particle_pools[pool_name] = []
	
	var pool = _particle_pools[pool_name]
	
	# Find inactive particle system
	for particles in pool:
		if particles and not particles.emitting:
			return particles
	
	# Create new particle system
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	
	if get_viewport():
		get_viewport().add_child(particles)
	
	pool.append(particles)
	return particles

func _configure_particles(particles: CPUParticles2D, config: Dictionary) -> void:
	"""Configure particle system with provided settings"""
	particles.amount = config.get("particle_count", 30)
	particles.lifetime = config.get("lifetime", 1.0)
	particles.one_shot = true
	
	# Emission shape
	match config.get("emission_shape", "sphere"):
		"sphere":
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
			particles.emission_sphere_radius = 5.0
		"box":
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(10, 10)
		"point":
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	
	# Velocity
	particles.initial_velocity_min = config.get("initial_velocity", 100.0) * 0.8
	particles.initial_velocity_max = config.get("initial_velocity", 100.0) * 1.2
	
	# Rotation
	particles.angular_velocity_min = -config.get("angular_velocity", 45.0)
	particles.angular_velocity_max = config.get("angular_velocity", 45.0)
	
	# Visual
	particles.color = config.get("color", Color.WHITE)
	particles.scale_amount_min = config.get("size", 4.0) * 0.8
	particles.scale_amount_max = config.get("size", 4.0) * 1.2
	
	# Apply curves if provided
	if "scale_curve" in config:
		particles.scale_amount_curve = config.scale_curve

func _create_fade_out_curve() -> Curve:
	"""Create a curve that fades from 1.0 to 0.0"""
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

# === PERFORMANCE MONITORING ===

func get_active_effects_count() -> Dictionary:
	"""Get count of active effects for performance monitoring"""
	return {
		"glass_morphism": _active_glass_effects.size(),
		"transitions": _active_transitions.size(),
		"particle_pools": _particle_pools.size(),
		"total_particles": _get_total_particle_count()
	}

func _get_total_particle_count() -> int:
	"""Count total particles across all pools"""
	var count = 0
	for pool_name in _particle_pools:
		count += _particle_pools[pool_name].size()
	return count

func cleanup_unused_effects() -> void:
	"""Clean up inactive effects to free memory"""
	# Clean up null controls from glass effects
	var to_remove = []
	for control in _active_glass_effects:
		if not is_instance_valid(control):
			to_remove.append(control)
	
	for control in to_remove:
		_active_glass_effects.erase(control)
	
	# Clean up completed transitions
	_active_transitions = _active_transitions.filter(func(t): return is_instance_valid(t))
	
	# Clean up excess particles
	for pool_name in _particle_pools:
		var pool = _particle_pools[pool_name]
		var active_count = 0
		
		for i in range(pool.size() - 1, -1, -1):
			var particles = pool[i]
			if not is_instance_valid(particles):
				pool.remove_at(i)
			elif particles.emitting:
				active_count += 1
		
		# Keep only a reasonable number of inactive particles
		while pool.size() - active_count > 5:
			var particles = pool.pop_back()
			if is_instance_valid(particles):
				particles.queue_free()
