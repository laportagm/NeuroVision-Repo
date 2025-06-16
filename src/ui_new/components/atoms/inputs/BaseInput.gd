## BaseInput.gd
## Base class for all input components in NeuroVision
##
## Extends BaseComponent with input-specific functionality:
## - Value management and validation
## - Input states (focused, error, disabled)
## - Label and helper text support
## - Validation framework
## - Error handling
## - Input masking
## - Accessibility features

class_name BaseInput
extends BaseComponent

# === SIGNALS ===
signal value_changed(new_value: Variant)
signal value_submitted(value: Variant)
signal validation_changed(is_valid: bool)
signal focus_entered()
signal focus_exited()
signal error_state_changed(has_error: bool)
signal input_started()
signal input_ended()

# === CONSTANTS ===
const ERROR_SHAKE_AMOUNT := 5.0
const ERROR_SHAKE_DURATION := 0.3
const FOCUS_ANIMATION_DURATION := 0.2
const HELPER_TEXT_FADE_DURATION := 0.15

# === ENUMS ===
enum InputState {
	DEFAULT,
	FOCUSED,
	ERROR,
	SUCCESS,
	DISABLED,
	LOADING
}

enum ValidationMode {
	NONE,          # No validation
	ON_CHANGE,     # Validate as user types
	ON_SUBMIT,     # Validate on submit/blur
	CONTINUOUS     # Always validate
}

enum InputSize {
	SMALL,
	MEDIUM,
	LARGE
}

# === EXPORT VARIABLES ===
@export_group("Input Configuration")
@export var input_name: String = ""
@export var default_value: String = ""
@export var placeholder: String = "" : set = set_placeholder
@export var required: bool = false : set = set_required
@export var disabled: bool = false : set = set_disabled
@export var read_only: bool = false : set = set_read_only
@export var max_length: int = -1 : set = set_max_length

@export_group("Labels and Helper Text")
@export var label_text: String = "" : set = set_label_text
@export var helper_text: String = "" : set = set_helper_text
@export var error_text: String = "" : set = set_error_text
@export var success_text: String = "" : set = set_success_text
@export var show_character_count: bool = false
@export var floating_label: bool = false

@export_group("Validation")
@export var validation_mode: ValidationMode = ValidationMode.ON_SUBMIT
@export var validation_pattern: String = ""  # Regex pattern
@export var validation_func: Callable  # Custom validation function
@export var auto_validate: bool = true
@export var show_validation_icon: bool = true

@export_group("Appearance")
@export var input_size: InputSize = InputSize.MEDIUM : set = set_input_size
@export var outlined: bool = true : set = set_outlined
@export var filled: bool = false : set = set_filled
@export var rounded_corners: bool = true
@export var show_clear_button: bool = true
@export var icon: Texture2D : set = set_icon
@export var trailing_icon: Texture2D : set = set_trailing_icon

# === PRIVATE VARIABLES ===
var _input_container: PanelContainer
var _input_control: Control  # Actual input control (LineEdit, TextEdit, etc.)
var _label: Label
var _helper_label: Label
var _error_label: Label
var _character_count_label: Label
var _icon_left: TextureRect
var _icon_right: TextureRect
var _clear_button: Button
var _validation_icon: TextureRect

var _current_value: Variant
var _current_state: InputState = InputState.DEFAULT
var _is_valid: bool = true
var _is_focused: bool = false
var _has_content: bool = false

var _error_shake_tween: Tween
var _focus_tween: Tween
var _validation_timer: Timer

# Size configurations
var _size_configs = {
	InputSize.SMALL: {
		"height": 32,
		"padding": Vector2(12, 6),
		"font_size": 12,
		"icon_size": 16,
		"border_width": 1
	},
	InputSize.MEDIUM: {
		"height": 40,
		"padding": Vector2(16, 8),
		"font_size": 14,
		"icon_size": 20,
		"border_width": 2
	},
	InputSize.LARGE: {
		"height": 48,
		"padding": Vector2(20, 12),
		"font_size": 16,
		"icon_size": 24,
		"border_width": 2
	}
}

# === LIFECYCLE ===

func _on_ready() -> void:
	"""Initialize input structure"""
	_create_input_structure()
	_setup_validation_timer()
	_apply_initial_configuration()
	_setup_accessibility_features()
	
	# Set initial value
	if default_value:
		set_value(default_value)

func _on_theme_changed(theme: Theme) -> void:
	"""Apply theme to input"""
	super._on_theme_changed(theme)
	_update_input_style()

# === INPUT STRUCTURE ===

