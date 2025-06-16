## AnimationManager.gd
## Centralized animation management system for NeuroVision
##
## This manager handles:
## - UI animation orchestration
## - Animation presets and templates
## - Transition coordination
## - Performance optimization
## - Accessibility considerations (reduced motion)
## - Animation queuing and sequencing

class_name AnimationManager
extends Node

# === SIGNALS ===
signal animation_started(animation_id: String)
signal animation_completed(animation_id: String)
signal animation_cancelled(animation_id: String)
signal queue_updated(queue_size: int)
signal performance_warning(fps: float)

# === CONSTANTS ===
const DEFAULT_DURATION := 0.3
const DEFAULT_EASING := Tween.EASE_IN_OUT
const DEFAULT_TRANSITION := Tween.TRANS_CUBIC
const MIN_FPS_WARNING := 30.0
const MAX_CONCURRENT_ANIMATIONS := 10

# Animation preset durations (Material 3 based)
const DURATION_PRESETS = {
	"instant": 0.0,
	"short1": 0.05,
	"short2": 0.1,
	"short3": 0.15,
	"short4": 0.2,
	"medium1": 0.25,
	"medium2": 0.3,
	"medium3": 0.35,
	"medium4": 0.4,
	"long1": 0.45,
	"long2": 0.5,
	"long3": 0.55,
	"long4": 0.6,
	"extra_long1": 0.7,
	"extra_long2": 0.8,
	"extra_long3": 0.9,
	"extra_long4": 1.0
}

# === ENUMS ===
enum AnimationType {
	FADE,
	SLIDE,
	SCALE,
	ROTATE,
	COLOR,
	CUSTOM
}

enum AnimationPriority {
	LOW = 0,
	NORMAL = 1,
	HIGH = 2,
	CRITICAL = 3
}

enum QueueMode {
	PARALLEL,     # Run animations simultaneously
	SEQUENTIAL,   # Run one after another
	STAGGERED     # Run with delay between each
}

# === PRIVATE VARIABLES ===
# Animation tracking
var _active_animations: Dictionary = {}  # animation_id: AnimationData
var _animation_queue: Array[AnimationData] = []
var _animation_counter: int = 0

# Performance monitoring
var _fps_monitor: Timer
var _recent_fps: Array[float] = []
var _performance_mode: bool = false

# Settings
var _global_time_scale: float = 1.0
var _reduce_motion: bool = false
var _enable_animations: bool = true

# Presets
var _animation_presets: Dictionary = {}
var _easing_curves: Dictionary = {}

# === INNER CLASSES ===

class AnimationData:
	var id: String
	var node: Node
	var type: AnimationType
	var properties: Dictionary = {}
	var duration: float
	var delay: float = 0.0
	var easing: Tween.EaseType
	var transition: Tween.TransitionType
	var priority: AnimationPriority
	var callback: Callable
	var tween: Tween
	var start_time: float
	var is_looping: bool = false
	var loop_count: int = -1  # -1 for infinite

class AnimationPreset:
	var name: String
	var type: AnimationType
	var duration: float
	var easing: Tween.EaseType
	var transition: Tween.TransitionType
	var properties: Dictionary = {}
	
	func apply_to_data(data: AnimationData) -> void:
		data.type = type
		data.duration = duration
		data.easing = easing
		data.transition = transition
		data.properties = properties.duplicate()

# === INITIALIZATION ===

func _ready() -> void:
	_setup_fps_monitoring()
	_register_default_presets()
	_load_user_preferences()
	print("[AnimationManager] Animation system initialized")

func _setup_fps_monitoring() -> void:
	"""Set up FPS monitoring for performance management"""
	_fps_monitor = Timer.new()
	_fps_monitor.wait_time = 0.1
	_fps_monitor.timeout.connect(_check_performance)
	add_child(_fps_monitor)
	_fps_monitor.start()

