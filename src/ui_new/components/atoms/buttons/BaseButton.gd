## BaseButton.gd
## Base class for all button components in NeuroVision
##
## Extends BaseComponent with button-specific functionality:
## - Click handling with proper event propagation
## - Hover and focus states
## - Button variants (primary, secondary, etc.)
## - Icon support
## - Loading states
## - Ripple effects (Material design)
## - Keyboard shortcuts

class_name NVBaseButton
extends BaseComponent

# === SIGNALS ===
signal pressed()
signal button_down()
signal button_up()
signal toggled(pressed: bool)
signal hover_started()
signal hover_ended()
signal focus_entered()
signal focus_exited()

# === CONSTANTS ===
const CLICK_ANIMATION_DURATION := 0.1
const HOVER_ANIMATION_DURATION := 0.2
const RIPPLE_DURATION := 0.6
const DEFAULT_PADDING := Vector2(16, 8)

# === ENUMS ===
enum ButtonVariant {
	DEFAULT,
	PRIMARY,
	SECONDARY,
	SUCCESS,
	WARNING,
	DANGER,
	GHOST,
	LINK,
	CUSTOM
}

enum ButtonSize {
	SMALL,
	MEDIUM,
	LARGE,
	EXTRA_LARGE
}

enum IconPosition {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

# === EXPORT VARIABLES ===
@export_group("Button Configuration")
@export var text: String = "" : set = set_text
@export var variant: ButtonVariant = ButtonVariant.DEFAULT : set = set_variant
@export var size: ButtonSize = ButtonSize.MEDIUM : set = set_size
@export var disabled: bool = false : set = set_disabled
@export var toggle_mode: bool = false
@export var button_pressed: bool = false : set = set_pressed
@export var action_mode: Button.ActionMode = Button.ACTION_MODE_BUTTON_RELEASE

@export_group("Button Appearance")
@export var flat: bool = false : set = set_flat
@export var outlined: bool = false : set = set_outlined
@export var rounded: bool = true
@export var full_width: bool = false
@export var custom_minimum_size_enabled: bool = true

@export_group("Icon Settings")
@export var icon: Texture2D : set = set_icon
@export var icon_position: IconPosition = IconPosition.LEFT : set = set_icon_position
@export var icon_spacing: float = 8.0
@export var expand_icon: bool = false

@export_group("Effects")
@export var enable_ripple: bool = true
@export var enable_hover_effect: bool = true
@export var enable_press_effect: bool = true
@export var enable_sound: bool = true

@export_group("Keyboard")
@export var shortcut: Shortcut
@export var shortcut_in_tooltip: bool = true

# === PRIVATE VARIABLES ===
var _button_control: Button
var _label: Label
var _icon_rect: TextureRect
var _ripple_container: Control
var _loading_spinner: Control

var _is_hovered: bool = false
var _is_pressed: bool = false
var _is_loading: bool = false

var _original_scale: Vector2 = Vector2.ONE
var _hover_tween: Tween
var _press_tween: Tween
var _ripple_instances: Array = []

# Size configurations
var _size_configs = {
	ButtonSize.SMALL: {
		"font_size": 12,
		"padding": Vector2(12, 6),
		"min_size": Vector2(64, 28),
		"icon_size": 16
	},
	ButtonSize.MEDIUM: {
		"font_size": 14,
		"padding": Vector2(16, 8),
		"min_size": Vector2(80, 36),
		"icon_size": 20
	},
	ButtonSize.LARGE: {
		"font_size": 16,
		"padding": Vector2(20, 12),
		"min_size": Vector2(96, 44),
		"icon_size": 24
	},
	ButtonSize.EXTRA_LARGE: {
		"font_size": 18,
		"padding": Vector2(24, 16),
		"min_size": Vector2(112, 52),
		"icon_size": 28
	}
}

# === LIFECYCLE ===

func _on_ready() -> void:
	"""Initialize button structure"""
	_create_button_structure()
	_setup_button_signals()
	_apply_initial_configuration()
	_setup_accessibility_features()

func _on_theme_changed(theme: Theme) -> void:
	"""Apply theme to button"""
	super._on_theme_changed(theme)
	_update_button_style()

# === BUTTON STRUCTURE ===

func _create_button_structure() -> void:
	"""Create the internal button structure"""
	# Main button control
	_button_control = Button.new()
	_button_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button_control.flat = true  # We'll handle styling ourselves
	add_child(_button_control)
	
