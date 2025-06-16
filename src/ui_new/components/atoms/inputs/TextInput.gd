## TextInput.gd
## Single-line text input component for NeuroVision
##
## Extends BaseInput with text-specific functionality:
## - Text entry and editing
## - Input masking (password, etc.)
## - Auto-completion
## - Text transformation
## - Copy/paste handling
## - Undo/redo support

class_name TextInput
extends BaseInput

# === SIGNALS ===
signal text_changed(new_text: String)
signal text_submitted(text: String)
signal selection_changed()
signal auto_complete_selected(option: String)

# === CONSTANTS ===
const AUTO_COMPLETE_MAX_ITEMS := 8
const AUTO_COMPLETE_DELAY := 0.3
const PASSWORD_MASK_CHAR := "•"

# === ENUMS ===
enum InputType {
	TEXT,
	PASSWORD,
	EMAIL,
	URL,
	NUMBER,
	PHONE,
	SEARCH
}

enum TextTransform {
	NONE,
	UPPERCASE,
	LOWERCASE,
	CAPITALIZE,
	TITLE_CASE
}

enum AutoCompleteMode {
	OFF,
	INLINE,      # Show completion inline
	DROPDOWN,    # Show dropdown list
	BOTH         # Show both inline and dropdown
}

# === EXPORT VARIABLES ===
@export_group("Text Input Settings")
@export var input_type: InputType = InputType.TEXT : set = set_input_type
@export var text_transform: TextTransform = TextTransform.NONE : set = set_text_transform
@export var allow_tabs: bool = false
@export var context_menu_enabled: bool = true
@export var middle_mouse_paste_enabled: bool = true
@export var deselect_on_focus_loss: bool = true

@export_group("Auto Complete")
@export var auto_complete_mode: AutoCompleteMode = AutoCompleteMode.OFF : set = set_auto_complete_mode
@export var auto_complete_options: PackedStringArray = [] : set = set_auto_complete_options
@export var auto_complete_min_chars: int = 2
@export var auto_complete_case_sensitive: bool = false
@export var custom_auto_complete_func: Callable

@export_group("Input Restrictions")
@export var allowed_characters: String = ""  # Empty = all allowed
@export var denied_characters: String = ""
@export var trim_spaces: bool = false
@export var allow_empty: bool = true
@export var min_length: int = 0

@export_group("Shortcuts")
@export var select_all_on_focus: bool = false
@export var clear_button_shortcut: InputEvent
@export var submit_on_enter: bool = true
@export var submit_on_focus_loss: bool = false

# === PRIVATE VARIABLES ===
var _line_edit: LineEdit
var _auto_complete_popup: PopupPanel
var _auto_complete_list: ItemList
var _auto_complete_timer: Timer

var _original_text: String = ""
var _filtered_options: PackedStringArray = []
var _is_auto_completing: bool = false
var _last_caret_position: int = 0

# Input type specific validation patterns
var _input_type_patterns = {
	InputType.EMAIL: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
	InputType.URL: "^(https?://)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?$",
	InputType.NUMBER: "^-?\\d*\\.?\\d+$",
	InputType.PHONE: "^[\\d\\s()+-]+$"
}

# === LIFECYCLE ===

func _on_ready() -> void:
	"""Initialize text input"""
	super._on_ready()
	_create_line_edit()
	_setup_auto_complete()
	_apply_input_type_settings()

# === SETUP ===

func _create_line_edit() -> void:
	"""Create and configure LineEdit"""
	# Replace placeholder control with LineEdit
	var old_control = _input_control
	
	_line_edit = LineEdit.new()
	_line_edit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_line_edit.flat = true  # Remove default styling
	_line_edit.context_menu_enabled = context_menu_enabled
	_line_edit.middle_mouse_paste_enabled = middle_mouse_paste_enabled
	_line_edit.deselect_on_focus_loss_enabled = deselect_on_focus_loss
	_line_edit.caret_blink = true
	_line_edit.caret_blink_interval = 0.5
	
	# Replace in parent
	if old_control.get_parent():
		var parent = old_control.get_parent()
		var index = old_control.get_index()
		parent.remove_child(old_control)
		parent.add_child(_line_edit)
		parent.move_child(_line_edit, index)
		old_control.queue_free()
	
	_input_control = _line_edit
	
	# Connect signals
	_line_edit.text_changed.connect(_on_text_changed)
	_line_edit.text_submitted.connect(_on_text_submitted)
	_line_edit.focus_entered.connect(_on_focus_entered)
	_line_edit.focus_exited.connect(_on_focus_exited)
	_line_edit.selection_active_changed.connect(_on_selection_changed)
	_line_edit.gui_input.connect(_on_line_edit_gui_input)
	
	# Apply initial settings
	_line_edit.placeholder_text = placeholder
	_line_edit.max_length = max_length if max_length > 0 else 0
	_line_edit.editable = not read_only
	_line_edit.select_all_on_focus = select_all_on_focus
	
	# Set initial text
	if default_value:
		_line_edit.text = default_value
		_original_text = default_value

