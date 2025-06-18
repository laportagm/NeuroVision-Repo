class_name TutorialOverlay
extends Control

## Tutorial overlay UI component for onboarding
##
## Displays tutorial tooltips, highlights UI elements, and guides users
## through their first experience with the NeuroVision platform.

signal next_pressed()
signal skip_pressed()
signal previous_pressed()

# === CONSTANTS ===
const ANIMATION_DURATION: float = 0.3
const HIGHLIGHT_PADDING: int = 10
const TOOLTIP_MARGIN: int = 20
const ARROW_SIZE: int = 20

# === NODES ===
@onready var overlay_rect: ColorRect = $OverlayRect
@onready var highlight_container: Control = $HighlightContainer
@onready var tooltip_panel: PanelContainer = $TooltipPanel
@onready var title_label: Label = $TooltipPanel/Content/VBox/TitleLabel
@onready var description_label: RichTextLabel = $TooltipPanel/Content/VBox/DescriptionLabel
@onready var progress_bar: ProgressBar = $TooltipPanel/Content/VBox/ProgressContainer/ProgressBar
@onready var progress_label: Label = $TooltipPanel/Content/VBox/ProgressContainer/ProgressLabel
@onready var button_container: HBoxContainer = $TooltipPanel/Content/VBox/ButtonContainer
@onready var previous_button: Button = $TooltipPanel/Content/VBox/ButtonContainer/PreviousButton
@onready var skip_button: Button = $TooltipPanel/Content/VBox/ButtonContainer/SkipButton
@onready var next_button: Button = $TooltipPanel/Content/VBox/ButtonContainer/NextButton
@onready var close_button: Button = $TooltipPanel/Content/CloseButton

# === PRIVATE VARIABLES ===
var _current_highlight_rect: Rect2
var _highlight_tween: Tween
var _tooltip_tween: Tween
var _pulse_tween: Tween

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the tutorial overlay"""
	_setup_ui()
	_connect_signals()
	_apply_theme()
	
	# Start with overlay visible but tooltip hidden
	visible = true
	tooltip_panel.modulate.a = 0.0
	tooltip_panel.visible = false
	
	# Fade in overlay
	overlay_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay_rect, "modulate:a", 0.7, ANIMATION_DURATION)

func set_step_content(title: String, description: String, current_step: int, total_steps: int) -> void:
	"""Set the content for the current tutorial step"""
	title_label.text = title
	description_label.text = description
	
	# Update progress
	progress_bar.value = float(current_step + 1) / float(total_steps) * 100.0
	progress_label.text = "Step %d of %d" % [current_step + 1, total_steps]
	
	# Update button states
	previous_button.disabled = current_step <= 0
	next_button.text = "Next" if current_step < total_steps - 1 else "Finish"
	
	# Show tooltip with animation
	_show_tooltip()

func highlight_area(rect: Rect2, position_hint: String = "auto") -> void:
	"""Highlight a specific area of the screen"""
	_current_highlight_rect = rect
	
	# Add padding to highlight
	rect = rect.grow(HIGHLIGHT_PADDING)
	
	# Create or update highlight mask
	_update_highlight_mask(rect)
	
	# Position tooltip based on hint
	_position_tooltip(rect, position_hint)
	
	# Add pulse effect to highlight
	_add_highlight_pulse()

func clear_highlight() -> void:
	"""Clear any highlighted area"""
	_current_highlight_rect = Rect2()
	_update_highlight_mask(Rect2())
	
	# Center the tooltip
	_center_tooltip()

func set_skip_enabled(enabled: bool) -> void:
	"""Enable or disable the skip button"""
	skip_button.visible = enabled

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup UI elements"""
	# Set anchors for full screen overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Setup overlay background
	overlay_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_rect.color = Color(0, 0, 0, 0.7)
	overlay_rect.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow clicks through
	
	# Setup highlight container
	highlight_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	highlight_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Setup tooltip panel
	tooltip_panel.custom_minimum_size = Vector2(400, 200)
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_STOP

