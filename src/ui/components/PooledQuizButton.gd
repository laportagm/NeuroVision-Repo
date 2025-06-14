class_name PooledQuizButton
extends Button

## Pooled quiz answer button with automatic reset capabilities
## Implements the reset() interface required by UIPoolManager

# === SIGNALS ===
## Emitted when this button is selected as an answer
signal answer_selected(option_index: int, option_text: String)

# === PRIVATE VARIABLES ===
var _option_index: int = -1
var _original_style_normal: StyleBox = null
var _original_style_hover: StyleBox = null
var _original_style_pressed: StyleBox = null

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the pooled quiz button"""
	# Store original styles for reset
	_original_style_normal = get_theme_stylebox("normal")
	_original_style_hover = get_theme_stylebox("hover")
	_original_style_pressed = get_theme_stylebox("pressed")
	
	# Connect pressed signal
	pressed.connect(_on_button_pressed)

func setup_option(index: int, option_text: String) -> void:
	"""Configure the button for a specific quiz option"""
	_option_index = index
	text = "%s. %s" % [char(65 + index), option_text]  # A, B, C, D...
	
	# Apply Material 3 styling if available
	if ClassDB.class_exists("M3ComponentApplicator"):
		M3ComponentApplicator.apply_m3_button_styling(self, M3ComponentApplicator.ButtonVariant.TERTIARY)
	
	# Enable keyboard navigation
	focus_mode = Control.FOCUS_ALL
	
	# Add number key shortcuts (1-4 for typical quiz)
	if index < 9:  # Support keys 1-9
		var shortcut = Shortcut.new()
		var key = InputEventKey.new()
		key.keycode = KEY_1 + index
		shortcut.events = [key]
		self.shortcut = shortcut

func set_selected_state(selected: bool) -> void:
	"""Set the visual selected state of the button"""
	button_pressed = selected
	
	if selected:
		# Apply selected styling
		modulate = Color(1.2, 1.2, 1.0)  # Slight yellow tint
	else:
		modulate = Color.WHITE

func get_option_index() -> int:
	"""Get the option index for this button"""
	return _option_index

func get_option_text() -> String:
	"""Get the clean option text (without letter prefix)"""
	if text.length() > 3 and text.substr(1, 2) == ". ":
		return text.substr(3)  # Remove "A. " prefix
	return text

func reset() -> void:
	"""Reset the button to its initial state (required by UIPoolManager)"""
	# Clear text and state
	text = ""
	_option_index = -1
	button_pressed = false
	disabled = false
	modulate = Color.WHITE
	
	# Reset visual styles
	if _original_style_normal:
		add_theme_stylebox_override("normal", _original_style_normal)
	if _original_style_hover:
		add_theme_stylebox_override("hover", _original_style_hover)
	if _original_style_pressed:
		add_theme_stylebox_override("pressed", _original_style_pressed)
	
	# Clear shortcuts
	shortcut = null
	
	# Disconnect any additional signals (keep the main pressed signal)
	var connections = get_signal_connection_list("answer_selected")
	for connection in connections:
		answer_selected.disconnect(connection.callable)
	
	# Reset focus neighbors (will be set by parent when used)
	focus_neighbor_top = NodePath()
	focus_neighbor_bottom = NodePath()
	focus_neighbor_left = NodePath()
	focus_neighbor_right = NodePath()

# === ACCESSIBILITY METHODS ===

func announce_selection() -> void:
	"""Announce selection for screen readers"""
	if has_node("/root/AccessibilityManager") and AccessibilityManager.is_screen_reader_enabled():
		AccessibilityManager.announce("Selected option %s" % text)

# === PRIVATE METHODS ===

func _on_button_pressed() -> void:
	"""Handle button press and emit custom signal"""
	if _option_index >= 0:
		answer_selected.emit(_option_index, get_option_text())
		announce_selection()

func _gui_input(event: InputEvent) -> void:
	"""Handle additional input for accessibility"""
	super._gui_input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE, KEY_ENTER:
				if has_focus():
					_on_button_pressed()

# === UTILITY METHODS ===

func get_pool_info() -> Dictionary:
	"""Get information about this pooled object for debugging"""
	return {
		"pool_name": get_meta("pool_name", "unknown"),
		"is_pooled": get_meta("pooled_object", false),
		"option_index": _option_index,
		"option_text": get_option_text(),
		"is_in_scene": get_parent() != null
	}