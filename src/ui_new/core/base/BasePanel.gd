## BasePanel.gd
## Base class for all panel components in NeuroVision
##
## Extends BaseComponent with panel-specific functionality:
## - Consistent panel styling and behavior
## - Drag and resize capabilities
## - Animation presets for panels
## - Header/content/footer structure
## - Responsive panel behavior
## - Glass morphism effects support

class_name BasePanel
extends BaseComponent

# === SIGNALS ===
signal panel_opened()
signal panel_closed()
signal panel_minimized()
signal panel_maximized()
signal panel_dragged(new_position: Vector2)
signal panel_resized(new_size: Vector2)

# === CONSTANTS ===
const MIN_PANEL_SIZE := Vector2(300, 200)
const PANEL_MARGIN := 20
const HEADER_HEIGHT := 48
const RESIZE_HANDLE_SIZE := 8

# === EXPORT VARIABLES ===
@export_group("Panel Configuration")
@export var panel_title: String = "Panel" : set = set_panel_title
@export var show_header: bool = true
@export var show_close_button: bool = true
@export var show_minimize_button: bool = false
@export var show_maximize_button: bool = false

@export_group("Panel Behavior")
@export var draggable: bool = true
@export var resizable: bool = false
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 30.0
@export var remember_position: bool = true
@export var modal: bool = false

@export_group("Panel Appearance")
@export var use_glass_effect: bool = true
@export var panel_color: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var header_color: Color = Color(0.15, 0.15, 0.15, 1.0)
@export var border_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var corner_radius: int = 8

# === PRIVATE VARIABLES ===
var _panel_container: PanelContainer
var _header_container: Control
var _content_container: Control
var _footer_container: Control
var _title_label: Label
var _close_button: Button
var _minimize_button: Button
var _maximize_button: Button

var _is_dragging: bool = false
var _drag_offset: Vector2
var _is_resizing: bool = false
var _resize_start_size: Vector2
var _resize_start_pos: Vector2

var _is_minimized: bool = false
var _is_maximized: bool = false
var _pre_maximize_rect: Rect2

var _auto_hide_timer: Timer
var _panel_state: Dictionary = {}

# === LIFECYCLE METHODS ===

func _on_ready() -> void:
	"""Initialize panel structure"""
	_create_panel_structure()
	_setup_panel_behavior()
	_apply_panel_styling()
	_restore_panel_state()

func _on_theme_changed(theme: Theme) -> void:
	"""Apply theme to panel components"""
	super._on_theme_changed(theme)
	_apply_panel_styling()

# === PANEL STRUCTURE ===

func _create_panel_structure() -> void:
	"""Create the standard panel structure"""
	# Main panel container
	_panel_container = PanelContainer.new()
	_panel_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_panel_container)
	
	# Main vertical layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel_container.add_child(vbox)
	
	# Header
	if show_header:
		_header_container = _create_header()
		vbox.add_child(_header_container)
	
	# Content area with margins
	var content_margin = MarginContainer.new()
	content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 16)
	content_margin.add_theme_constant_override("margin_right", 16)
	content_margin.add_theme_constant_override("margin_top", 8)
	content_margin.add_theme_constant_override("margin_bottom", 8)
	vbox.add_child(content_margin)
	
	_content_container = Control.new()
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_child(_content_container)
	
	# Footer (optional, created on demand)
	_footer_container = Control.new()
	_footer_container.visible = false
	vbox.add_child(_footer_container)

func _create_header() -> Control:
	"""Create panel header with controls"""
	var header = PanelContainer.new()
	header.custom_minimum_size.y = HEADER_HEIGHT
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header.add_child(hbox)
	
	# Title
	_title_label = Label.new()
	_title_label.text = panel_title
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_style_override("font_size", 16)
	hbox.add_child(_title_label)
	
	# Window controls
	if show_minimize_button:
		_minimize_button = _create_header_button("−", _on_minimize_pressed)
		hbox.add_child(_minimize_button)
	
	if show_maximize_button:
		_maximize_button = _create_header_button("□", _on_maximize_pressed)
		hbox.add_child(_maximize_button)
	
	if show_close_button:
		_close_button = _create_header_button("×", _on_close_pressed)
		hbox.add_child(_close_button)
	
	# Make header draggable
	if draggable:
		header.gui_input.connect(_on_header_input)
	
	return header