func _connect_signals() -> void:
	"""Connect button signals"""
	next_button.pressed.connect(func(): next_pressed.emit())
	skip_button.pressed.connect(func(): skip_pressed.emit())
	previous_button.pressed.connect(func(): previous_pressed.emit())
	close_button.pressed.connect(func(): skip_pressed.emit())

func _apply_theme() -> void:
	"""Apply Material 3 theme to UI elements"""
	# Style panel with basic design
	if tooltip_panel:
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(0.2, 0.2, 0.25, 0.95)
		panel_style.set_corner_radius_all(8)
		panel_style.set_content_margin_all(16)
		panel_style.shadow_size = 4
		panel_style.shadow_color = Color(0, 0, 0, 0.3)
		panel_style.shadow_offset = Vector2(0, 4)
		tooltip_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style title
	if title_label:
		title_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
		title_label.add_theme_font_size_override("font_size", 20)
	
	# Style description
	if description_label:
		description_label.add_theme_color_override("default_color", Color.WHITE)
		description_label.add_theme_font_size_override("normal_font_size", 14)
		description_label.add_theme_font_size_override("bold_font_size", 16)
	
	# Style progress bar
	if progress_bar:
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Color(0.3, 0.3, 0.3)
		bg_style.set_corner_radius_all(12)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.3, 0.7, 1.0)
		fill_style.set_corner_radius_all(12)
		
		progress_bar.add_theme_stylebox_override("background", bg_style)
		progress_bar.add_theme_stylebox_override("fill", fill_style)
	
	# Style buttons
	if next_button:
		_apply_basic_button_style(next_button, Color(0.3, 0.7, 1.0))
	if skip_button:
		_apply_basic_button_style(skip_button, Color(0.6, 0.6, 0.6))
	if previous_button:
		_apply_basic_button_style(previous_button, Color(0.5, 0.5, 0.5))
	if close_button:
		close_button.flat = true
		close_button.add_theme_color_override("font_color", Color.WHITE)
		close_button.text = "✕"

func _show_tooltip() -> void:
	"""Show tooltip with animation"""
	tooltip_panel.visible = true
	
	if _tooltip_tween:
		_tooltip_tween.kill()
	
	_tooltip_tween = create_tween()
	_tooltip_tween.set_trans(Tween.TRANS_BACK)
	_tooltip_tween.set_ease(Tween.EASE_OUT)
	_tooltip_tween.set_parallel(true)
	
	_tooltip_tween.tween_property(tooltip_panel, "modulate:a", 1.0, ANIMATION_DURATION)
	_tooltip_tween.tween_property(tooltip_panel, "scale", Vector2.ONE, ANIMATION_DURATION).from(Vector2(0.9, 0.9))

func _update_highlight_mask(rect: Rect2) -> void:
	"""Update the highlight mask to show through a specific area"""
	# Clear existing highlights
	for child in highlight_container.get_children():
		child.queue_free()
	
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	
	# Create highlight border
	var highlight_border = ReferenceRect.new()
	highlight_border.position = rect.position
	highlight_border.size = rect.size
	highlight_border.border_color = Color(0.3, 0.7, 1.0)
	highlight_border.border_width = 3
	highlight_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight_container.add_child(highlight_border)
	
	# Create cutout effect using multiple ColorRects
	var viewport_size = get_viewport_rect().size
	
	# Top mask
	var top_mask = ColorRect.new()
	top_mask.color = Color(0, 0, 0, 0.7)
	top_mask.position = Vector2.ZERO
	top_mask.size = Vector2(viewport_size.x, rect.position.y)
	top_mask.mouse_filter = Control.MOUSE_FILTER_PASS
	highlight_container.add_child(top_mask)
	
	# Bottom mask
	var bottom_mask = ColorRect.new()
	bottom_mask.color = Color(0, 0, 0, 0.7)
	bottom_mask.position = Vector2(0, rect.position.y + rect.size.y)
	bottom_mask.size = Vector2(viewport_size.x, viewport_size.y - (rect.position.y + rect.size.y))
	bottom_mask.mouse_filter = Control.MOUSE_FILTER_PASS
	highlight_container.add_child(bottom_mask)
	
	# Left mask
	var left_mask = ColorRect.new()
	left_mask.color = Color(0, 0, 0, 0.7)
	left_mask.position = Vector2(0, rect.position.y)
	left_mask.size = Vector2(rect.position.x, rect.size.y)
	left_mask.mouse_filter = Control.MOUSE_FILTER_PASS
	highlight_container.add_child(left_mask)
	
	# Right mask
	var right_mask = ColorRect.new()
	right_mask.color = Color(0, 0, 0, 0.7)
	right_mask.position = Vector2(rect.position.x + rect.size.x, rect.position.y)
	right_mask.size = Vector2(viewport_size.x - (rect.position.x + rect.size.x), rect.size.y)
	right_mask.mouse_filter = Control.MOUSE_FILTER_PASS
	highlight_container.add_child(right_mask)

