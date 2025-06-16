## BaseLabel.gd
## Base class for all label components in NeuroVision
##
## Extends BaseComponent with label-specific functionality:
## - Text rendering with theme integration
## - Auto-sizing and text wrapping
## - Rich text support
## - Typography presets
## - Accessibility features
## - Dynamic text updates with animations

class_name BaseLabel
extends BaseComponent

# === SIGNALS ===
signal text_changed(new_text: String)
signal text_overflow_changed(is_overflowing: bool)
signal link_clicked(url: String)
signal size_calculated(text_size: Vector2)

# === CONSTANTS ===
const MIN_FONT_SIZE := 10
const MAX_FONT_SIZE := 72
const DEFAULT_LINE_SPACING := 1.2
const TRUNCATE_SUFFIX := "..."

# === ENUMS ===
enum TextAlign {
	LEFT,
	CENTER,
	RIGHT,
	JUSTIFY
}

enum VerticalAlign {
	TOP,
	CENTER,
	BOTTOM
}

enum TypographyPreset {
	DISPLAY_LARGE,
	DISPLAY_MEDIUM,
	DISPLAY_SMALL,
	HEADLINE_LARGE,
	HEADLINE_MEDIUM,
	HEADLINE_SMALL,
	TITLE_LARGE,
	TITLE_MEDIUM,
	TITLE_SMALL,
	BODY_LARGE,
	BODY_MEDIUM,
	BODY_SMALL,
	LABEL_LARGE,
	LABEL_MEDIUM,
	LABEL_SMALL
}

enum OverflowMode {
	VISIBLE,       # Show all text, may overflow bounds
	TRUNCATE,      # Cut off with ellipsis
	WRAP,          # Wrap to next line
	SHRINK,        # Reduce font size to fit
	SCROLL         # Enable scrolling
}

# === EXPORT VARIABLES ===
@export_group("Text Content")
@export_multiline var text: String = "" : set = set_text
@export var bbcode_enabled: bool = false : set = set_bbcode_enabled
@export var auto_translate: bool = true
@export var placeholder_text: String = ""
@export var placeholder_alpha: float = 0.5

@export_group("Typography")
@export var typography_preset: TypographyPreset = TypographyPreset.BODY_MEDIUM : set = set_typography_preset
@export var custom_font: Font : set = set_custom_font
@export var font_size: int = 14 : set = set_font_size
@export var line_spacing: float = DEFAULT_LINE_SPACING : set = set_line_spacing
@export var letter_spacing: float = 0.0 : set = set_letter_spacing
@export var font_color: Color = Color.WHITE : set = set_font_color
@export var use_theme_color: bool = true

@export_group("Layout")
@export var text_align: TextAlign = TextAlign.LEFT : set = set_text_align
@export var vertical_align: VerticalAlign = VerticalAlign.TOP : set = set_vertical_align
@export var overflow_mode: OverflowMode = OverflowMode.WRAP : set = set_overflow_mode
@export var max_lines: int = -1 : set = set_max_lines
@export var min_font_size: int = MIN_FONT_SIZE
@export var auto_size: bool = false : set = set_auto_size

@export_group("Effects")
@export var outline_enabled: bool = false : set = set_outline_enabled
@export var outline_size: int = 1 : set = set_outline_size
@export var outline_color: Color = Color.BLACK : set = set_outline_color
@export var shadow_enabled: bool = false : set = set_shadow_enabled
@export var shadow_offset: Vector2 = Vector2(2, 2) : set = set_shadow_offset
@export var shadow_color: Color = Color(0, 0, 0, 0.5) : set = set_shadow_color

@export_group("Animation")
@export var animate_text_changes: bool = true
@export var typewriter_enabled: bool = false
@export var typewriter_speed: float = 0.05
@export var fade_in_duration: float = 0.3

# === PRIVATE VARIABLES ===
var _label: Label
var _rich_label: RichTextLabel
var _scroll_container: ScrollContainer
var _active_label: Control

var _is_overflowing: bool = false
var _calculated_font_size: int
var _typewriter_tween: Tween
var _fade_tween: Tween

