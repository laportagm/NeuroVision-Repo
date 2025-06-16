## UIManager.gd
## Central UI coordinator for NeuroVision
##
## This singleton manages the entire UI system including:
## - Screen navigation and lifecycle
## - Global UI state management
## - Component registration and lookup
## - Event bus for UI communication
## - Performance monitoring
## - Dependency injection for UI services

class_name UIManager
extends Node

# === SIGNALS ===
signal screen_changed(from_screen: String, to_screen: String)
signal ui_state_changed(state_key: String, new_value: Variant)
signal component_registered(component_id: String)
signal component_unregistered(component_id: String)
signal ui_event(event_name: String, data: Dictionary)
signal navigation_blocked(reason: String)

# === CONSTANTS ===
const SCREEN_TRANSITION_DELAY := 0.1
const MAX_NAVIGATION_HISTORY := 50
const PERFORMANCE_LOG_INTERVAL := 60.0  # Log performance every minute

# === ENUMS ===
enum NavigationMode {
	REPLACE,    # Replace current screen
	PUSH,       # Push onto navigation stack
	MODAL,      # Show as modal over current
	OVERLAY     # Show as overlay (multiple allowed)
}

# === PRIVATE VARIABLES ===
# Service references (injected)
var _theme_manager: ThemeManager
var _layout_manager: LayoutManager
var _animation_manager: AnimationManager

# Screen management
var _screen_container: Control
var _screens: Dictionary = {}  # screen_name: screen_instance
var _current_screen: BaseScreen
var _screen_stack: Array[String] = []
var _modal_stack: Array[BaseScreen] = []
var _overlay_stack: Array[BaseScreen] = []

# Component registry
var _registered_components: Dictionary = {}  # component_id: component_ref
var _component_groups: Dictionary = {}  # group_name: Array[component_id]

# UI State
var _global_ui_state: Dictionary = {}
var _screen_states: Dictionary = {}  # screen_name: state_dict

# Performance tracking
var _performance_stats: Dictionary = {
	"screen_changes": 0,
	"components_created": 0,
	"events_dispatched": 0,
	"average_transition_time": 0.0
}
var _performance_timer: Timer

# Configuration
var _config: Dictionary = {
	"enable_navigation_history": true,
	"enable_performance_monitoring": true,
	"enable_debug_overlay": false,
	"default_transition_type": BaseScreen.TransitionType.FADE
}

# === INITIALIZATION ===

func _init() -> void:
	name = "UIManager"
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	_setup_screen_container()
	_setup_performance_monitoring()
	print("[UIManager] UI system initialized")

func initialize(theme_mgr: ThemeManager, layout_mgr: LayoutManager, anim_mgr: AnimationManager) -> void:
	"""Initialize UI manager with required services"""
	_theme_manager = theme_mgr
	_layout_manager = layout_mgr
	_animation_manager = anim_mgr
	
	# Connect to service signals
	if _theme_manager:
		_theme_manager.theme_changed.connect(_on_theme_changed)
	if _layout_manager:
		_layout_manager.breakpoint_changed.connect(_on_breakpoint_changed)
	
	print("[UIManager] Services initialized")

# === PUBLIC API ===

## Screen Navigation

func register_screen(screen_name: String, screen_scene: PackedScene) -> void:
	"""Register a screen scene for navigation"""
	_screens[screen_name] = screen_scene
	print("[UIManager] Registered screen: %s" % screen_name)

func navigate_to(screen_name: String, params: Dictionary = {}, mode: NavigationMode = NavigationMode.REPLACE) -> void:
	"""Navigate to a registered screen"""
	if not _screens.has(screen_name):
		push_error("[UIManager] Unknown screen: %s" % screen_name)
		return
	
	# Track performance
	var start_time = Time.get_ticks_msec()
	
	match mode:
		NavigationMode.REPLACE:
			await _replace_screen(screen_name, params)
		NavigationMode.PUSH:
			await _push_screen(screen_name, params)
		NavigationMode.MODAL:
			await _show_modal(screen_name, params)
		NavigationMode.OVERLAY:
			await _show_overlay(screen_name, params)
	
	# Update performance stats
	var transition_time = Time.get_ticks_msec() - start_time
	_update_performance_stat("average_transition_time", transition_time)
	_performance_stats.screen_changes += 1

func navigate_back() -> bool:
	"""Navigate back in history. Returns true if successful"""
	if _modal_stack.size() > 0:
		await _close_modal()
		return true
	
	if _overlay_stack.size() > 0:
		await _close_overlay()
		return true
	
	if _screen_stack.size() > 1:
		_screen_stack.pop_back()  # Remove current
		var previous = _screen_stack[-1]
		await navigate_to(previous, {}, NavigationMode.REPLACE)
		return true
	
	return false

