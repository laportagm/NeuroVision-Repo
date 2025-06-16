## BaseScreen.gd
## Base class for all screen/scene components in NeuroVision
##
## Provides screen-level functionality:
## - Screen lifecycle management
## - Navigation and transition handling
## - State persistence between screen changes
## - Input handling and shortcuts
## - Screen-level loading and resource management
## - Integration with navigation system

class_name BaseScreen
extends BaseComponent

# === SIGNALS ===
signal screen_entered(from_screen: String)
signal screen_exited(to_screen: String)
signal transition_started(transition_type: String)
signal transition_completed()
signal navigation_requested(target_screen: String, params: Dictionary)
signal back_requested()

# === CONSTANTS ===
enum TransitionType {
	NONE,
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	ZOOM_IN,
	ZOOM_OUT,
	CUSTOM
}

const TRANSITION_DURATION := 0.5
const LOADING_FADE_DURATION := 0.3

# === EXPORT VARIABLES ===
@export_group("Screen Configuration")
@export var screen_name: String = ""
@export var screen_title: String = ""
@export var allow_back_navigation: bool = true
@export var persist_state: bool = true
@export var requires_authentication: bool = false

@export_group("Transitions")
@export var entry_transition: TransitionType = TransitionType.FADE
@export var exit_transition: TransitionType = TransitionType.FADE
@export var transition_duration: float = TRANSITION_DURATION

@export_group("Loading")
@export var show_loading_overlay: bool = true
@export var minimum_loading_time: float = 0.0
@export var preload_resources: Array[String] = []

@export_group("Input")
@export var capture_back_button: bool = true
@export var custom_shortcuts: Dictionary = {}  # action_name: callable

# === PRIVATE VARIABLES ===
var _screen_state: Dictionary = {}
var _navigation_params: Dictionary = {}
var _previous_screen: String = ""
var _is_active: bool = false
var _is_transitioning: bool = false

var _loading_overlay: Control
var _loading_progress: float = 0.0
var _resources_loaded: Dictionary = {}

var _transition_tween: Tween
var _original_position: Vector2
var _original_scale: Vector2

# === LIFECYCLE METHODS ===

func _on_ready() -> void:
	"""Initialize screen systems"""
	# Set screen name from class if not provided
	if screen_name.is_empty():
		screen_name = get_class()
	
	# Store original transform for transitions
	_original_position = position
	_original_scale = scale
	
	# Create loading overlay if needed
	if show_loading_overlay:
		_create_loading_overlay()
	
	# Set up input handling
	_setup_input_handling()
	
	# Initialize screen-specific content
	_on_screen_ready()

func _input(event: InputEvent) -> void:
	"""Handle screen-level input"""
	if not _is_active or _is_transitioning:
		return
	
	# Back button handling
	if capture_back_button and event.is_action_pressed("ui_cancel"):
		if allow_back_navigation:
			request_back()
			get_viewport().set_input_as_handled()
	
	# Custom shortcuts
	for action in custom_shortcuts:
		if event.is_action_pressed(action):
			custom_shortcuts[action].call()
			get_viewport().set_input_as_handled()

# === VIRTUAL METHODS ===

func _on_screen_ready() -> void:
	"""Override to initialize screen-specific content"""
	pass

func _on_enter_screen(params: Dictionary) -> void:
	"""Override to handle screen entry with parameters"""
	pass

func _on_exit_screen() -> void:
	"""Override to handle screen exit"""
	pass

func _on_screen_resumed() -> void:
	"""Override to handle screen resume from background"""
	pass

func _on_screen_paused() -> void:
	"""Override to handle screen pause to background"""
	pass

func _can_navigate_away() -> bool:
	"""Override to validate if screen can be exited"""
	return true

func _get_state_to_save() -> Dictionary:
	"""Override to provide custom state for persistence"""
	return {}

func _restore_from_state(state: Dictionary) -> void:
	"""Override to restore from saved state"""
	pass

# === PUBLIC METHODS ===