	# Ripple effect container
	if enable_ripple:
		_ripple_container = Control.new()
		_ripple_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_ripple_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_button_control.add_child(_ripple_container)
	
	# Content container for layout
	var content_container = HBoxContainer.new()
	content_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	content_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button_control.add_child(content_container)
	
	# Icon
	_icon_rect = TextureRect.new()
	_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content_container.add_child(_icon_rect)
	
	# Label
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	content_container.add_child(_label)
	
	# Loading spinner placeholder
	_loading_spinner = Control.new()
	_loading_spinner.visible = false
	_loading_spinner.custom_minimum_size = Vector2(20, 20)
	content_container.add_child(_loading_spinner)

func _setup_button_signals() -> void:
	"""Connect button signals"""
	_button_control.pressed.connect(_on_button_pressed)
	_button_control.button_down.connect(_on_button_down)
	_button_control.button_up.connect(_on_button_up)
	_button_control.toggled.connect(_on_button_toggled)
	_button_control.mouse_entered.connect(_on_mouse_entered)
	_button_control.mouse_exited.connect(_on_mouse_exited)
	_button_control.focus_entered.connect(_on_focus_entered)
	_button_control.focus_exited.connect(_on_focus_exited)

func _apply_initial_configuration() -> void:
	"""Apply initial configuration"""
	set_text(text)
	set_variant(variant)
	set_size(size)
	set_disabled(disabled)
	set_flat(flat)
	set_outlined(outlined)
	set_icon(icon)
	set_icon_position(icon_position)
	
	_button_control.toggle_mode = toggle_mode
	_button_control.button_pressed = button_pressed
	_button_control.action_mode = action_mode
	_button_control.shortcut = shortcut
	_button_control.shortcut_in_tooltip = shortcut_in_tooltip

func _setup_accessibility_features() -> void:
	"""Set up accessibility features"""
	# Ensure button is keyboard navigable
	_button_control.focus_mode = Control.FOCUS_ALL
	
	# Set up screen reader label
	if screen_reader_label.is_empty() and not text.is_empty():
		screen_reader_label = text
	
	# Apply accessibility metadata
	_button_control.set_meta("accessible_role", "button")
	_button_control.set_meta("accessible_label", screen_reader_label)

# === PUBLIC METHODS ===

func set_text(value: String) -> void:
	"""Set button text"""
	text = value
	if _label:
		_label.text = value
		_label.visible = not value.is_empty()

func set_variant(value: ButtonVariant) -> void:
	"""Set button variant"""
	variant = value
	if is_inside_tree():
		_update_button_style()

func set_size(value: ButtonSize) -> void:
	"""Set button size"""
	size = value
	if is_inside_tree():
		_apply_size_configuration()

func set_disabled(value: bool) -> void:
	"""Set button disabled state"""
	disabled = value
	if _button_control:
		_button_control.disabled = value
		modulate.a = 1.0 if not value else 0.6

func set_flat(value: bool) -> void:
	"""Set flat style"""
	flat = value
	if is_inside_tree():
		_update_button_style()

func set_outlined(value: bool) -> void:
	"""Set outlined style"""
	outlined = value
	if is_inside_tree():
		_update_button_style()

func set_icon(value: Texture2D) -> void:
	"""Set button icon"""
	icon = value
	if _icon_rect:
		_icon_rect.texture = value
		_icon_rect.visible = value != null
		_update_icon_layout()

func set_icon_position(value: IconPosition) -> void:
	"""Set icon position"""
	icon_position = value
	if is_inside_tree():
		_update_icon_layout()

func set_pressed(value: bool) -> void:
	"""Set pressed state (for toggle buttons)"""
	button_pressed = value
	if _button_control:
		_button_control.button_pressed = value

func set_loading(loading: bool) -> void:
	"""Set loading state"""
	_is_loading = loading
	
	if _loading_spinner:
		_loading_spinner.visible = loading
	
	if _label:
		_label.visible = not loading and not text.is_empty()
	
	if _icon_rect:
		_icon_rect.visible = not loading and icon != null
	
	set_disabled(loading)
	
