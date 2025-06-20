extends Node
class_name SimpleFocusManager

## Simple focus management system for keyboard navigation
##
## This manager helps track focus order and handle Tab/Shift+Tab navigation
## across UI controls. It's designed to be simple and work with existing
## Godot focus system while adding additional control.

signal focus_changed(control: Control, label: String)
signal focus_wrapped(direction: String)

# === CONSTANTS ===
const FOCUS_RING_COLOR: Color = Color.CYAN
const FOCUS_RING_WIDTH: int = 3

# === PRIVATE VARIABLES ===
var _focus_registry: Array[Control] = []
var _focus_labels: Dictionary = {}  # Control -> String label for announcements
var _current_focus_index: int = -1
var _is_enabled: bool = true

# === PUBLIC METHODS ===

func register_control(control: Control, label: String = "") -> void:
	## Register a control for focus management
	if control in _focus_registry:
		return
		
	_focus_registry.append(control)
	
	# Store label for screen reader announcements
	if label.is_empty():
		label = _get_control_label(control)
	_focus_labels[control] = label
	
	# Connect to focus signals
	if not control.focus_entered.is_connected(_on_control_focus_entered):
		control.focus_entered.connect(_on_control_focus_entered.bind(control))
	
	# Ensure control can receive focus
	if control.focus_mode == Control.FOCUS_NONE:
		control.focus_mode = Control.FOCUS_ALL

func unregister_control(control: Control) -> void:
	## Remove a control from focus management
	var index = _focus_registry.find(control)
	if index >= 0:
		_focus_registry.remove_at(index)
		_focus_labels.erase(control)
		
		# Disconnect signals
		if control.focus_entered.is_connected(_on_control_focus_entered):
			control.focus_entered.disconnect(_on_control_focus_entered)
		
		# Adjust current focus index if needed
		if _current_focus_index >= index:
			_current_focus_index -= 1

func clear_registry() -> void:
	## Clear all registered controls
	for control in _focus_registry:
		if control.focus_entered.is_connected(_on_control_focus_entered):
			control.focus_entered.disconnect(_on_control_focus_entered)
	
	_focus_registry.clear()
	_focus_labels.clear()
	_current_focus_index = -1

func focus_next() -> void:
	## Move focus to the next control in the registry
	if _focus_registry.is_empty():
		return
		
	_current_focus_index = (_current_focus_index + 1) % _focus_registry.size()
	
	var control = _focus_registry[_current_focus_index]
	if is_instance_valid(control) and control.is_visible_in_tree() and not control.disabled:
		control.grab_focus()
	else:
		# Skip disabled/hidden controls
		focus_next()

func focus_previous() -> void:
	## Move focus to the previous control in the registry
	if _focus_registry.is_empty():
		return
		
	_current_focus_index = _current_focus_index - 1
	if _current_focus_index < 0:
		_current_focus_index = _focus_registry.size() - 1
		focus_wrapped.emit("backward")
	
	var control = _focus_registry[_current_focus_index]
	if is_instance_valid(control) and control.is_visible_in_tree() and not control.disabled:
		control.grab_focus()
	else:
		# Skip disabled/hidden controls
		focus_previous()

func set_focus_to_control(control: Control) -> void:
	## Set focus to a specific control if it's registered
	var index = _focus_registry.find(control)
	if index >= 0:
		_current_focus_index = index
		control.grab_focus()

func get_current_focus() -> Control:
	## Get the currently focused control
	if _current_focus_index >= 0 and _current_focus_index < _focus_registry.size():
		return _focus_registry[_current_focus_index]
	return null

func enable() -> void:
	## Enable focus management
	_is_enabled = true

func disable() -> void:
	## Disable focus management
	_is_enabled = false

# === PRIVATE METHODS ===

func _on_control_focus_entered(control: Control) -> void:
	## Handle when a registered control gains focus
	if not _is_enabled:
		return
		
	var index = _focus_registry.find(control)
	if index >= 0:
		_current_focus_index = index
		
		# Emit signal for accessibility announcements
		var label = _focus_labels.get(control, "")
		focus_changed.emit(control, label)
		
		# If AccessibilityManager is available, announce the focus change
		var accessibility_mgr = get_node_or_null("/root/AccessibilityManager")
		if accessibility_mgr and accessibility_mgr.is_screen_reader_enabled():
			accessibility_mgr.announce(label)

func _get_control_label(control: Control) -> String:
	## Generate a default label for a control
	if control is Button:
		return control.text
	elif control is LineEdit:
		return control.placeholder_text if control.placeholder_text else "Text input"
	elif control is TextEdit:
		return "Text area"
	elif control is OptionButton:
		return "Dropdown menu"
	elif control is CheckBox:
		return control.text if control.text else "Checkbox"
	elif control is SpinBox:
		return "Number input"
	else:
		return control.get_class()

func create_focus_style() -> StyleBoxFlat:
	## Create a consistent focus indicator style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.3)
	style.border_color = FOCUS_RING_COLOR
	style.set_border_width_all(FOCUS_RING_WIDTH)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(8)
	return style