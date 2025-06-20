class_name SelectionFeedbackManager
extends Node

## Manages visual and audio feedback for structure selection in the educational platform
##
## This system provides clear, immediate feedback when students interact with brain structures,
## improving the learning experience through multiple sensory channels.

# === CONSTANTS ===
const SELECTION_SOUND_PATH = "res://assets/audio/ui/selection_confirm.ogg"
const HOVER_SOUND_PATH = "res://assets/audio/ui/hover_soft.ogg"
const DESELECT_SOUND_PATH = "res://assets/audio/ui/deselect.ogg"
const ERROR_SOUND_PATH = "res://assets/audio/ui/error_soft.ogg"

# Visual feedback durations from M3 design tokens
static func _get_feedback_duration() -> float:
	return M3DesignTokens.M3_DURATION["medium2"] / 1000.0

static func _get_pulse_duration() -> float:
	return M3DesignTokens.M3_DURATION["long2"] / 1000.0

# === EXPORTS ===
@export_group("Audio Settings")
@export var enable_audio_feedback: bool = true
@export_range(0.0, 1.0) var master_volume: float = 0.7
@export_range(0.0, 1.0) var selection_volume: float = 0.8
@export_range(0.0, 1.0) var hover_volume: float = 0.5

@export_group("Visual Settings")
@export var enable_visual_feedback: bool = true
@export var selection_pulse_count: int = 2
@export var selection_pulse_scale: float = 1.15
@export var hover_glow_intensity: float = 0.3

@export_group("Haptic Settings")
@export var enable_haptic_feedback: bool = true
@export var selection_haptic_strength: float = 0.8
@export var hover_haptic_strength: float = 0.3

# === NODES ===
var _audio_player: AudioStreamPlayer
var _hover_audio_player: AudioStreamPlayer
var _selection_indicator: Node3D
var _active_tweens: Dictionary = {}  # mesh_instance -> Tween