	# Add loading animation
	if loading and _loading_spinner:
		_animate_loading_spinner()

func click() -> void:
	"""Programmatically click the button"""
	if not disabled:
		_on_button_pressed()

# === PRIVATE METHODS ===

func _update_button_style() -> void:
	"""Update button visual style based on variant"""
	if not _button_control:
		return
	
	# Get colors from theme based on variant
	var bg_color = _get_variant_color("background")
	var text_color = _get_variant_color("text")
	var border_color = _get_variant_color("border")
	
	# Create style
	var style = StyleBoxFlat.new()
	
	if not flat:
		style.bg_color = bg_color
	else:
		style.bg_color = Color.TRANSPARENT
	
	if outlined:
		style.border_color = border_color
		style.border_width_bottom = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
	
	if rounded:
		var radius = 4 * (_size_configs[size].font_size / 14.0)
		style.corner_radius_bottom_left = radius
		style.corner_radius_bottom_right = radius
		style.corner_radius_top_left = radius
		style.corner_radius_top_right = radius
	
	# Apply padding
	var padding = _size_configs[size].padding
	style.content_margin_bottom = padding.y
	style.content_margin_left = padding.x
	style.content_margin_right = padding.x
	style.content_margin_top = padding.y
	
	# Apply styles
	_button_control.add_theme_stylebox_override("normal", style)
	_button_control.add_theme_stylebox_override("hover", _create_hover_style(style))
	_button_control.add_theme_stylebox_override("pressed", _create_pressed_style(style))
	_button_control.add_theme_stylebox_override("disabled", _create_disabled_style(style))
	
	# Text color
	if _label:
		_label.add_theme_color_override("font_color", text_color)

func _get_variant_color(color_type: String) -> Color:
	"""Get color based on variant and type"""
	# This would integrate with the theme system
	# For now, return default colors
	match variant:
		ButtonVariant.PRIMARY:
			match color_type:
				"background": return Color(0.2, 0.5, 1.0)
				"text": return Color.WHITE
				"border": return Color(0.1, 0.4, 0.9)
		ButtonVariant.DANGER:
			match color_type:
				"background": return Color(0.9, 0.2, 0.2)
				"text": return Color.WHITE
				"border": return Color(0.8, 0.1, 0.1)
		_:
			match color_type:
				"background": return Color(0.2, 0.2, 0.2)
				"text": return Color.WHITE
				"border": return Color(0.3, 0.3, 0.3)
	
	return Color.WHITE

func _create_hover_style(base_style: StyleBoxFlat) -> StyleBoxFlat:
	"""Create hover state style"""
	var hover_style = base_style.duplicate()
	hover_style.bg_color = hover_style.bg_color.lightened(0.1)
	return hover_style

func _create_pressed_style(base_style: StyleBoxFlat) -> StyleBoxFlat:
	"""Create pressed state style"""
	var pressed_style = base_style.duplicate()
	pressed_style.bg_color = pressed_style.bg_color.darkened(0.1)
	return pressed_style

func _create_disabled_style(base_style: StyleBoxFlat) -> StyleBoxFlat:
	"""Create disabled state style"""
	var disabled_style = base_style.duplicate()
	disabled_style.bg_color = disabled_style.bg_color.darkened(0.3)
	return disabled_style

func _apply_size_configuration() -> void:
	"""Apply size configuration"""
	var config = _size_configs[size]
	
	# Set minimum size
	if custom_minimum_size_enabled:
		custom_minimum_size = config.min_size
	
	# Set font size
	if _label:
		_label.add_theme_font_size_override("font_size", config.font_size)
	
	# Set icon size
	if _icon_rect:
		_icon_rect.custom_minimum_size = Vector2(config.icon_size, config.icon_size)
	
	# Update style
	_update_button_style()

func _update_icon_layout() -> void:
	"""Update icon position in layout"""
	if not _icon_rect or not _icon_rect.get_parent():
		return
	
	var container = _icon_rect.get_parent()
	
	# Reorder children based on icon position
	match icon_position:
		IconPosition.LEFT:
			container.move_child(_icon_rect, 0)
		IconPosition.RIGHT:
			container.move_child(_icon_rect, container.get_child_count() - 1)

func _animate_loading_spinner() -> void:
	"""Animate loading spinner"""
	if not _loading_spinner or not _is_loading:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(_loading_spinner, "rotation", TAU, 1.0)

# === ANIMATION METHODS ===

func _on_mouse_entered() -> void:
	"""Handle mouse enter"""
	_is_hovered = true
	hover_started.emit()
	