func _setup_auto_complete() -> void:
	"""Set up auto-complete system"""
	if auto_complete_mode == AutoCompleteMode.OFF:
		return
	
	# Create timer for delayed auto-complete
	_auto_complete_timer = Timer.new()
	_auto_complete_timer.wait_time = AUTO_COMPLETE_DELAY
	_auto_complete_timer.one_shot = true
	_auto_complete_timer.timeout.connect(_show_auto_complete)
	add_child(_auto_complete_timer)
	
	# Create popup for dropdown
	if auto_complete_mode in [AutoCompleteMode.DROPDOWN, AutoCompleteMode.BOTH]:
		_auto_complete_popup = PopupPanel.new()
		_auto_complete_popup.unresizable = false
		_auto_complete_popup.popup_window = false
		add_child(_auto_complete_popup)
		
		# Create list
		_auto_complete_list = ItemList.new()
		_auto_complete_list.custom_minimum_size = Vector2(200, 0)
		_auto_complete_list.max_text_lines = 1
		_auto_complete_list.auto_height = true
		_auto_complete_list.max_columns = 1
		_auto_complete_list.same_column_width = true
		_auto_complete_list.item_selected.connect(_on_auto_complete_selected)
		_auto_complete_popup.add_child(_auto_complete_list)

func _apply_input_type_settings() -> void:
	"""Apply settings based on input type"""
	match input_type:
		InputType.PASSWORD:
			_line_edit.secret = true
			_line_edit.secret_character = PASSWORD_MASK_CHAR
			
		InputType.EMAIL:
			validation_pattern = _input_type_patterns[InputType.EMAIL]
			allowed_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@.-_+"
			text_transform = TextTransform.LOWERCASE
			
		InputType.URL:
			validation_pattern = _input_type_patterns[InputType.URL]
			text_transform = TextTransform.LOWERCASE
			
		InputType.NUMBER:
			validation_pattern = _input_type_patterns[InputType.NUMBER]
			allowed_characters = "0123456789.-"
			
		InputType.PHONE:
			validation_pattern = _input_type_patterns[InputType.PHONE]
			allowed_characters = "0123456789+- ()"
			
		InputType.SEARCH:
			set_icon(preload("res://assets/icons/search.svg") if FileAccess.file_exists("res://assets/icons/search.svg") else null)
			show_clear_button = true

# === PUBLIC METHODS ===

func set_text(text: String) -> void:
	"""Set input text"""
	if _line_edit:
		_line_edit.text = _apply_text_transform(text)
		set_value(_line_edit.text)

func get_text() -> String:
	"""Get input text"""
	return _line_edit.text if _line_edit else ""

func set_input_type(type: InputType) -> void:
	"""Set input type"""
	input_type = type
	if is_inside_tree():
		_apply_input_type_settings()

func set_text_transform(transform: TextTransform) -> void:
	"""Set text transformation"""
	text_transform = transform
	if _line_edit and not _line_edit.text.is_empty():
		_line_edit.text = _apply_text_transform(_line_edit.text)

func set_auto_complete_mode(mode: AutoCompleteMode) -> void:
	"""Set auto-complete mode"""
	auto_complete_mode = mode
	if is_inside_tree():
		_setup_auto_complete()

func set_auto_complete_options(options: PackedStringArray) -> void:
	"""Set auto-complete options"""
	auto_complete_options = options
	_filter_auto_complete_options()

func select_all() -> void:
	"""Select all text"""
	if _line_edit:
		_line_edit.select_all()

func select(from: int, to: int) -> void:
	"""Select text range"""
	if _line_edit:
		_line_edit.select(from, to)

func deselect() -> void:
	"""Clear selection"""
	if _line_edit:
		_line_edit.deselect()

func insert_text_at_caret(text: String) -> void:
	"""Insert text at current caret position"""
	if _line_edit:
		_line_edit.insert_text_at_caret(text)

func delete_text(from_column: int, to_column: int) -> void:
	"""Delete text in range"""
	if _line_edit:
		_line_edit.delete_text(from_column, to_column)

func set_caret_position(position: int) -> void:
	"""Set caret position"""
	if _line_edit:
		_line_edit.caret_column = position

func get_caret_position() -> int:
	"""Get current caret position"""
	return _line_edit.caret_column if _line_edit else 0

func undo() -> void:
	"""Undo last text change"""
	if _line_edit:
		# LineEdit doesn't have built-in undo, so we implement basic version
		_line_edit.text = _original_text
		text_changed.emit(_original_text)