# === PRIVATE VARIABLES ===
var _audio_cache: Dictionary = {}
var _last_hover_time: float = 0.0
var _hover_cooldown: float = 0.1  # Prevent spam

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize feedback systems"""
	_setup_audio_players()
	_preload_audio_resources()
	_create_selection_indicator()
	
	# Connect to accessibility settings if available
	if has_node("/root/AccessibilityManager"):
		var accessibility = get_node_or_null("/root/AccessibilityManager")
		if accessibility.has_signal("audio_cues_changed"):
			accessibility.audio_cues_changed.connect(_on_audio_cues_changed)

func provide_selection_feedback(mesh_instance: MeshInstance3D, structure_name: String) -> void:
	"""Provide comprehensive feedback for structure selection"""
	if not mesh_instance:
		return
	
	print("[SelectionFeedback] Providing feedback for: ", structure_name)
	
	# Visual feedback
	if enable_visual_feedback:
		_create_selection_pulse(mesh_instance)
		_show_selection_indicator(mesh_instance)
	
	# Audio feedback
	if enable_audio_feedback:
		_play_selection_sound()
	
	# Haptic feedback (if available)
	if enable_haptic_feedback:
		_trigger_haptic_feedback(selection_haptic_strength)
	
	# Accessibility announcement
	_announce_selection(structure_name)

func provide_hover_feedback(mesh_instance: MeshInstance3D, _structure_name: String) -> void:
	"""Provide subtle feedback for structure hovering"""
	if not mesh_instance:
		return
	
	# Throttle hover feedback
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_hover_time < _hover_cooldown:
		return
	_last_hover_time = current_time
	
	# Visual feedback
	if enable_visual_feedback:
		_create_hover_glow(mesh_instance)
	
	# Audio feedback (subtle)
	if enable_audio_feedback:
		_play_hover_sound()
	
	# Light haptic feedback
	if enable_haptic_feedback:
		_trigger_haptic_feedback(hover_haptic_strength)

func provide_deselection_feedback(mesh_instance: MeshInstance3D) -> void:
	"""Provide feedback when structure is deselected"""
	if not mesh_instance:
		return
	
	# Stop any active animations
	_stop_mesh_animations(mesh_instance)
	
	# Audio feedback
	if enable_audio_feedback:
		_play_deselect_sound()
	
	# Hide selection indicator
	if _selection_indicator:
		_selection_indicator.visible = false

func provide_error_feedback(message: String = "") -> void:
	"""Provide feedback for selection errors"""
	# Audio feedback
	if enable_audio_feedback:
		_play_error_sound()
	
	# Visual screen shake (subtle)
	if enable_visual_feedback and get_viewport():
		_create_error_shake()
	
	# Accessibility announcement
	if not message.is_empty():
		_announce_error(message)

func clear_all_feedback() -> void:
	"""Clear all active feedback effects"""
	# Stop all tweens
	for mesh in _active_tweens:
		if _active_tweens[mesh] and is_instance_valid(_active_tweens[mesh]):
			_active_tweens[mesh].kill()
	_active_tweens.clear()
	
	# Hide indicators
	if _selection_indicator:
		_selection_indicator.visible = false

# === PRIVATE METHODS ===

func _setup_audio_players() -> void:
	"""Setup audio stream players for feedback"""
	# Main selection audio
	_audio_player = AudioStreamPlayer.new()
	_audio_player.bus = "UI"
	_audio_player.volume_db = linear_to_db(master_volume * selection_volume)
	add_child(_audio_player)
	
	# Hover audio (can overlap)
	_hover_audio_player = AudioStreamPlayer.new()
	_hover_audio_player.bus = "UI"
	_hover_audio_player.volume_db = linear_to_db(master_volume * hover_volume)
	add_child(_hover_audio_player)

func _preload_audio_resources() -> void:
	"""Preload audio files for instant playback"""
	var audio_files = {
		"selection": SELECTION_SOUND_PATH,
		"hover": HOVER_SOUND_PATH,
		"deselect": DESELECT_SOUND_PATH,
		"error": ERROR_SOUND_PATH
	}
	
	for key in audio_files:
		if ResourceLoader.exists(audio_files[key]):
			_audio_cache[key] = load(audio_files[key])
		else:
			# Create placeholder sound if file doesn't exist
			_audio_cache[key] = _create_placeholder_sound(key)

func _create_placeholder_sound(_type: String) -> AudioStream:
	"""Create a simple procedural sound as placeholder"""
	# In production, you'd have actual audio files
	# This is just to prevent errors during development
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	stream.buffer_length = 0.1
	return stream

func _create_selection_indicator() -> void:
	"""Create 3D selection indicator"""
	_selection_indicator = Node3D.new()
	_selection_indicator.name = "SelectionIndicator"
	
	# Create multiple ring meshes for animated effect
	for i in range(3):
		var ring = _create_selection_ring(i)
		_selection_indicator.add_child(ring)
	
	_selection_indicator.visible = false
	add_child(_selection_indicator)

func _create_selection_ring(index: int) -> MeshInstance3D:
	"""Create a single selection ring"""
	var ring = MeshInstance3D.new()
	ring.name = "Ring" + str(index)
	
	# Create torus mesh
	var torus = TorusMesh.new()
	torus.inner_radius = 0.8 + (index * 0.1)
	torus.outer_radius = 1.0 + (index * 0.1)
	torus.ring_segments = 32
	torus.rings = 8
	ring.mesh = torus
	
	# Create material with M3 colors
	var material = StandardMaterial3D.new()
	material.albedo_color = M3DesignTokens.get_color("primary")
	material.emission_enabled = true
	material.emission = M3DesignTokens.get_color("primary")
	material.emission_energy_multiplier = 0.5 - (index * 0.1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8 - (index * 0.2)
	ring.material_override = material
	
	return ring

func _create_selection_pulse(mesh_instance: MeshInstance3D) -> void:
	"""Create pulsing animation for selected mesh"""
	# Stop any existing animation
	_stop_mesh_animations(mesh_instance)
	
	# Create new tween
	var tween = create_tween()
	tween.set_loops(selection_pulse_count)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var original_scale = mesh_instance.scale
	var pulse_scale = original_scale * selection_pulse_scale
	
	var pulse_duration = _get_pulse_duration()
	tween.tween_property(mesh_instance, "scale", pulse_scale, pulse_duration * 0.3)
	tween.tween_property(mesh_instance, "scale", original_scale, pulse_duration * 0.7)
	
	_active_tweens[mesh_instance] = tween

func _show_selection_indicator(_mesh_instance: MeshInstance3D) -> void:
	"""Show and animate selection indicator at mesh position"""
	# Selection indicator disabled - no visual rings shown
	# This removes the blue blur ring that appears after right-clicking
	return
	
	# Original code commented out to remove visual rings
	# if not _selection_indicator:
	# 	return
	# 
	# _selection_indicator.visible = true
	# _selection_indicator.global_position = mesh_instance.global_position
	# 
	# # Animate rings
	# for i in range(_selection_indicator.get_child_count()):
	# 	var ring = _selection_indicator.get_child(i)
	# 	if ring is MeshInstance3D:
	# 		_animate_selection_ring(ring, i)

func _animate_selection_ring(ring: MeshInstance3D, _index: int) -> void:
	"""Animate individual selection ring"""
	# Disabled spinning animation - rings now remain static
	# var tween = create_tween()
	# tween.set_loops()
	# tween.set_trans(Tween.TRANS_LINEAR)
	# 
	# var rotation_speed = 1.0 + (index * 0.5)
	# var duration = 2.0 / rotation_speed
	# 
	# tween.tween_property(ring, "rotation:y", TAU, duration).from(0.0)
	
	# Optional: Add a subtle pulse animation instead of spinning
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(ring, "scale", Vector3.ONE * 1.1, 1.0)
	tween.tween_property(ring, "scale", Vector3.ONE, 1.0)

func _create_hover_glow(mesh_instance: MeshInstance3D) -> void:
	"""Create subtle glow effect for hovered mesh"""
	# This would ideally use a shader for rim lighting
	# For now, we'll use a simple emission boost
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	var duration = _get_feedback_duration()
	
	# Store original emission values and boost them
	var has_tweeners = false
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if material and material is StandardMaterial3D:
			var std_material = material as StandardMaterial3D
			if std_material.emission_enabled:
				var original_emission = std_material.emission_energy_multiplier
				var target_emission = original_emission + hover_glow_intensity
				tween.tween_property(std_material, "emission_energy_multiplier", target_emission, duration * 0.3)
				has_tweeners = true
	
	# If no tweeners were added, kill the tween to prevent errors
	if not has_tweeners:
		tween.kill()

func _create_error_shake() -> void:
	"""Create subtle screen shake for errors"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	var original_fov = camera.fov
	var shake_amount = 0.5
	
	tween.tween_property(camera, "fov", original_fov + shake_amount, 0.05)
	tween.tween_property(camera, "fov", original_fov - shake_amount, 0.05)
	tween.tween_property(camera, "fov", original_fov, 0.05)