func _register_default_presets() -> void:
	"""Register default animation presets"""
	# Fade animations
	register_preset("fade_in", _create_fade_preset(0.0, 1.0, "medium2"))
	register_preset("fade_out", _create_fade_preset(1.0, 0.0, "medium2"))
	
	# Slide animations
	register_preset("slide_in_left", _create_slide_preset(Vector2(-100, 0), Vector2.ZERO, "medium3"))
	register_preset("slide_in_right", _create_slide_preset(Vector2(100, 0), Vector2.ZERO, "medium3"))
	register_preset("slide_in_top", _create_slide_preset(Vector2(0, -100), Vector2.ZERO, "medium3"))
	register_preset("slide_in_bottom", _create_slide_preset(Vector2(0, 100), Vector2.ZERO, "medium3"))
	
	# Scale animations
	register_preset("scale_in", _create_scale_preset(Vector2(0.8, 0.8), Vector2(1.0, 1.0), "medium2"))
	register_preset("scale_out", _create_scale_preset(Vector2(1.0, 1.0), Vector2(0.8, 0.8), "medium2"))
	register_preset("bounce_in", _create_scale_preset(Vector2(0.3, 0.3), Vector2(1.0, 1.0), "medium4", Tween.TRANS_ELASTIC))
	
	# Material 3 emphasis animations
	register_preset("emphasis_pulse", _create_emphasis_preset("pulse", "short4"))
	register_preset("emphasis_shake", _create_emphasis_preset("shake", "short3"))
	
	# Page transitions
	register_preset("page_enter", _create_page_transition_preset(true))
	register_preset("page_exit", _create_page_transition_preset(false))

# === PUBLIC API ===

## Animation Creation

func animate(node: Node, properties: Dictionary, duration: float = DEFAULT_DURATION) -> String:
	"""Animate node properties with automatic type detection"""
	var anim_data = AnimationData.new()
	anim_data.id = _generate_animation_id()
	anim_data.node = node
	anim_data.type = AnimationType.CUSTOM
	anim_data.properties = properties
	anim_data.duration = duration * _global_time_scale
	anim_data.easing = DEFAULT_EASING
	anim_data.transition = DEFAULT_TRANSITION
	anim_data.priority = AnimationPriority.NORMAL
	
	return _start_animation(anim_data)

func animate_with_preset(node: Node, preset_name: String, overrides: Dictionary = {}) -> String:
	"""Animate using a preset with optional property overrides"""
	if not _animation_presets.has(preset_name):
		push_error("[AnimationManager] Unknown preset: %s" % preset_name)
		return ""
	
	var preset: AnimationPreset = _animation_presets[preset_name]
	var anim_data = AnimationData.new()
	anim_data.id = _generate_animation_id()
	anim_data.node = node
	
	preset.apply_to_data(anim_data)
	
	# Apply overrides
	for key in overrides:
		if key in anim_data.properties:
			anim_data.properties[key] = overrides[key]
	
	return _start_animation(anim_data)

func fade(node: Node, target_alpha: float, duration: float = DEFAULT_DURATION) -> String:
	"""Fade node to target alpha"""
	return animate(node, {"modulate:a": target_alpha}, duration)

func slide(node: Node, target_position: Vector2, duration: float = DEFAULT_DURATION) -> String:
	"""Slide node to target position"""
	return animate(node, {"position": target_position}, duration)

func scale(node: Node, target_scale: Vector2, duration: float = DEFAULT_DURATION) -> String:
	"""Scale node to target size"""
	return animate(node, {"scale": target_scale}, duration)

func color(node: Node, target_color: Color, duration: float = DEFAULT_DURATION) -> String:
	"""Animate node color"""
	return animate(node, {"modulate": target_color}, duration)

## Animation Sequences

func create_sequence() -> AnimationSequence:
	"""Create an animation sequence builder"""
	return AnimationSequence.new(self)

func create_parallel() -> AnimationParallel:
	"""Create a parallel animation group"""
	return AnimationParallel.new(self)