func _create_input_structure() -> void:
	"""Create the input control structure"""
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)
	
	# Label
	_label = Label.new()
	_label.visible = not label_text.is_empty()
	main_container.add_child(_label)
	
	# Input container
	_input_container = PanelContainer.new()
	_input_container.mouse_filter = Control.MOUSE_FILTER_PASS
	main_container.add_child(_input_container)
	
	# Input content container
	var input_content = HBoxContainer.new()
	input_content.add_theme_constant_override("separation", 8)
	_input_container.add_child(input_content)
	
	# Left icon
	_icon_left = TextureRect.new()
	_icon_left.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_left.visible = false
	input_content.add_child(_icon_left)
	
	# Input control placeholder (will be replaced by specific input type)
	_input_control = Control.new()
	_input_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_content.add_child(_input_control)
	
	# Clear button
	_clear_button = Button.new()
	_clear_button.flat = true
	_clear_button.icon = preload("res://assets/icons/close.svg") if FileAccess.file_exists("res://assets/icons/close.svg") else null
	_clear_button.visible = false
	_clear_button.pressed.connect(_on_clear_pressed)
	input_content.add_child(_clear_button)
	
	# Validation icon
	_validation_icon = TextureRect.new()
	_validation_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_validation_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_validation_icon.visible = false
	input_content.add_child(_validation_icon)
	
	# Right icon
	_icon_right = TextureRect.new()
	_icon_right.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_right.visible = false
	input_content.add_child(_icon_right)
	
	# Helper/Error text container
	var helper_container = HBoxContainer.new()
	main_container.add_child(helper_container)
	
	# Helper text
	_helper_label = Label.new()
	_helper_label.add_theme_font_size_override("font_size", 12)
	_helper_label.modulate.a = 0.7
	_helper_label.visible = false
	helper_container.add_child(_helper_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	helper_container.add_child(spacer)
	
	# Character count
	_character_count_label = Label.new()
	_character_count_label.add_theme_font_size_override("font_size", 12)
	_character_count_label.modulate.a = 0.7
	_character_count_label.visible = show_character_count
	helper_container.add_child(_character_count_label)
	
	# Error text (initially hidden, shares space with helper)
	_error_label = Label.new()
	_error_label.add_theme_font_size_override("font_size", 12)
	_error_label.modulate = Color(1, 0.3, 0.3)
	_error_label.visible = false
	# Position absolutely to overlay helper text
	_error_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_error_label.position.y = -20
	main_container.add_child(_error_label)

func _setup_validation_timer() -> void:
	"""Set up debounced validation timer"""
	_validation_timer = Timer.new()
	_validation_timer.wait_time = 0.5
	_validation_timer.one_shot = true
	_validation_timer.timeout.connect(_perform_validation)
	add_child(_validation_timer)

func _apply_initial_configuration() -> void:
	"""Apply initial settings"""
	set_label_text(label_text)
	set_helper_text(helper_text)
	set_placeholder(placeholder)
	set_disabled(disabled)
	set_read_only(read_only)
	set_max_length(max_length)
	set_required(required)
	set_input_size(input_size)
	set_outlined(outlined)
	set_filled(filled)
	set_icon(icon)
	set_trailing_icon(trailing_icon)
	
	_update_input_style()

func _setup_accessibility_features() -> void:
	"""Set up accessibility support"""
	# Set accessible role
	set_meta("accessible_role", "textbox")
	
	# Create accessible name from label
	if not screen_reader_label.is_empty():
		set_meta("accessible_name", screen_reader_label)
	elif not label_text.is_empty():
		set_meta("accessible_name", label_text)
	
	# Set additional properties
	set_meta("accessible_required", required)
	set_meta("accessible_invalid", not _is_valid)
	
	if not helper_text.is_empty():
		set_meta("accessible_description", helper_text)

# === PUBLIC METHODS ===

func set_value(value: Variant) -> void:
	"""Set input value"""
	var old_value = _current_value
	_current_value = value
	
	# Update character count
	_update_character_count()
	
	# Clear error state on new input
	if _current_state == InputState.ERROR:
		_set_state(InputState.DEFAULT)
	
	# Validate if needed
	if validation_mode == ValidationMode.ON_CHANGE or validation_mode == ValidationMode.CONTINUOUS:
		_validation_timer.start()
	
	value_changed.emit(value)
	
	# Track analytics
	if track_analytics and old_value != value:
		_track_event("input_changed", {"field": input_name})

func get_value() -> Variant:
	"""Get current input value"""
	return _current_value

func set_placeholder(text: String) -> void:
	"""Set placeholder text"""
	placeholder = text
	# Placeholder implementation depends on specific input type

func set_label_text(text: String) -> void:
	"""Set label text"""
	label_text = text
	if _label:
		_label.text = text
		_label.visible = not text.is_empty()

func set_helper_text(text: String) -> void:
	"""Set helper text"""
	helper_text = text
	if _helper_label:
		_helper_label.text = text
		_helper_label.visible = not text.is_empty() and _current_state != InputState.ERROR

func set_error_text(text: String) -> void:
	"""Set error text and show error state"""
	error_text = text
	_set_state(InputState.ERROR)
	
	if _error_label:
		_error_label.text = text
		_error_label.visible = not text.is_empty()
		_helper_label.visible = false
		
		# Shake animation
		if _error_shake_tween:
			_error_shake_tween.kill()
		
		_error_shake_tween = create_tween()
		_error_shake_tween.set_loops(2)
		_error_shake_tween.tween_property(
			_input_container,
			"position:x",
			position.x + ERROR_SHAKE_AMOUNT,
			ERROR_SHAKE_DURATION / 4
		)
		_error_shake_tween.tween_property(
			_input_container,
			"position:x",
			position.x - ERROR_SHAKE_AMOUNT,
			ERROR_SHAKE_DURATION / 4
		)
		_error_shake_tween.tween_property(
			_input_container,
			"position:x",
			position.x,
			ERROR_SHAKE_DURATION / 4
		)

func set_success_text(text: String) -> void:
	"""Set success text and show success state"""
	success_text = text
	_set_state(InputState.SUCCESS)
	
	if _helper_label:
		_helper_label.text = text
		_helper_label.visible = not text.is_empty()
		_helper_label.modulate = Color(0.3, 1, 0.3)
		_error_label.visible = false

func set_disabled(value: bool) -> void:
	"""Set disabled state"""
	disabled = value
	
	if disabled:
		_set_state(InputState.DISABLED)
	else:
		_set_state(InputState.DEFAULT)
	
	# Disable actual input control
	if _input_control:
		_input_control.set_process_input(not disabled)
		_input_control.modulate.a = 1.0 if not disabled else 0.6

func set_read_only(value: bool) -> void:
	"""Set read-only state"""
	read_only = value
	# Implementation depends on specific input type

func set_required(value: bool) -> void:
	"""Set required field status"""
	required = value
	
	if _label and required:
		_label.text = label_text + " *"
	
	set_meta("accessible_required", required)

func set_max_length(length: int) -> void:
	"""Set maximum input length"""
	max_length = length
	_update_character_count()

func set_input_size(size: InputSize) -> void:
	"""Set input size"""
	input_size = size
	
	if is_inside_tree():
		_apply_size_configuration()

func set_outlined(value: bool) -> void:
	"""Set outlined style"""
	outlined = value
	_update_input_style()

func set_filled(value: bool) -> void:
	"""Set filled style"""
	filled = value
	_update_input_style()

func set_icon(texture: Texture2D) -> void:
	"""Set leading icon"""
	icon = texture
	if _icon_left:
		_icon_left.texture = texture
		_icon_left.visible = texture != null

func set_trailing_icon(texture: Texture2D) -> void:
	"""Set trailing icon"""
	trailing_icon = texture
	if _icon_right:
		_icon_right.texture = texture
		_icon_right.visible = texture != null

func clear() -> void:
	"""Clear input value"""
	set_value("")
	_clear_button.visible = false

func focus() -> void:
	"""Focus the input"""
	if _input_control and _input_control.has_method("grab_focus"):
		_input_control.grab_focus()

func validate() -> bool:
	"""Manually trigger validation"""
	return _perform_validation()

func set_validation_function(validation_callable: Callable) -> void:
	"""Set custom validation function"""
	validation_func = validation_callable

func show_error(message: String) -> void:
	"""Show error with message"""
	set_error_text(message)

func clear_error() -> void:
	"""Clear error state"""
	_set_state(InputState.DEFAULT)
	_error_label.visible = false
	_helper_label.visible = not helper_text.is_empty()

# === PRIVATE METHODS ===

func _set_state(state: InputState) -> void:
	"""Set input state"""
	var old_state = _current_state
	_current_state = state
	
	if old_state == InputState.ERROR and state != InputState.ERROR:
		error_state_changed.emit(false)
	elif old_state != InputState.ERROR and state == InputState.ERROR:
		error_state_changed.emit(true)
	
	_update_input_style()
	_update_validation_icon()

func _update_input_style() -> void:
	"""Update input visual style based on state"""
	if not _input_container:
		return
	
	# Create appropriate style
	var style = StyleBoxFlat.new()
	
	# Base style
	var config = _size_configs[input_size]
	style.content_margin_left = config.padding.x
	style.content_margin_right = config.padding.x
	style.content_margin_top = config.padding.y
	style.content_margin_bottom = config.padding.y
	
	if rounded_corners:
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
	
	# Apply state-specific styling
	match _current_state:
		InputState.DEFAULT:
			if outlined:
				style.border_color = get_theme_color("font_color", "Label")
				style.border_color.a = 0.3
				style.border_width_left = config.border_width
				style.border_width_right = config.border_width
				style.border_width_top = config.border_width
				style.border_width_bottom = config.border_width
				style.bg_color = Color.TRANSPARENT
			elif filled:
				style.bg_color = get_theme_color("font_color", "Label")
				style.bg_color.a = 0.1
				
		InputState.FOCUSED:
			if outlined:
				style.border_color = get_theme_color("accent_color", "Editor") if has_theme_color("accent_color", "Editor") else Color(0.2, 0.5, 1.0)
				style.border_width_left = config.border_width
				style.border_width_right = config.border_width
				style.border_width_top = config.border_width
				style.border_width_bottom = config.border_width
				style.bg_color = Color.TRANSPARENT
			elif filled:
				style.bg_color = get_theme_color("accent_color", "Editor") if has_theme_color("accent_color", "Editor") else Color(0.2, 0.5, 1.0)
				style.bg_color.a = 0.2
				
		InputState.ERROR:
			style.border_color = Color(1, 0.3, 0.3)
			style.border_width_left = config.border_width
			style.border_width_right = config.border_width
			style.border_width_top = config.border_width
			style.border_width_bottom = config.border_width
			if filled:
				style.bg_color = Color(1, 0.3, 0.3)
				style.bg_color.a = 0.1
				
		InputState.SUCCESS:
			style.border_color = Color(0.3, 1, 0.3)
			style.border_width_left = config.border_width
			style.border_width_right = config.border_width
			style.border_width_top = config.border_width
			style.border_width_bottom = config.border_width
			if filled:
				style.bg_color = Color(0.3, 1, 0.3)
				style.bg_color.a = 0.1
				
		InputState.DISABLED:
			style.border_color = get_theme_color("font_color", "Label")
			style.border_color.a = 0.1
			style.border_width_left = config.border_width
			style.border_width_right = config.border_width
			style.border_width_top = config.border_width
			style.border_width_bottom = config.border_width
			if filled:
				style.bg_color = get_theme_color("font_color", "Label")
				style.bg_color.a = 0.05
	
	_input_container.add_theme_stylebox_override("panel", style)

func _update_validation_icon() -> void:
	"""Update validation icon based on state"""
	if not show_validation_icon or not _validation_icon:
		return
	
	match _current_state:
		InputState.ERROR:
			_validation_icon.texture = preload("res://assets/icons/error.svg") if FileAccess.file_exists("res://assets/icons/error.svg") else null
			_validation_icon.modulate = Color(1, 0.3, 0.3)
			_validation_icon.visible = true
		InputState.SUCCESS:
			_validation_icon.texture = preload("res://assets/icons/check.svg") if FileAccess.file_exists("res://assets/icons/check.svg") else null
			_validation_icon.modulate = Color(0.3, 1, 0.3)
			_validation_icon.visible = true
		_:
			_validation_icon.visible = false

func _update_character_count() -> void:
	"""Update character count display"""
	if not show_character_count or not _character_count_label:
		return
	
	var current_length = str(_current_value).length()
	
	if max_length > 0:
		_character_count_label.text = "%d/%d" % [current_length, max_length]
		
		# Color based on proximity to limit
		var ratio = float(current_length) / float(max_length)
		if ratio > 0.9:
			_character_count_label.modulate = Color(1, 0.3, 0.3)
		elif ratio > 0.8:
			_character_count_label.modulate = Color(1, 0.8, 0.3)
		else:
			_character_count_label.modulate = Color(1, 1, 1, 0.7)
	else:
		_character_count_label.text = str(current_length)

func _apply_size_configuration() -> void:
	"""Apply size configuration to input"""
	var config = _size_configs[input_size]
	
	# Set container height
	_input_container.custom_minimum_size.y = config.height
	
	# Update font sizes
	if _label:
		_label.add_theme_font_size_override("font_size", config.font_size)
	
	# Update icon sizes
	for icon_rect in [_icon_left, _icon_right, _validation_icon]:
		if icon_rect:
			icon_rect.custom_minimum_size = Vector2(config.icon_size, config.icon_size)
	
	if _clear_button:
		_clear_button.custom_minimum_size = Vector2(config.icon_size, config.icon_size)
	
	_update_input_style()

func _perform_validation() -> bool:
	"""Perform input validation"""
	if not auto_validate:
		return true
	
	var is_valid = true
	var error_message = ""
	
	# Required validation
	if required and str(_current_value).is_empty():
		is_valid = false
		error_message = "This field is required"
	
	# Pattern validation
	elif not validation_pattern.is_empty():
		var regex = RegEx.new()
		regex.compile(validation_pattern)
		if not regex.search(str(_current_value)):
			is_valid = false
			error_message = "Invalid format"
	
	# Custom validation
	elif validation_func and validation_func.is_valid():
		var result = validation_func.call(_current_value)
		if result is bool:
			is_valid = result
			if not is_valid:
				error_message = "Invalid input"
		elif result is String:
			is_valid = false
			error_message = result
	
	# Update state
	_is_valid = is_valid
	validation_changed.emit(is_valid)
	
	if is_valid:
		clear_error()
		if not success_text.is_empty():
			set_success_text(success_text)
	else:
		set_error_text(error_message)
	
	# Update accessibility
	set_meta("accessible_invalid", not is_valid)
	
	return is_valid

# === SIGNAL HANDLERS ===

func _on_focus_entered() -> void:
	"""Handle focus enter"""
	_is_focused = true
	_set_state(InputState.FOCUSED)
	
	# Animate focus
	if _focus_tween:
		_focus_tween.kill()
	
	_focus_tween = create_tween()
	_focus_tween.set_parallel(true)
	_focus_tween.tween_property(self, "scale", Vector2(1.02, 1.02), FOCUS_ANIMATION_DURATION)
	
	# Floating label animation
	if floating_label and _label:
		_animate_floating_label(true)
	
	focus_entered.emit()
	input_started.emit()

func _on_focus_exited() -> void:
	"""Handle focus exit"""
	_is_focused = false
	
	# Validate on blur
	if validation_mode == ValidationMode.ON_SUBMIT:
		_perform_validation()
	
	# Reset state if not error
	if _current_state != InputState.ERROR:
		_set_state(InputState.DEFAULT)
	
	# Animate unfocus
	if _focus_tween:
		_focus_tween.kill()
	
	_focus_tween = create_tween()
	_focus_tween.tween_property(self, "scale", Vector2.ONE, FOCUS_ANIMATION_DURATION)
	
	# Floating label animation
	if floating_label and _label and str(_current_value).is_empty():
		_animate_floating_label(false)
	
	focus_exited.emit()
	input_ended.emit()

func _on_clear_pressed() -> void:
	"""Handle clear button press"""
	clear()
	focus()

func _animate_floating_label(float_up: bool) -> void:
	"""Animate floating label"""
	if not _label:
		return
	
	var label_tween = create_tween()
	
	if float_up:
		label_tween.set_parallel(true)
		label_tween.tween_property(_label, "position:y", -20, 0.2)
		label_tween.tween_property(_label, "scale", Vector2(0.8, 0.8), 0.2)
		label_tween.tween_property(_label, "modulate:a", 0.7, 0.2)
	else:
		label_tween.set_parallel(true)
		label_tween.tween_property(_label, "position:y", 0, 0.2)
		label_tween.tween_property(_label, "scale", Vector2.ONE, 0.2)
		label_tween.tween_property(_label, "modulate:a", 1.0, 0.2)

# === THEME INTERFACE ===

func get_theme_type_name() -> String:
	"""Get theme type for this component"""
	return "LineEdit"  # Base theme type

func get_theme_properties() -> Dictionary:
	"""Get themeable properties"""
	return {
		"colors": {
			"font_color": "Input text color",
			"font_color_placeholder": "Placeholder text color",
			"font_color_disabled": "Disabled text color",
			"selection_color": "Text selection color",
			"cursor_color": "Text cursor color",
			"border_color": "Input border color",
			"border_color_focus": "Focused border color",
			"border_color_error": "Error border color",
			"background_color": "Input background color"
		},
		"constants": {
			"border_width": "Border thickness",
			"corner_radius": "Corner radius",
			"padding_left": "Left padding",
			"padding_right": "Right padding",
			"padding_top": "Top padding",
			"padding_bottom": "Bottom padding"
		},
		"fonts": {
			"font": "Input text font"
		},
		"font_sizes": {
			"font_size": "Input text size"
		}
	}