func enter_screen(from_screen: String, params: Dictionary = {}) -> void:
	"""Enter this screen with transition"""
	if _is_active:
		push_warning("Screen %s is already active" % screen_name)
		return
	
	_previous_screen = from_screen
	_navigation_params = params
	_is_active = true
	
	# Show loading if needed
	if show_loading_overlay:
		await _show_loading_screen()
	
	# Preload resources
	if not preload_resources.is_empty():
		await _preload_screen_resources()
	
	# Restore state if available
	if persist_state and not _screen_state.is_empty():
		_restore_from_state(_screen_state)
	
	# Perform entry transition
	await _perform_entry_transition()
	
	# Call implementation
	_on_enter_screen(params)
	
	# Emit signal
	screen_entered.emit(from_screen)

func exit_screen(to_screen: String) -> void:
	"""Exit this screen with transition"""
	if not _is_active:
		return
	
	# Check if we can navigate away
	if not _can_navigate_away():
		push_warning("Navigation blocked by screen %s" % screen_name)
		return
	
	# Save state if needed
	if persist_state:
		_screen_state = _get_state_to_save()
	
	# Call implementation
	_on_exit_screen()
	
	# Perform exit transition
	await _perform_exit_transition()
	
	_is_active = false
	
	# Emit signal
	screen_exited.emit(to_screen)

func resume_screen() -> void:
	"""Resume screen from paused state"""
	if not _is_active:
		return
	
	show()
	_on_screen_resumed()

func pause_screen() -> void:
	"""Pause screen to background"""
	if not _is_active:
		return
	
	_on_screen_paused()
	hide()

func request_navigation(target_screen: String, params: Dictionary = {}) -> void:
	"""Request navigation to another screen"""
	if _is_transitioning:
		return
	
	navigation_requested.emit(target_screen, params)

func request_back() -> void:
	"""Request navigation back to previous screen"""
	if _is_transitioning:
		return
	
	back_requested.emit()

func reload_screen() -> void:
	"""Reload the current screen"""
	var params = _navigation_params
	exit_screen(screen_name)
	await get_tree().process_frame
	enter_screen(screen_name, params)

func update_loading_progress(progress: float, status_text: String = "") -> void:
	"""Update loading overlay progress"""
	_loading_progress = clamp(progress, 0.0, 1.0)
	
	if _loading_overlay:
		var progress_bar = _loading_overlay.get_node_or_null("VBox/ProgressBar")
		if progress_bar:
			progress_bar.value = _loading_progress
		
		var status_label = _loading_overlay.get_node_or_null("VBox/StatusLabel")
		if status_label and not status_text.is_empty():
			status_label.text = status_text

func get_screen_info() -> Dictionary:
	"""Get screen information"""
	var info = super.get_component_info()
	info.merge({
		"screen_name": screen_name,
		"screen_title": screen_title,
		"is_active": _is_active,
		"previous_screen": _previous_screen,
		"navigation_params": _navigation_params,
		"state": _screen_state
	})
	return info

# === PRIVATE METHODS ===

func _create_loading_overlay() -> void:
	"""Create loading overlay UI"""
	_loading_overlay = ColorRect.new()
	_loading_overlay.color = Color(0, 0, 0, 0.8)
	_loading_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_loading_overlay.visible = false
	add_child(_loading_overlay)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_loading_overlay.add_child(vbox)
	
	# Loading label
	var label = Label.new()
	label.text = "Loading..."
	label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(label)
	
	# Progress bar
	var progress = ProgressBar.new()
	progress.custom_minimum_size.x = 300
	progress.value = 0
	vbox.add_child(progress)
	
	# Status label
	var status = Label.new()
	status.name = "StatusLabel"
	status.text = ""
	vbox.add_child(status)

func _show_loading_screen() -> void:
	"""Show loading overlay with fade"""
	if not _loading_overlay:
		return
	
	_loading_overlay.visible = true
	_loading_overlay.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(_loading_overlay, "modulate:a", 1.0, LOADING_FADE_DURATION)
	await tween.finished

func _hide_loading_screen() -> void:
	"""Hide loading overlay with fade"""
	if not _loading_overlay:
		return
	
	var tween = create_tween()
	tween.tween_property(_loading_overlay, "modulate:a", 0.0, LOADING_FADE_DURATION)
	await tween.finished
	_loading_overlay.visible = false

