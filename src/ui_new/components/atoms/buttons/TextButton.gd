## TextButton.gd
## Standard text button component for NeuroVision
##
## Extends BaseButton with text-specific functionality while preserving
## the enhanced features from the original EnhancedButton implementation.
## This is the primary button component for most UI needs.

class_name TextButton
extends NVBaseButton

# === EXPORT VARIABLES ===
@export_group("Text Configuration")
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER : set = set_text_alignment
@export var text_overflow_mode: TextServer.OverrunBehavior = TextServer.OVERRUN_TRIM_ELLIPSIS : set = set_text_overflow_mode
@export var auto_translate: bool = true : set = set_auto_translate

@export_group("Enhanced Features")
@export var enable_enhanced_feedback: bool = true
@export var press_scale_factor: float = 0.95
@export var hover_elevation: int = 2
@export var ripple_max_scale: float = 2.0

# === PRIVATE VARIABLES ===
var _enhanced_animator: Node  # ButtonAnimator
var _original_theme_cache: Dictionary = {}

# === INITIALIZATION ===

func _on_ready() -> void:
	"""Initialize text button with enhanced features"""
	super._on_ready()
	
	# Create enhanced animator for advanced effects
	if enable_enhanced_feedback:
		_setup_enhanced_animator()
	
	# Apply text-specific configuration
	_configure_text_properties()
	
	# Set default variant if not specified
	if variant == ButtonVariant.DEFAULT:
		variant = ButtonVariant.PRIMARY

func _setup_enhanced_animator() -> void:
	"""Set up the enhanced animation system"""
	var ButtonAnimator = load("res://src/ui_new/components/atoms/buttons/ButtonAnimator.gd")
	_enhanced_animator = ButtonAnimator.new()
	_enhanced_animator.button = self
	_enhanced_animator.press_scale_factor = press_scale_factor
	_enhanced_animator.hover_elevation = hover_elevation
	_enhanced_animator.ripple_max_scale = ripple_max_scale
	add_child(_enhanced_animator)

func _configure_text_properties() -> void:
	"""Configure text-specific properties"""
	if _label:
		_label.horizontal_alignment = text_alignment
		_label.text_overrun_behavior = text_overflow_mode
		_label.auto_translate = auto_translate

# === PUBLIC METHODS ===

func set_text_alignment(value: HorizontalAlignment) -> void:
	"""Set text alignment"""
	text_alignment = value
	if _label:
		_label.horizontal_alignment = value

func set_text_overflow_mode(value: TextServer.OverrunBehavior) -> void:
	"""Set text overflow behavior"""
	text_overflow_mode = value
	if _label:
		_label.text_overrun_behavior = value

func set_auto_translate(value: bool) -> void:
	"""Set auto-translation for text"""
	auto_translate = value
	if _label:
		_label.auto_translate = value

func set_enhanced_feedback_enabled(enabled: bool) -> void:
	"""Enable or disable enhanced feedback effects"""
	enable_enhanced_feedback = enabled
	if _enhanced_animator:
		_enhanced_animator.set_enabled(enabled)

# === THEME CUSTOMIZATION ===

func apply_text_style(style_name: String) -> void:
	"""Apply a predefined text style"""
	match style_name:
		"heading":
			if _label:
				_label.add_theme_font_size_override("font_size", 18)
				_label.add_theme_font_override("font", preload("res://assets/fonts/bold.ttf"))
		"body":
			if _label:
				_label.add_theme_font_size_override("font_size", 14)
		"caption":
			if _label:
				_label.add_theme_font_size_override("font_size", 12)
				_label.modulate.a = 0.8

# === FACTORY METHODS ===

static func create_primary(text: String) -> TextButton:
	"""Create a primary action button"""
	var button = TextButton.new()
	button.text = text
	button.variant = ButtonVariant.PRIMARY
	button.size = ButtonSize.MEDIUM
	return button

static func create_secondary(text: String) -> TextButton:
	"""Create a secondary action button"""
	var button = TextButton.new()
	button.text = text
	button.variant = ButtonVariant.SECONDARY
	button.size = ButtonSize.MEDIUM
	return button

static func create_danger(text: String) -> TextButton:
	"""Create a danger/destructive action button"""
	var button = TextButton.new()
	button.text = text
	button.variant = ButtonVariant.DANGER
	button.size = ButtonSize.MEDIUM
	return button

static func create_ghost(text: String) -> TextButton:
	"""Create a ghost button (no background)"""
	var button = TextButton.new()
	button.text = text
	button.variant = ButtonVariant.GHOST
	button.flat = true
	button.size = ButtonSize.MEDIUM
	return button

static func create_link(text: String) -> TextButton:
	"""Create a link-style button"""
	var button = TextButton.new()
	button.text = text
	button.variant = ButtonVariant.LINK
	button.flat = true
	button.outlined = false
	button.size = ButtonSize.MEDIUM
	# Add underline on hover
	button.mouse_entered.connect(func(): button._label.add_theme_font_override("font", preload("res://assets/fonts/underline.ttf")))
	button.mouse_exited.connect(func(): button._label.remove_theme_font_override("font"))
	return button

# === ENHANCED ANIMATION OVERRIDES ===

func _on_mouse_entered() -> void:
	"""Enhanced mouse enter with elevation"""
	super._on_mouse_entered()
	
	if enable_enhanced_feedback and _enhanced_animator:
		_enhanced_animator.animate_hover_enter()

func _on_mouse_exited() -> void:
	"""Enhanced mouse exit"""
	super._on_mouse_exited()
	
	if enable_enhanced_feedback and _enhanced_animator:
		_enhanced_animator.animate_hover_exit()

func _on_button_down() -> void:
	"""Enhanced button press"""
	super._on_button_down()
	
	if enable_enhanced_feedback and _enhanced_animator:
		_enhanced_animator.animate_press()

func _on_button_up() -> void:
	"""Enhanced button release"""
	super._on_button_up()
	
	if enable_enhanced_feedback and _enhanced_animator:
		_enhanced_animator.animate_release()

# === ACCESSIBILITY ENHANCEMENTS ===

func _get_accessibility_description() -> String:
	"""Generate accessibility description for screen readers"""
	var description = text
	
	match variant:
		ButtonVariant.PRIMARY:
			description += " primary action button"
		ButtonVariant.DANGER:
			description += " danger button, this action cannot be undone"
		ButtonVariant.GHOST:
			description += " ghost button"
		ButtonVariant.LINK:
			description += " link button"
		_:
			description += " button"
	
	if disabled:
		description += ", disabled"
	
	if toggle_mode:
		description += ", toggle button, currently " + ("pressed" if button_pressed else "not pressed")
	
	return description

# === THEMING INTERFACE ===

func get_theme_properties() -> Dictionary:
	"""Extended theme properties for text buttons"""
	var props = super.get_theme_properties()
	
	# Add text-specific properties
	props.fonts["bold_font"] = "Bold font variant"
	props.fonts["italic_font"] = "Italic font variant"
	props.constants["text_spacing"] = "Letter spacing"
	props.constants["line_spacing"] = "Line height multiplier"
	
	return props