func get_current_screen() -> BaseScreen:
	"""Get the currently active screen"""
	return _current_screen

func get_screen_history() -> Array[String]:
	"""Get navigation history"""
	return _screen_stack.duplicate()

## Component Management

func register_component(component: BaseComponent) -> void:
	"""Register a UI component for management"""
	var comp_id = component.component_id
	_registered_components[comp_id] = weakref(component)
	component_registered.emit(comp_id)
	_performance_stats.components_created += 1

func unregister_component(component: BaseComponent) -> void:
	"""Unregister a UI component"""
	var comp_id = component.component_id
	_registered_components.erase(comp_id)
	
	# Remove from groups
	for group in _component_groups:
		_component_groups[group].erase(comp_id)
	
	component_unregistered.emit(comp_id)

func add_component_to_group(component: BaseComponent, group_name: String) -> void:
	"""Add component to a named group"""
	if not _component_groups.has(group_name):
		_component_groups[group_name] = []
	
	if not component.component_id in _component_groups[group_name]:
		_component_groups[group_name].append(component.component_id)

func get_components_in_group(group_name: String) -> Array[BaseComponent]:
	"""Get all components in a group"""
	var components: Array[BaseComponent] = []
	
	if _component_groups.has(group_name):
		for comp_id in _component_groups[group_name]:
			var weak = _registered_components.get(comp_id)
			if weak and weak.get_ref():
				components.append(weak.get_ref())
	
	return components

func find_component(component_id: String) -> BaseComponent:
	"""Find a component by ID"""
	var weak = _registered_components.get(component_id)
	if weak and weak.get_ref():
		return weak.get_ref()
	return null

## State Management

func set_ui_state(key: String, value: Variant) -> void:
	"""Set global UI state value"""
	_global_ui_state[key] = value
	ui_state_changed.emit(key, value)

func get_ui_state(key: String, default_value: Variant = null) -> Variant:
	"""Get global UI state value"""
	return _global_ui_state.get(key, default_value)

func get_all_ui_state() -> Dictionary:
	"""Get entire UI state dictionary"""
	return _global_ui_state.duplicate()

func save_screen_state(screen_name: String, state: Dictionary) -> void:
	"""Save state for a specific screen"""
	_screen_states[screen_name] = state

func get_screen_state(screen_name: String) -> Dictionary:
	"""Get saved state for a screen"""
	return _screen_states.get(screen_name, {})

## Event System

func emit_ui_event(event_name: String, data: Dictionary = {}) -> void:
	"""Emit a UI event through the event bus"""
	data["timestamp"] = Time.get_ticks_msec()
	data["source"] = "UIManager"
	ui_event.emit(event_name, data)
	_performance_stats.events_dispatched += 1

func connect_to_ui_event(event_name: String, callable: Callable) -> void:
	"""Helper to connect to specific UI events"""
	ui_event.connect(func(name, data):
		if name == event_name:
			callable.call(data)
	)

## Configuration

func set_config(key: String, value: Variant) -> void:
	"""Set UI manager configuration"""
	_config[key] = value

func get_config(key: String, default_value: Variant = null) -> Variant:
	"""Get UI manager configuration"""
	return _config.get(key, default_value)

# === PRIVATE METHODS ===

func _setup_screen_container() -> void:
	"""Create the screen container"""
	_screen_container = Control.new()
	_screen_container.name = "ScreenContainer"
	_screen_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_screen_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_screen_container)

func _setup_performance_monitoring() -> void:
	"""Set up performance monitoring timer"""
	if not _config.enable_performance_monitoring:
		return
	
	_performance_timer = Timer.new()
	_performance_timer.wait_time = PERFORMANCE_LOG_INTERVAL
	_performance_timer.timeout.connect(_log_performance_stats)
	add_child(_performance_timer)
	_performance_timer.start()

func _replace_screen(screen_name: String, params: Dictionary) -> void:
	"""Replace current screen with new one"""
	var old_screen_name = ""
	
	# Exit current screen
	if _current_screen:
		old_screen_name = _current_screen.screen_name
		await _current_screen.exit_screen(screen_name)
		_current_screen.queue_free()
	
	# Small delay to ensure cleanup
	await get_tree().create_timer(SCREEN_TRANSITION_DELAY).timeout
	
	# Create and enter new screen
	var new_screen = await _create_screen(screen_name)
	if new_screen:
		_current_screen = new_screen
		await _current_screen.enter_screen(old_screen_name, params)
		
		# Update navigation history
		if _config.enable_navigation_history:
			_screen_stack.append(screen_name)
			if _screen_stack.size() > MAX_NAVIGATION_HISTORY:
				_screen_stack.pop_front()
		
		screen_changed.emit(old_screen_name, screen_name)