func stagger(nodes: Array, properties: Dictionary, duration: float = DEFAULT_DURATION, delay: float = 0.1) -> Array[String]:
	"""Animate multiple nodes with staggered timing"""
	var ids: Array[String] = []
	var current_delay = 0.0
	
	for node in nodes:
		if node is Node:
			var anim_data = AnimationData.new()
			anim_data.id = _generate_animation_id()
			anim_data.node = node
			anim_data.type = AnimationType.CUSTOM
			anim_data.properties = properties
			anim_data.duration = duration * _global_time_scale
			anim_data.delay = current_delay
			anim_data.easing = DEFAULT_EASING
			anim_data.transition = DEFAULT_TRANSITION
			anim_data.priority = AnimationPriority.NORMAL
			
			ids.append(_start_animation(anim_data))
			current_delay += delay
	
	return ids

## Animation Control

func pause_animation(animation_id: String) -> void:
	"""Pause a specific animation"""
	if _active_animations.has(animation_id):
		var anim_data: AnimationData = _active_animations[animation_id]
		if anim_data.tween and anim_data.tween.is_running():
			anim_data.tween.pause()

func resume_animation(animation_id: String) -> void:
	"""Resume a paused animation"""
	if _active_animations.has(animation_id):
		var anim_data: AnimationData = _active_animations[animation_id]
		if anim_data.tween:
			anim_data.tween.play()

func stop_animation(animation_id: String, finish: bool = false) -> void:
	"""Stop an animation, optionally jumping to end"""
	if _active_animations.has(animation_id):
		var anim_data: AnimationData = _active_animations[animation_id]
		if anim_data.tween:
			if finish:
				anim_data.tween.custom_step(999.0)  # Force to end
			anim_data.tween.kill()
		
		_cleanup_animation(animation_id)
		animation_cancelled.emit(animation_id)

func stop_all_animations(node: Node = null) -> void:
	"""Stop all animations, optionally for a specific node"""
	var to_stop = []
	
	for id in _active_animations:
		var anim_data: AnimationData = _active_animations[id]
		if not node or anim_data.node == node:
			to_stop.append(id)
	
	for id in to_stop:
		stop_animation(id)

func is_animating(node: Node) -> bool:
	"""Check if a node is currently being animated"""
	for anim_data in _active_animations.values():
		if anim_data.node == node:
			return true
	return false

## Settings

func set_global_time_scale(scale: float) -> void:
	"""Set global animation speed multiplier"""
	_global_time_scale = clamp(scale, 0.1, 2.0)

func set_reduce_motion(enabled: bool) -> void:
	"""Enable/disable reduced motion mode"""
	_reduce_motion = enabled
	
	if enabled:
		# Stop non-essential animations
		_stop_non_essential_animations()
		# Reduce durations
		_global_time_scale = 0.5

func set_animations_enabled(enabled: bool) -> void:
	"""Enable/disable all animations"""
	_enable_animations = enabled
	
	if not enabled:
		stop_all_animations()

func register_preset(name: String, preset: AnimationPreset) -> void:
	"""Register a custom animation preset"""
	_animation_presets[name] = preset

func register_easing_curve(name: String, curve: Curve) -> void:
	"""Register a custom easing curve"""
	_easing_curves[name] = curve

# === PRIVATE METHODS ===

func _start_animation(anim_data: AnimationData) -> String:
	"""Start an animation"""
	if not _enable_animations:
		return ""
	
	if _reduce_motion and anim_data.priority < AnimationPriority.HIGH:
		# Skip or reduce non-essential animations
		anim_data.duration *= 0.5
	
	# Check performance mode
	if _performance_mode and _active_animations.size() >= MAX_CONCURRENT_ANIMATIONS:
		# Queue or skip based on priority
		if anim_data.priority < AnimationPriority.HIGH:
			return ""
		else:
			_animation_queue.append(anim_data)
			queue_updated.emit(_animation_queue.size())
			return anim_data.id
	
	# Create tween
	anim_data.tween = create_tween()
	anim_data.tween.set_ease(anim_data.easing)
	anim_data.tween.set_trans(anim_data.transition)
	
	# Add delay if specified
	if anim_data.delay > 0:
		anim_data.tween.tween_interval(anim_data.delay)
	
	# Apply properties
	for property in anim_data.properties:
		var target_value = anim_data.properties[property]
		anim_data.tween.tween_property(
			anim_data.node,
			property,
			target_value,
			anim_data.duration
		)
	
	# Handle completion
	anim_data.tween.finished.connect(_on_animation_completed.bind(anim_data.id))
	
	# Track animation
	anim_data.start_time = Time.get_ticks_msec() / 1000.0
	_active_animations[anim_data.id] = anim_data
	
	animation_started.emit(anim_data.id)
	
	return anim_data.id