	if enable_hover_effect and not disabled:
		_animate_hover(true)

func _on_mouse_exited() -> void:
	"""Handle mouse exit"""
	_is_hovered = false
	hover_ended.emit()
	
	if enable_hover_effect:
		_animate_hover(false)

func _animate_hover(entering: bool) -> void:
	"""Animate hover state"""
	if _hover_tween:
		_hover_tween.kill()
	
	_hover_tween = create_tween()
	
	var target_scale = _original_scale * 1.05 if entering else _original_scale
	_hover_tween.tween_property(self, "scale", target_scale, HOVER_ANIMATION_DURATION)

func _on_button_down() -> void:
	"""Handle button press down"""
	_is_pressed = true
	button_down.emit()
	
	if enable_press_effect and not disabled:
		_animate_press(true)
	
	if enable_ripple and not disabled:
		_create_ripple_effect()

func _on_button_up() -> void:
	"""Handle button press up"""
	_is_pressed = false
	button_up.emit()
	
	if enable_press_effect:
		_animate_press(false)

func _animate_press(pressing: bool) -> void:
	"""Animate press state"""
	if _press_tween:
		_press_tween.kill()
	
	_press_tween = create_tween()
	
	var target_scale = _original_scale * 0.95 if pressing else _original_scale
	_press_tween.tween_property(self, "scale", target_scale, CLICK_ANIMATION_DURATION)

func _create_ripple_effect() -> void:
	"""Create material design ripple effect"""
	if not _ripple_container:
		return
	
	var ripple = ColorRect.new()
	ripple.color = Color(1, 1, 1, 0.3)
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Position at click location
	var local_pos = _ripple_container.get_local_mouse_position()
	ripple.position = local_pos - Vector2(10, 10)
	ripple.size = Vector2(20, 20)
	
	# Make circular
	var style = StyleBoxFlat.new()
	style.bg_color = ripple.color
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	ripple.add_theme_stylebox_override("panel", style)
	
	_ripple_container.add_child(ripple)
	_ripple_instances.append(ripple)
	
	# Animate ripple
	var tween = create_tween()
	tween.set_parallel(true)
	
	var final_size = _button_control.size.length() * 2
	tween.tween_property(ripple, "size", Vector2(final_size, final_size), RIPPLE_DURATION)
	tween.tween_property(ripple, "position", local_pos - Vector2(final_size/2, final_size/2), RIPPLE_DURATION)
	tween.tween_property(ripple, "modulate:a", 0.0, RIPPLE_DURATION)
	
	tween.finished.connect(func(): 
		ripple.queue_free()
		_ripple_instances.erase(ripple)
	)

# === SIGNAL HANDLERS ===

func _on_button_pressed() -> void:
	"""Handle button press"""
	if enable_sound:
		# Play click sound
		pass
	
	if track_analytics:
		_track_event("button_clicked", {"variant": ButtonVariant.keys()[variant]})
	
	pressed.emit()

func _on_button_toggled(pressed: bool) -> void:
	"""Handle toggle button state change"""
	button_pressed = pressed
	toggled.emit(pressed)

func _on_focus_entered() -> void:
	"""Handle focus enter"""
	focus_entered.emit()

func _on_focus_exited() -> void:
	"""Handle focus exit"""
	focus_exited.emit()

# === THEME INTERFACE ===

func get_theme_type_name() -> String:
	"""Get theme type for this component"""
	return "Button"

func get_theme_properties() -> Dictionary:
	"""Get themeable properties"""
	return {
		"colors": {
			"font_color": "Button text color",
			"font_color_hover": "Button text color on hover",
			"font_color_pressed": "Button text color when pressed",
			"font_color_disabled": "Button text color when disabled",
			"icon_color": "Button icon color"
		},
		"styles": {
			"normal": "Default button style",
			"hover": "Button hover style",
			"pressed": "Button pressed style",
			"disabled": "Button disabled style",
			"focus": "Button focus style"
		},
		"fonts": {
			"font": "Button text font"
		},
		"constants": {
			"hseparation": "Horizontal separation between icon and text",
			"vseparation": "Vertical separation in button"
		}
	}