func _push_screen(screen_name: String, params: Dictionary) -> void:
	"""Push new screen onto stack (pause current)"""
	if _current_screen:
		_current_screen.pause_screen()
	
	var new_screen = await _create_screen(screen_name)
	if new_screen:
		var old_name = _current_screen.screen_name if _current_screen else ""
		_current_screen = new_screen
		await _current_screen.enter_screen(old_name, params)
		_screen_stack.append(screen_name)
		screen_changed.emit(old_name, screen_name)

func _show_modal(screen_name: String, params: Dictionary) -> void:
	"""Show screen as modal"""
	var modal_screen = await _create_screen(screen_name)
	if modal_screen:
		modal_screen.z_index = 100 + _modal_stack.size()
		_modal_stack.append(modal_screen)
		await modal_screen.enter_screen(_current_screen.screen_name if _current_screen else "", params)

func _show_overlay(screen_name: String, params: Dictionary) -> void:
	"""Show screen as overlay"""
	var overlay_screen = await _create_screen(screen_name)
	if overlay_screen:
		overlay_screen.z_index = 200 + _overlay_stack.size()
		_overlay_stack.append(overlay_screen)
		await overlay_screen.enter_screen(_current_screen.screen_name if _current_screen else "", params)

func _close_modal() -> void:
	"""Close top modal"""
	if _modal_stack.is_empty():
		return
	
	var modal = _modal_stack.pop_back()
	await modal.exit_screen(_current_screen.screen_name if _current_screen else "")
	modal.queue_free()

func _close_overlay() -> void:
	"""Close top overlay"""
	if _overlay_stack.is_empty():
		return
	
	var overlay = _overlay_stack.pop_back()
	await overlay.exit_screen(_current_screen.screen_name if _current_screen else "")
	overlay.queue_free()

func _create_screen(screen_name: String) -> BaseScreen:
	"""Create a screen instance"""
	var screen_scene = _screens.get(screen_name)
	if not screen_scene:
		push_error("[UIManager] Screen not registered: %s" % screen_name)
		return null
	
	var screen_instance = screen_scene.instantiate()
	if not screen_instance is BaseScreen:
		push_error("[UIManager] Screen must extend BaseScreen: %s" % screen_name)
		screen_instance.queue_free()
		return null
	
	_screen_container.add_child(screen_instance)
	
	# Apply current theme
	if _theme_manager:
		screen_instance.apply_theme(_theme_manager.get_current_theme())
	
	# Connect navigation signals
	screen_instance.navigation_requested.connect(_on_navigation_requested)
	screen_instance.back_requested.connect(func(): navigate_back())
	
	return screen_instance

func _on_navigation_requested(target_screen: String, params: Dictionary) -> void:
	"""Handle navigation request from screen"""
	navigate_to(target_screen, params)

func _on_theme_changed(theme: Theme) -> void:
	"""Handle theme change from ThemeManager"""
	# Apply to all screens
	if _current_screen:
		_current_screen.apply_theme(theme)
	
	for modal in _modal_stack:
		modal.apply_theme(theme)
	
	for overlay in _overlay_stack:
		overlay.apply_theme(theme)

func _on_breakpoint_changed(breakpoint: String) -> void:
	"""Handle responsive breakpoint change"""
	emit_ui_event("breakpoint_changed", {"breakpoint": breakpoint})

func _update_performance_stat(stat: String, value: float) -> void:
	"""Update performance statistics"""
	if stat == "average_transition_time":
		var current = _performance_stats[stat]
		var count = _performance_stats.screen_changes
		_performance_stats[stat] = (current * (count - 1) + value) / count

func _log_performance_stats() -> void:
	"""Log performance statistics"""
	print("[UIManager] Performance Stats:")
	print("  Screen changes: %d" % _performance_stats.screen_changes)
	print("  Components created: %d" % _performance_stats.components_created)
	print("  Events dispatched: %d" % _performance_stats.events_dispatched)
	print("  Avg transition time: %.2fms" % _performance_stats.average_transition_time)
	print("  Active components: %d" % _registered_components.size())

# === DEBUG METHODS ===

func get_debug_info() -> Dictionary:
	"""Get debug information about UI state"""
	return {
		"current_screen": _current_screen.screen_name if _current_screen else "none",
		"screen_stack": _screen_stack,
		"modal_count": _modal_stack.size(),
		"overlay_count": _overlay_stack.size(),
		"registered_components": _registered_components.size(),
		"component_groups": _component_groups.keys(),
		"performance_stats": _performance_stats
	}