func _on_animation_completed(animation_id: String) -> void:
	"""Handle animation completion"""
	if not _active_animations.has(animation_id):
		return
	
	var anim_data: AnimationData = _active_animations[animation_id]
	
	# Handle looping
	if anim_data.is_looping:
		if anim_data.loop_count == -1 or anim_data.loop_count > 0:
			if anim_data.loop_count > 0:
				anim_data.loop_count -= 1
			
			# Restart animation
			_start_animation(anim_data)
			return
	
	# Call completion callback
	if anim_data.callback:
		anim_data.callback.call()
	
	_cleanup_animation(animation_id)
	animation_completed.emit(animation_id)
	
	# Process queued animations
	_process_animation_queue()

func _cleanup_animation(animation_id: String) -> void:
	"""Clean up completed animation"""
	_active_animations.erase(animation_id)

func _process_animation_queue() -> void:
	"""Process queued animations"""
	if _animation_queue.is_empty():
		return
	
	# Start next animation if under limit
	if _active_animations.size() < MAX_CONCURRENT_ANIMATIONS:
		var next_anim = _animation_queue.pop_front()
		_start_animation(next_anim)
		queue_updated.emit(_animation_queue.size())

func _check_performance() -> void:
	"""Monitor animation performance"""
	var fps = Engine.get_frames_per_second()
	_recent_fps.append(fps)
	
	if _recent_fps.size() > 10:
		_recent_fps.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for f in _recent_fps:
		avg_fps += f
	avg_fps /= _recent_fps.size()
	
	# Enter/exit performance mode
	if avg_fps < MIN_FPS_WARNING and not _performance_mode:
		_performance_mode = true
		performance_warning.emit(avg_fps)
		print("[AnimationManager] Entering performance mode (FPS: %.1f)" % avg_fps)
	elif avg_fps > MIN_FPS_WARNING + 10 and _performance_mode:
		_performance_mode = false
		print("[AnimationManager] Exiting performance mode")

func _stop_non_essential_animations() -> void:
	"""Stop animations with low priority"""
	var to_stop = []
	
	for id in _active_animations:
		var anim_data: AnimationData = _active_animations[id]
		if anim_data.priority < AnimationPriority.HIGH:
			to_stop.append(id)
	
	for id in to_stop:
		stop_animation(id)

func _generate_animation_id() -> String:
	"""Generate unique animation ID"""
	_animation_counter += 1
	return "anim_%d_%d" % [Time.get_ticks_msec(), _animation_counter]

func _load_user_preferences() -> void:
	"""Load animation preferences"""
	# Would load from settings
	pass

# === PRESET CREATION HELPERS ===

func _create_fade_preset(from_alpha: float, to_alpha: float, duration_preset: String) -> AnimationPreset:
	var preset = AnimationPreset.new()
	preset.name = "fade"
	preset.type = AnimationType.FADE
	preset.duration = DURATION_PRESETS.get(duration_preset, DEFAULT_DURATION)
	preset.easing = Tween.EASE_IN_OUT
	preset.transition = Tween.TRANS_CUBIC
	preset.properties = {"modulate:a": to_alpha}
	return preset

func _create_slide_preset(from_offset: Vector2, to_offset: Vector2, duration_preset: String) -> AnimationPreset:
	var preset = AnimationPreset.new()
	preset.name = "slide"
	preset.type = AnimationType.SLIDE
	preset.duration = DURATION_PRESETS.get(duration_preset, DEFAULT_DURATION)
	preset.easing = Tween.EASE_OUT
	preset.transition = Tween.TRANS_CUBIC
	preset.properties = {"position": to_offset}
	return preset