func _preload_screen_resources() -> void:
	"""Preload resources needed by screen"""
	var total = preload_resources.size()
	var loaded = 0
	
	for resource_path in preload_resources:
		update_loading_progress(float(loaded) / float(total), "Loading: " + resource_path.get_file())
		
		var resource = load(resource_path)
		if resource:
			_resources_loaded[resource_path] = resource
			track_resource(resource)
		else:
			push_error("Failed to load resource: " + resource_path)
		
		loaded += 1
		await get_tree().process_frame
	
	update_loading_progress(1.0, "Complete")
	
	# Ensure minimum loading time
	if minimum_loading_time > 0:
		await get_tree().create_timer(minimum_loading_time).timeout
	
	await _hide_loading_screen()

func _perform_entry_transition() -> void:
	"""Perform screen entry transition"""
	if entry_transition == TransitionType.NONE:
		return
	
	_is_transitioning = true
	transition_started.emit("entry")
	
	# Set initial state based on transition type
	match entry_transition:
		TransitionType.FADE:
			modulate.a = 0.0
		TransitionType.SLIDE_LEFT:
			position.x = get_viewport_rect().size.x
		TransitionType.SLIDE_RIGHT:
			position.x = -get_viewport_rect().size.x
		TransitionType.SLIDE_UP:
			position.y = get_viewport_rect().size.y
		TransitionType.SLIDE_DOWN:
			position.y = -get_viewport_rect().size.y
		TransitionType.ZOOM_IN:
			scale = Vector2(0.5, 0.5)
			modulate.a = 0.0
		TransitionType.ZOOM_OUT:
			scale = Vector2(1.5, 1.5)
			modulate.a = 0.0
	
	# Animate to normal state
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	
	match entry_transition:
		TransitionType.FADE:
			_transition_tween.tween_property(self, "modulate:a", 1.0, transition_duration)
		TransitionType.SLIDE_LEFT, TransitionType.SLIDE_RIGHT:
			_transition_tween.tween_property(self, "position:x", _original_position.x, transition_duration)
		TransitionType.SLIDE_UP, TransitionType.SLIDE_DOWN:
			_transition_tween.tween_property(self, "position:y", _original_position.y, transition_duration)
		TransitionType.ZOOM_IN, TransitionType.ZOOM_OUT:
			_transition_tween.tween_property(self, "scale", _original_scale, transition_duration)
			_transition_tween.tween_property(self, "modulate:a", 1.0, transition_duration)
	
	await _transition_tween.finished
	_is_transitioning = false
	transition_completed.emit()

func _perform_exit_transition() -> void:
	"""Perform screen exit transition"""
	if exit_transition == TransitionType.NONE:
		return
	
	_is_transitioning = true
	transition_started.emit("exit")
	
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	
	# Animate based on transition type
	match exit_transition:
		TransitionType.FADE:
			_transition_tween.tween_property(self, "modulate:a", 0.0, transition_duration)
		TransitionType.SLIDE_LEFT:
			_transition_tween.tween_property(self, "position:x", -get_viewport_rect().size.x, transition_duration)
		TransitionType.SLIDE_RIGHT:
			_transition_tween.tween_property(self, "position:x", get_viewport_rect().size.x, transition_duration)
		TransitionType.SLIDE_UP:
			_transition_tween.tween_property(self, "position:y", -get_viewport_rect().size.y, transition_duration)
		TransitionType.SLIDE_DOWN:
			_transition_tween.tween_property(self, "position:y", get_viewport_rect().size.y, transition_duration)
		TransitionType.ZOOM_IN:
			_transition_tween.tween_property(self, "scale", Vector2(1.5, 1.5), transition_duration)
			_transition_tween.tween_property(self, "modulate:a", 0.0, transition_duration)
		TransitionType.ZOOM_OUT:
			_transition_tween.tween_property(self, "scale", Vector2(0.5, 0.5), transition_duration)
			_transition_tween.tween_property(self, "modulate:a", 0.0, transition_duration)
	
	await _transition_tween.finished
	_is_transitioning = false
	transition_completed.emit()

func _setup_input_handling() -> void:
	"""Set up screen input handling"""
	# Ensure we can receive input
	set_process_input(true)
	
	# Set up as top-level for modal behavior if needed
	if requires_authentication:
		z_index = 1000  # Ensure on top

func get_resource(path: String) -> Resource:
	"""Get a preloaded resource"""
	return _resources_loaded.get(path)