func _create_header_button(text: String, callback: Callable) -> Button:
	"""Create a standardized header button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(32, 32)
	button.flat = true
	button.pressed.connect(callback)
	return button

# === PANEL BEHAVIOR ===

func _setup_panel_behavior() -> void:
	"""Configure panel behavior systems"""
	# Auto-hide timer
	if auto_hide:
		_auto_hide_timer = Timer.new()
		_auto_hide_timer.wait_time = auto_hide_delay
		_auto_hide_timer.one_shot = true
		_auto_hide_timer.timeout.connect(hide_panel)
		add_child(_auto_hide_timer)
		
		# Reset timer on mouse enter
		mouse_entered.connect(_reset_auto_hide_timer)
	
	# Modal behavior
	if modal:
		mouse_filter = Control.MOUSE_FILTER_STOP
		z_index = 100
	
	# Resize handles
	if resizable:
		_create_resize_handles()

func _create_resize_handles() -> void:
	"""Create resize handles for the panel"""
	# For now, just bottom-right corner resize
	var resize_handle = Control.new()
	resize_handle.custom_minimum_size = Vector2(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
	resize_handle.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	resize_handle.position = -resize_handle.size
	resize_handle.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	resize_handle.gui_input.connect(_on_resize_handle_input)
	add_child(resize_handle)

# === PUBLIC METHODS ===

func show_panel(animated: bool = true) -> void:
	"""Show the panel with animation"""
	show_component(animated)
	panel_opened.emit()
	_reset_auto_hide_timer()

func hide_panel(animated: bool = true) -> void:
	"""Hide the panel with animation"""
	hide_component(animated)
	panel_closed.emit()
	if _auto_hide_timer:
		_auto_hide_timer.stop()

func minimize_panel() -> void:
	"""Minimize the panel"""
	if _is_minimized:
		return
	
	_is_minimized = true
	_content_container.visible = false
	if _footer_container:
		_footer_container.visible = false
	
	# Adjust size to just show header
	custom_minimum_size.y = HEADER_HEIGHT
	size.y = HEADER_HEIGHT
	
	panel_minimized.emit()

func maximize_panel() -> void:
	"""Maximize the panel to fill viewport"""
	if _is_maximized:
		return
	
	_pre_maximize_rect = Rect2(position, size)
	_is_maximized = true
	
	# Fill viewport with margins
	var viewport_size = get_viewport_rect().size
	position = Vector2(PANEL_MARGIN, PANEL_MARGIN)
	size = viewport_size - Vector2(PANEL_MARGIN * 2, PANEL_MARGIN * 2)
	
	panel_maximized.emit()

func restore_panel() -> void:
	"""Restore panel from minimized/maximized state"""
	if _is_minimized:
		_is_minimized = false
		_content_container.visible = true
		if _footer_container:
			_footer_container.visible = true
		custom_minimum_size = MIN_PANEL_SIZE
	
	if _is_maximized:
		_is_maximized = false
		position = _pre_maximize_rect.position
		size = _pre_maximize_rect.size

func set_panel_title(value: String) -> void:
	"""Set the panel title"""
	panel_title = value
	if _title_label:
		_title_label.text = value

func get_content_container() -> Control:
	"""Get the content container for adding custom content"""
	return _content_container

func add_to_footer(control: Control) -> void:
	"""Add a control to the panel footer"""
	if _footer_container:
		_footer_container.visible = true
		_footer_container.add_child(control)

# === PRIVATE METHODS ===

func _apply_panel_styling() -> void:
	"""Apply visual styling to the panel"""
	if not _panel_container:
		return
	
	# Create custom panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = panel_color
	panel_style.border_color = border_color
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = corner_radius
	panel_style.corner_radius_top_right = corner_radius
	panel_style.corner_radius_bottom_left = corner_radius
	panel_style.corner_radius_bottom_right = corner_radius
	
	_panel_container.add_theme_stylebox_override("panel", panel_style)
	
	# Header styling
	if _header_container:
		var header_style = StyleBoxFlat.new()
		header_style.bg_color = header_color
		header_style.corner_radius_top_left = corner_radius
		header_style.corner_radius_top_right = corner_radius
		_header_container.add_theme_stylebox_override("panel", header_style)
	
	# Apply glass effect if enabled
	if use_glass_effect:
		_apply_glass_effect()

func _apply_glass_effect() -> void:
	"""Apply glass morphism effect to panel"""
	# This would integrate with the existing glass shader system
	# For now, just a placeholder
	modulate.a = 0.95

func _on_header_input(event: InputEvent) -> void:
	"""Handle header input for dragging"""
	if not draggable:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_drag_offset = get_global_mouse_position() - global_position
			else:
				_is_dragging = false
	
	elif event is InputEventMouseMotion and _is_dragging:
		var new_position = get_global_mouse_position() - _drag_offset
		global_position = new_position
		panel_dragged.emit(new_position)

func _on_resize_handle_input(event: InputEvent) -> void:
	"""Handle resize handle input"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_resizing = true
				_resize_start_size = size
				_resize_start_pos = get_global_mouse_position()
			else:
				_is_resizing = false
	
	elif event is InputEventMouseMotion and _is_resizing:
		var delta = get_global_mouse_position() - _resize_start_pos
		var new_size = _resize_start_size + delta
		new_size.x = max(new_size.x, MIN_PANEL_SIZE.x)
		new_size.y = max(new_size.y, MIN_PANEL_SIZE.y)
		size = new_size
		panel_resized.emit(new_size)

func _on_close_pressed() -> void:
	"""Handle close button press"""
	hide_panel()

func _on_minimize_pressed() -> void:
	"""Handle minimize button press"""
	if _is_minimized:
		restore_panel()
	else:
		minimize_panel()

func _on_maximize_pressed() -> void:
	"""Handle maximize button press"""
	if _is_maximized:
		restore_panel()
	else:
		maximize_panel()

func _reset_auto_hide_timer() -> void:
	"""Reset the auto-hide timer"""
	if _auto_hide_timer:
		_auto_hide_timer.stop()
		_auto_hide_timer.start()

func _save_panel_state() -> void:
	"""Save panel state for persistence"""
	_panel_state = {
		"position": position,
		"size": size,
		"visible": visible,
		"minimized": _is_minimized,
		"maximized": _is_maximized
	}

func _restore_panel_state() -> void:
	"""Restore panel state from saved data"""
	if not remember_position or _panel_state.is_empty():
		return
	
	if _panel_state.has("position"):
		position = _panel_state.position
	if _panel_state.has("size"):
		size = _panel_state.size
	if _panel_state.has("minimized") and _panel_state.minimized:
		minimize_panel()
	if _panel_state.has("maximized") and _panel_state.maximized:
		maximize_panel()