func _create_scale_preset(from_scale: Vector2, to_scale: Vector2, duration_preset: String, transition: Tween.TransitionType = Tween.TRANS_CUBIC) -> AnimationPreset:
	var preset = AnimationPreset.new()
	preset.name = "scale"
	preset.type = AnimationType.SCALE
	preset.duration = DURATION_PRESETS.get(duration_preset, DEFAULT_DURATION)
	preset.easing = Tween.EASE_OUT
	preset.transition = transition
	preset.properties = {"scale": to_scale}
	return preset

func _create_emphasis_preset(emphasis_type: String, duration_preset: String) -> AnimationPreset:
	var preset = AnimationPreset.new()
	preset.name = "emphasis_" + emphasis_type
	preset.type = AnimationType.CUSTOM
	preset.duration = DURATION_PRESETS.get(duration_preset, DEFAULT_DURATION)
	preset.easing = Tween.EASE_IN_OUT
	preset.transition = Tween.TRANS_SINE
	
	match emphasis_type:
		"pulse":
			preset.properties = {"scale": Vector2(1.1, 1.1)}
		"shake":
			preset.properties = {"position": Vector2(5, 0)}
	
	return preset

func _create_page_transition_preset(is_enter: bool) -> AnimationPreset:
	var preset = AnimationPreset.new()
	preset.name = "page_transition"
	preset.type = AnimationType.CUSTOM
	preset.duration = DURATION_PRESETS.long1
	preset.easing = Tween.EASE_IN_OUT
	preset.transition = Tween.TRANS_CUBIC
	
	if is_enter:
		preset.properties = {
			"modulate:a": 1.0,
			"position": Vector2.ZERO
		}
	else:
		preset.properties = {
			"modulate:a": 0.0,
			"position": Vector2(0, 50)
		}
	
	return preset

# === BUILDER CLASSES ===

class AnimationSequence:
	var _manager: AnimationManager
	var _steps: Array = []
	
	func _init(manager: AnimationManager) -> void:
		_manager = manager
	
	func then(node: Node, properties: Dictionary, duration: float = DEFAULT_DURATION) -> AnimationSequence:
		_steps.append({
			"node": node,
			"properties": properties,
			"duration": duration
		})
		return self
	
	func then_preset(node: Node, preset_name: String) -> AnimationSequence:
		_steps.append({
			"node": node,
			"preset": preset_name
		})
		return self
	
	func then_wait(duration: float) -> AnimationSequence:
		_steps.append({
			"wait": duration
		})
		return self
	
	func start() -> String:
		if _steps.is_empty():
			return ""
		
		# Create sequential tween
		var tween = _manager.create_tween()
		var id = _manager._generate_animation_id()
		
		for step in _steps:
			if step.has("wait"):
				tween.tween_interval(step.wait)
			elif step.has("preset"):
				# Handle preset
				pass
			else:
				for property in step.properties:
					tween.tween_property(
						step.node,
						property,
						step.properties[property],
						step.duration
					)
		
		return id

class AnimationParallel:
	var _manager: AnimationManager
	var _animations: Array = []
	
	func _init(manager: AnimationManager) -> void:
		_manager = manager
	
	func add(node: Node, properties: Dictionary, duration: float = DEFAULT_DURATION) -> AnimationParallel:
		_animations.append({
			"node": node,
			"properties": properties,
			"duration": duration
		})
		return self
	
	func start() -> Array[String]:
		var ids: Array[String] = []
		
		for anim in _animations:
			var id = _manager.animate(anim.node, anim.properties, anim.duration)
			ids.append(id)
		
		return ids

# === DEBUG ===

func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"active_animations": _active_animations.size(),
		"queued_animations": _animation_queue.size(),
		"performance_mode": _performance_mode,
		"average_fps": _recent_fps.reduce(func(a, b): return a + b, 0.0) / max(_recent_fps.size(), 1),
		"global_time_scale": _global_time_scale,
		"reduce_motion": _reduce_motion,
		"animations_enabled": _enable_animations
	}