# Typography configurations based on Material 3
var _typography_configs = {
	TypographyPreset.DISPLAY_LARGE: {
		"font_size": 57,
		"line_height": 64,
		"letter_spacing": -0.25,
		"font_weight": 400
	},
	TypographyPreset.DISPLAY_MEDIUM: {
		"font_size": 45,
		"line_height": 52,
		"letter_spacing": 0,
		"font_weight": 400
	},
	TypographyPreset.DISPLAY_SMALL: {
		"font_size": 36,
		"line_height": 44,
		"letter_spacing": 0,
		"font_weight": 400
	},
	TypographyPreset.HEADLINE_LARGE: {
		"font_size": 32,
		"line_height": 40,
		"letter_spacing": 0,
		"font_weight": 400
	},
	TypographyPreset.HEADLINE_MEDIUM: {
		"font_size": 28,
		"line_height": 36,
		"letter_spacing": 0,
		"font_weight": 400
	},
	TypographyPreset.HEADLINE_SMALL: {
		"font_size": 24,
		"line_height": 32,
		"letter_spacing": 0,
		"font_weight": 400
	},
	TypographyPreset.TITLE_LARGE: {
		"font_size": 22,
		"line_height": 28,
		"letter_spacing": 0,
		"font_weight": 500
	},
	TypographyPreset.TITLE_MEDIUM: {
		"font_size": 16,
		"line_height": 24,
		"letter_spacing": 0.15,
		"font_weight": 500
	},
	TypographyPreset.TITLE_SMALL: {
		"font_size": 14,
		"line_height": 20,
		"letter_spacing": 0.1,
		"font_weight": 500
	},
	TypographyPreset.BODY_LARGE: {
		"font_size": 16,
		"line_height": 24,
		"letter_spacing": 0.5,
		"font_weight": 400
	},
	TypographyPreset.BODY_MEDIUM: {
		"font_size": 14,
		"line_height": 20,
		"letter_spacing": 0.25,
		"font_weight": 400
	},
	TypographyPreset.BODY_SMALL: {
		"font_size": 12,
		"line_height": 16,
		"letter_spacing": 0.4,
		"font_weight": 400
	},
	TypographyPreset.LABEL_LARGE: {
		"font_size": 14,
		"line_height": 20,
		"letter_spacing": 0.1,
		"font_weight": 500
	},
	TypographyPreset.LABEL_MEDIUM: {
		"font_size": 12,
		"line_height": 16,
		"letter_spacing": 0.5,
		"font_weight": 500
	},
	TypographyPreset.LABEL_SMALL: {
		"font_size": 11,
		"line_height": 16,
		"letter_spacing": 0.5,
		"font_weight": 500
	}
}

# === LIFECYCLE ===

func _on_ready() -> void:
	"""Initialize label structure"""
	_create_label_structure()
	_apply_initial_configuration()
	_setup_accessibility_features()

func _on_theme_changed(theme: Theme) -> void:
	"""Apply theme to label"""
	super._on_theme_changed(theme)
	_update_label_style()

# === LABEL STRUCTURE ===

func _create_label_structure() -> void:
	"""Create the appropriate label control based on settings"""
	if overflow_mode == OverflowMode.SCROLL:
		_create_scrollable_label()
	elif bbcode_enabled:
		_create_rich_label()
	else:
		_create_standard_label()

func _create_standard_label() -> void:
	"""Create a standard Label control"""
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.clip_text = overflow_mode == OverflowMode.TRUNCATE
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if overflow_mode == OverflowMode.WRAP else TextServer.AUTOWRAP_OFF
	add_child(_label)
	_active_label = _label

func _create_rich_label() -> void:
	"""Create a RichTextLabel for BBCode support"""
	_rich_label = RichTextLabel.new()
	_rich_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rich_label.bbcode_enabled = true
	_rich_label.fit_content = auto_size
	_rich_label.scroll_active = false
	_rich_label.meta_clicked.connect(_on_meta_clicked)
	add_child(_rich_label)
	_active_label = _rich_label

func _create_scrollable_label() -> void:
	"""Create a scrollable label setup"""
	_scroll_container = ScrollContainer.new()
	_scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_scroll_container)
	
	if bbcode_enabled:
		_create_rich_label()
		_scroll_container.add_child(_rich_label)
		_rich_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		_create_standard_label()
		_scroll_container.add_child(_label)
		_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _apply_initial_configuration() -> void:
	"""Apply initial settings to the label"""
	set_typography_preset(typography_preset)
	set_text(text)
	set_text_align(text_align)
	set_vertical_align(vertical_align)
	set_font_color(font_color)
	
	if custom_font:
		set_custom_font(custom_font)
	
	_update_effects()