func clear() -> void:
	"""Clear input"""
	super.clear()
	if _line_edit:
		_line_edit.text = ""
		_line_edit.clear()

# === OVERRIDE METHODS ===

func set_value(value: Variant) -> void:
	"""Override to handle text value"""
	super.set_value(str(value))
	if _line_edit:
		_line_edit.text = str(value)

func set_placeholder(text: String) -> void:
	"""Override to set LineEdit placeholder"""
	super.set_placeholder(text)
	if _line_edit:
		_line_edit.placeholder_text = text

func set_max_length(length: int) -> void:
	"""Override to set LineEdit max length"""
	super.set_max_length(length)
	if _line_edit:
		_line_edit.max_length = length if length > 0 else 0

func set_read_only(value: bool) -> void:
	"""Override to set LineEdit editable"""
	super.set_read_only(value)
	if _line_edit:
		_line_edit.editable = not value

# === PRIVATE METHODS ===

func _apply_text_transform(text: String) -> String:
	"""Apply text transformation"""
	match text_transform:
		TextTransform.UPPERCASE:
			return text.to_upper()
		TextTransform.LOWERCASE:
			return text.to_lower()
		TextTransform.CAPITALIZE:
			return text.capitalize()
		TextTransform.TITLE_CASE:
			# Title case each word
			var words = text.split(" ")
			for i in range(words.size()):
				words[i] = words[i].capitalize()
			return " ".join(words)
		_:
			return text

func _filter_text_input(text: String) -> String:
	"""Filter text based on allowed/denied characters"""
	var filtered = text
	
	# Apply allowed characters filter
	if not allowed_characters.is_empty():
		var new_text = ""
		for c in filtered:
			if c in allowed_characters:
				new_text += c
		filtered = new_text
	
	# Apply denied characters filter
	if not denied_characters.is_empty():
		for c in denied_characters:
			filtered = filtered.replace(c, "")
	
	# Trim spaces if needed
	if trim_spaces:
		filtered = filtered.strip_edges()
	
	return filtered

func _filter_auto_complete_options() -> void:
	"""Filter auto-complete options based on current text"""
	if not _line_edit or _line_edit.text.length() < auto_complete_min_chars:
		_filtered_options.clear()
		return
	
	var search_text = _line_edit.text
	if not auto_complete_case_sensitive:
		search_text = search_text.to_lower()
	
	_filtered_options.clear()
	
	# Use custom function if provided
	if custom_auto_complete_func and custom_auto_complete_func.is_valid():
		var results = custom_auto_complete_func.call(search_text)
		if results is Array:
			for result in results:
				_filtered_options.append(str(result))
	else:
		# Default filtering
		for option in auto_complete_options:
			var check_option = option
			if not auto_complete_case_sensitive:
				check_option = option.to_lower()
			
			if check_option.begins_with(search_text):
				_filtered_options.append(option)
				if _filtered_options.size() >= AUTO_COMPLETE_MAX_ITEMS:
					break

func _show_auto_complete() -> void:
	"""Show auto-complete suggestions"""
	_filter_auto_complete_options()
	
	if _filtered_options.is_empty():
		_hide_auto_complete()
		return
	
	_is_auto_completing = true
	
	# Inline completion
	if auto_complete_mode in [AutoCompleteMode.INLINE, AutoCompleteMode.BOTH]:
		# Show first suggestion as ghost text
		var first_option = _filtered_options[0]
		var current_text = _line_edit.text
		if first_option.begins_with(current_text):
			# This would require custom rendering for ghost text
			pass
	
	# Dropdown completion
	if auto_complete_mode in [AutoCompleteMode.DROPDOWN, AutoCompleteMode.BOTH] and _auto_complete_popup:
		_auto_complete_list.clear()
		
		for option in _filtered_options:
			_auto_complete_list.add_item(option)
		
		# Position popup below input
		var input_rect = _input_container.get_global_rect()
		_auto_complete_popup.position = Vector2(
			input_rect.position.x,
			input_rect.position.y + input_rect.size.y + 2
		)
		_auto_complete_popup.size = Vector2(
			input_rect.size.x,
			min(_filtered_options.size() * 30 + 8, 240)
		)
		
		_auto_complete_popup.popup()

func _hide_auto_complete() -> void:
	"""Hide auto-complete suggestions"""
	_is_auto_completing = false
	
	if _auto_complete_popup:
		_auto_complete_popup.hide()

func _accept_auto_complete(index: int = 0) -> void:
	"""Accept auto-complete suggestion"""
	if _filtered_options.is_empty() or index >= _filtered_options.size():
		return
	
	var selected = _filtered_options[index]
	_line_edit.text = selected
	_line_edit.caret_column = selected.length()
	
	_hide_auto_complete()
	auto_complete_selected.emit(selected)