func _stop_mesh_animations(mesh_instance: MeshInstance3D) -> void:
	"""Stop all animations for a mesh"""
	if mesh_instance in _active_tweens:
		if _active_tweens[mesh_instance] and is_instance_valid(_active_tweens[mesh_instance]):
			_active_tweens[mesh_instance].kill()
		_active_tweens.erase(mesh_instance)

func _play_selection_sound() -> void:
	"""Play selection confirmation sound"""
	if "selection" in _audio_cache and _audio_player:
		_audio_player.stream = _audio_cache["selection"]
		_audio_player.play()

func _play_hover_sound() -> void:
	"""Play hover sound"""
	if "hover" in _audio_cache and _hover_audio_player:
		_hover_audio_player.stream = _audio_cache["hover"]
		_hover_audio_player.play()

func _play_deselect_sound() -> void:
	"""Play deselection sound"""
	if "deselect" in _audio_cache and _audio_player:
		_audio_player.stream = _audio_cache["deselect"]
		_audio_player.play()

func _play_error_sound() -> void:
	"""Play error sound"""
	if "error" in _audio_cache and _audio_player:
		_audio_player.stream = _audio_cache["error"]
		_audio_player.play()

func _trigger_haptic_feedback(_strength: float) -> void:
	"""Trigger haptic feedback if available"""
	# This would integrate with platform-specific haptic APIs
	# For now, we'll just log it
	if OS.has_feature("mobile") or OS.has_feature("web"):
		# Would call platform-specific haptic API here
		pass

func _announce_selection(structure_name: String) -> void:
	"""Announce selection for accessibility"""
	if has_node("/root/AccessibilityManager"):
		var accessibility = get_node_or_null("/root/AccessibilityManager")
		if accessibility.has_method("announce"):
			accessibility.announce("Selected: " + structure_name)

func _announce_error(message: String) -> void:
	"""Announce error for accessibility"""
	if has_node("/root/AccessibilityManager"):
		var accessibility = get_node_or_null("/root/AccessibilityManager")
		if accessibility.has_method("announce"):
			accessibility.announce("Error: " + message)

func _on_audio_cues_changed(enabled: bool) -> void:
	"""Handle accessibility audio cue changes"""
	enable_audio_feedback = enabled