func _setup_accessibility_features() -> void:
	"""Set up screen reader support"""
	if screen_reader_label.is_empty() and not text.is_empty():
		screen_reader_label = text.strip_edges()
	
	# Set accessibility metadata
	set_meta("accessible_role", "text")
	set_meta("accessible_value", text)

# === PUBLIC METHODS ===

func set_text(value: String) -> void:
	"""Set label text with optional animation"""
	var old_text = text
	text = value
	
	if not is_inside_tree():
		return
	
	# Update the appropriate label
	if _label:
		_label.text = value if not value.is_empty() else placeholder_text
		_label.modulate.a = 1.0 if not value.is_empty() else placeholder_alpha
	elif _rich_label:
		if bbcode_enabled:
			_rich_label.text = value if not value.is_empty() else "[color=#%s]%s[/color]" % [placeholder_alpha, placeholder_text]
		else:
			_rich_label.text = value if not value.is_empty() else placeholder_text
			_rich_label.modulate.a = 1.0 if not value.is_empty() else placeholder_alpha
	
	# Handle animations
	if animate_text_changes and old_text != value:
		if typewriter_enabled:
			_animate_typewriter()
		else:
			_animate_fade_transition()
	
	# Update overflow status
	_check_overflow()
	
	# Update accessibility
	set_meta("accessible_value", value)
	
	text_changed.emit(value)

func set_bbcode_enabled(value: bool) -> void:
	"""Enable/disable BBCode support"""
	if bbcode_enabled == value:
		return
	
	bbcode_enabled = value
	
	if is_inside_tree():
		# Recreate label structure
		if _active_label:
			_active_label.queue_free()
		_create_label_structure()
		_apply_initial_configuration()

func set_typography_preset(preset: TypographyPreset) -> void:
	"""Apply typography preset"""
	typography_preset = preset
	
	if not _typography_configs.has(preset):
		return
	
	var config = _typography_configs[preset]
	font_size = config.font_size
	line_spacing = config.line_height / float(config.font_size)
	letter_spacing = config.letter_spacing
	
	_update_label_style()

func set_custom_font(font: Font) -> void:
	"""Set custom font"""
	custom_font = font
	_update_label_style()

func set_font_size(size: int) -> void:
	"""Set font size"""
	font_size = clamp(size, min_font_size, MAX_FONT_SIZE)
	_calculated_font_size = font_size
	_update_label_style()

func set_line_spacing(spacing: float) -> void:
	"""Set line spacing"""
	line_spacing = spacing
	_update_label_style()

func set_letter_spacing(spacing: float) -> void:
	"""Set letter spacing"""
	letter_spacing = spacing
	_update_label_style()

func set_font_color(color: Color) -> void:
	"""Set font color"""
	font_color = color
	
	if not use_theme_color:
		_update_label_style()

func set_text_align(align: TextAlign) -> void:
	"""Set text alignment"""
	text_align = align
	
	if _label:
		match align:
			TextAlign.LEFT:
				_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			TextAlign.CENTER:
				_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			TextAlign.RIGHT:
				_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			TextAlign.JUSTIFY:
				_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
	elif _rich_label:
		# RichTextLabel doesn't have direct alignment, use BBCode
		_update_rich_text_alignment()

func set_vertical_align(align: VerticalAlign) -> void:
	"""Set vertical alignment"""
	vertical_align = align
	
	if _label:
		match align:
			VerticalAlign.TOP:
				_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			VerticalAlign.CENTER:
				_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			VerticalAlign.BOTTOM:
				_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

func set_overflow_mode(mode: OverflowMode) -> void:
	"""Set overflow handling mode"""
	if overflow_mode == mode:
		return
	
	overflow_mode = mode
	
	if is_inside_tree():
		# May need to recreate structure for scroll mode
		if mode == OverflowMode.SCROLL or (overflow_mode == OverflowMode.SCROLL and mode != OverflowMode.SCROLL):
			if _active_label:
				_active_label.queue_free()
			_create_label_structure()
			_apply_initial_configuration()
		else:
			_update_overflow_settings()