# === SIGNAL HANDLERS ===

func _on_text_changed(new_text: String) -> void:
	"""Handle text change"""
	# Filter input
	var filtered = _filter_text_input(new_text)
	if filtered != new_text:
		_line_edit.text = filtered
		_line_edit.caret_column = min(_last_caret_position, filtered.length())
		return
	
	# Apply text transform
	var transformed = _apply_text_transform(filtered)
	if transformed != filtered:
		_line_edit.text = transformed
		_line_edit.caret_column = min(_line_edit.caret_column, transformed.length())
	
	# Update clear button visibility
	if _clear_button:
		_clear_button.visible = show_clear_button and not transformed.is_empty()
	
	# Update value
	set_value(transformed)
	text_changed.emit(transformed)
	
	# Auto-complete
	if auto_complete_mode != AutoCompleteMode.OFF:
		_auto_complete_timer.stop()
		if transformed.length() >= auto_complete_min_chars:
			_auto_complete_timer.start()
		else:
			_hide_auto_complete()
	
	_last_caret_position = _line_edit.caret_column

func _on_text_submitted(text: String) -> void:
	"""Handle text submission"""
	# Validate before submission
	if validation_mode != ValidationMode.NONE:
		if not _perform_validation():
			return
	
	# Hide auto-complete
	_hide_auto_complete()
	
	text_submitted.emit(text)
	value_submitted.emit(text)

func _on_selection_changed() -> void:
	"""Handle selection change"""
	selection_changed.emit()

func _on_line_edit_gui_input(event: InputEvent) -> void:
	"""Handle LineEdit input events"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_TAB:
				if _is_auto_completing:
					_accept_auto_complete(0)
					accept_event()
				elif not allow_tabs:
					# Let tab navigation work
					pass
					
			KEY_ESCAPE:
				if _is_auto_completing:
					_hide_auto_complete()
					accept_event()
					
			KEY_ENTER, KEY_KP_ENTER:
				if _is_auto_completing and _auto_complete_list and _auto_complete_list.is_anything_selected():
					_accept_auto_complete(_auto_complete_list.get_selected_items()[0])
					accept_event()
				elif submit_on_enter:
					_on_text_submitted(_line_edit.text)
					
			KEY_UP:
				if _is_auto_completing and _auto_complete_list:
					var current = _auto_complete_list.get_selected_items()
					if current.is_empty():
						_auto_complete_list.select(_auto_complete_list.item_count - 1)
					else:
						_auto_complete_list.select(max(0, current[0] - 1))
					accept_event()
					
			KEY_DOWN:
				if _is_auto_completing and _auto_complete_list:
					var current = _auto_complete_list.get_selected_items()
					if current.is_empty():
						_auto_complete_list.select(0)
					else:
						_auto_complete_list.select(min(_auto_complete_list.item_count - 1, current[0] + 1))
					accept_event()

func _on_auto_complete_selected(index: int) -> void:
	"""Handle auto-complete selection"""
	_accept_auto_complete(index)

func _on_focus_entered() -> void:
	"""Override focus entered"""
	super._on_focus_entered()
	
	# Store original text for undo
	_original_text = _line_edit.text
	
	# Select all if configured
	if select_all_on_focus:
		_line_edit.select_all()

func _on_focus_exited() -> void:
	"""Override focus exited"""
	super._on_focus_exited()
	
	# Submit on focus loss if configured
	if submit_on_focus_loss and _line_edit.text != _original_text:
		_on_text_submitted(_line_edit.text)
	
	# Hide auto-complete
	_hide_auto_complete()

# === FACTORY METHODS ===

static func create_email_input() -> TextInput:
	"""Create an email input field"""
	var input = TextInput.new()
	input.input_type = InputType.EMAIL
	input.placeholder = "email@example.com"
	input.label_text = "Email"
	input.required = true
	return input

static func create_password_input() -> TextInput:
	"""Create a password input field"""
	var input = TextInput.new()
	input.input_type = InputType.PASSWORD
	input.placeholder = "Enter password"
	input.label_text = "Password"
	input.required = true
	input.min_length = 8
	return input

static func create_search_input() -> TextInput:
	"""Create a search input field"""
	var input = TextInput.new()
	input.input_type = InputType.SEARCH
	input.placeholder = "Search..."
	input.show_clear_button = true
	return input

static func create_number_input(min_value: float = -INF, max_value: float = INF) -> TextInput:
	"""Create a number input field"""
	var input = TextInput.new()
	input.input_type = InputType.NUMBER
	input.placeholder = "0"
	
	# Add number range validation
	input.validation_func = func(value: String) -> bool:
		if value.is_empty():
			return true
		var num = value.to_float()
		return num >= min_value and num <= max_value
	
	return input