func _position_tooltip(highlight_rect: Rect2, position_hint: String) -> void:
	"""Position the tooltip relative to the highlighted area"""
	var viewport_size = get_viewport_rect().size
	var tooltip_size = tooltip_panel.size
	var final_position = Vector2.ZERO
	
	match position_hint:
		"top":
			final_position.x = highlight_rect.position.x + (highlight_rect.size.x - tooltip_size.x) / 2
			final_position.y = highlight_rect.position.y - tooltip_size.y - TOOLTIP_MARGIN
		"bottom":
			final_position.x = highlight_rect.position.x + (highlight_rect.size.x - tooltip_size.x) / 2
			final_position.y = highlight_rect.position.y + highlight_rect.size.y + TOOLTIP_MARGIN
		"left":
			final_position.x = highlight_rect.position.x - tooltip_size.x - TOOLTIP_MARGIN
			final_position.y = highlight_rect.position.y + (highlight_rect.size.y - tooltip_size.y) / 2
		"right":
			final_position.x = highlight_rect.position.x + highlight_rect.size.x + TOOLTIP_MARGIN
			final_position.y = highlight_rect.position.y + (highlight_rect.size.y - tooltip_size.y) / 2
		"center", _:
			final_position = (viewport_size - tooltip_size) / 2
	
	# Ensure tooltip stays within viewport
	final_position.x = clamp(final_position.x, TOOLTIP_MARGIN, viewport_size.x - tooltip_size.x - TOOLTIP_MARGIN)
	final_position.y = clamp(final_position.y, TOOLTIP_MARGIN, viewport_size.y - tooltip_size.y - TOOLTIP_MARGIN)
	
	# Animate to position
	if _tooltip_tween:
		_tooltip_tween.kill()
	
	_tooltip_tween = create_tween()
	_tooltip_tween.set_trans(Tween.TRANS_CUBIC)
	_tooltip_tween.set_ease(Tween.EASE_OUT)
	_tooltip_tween.tween_property(tooltip_panel, "position", final_position, ANIMATION_DURATION)

func _center_tooltip() -> void:
	"""Center the tooltip on screen"""
	var viewport_size = get_viewport_rect().size
	var tooltip_size = tooltip_panel.size
	var center_position = (viewport_size - tooltip_size) / 2
	
	if _tooltip_tween:
		_tooltip_tween.kill()
	
	_tooltip_tween = create_tween()
	_tooltip_tween.set_trans(Tween.TRANS_CUBIC)
	_tooltip_tween.set_ease(Tween.EASE_OUT)
	_tooltip_tween.tween_property(tooltip_panel, "position", center_position, ANIMATION_DURATION)

func _add_highlight_pulse() -> void:
	"""Add pulse effect to highlight border"""
	if highlight_container.get_child_count() == 0:
		return
	
	var highlight_border = highlight_container.get_child(0)
	if not highlight_border:
		return
	
	if _pulse_tween:
		_pulse_tween.kill()
	
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	
	var original_color = Color(0.3, 0.7, 1.0)
	var pulse_color = original_color
	pulse_color.a = 0.5
	
	_pulse_tween.tween_property(highlight_border, "border_color", pulse_color, 1.0)
	_pulse_tween.tween_property(highlight_border, "border_color", original_color, 1.0)

func _apply_basic_button_style(button: Button, color: Color) -> void:
	"""Apply basic button styling"""
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = color
	button_style.set_corner_radius_all(6)
	button_style.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_color_override("font_color", Color.WHITE)