func set_max_lines(lines: int) -> void:
	"""Set maximum visible lines"""
	max_lines = lines
	
	if _label:
		_label.max_lines_visible = lines
	elif _rich_label:
		# RichTextLabel handles this differently
		pass

func set_auto_size(enabled: bool) -> void:
	"""Enable/disable auto-sizing"""
	auto_size = enabled
	
	if _rich_label:
		_rich_label.fit_content = enabled

func set_outline_enabled(enabled: bool) -> void:
	"""Enable/disable text outline"""
	outline_enabled = enabled
	_update_effects()

func set_outline_size(size: int) -> void:
	"""Set outline size"""
	outline_size = size
	_update_effects()

func set_outline_color(color: Color) -> void:
	"""Set outline color"""
	outline_color = color
	_update_effects()

func set_shadow_enabled(enabled: bool) -> void:
	"""Enable/disable text shadow"""
	shadow_enabled = enabled
	_update_effects()

func set_shadow_offset(offset: Vector2) -> void:
	"""Set shadow offset"""
	shadow_offset = offset
	_update_effects()

func set_shadow_color(color: Color) -> void:
	"""Set shadow color"""
	shadow_color = color
	_update_effects()

# === PRIVATE METHODS ===

func _update_label_style() -> void:
	"""Update label visual style"""
	if not is_inside_tree():
		return
	
	# Font settings
	var font_to_use = custom_font if custom_font else get_theme_font("font", "Label")
	var color_to_use = font_color if not use_theme_color else get_theme_color("font_color", "Label")
	
	if _label:
		if font_to_use:
			_label.add_theme_font_override("font", font_to_use)
		_label.add_theme_font_size_override("font_size", _calculated_font_size)
		_label.add_theme_color_override("font_color", color_to_use)
		_label.add_theme_constant_override("line_spacing", int(line_spacing * _calculated_font_size - _calculated_font_size))
		
	elif _rich_label:
		if font_to_use:
			_rich_label.add_theme_font_override("normal_font", font_to_use)
			_rich_label.add_theme_font_override("bold_font", font_to_use)
			_rich_label.add_theme_font_override("italics_font", font_to_use)
			_rich_label.add_theme_font_override("bold_italics_font", font_to_use)
		_rich_label.add_theme_font_size_override("normal_font_size", _calculated_font_size)
		_rich_label.add_theme_color_override("default_color", color_to_use)
		_rich_label.add_theme_constant_override("line_separation", int(line_spacing * _calculated_font_size - _calculated_font_size))

func _update_effects() -> void:
	"""Update text effects (outline, shadow)"""
	if _label:
		if outline_enabled:
			_label.add_theme_constant_override("outline_size", outline_size)
			_label.add_theme_color_override("font_outline_color", outline_color)
		else:
			_label.remove_theme_constant_override("outline_size")
			_label.remove_theme_color_override("font_outline_color")
		
		if shadow_enabled:
			_label.add_theme_constant_override("shadow_offset_x", int(shadow_offset.x))
			_label.add_theme_constant_override("shadow_offset_y", int(shadow_offset.y))
			_label.add_theme_color_override("font_shadow_color", shadow_color)
		else:
			_label.remove_theme_constant_override("shadow_offset_x")
			_label.remove_theme_constant_override("shadow_offset_y")
			_label.remove_theme_color_override("font_shadow_color")

func _update_overflow_settings() -> void:
	"""Update overflow mode settings"""
	if _label:
		match overflow_mode:
			OverflowMode.VISIBLE:
				_label.clip_text = false
				_label.autowrap_mode = TextServer.AUTOWRAP_OFF
			OverflowMode.TRUNCATE:
				_label.clip_text = true
				_label.autowrap_mode = TextServer.AUTOWRAP_OFF
			OverflowMode.WRAP:
				_label.clip_text = false
				_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			OverflowMode.SHRINK:
				_enable_auto_shrink()

func _enable_auto_shrink() -> void:
	"""Enable automatic font size reduction to fit"""
	# This would implement dynamic font sizing
	pass

func _check_overflow() -> void:
	"""Check if text is overflowing"""
	if not is_inside_tree():
		return
	
	var was_overflowing = _is_overflowing
	
	if _label:
		var text_size = _label.get_theme_font("font").get_string_size(
			_label.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			_calculated_font_size
		)
		_is_overflowing = text_size.x > size.x or text_size.y > size.y
		size_calculated.emit(text_size)
	
	if was_overflowing != _is_overflowing:
		text_overflow_changed.emit(_is_overflowing)
		
		if overflow_mode == OverflowMode.SHRINK and _is_overflowing:
			_shrink_to_fit()

func _shrink_to_fit() -> void:
	"""Reduce font size until text fits"""
	var test_size = _calculated_font_size
	
	while test_size > min_font_size and _is_overflowing:
		test_size -= 1
		_calculated_font_size = test_size
		_update_label_style()
		_check_overflow()

func _update_rich_text_alignment() -> void:
	"""Update RichTextLabel alignment using BBCode"""
	if not _rich_label or not bbcode_enabled:
		return
	
	var align_tag = ""
	match text_align:
		TextAlign.CENTER:
			align_tag = "[center]"
		TextAlign.RIGHT:
			align_tag = "[right]"
		TextAlign.JUSTIFY:
			align_tag = "[fill]"
	
	if align_tag:
		_rich_label.text = align_tag + text + align_tag.replace("[", "[/")
	else:
		_rich_label.text = text

# === ANIMATION METHODS ===

func _animate_typewriter() -> void:
	"""Animate text appearing letter by letter"""
	if not _active_label:
		return
	
	if _typewriter_tween:
		_typewriter_tween.kill()
	
	_typewriter_tween = create_tween()
	
	if _label:
		_label.visible_ratio = 0.0
		_typewriter_tween.tween_property(_label, "visible_ratio", 1.0, text.length() * typewriter_speed)
	elif _rich_label:
		_rich_label.visible_ratio = 0.0
		_typewriter_tween.tween_property(_rich_label, "visible_ratio", 1.0, text.length() * typewriter_speed)

func _animate_fade_transition() -> void:
	"""Animate text change with fade"""
	if not _active_label:
		return
	
	if _fade_tween:
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	
	# Fade out
	_fade_tween.tween_property(_active_label, "modulate:a", 0.0, fade_in_duration * 0.5)
	
	# Update text
	_fade_tween.tween_callback(func(): set_text(text))
	
	# Fade in
	_fade_tween.tween_property(_active_label, "modulate:a", 1.0, fade_in_duration * 0.5)

# === SIGNAL HANDLERS ===

func _on_meta_clicked(meta: String) -> void:
	"""Handle RichTextLabel link clicks"""
	link_clicked.emit(meta)
	
	if track_analytics:
		_track_event("link_clicked", {"url": meta})

# === UTILITY METHODS ===

func get_visible_line_count() -> int:
	"""Get number of visible lines"""
	if _label:
		return _label.get_visible_line_count()
	elif _rich_label:
		return _rich_label.get_visible_line_count()
	return 0

func get_text_size() -> Vector2:
	"""Get the actual size of the rendered text"""
	if _label:
		return _label.get_theme_font("font").get_string_size(
			_label.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			_calculated_font_size
		)
	return Vector2.ZERO

func select_all() -> void:
	"""Select all text (for RichTextLabel)"""
	if _rich_label:
		_rich_label.select_all()

func clear_selection() -> void:
	"""Clear text selection"""
	if _rich_label:
		_rich_label.deselect()

# === THEME INTERFACE ===

func get_theme_type_name() -> String:
	"""Get theme type for this component"""
	return "Label"

func get_theme_properties() -> Dictionary:
	"""Get themeable properties"""
	return {
		"colors": {
			"font_color": "Default text color",
			"font_color_shadow": "Shadow color",
			"font_outline_color": "Outline color",
			"font_color_selection": "Selected text color",
			"selection_color": "Selection background color"
		},
		"constants": {
			"line_spacing": "Space between lines",
			"outline_size": "Text outline thickness",
			"shadow_offset_x": "Shadow horizontal offset",
			"shadow_offset_y": "Shadow vertical offset"
		},
		"fonts": {
			"font": "Default font",
			"font_bold": "Bold font variant",
			"font_italic": "Italic font variant"
		},
		"font_sizes": {
			"font_size": "Default font size"
		}
	}