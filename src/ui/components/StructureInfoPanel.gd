extends PanelContainer

## Educational information panel for brain structures

signal close_requested()
signal quiz_requested(structure_id: String)

# === CONSTANTS ===
const PANEL_WIDTH: int = 450
const ANIMATION_DURATION: float = 0.3
const PANEL_MARGIN: int = 30

# === EXPORTS ===
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 30.0  # Increased to 30 seconds for testing
@export_group("Appearance")
@export var panel_color: Color = M3DesignTokens.get_ui_color("panel", "default")
@export var header_color: Color = M3DesignTokens.get_color("surface_container")
@export var text_color: Color = M3DesignTokens.get_color("on_surface")
@export var accent_color: Color = M3DesignTokens.get_color("primary")

# === PRIVATE VARIABLES ===
@onready var _header: PanelContainer = $VBoxContainer/Header
@onready var _title_label: Label = $VBoxContainer/Header/HBoxContainer/TitleLabel
@onready var _close_button: Button = $VBoxContainer/Header/HBoxContainer/CloseButton
@onready var _info_content: VBoxContainer = $VBoxContainer/ScrollContainer/InfoContent

var _auto_hide_timer: Timer = null
var _is_visible: bool = false
var _tween: Tween = null
var _current_structure_id: String = ""

# === PUBLIC METHODS ===

func _ready() -> void:
	_setup_ui()
	_setup_auto_hide()
	visible = false
	modulate.a = 0.0
	print("[InfoPanel] Panel initialized. Offsets: ", offset_left, ", ", offset_right, " Visible: ", visible)
	
	# Use scene-defined styling - themes are managed globally by UIThemeManager
	# Removed aggressive theme override to preserve editor appearance
	
	# Add slide-in animation
	modulate.a = 0
	position.x += 20
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(self, "position:x", position.x - 20, 0.5)

func display_structure_info(structure_data: Dictionary) -> void:
	"""Display information about a brain structure"""
	print("[InfoPanel] Displaying structure info: ", structure_data.get("displayName", structure_data.get("name", "Unknown")))
	_clear_content()
	
	# Store structure ID
	_current_structure_id = structure_data.get("id", "")
	
	# Set title
	var title = structure_data.get("displayName", structure_data.get("name", "Unknown Structure"))
	_title_label.text = title
	
	# Add description
	var description = structure_data.get("description", "")
	if description != "":
		_add_section("Description", description)
	
	# Add function
	var function = structure_data.get("function", "")
	if function != "":
		_add_section("Function", function)
	
	# Add key facts
	var key_facts = structure_data.get("keyFacts", [])
	if key_facts.size() > 0:
		_add_list_section("Key Facts", key_facts, "•")
	
	# Add clinical relevance
	var clinical = structure_data.get("clinicalRelevance", "")
	if clinical != "":
		_add_section("Clinical Relevance", clinical)
	
	# Add connections
	var connections = structure_data.get("connections", [])
	if connections.size() > 0:
		_add_connections_section(connections)
	
	# Add learning objectives
	var objectives = structure_data.get("learningObjectives", [])
	if objectives.size() > 0:
		_add_objectives_section(objectives)
	
	# Add category if present
	var category = structure_data.get("category", "")
	if category != "":
		_add_category_tag(category)
	
	# Add quiz button if we have assessments
	if _current_structure_id != "":
		_add_quiz_button()
	
	# Show panel
	show_panel()

func show_panel() -> void:
	"""Show the info panel with glass-morphism entrance animation"""
	print("[InfoPanel] Showing panel")
	if _is_visible:
		print("[InfoPanel] Panel already visible, resetting timer")
		_reset_auto_hide_timer()
		return
	
	_is_visible = true
	visible = true
	
	# Animate in with glass effect
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	
	# Set initial state for entrance animation
	var initial_offset_left = -PANEL_WIDTH + 50
	var initial_offset_right = 50
	offset_left = initial_offset_left
	offset_right = initial_offset_right
	scale = Vector2(0.95, 0.95)
	modulate.a = 0.0
	
	# Target positions
	var target_offset_left = -PANEL_WIDTH - PANEL_MARGIN
	var target_offset_right = -PANEL_MARGIN
	print("[InfoPanel] Animating offsets from (", offset_left, ", ", offset_right, ") to (", target_offset_left, ", ", target_offset_right, ")")
	
	# Animate with glass morphism effect
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, ANIMATION_DURATION * 0.8)
	_tween.tween_property(self, "offset_left", target_offset_left, ANIMATION_DURATION)
	_tween.tween_property(self, "offset_right", target_offset_right, ANIMATION_DURATION)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION * 0.9)
	_tween.set_parallel(false)
	
	# Subtle blur amount animation if shader is available
	if material and material.shader:
		_tween.set_parallel(true)
		_tween.tween_property(material, "shader_parameter/blur_amount", 4.0, ANIMATION_DURATION * 1.2).from(8.0)
		_tween.set_parallel(false)
	
	# Add callback to check final state
	_tween.tween_callback(func(): print("[InfoPanel] Animation complete. Offsets: (", offset_left, ", ", offset_right, ") Visible: ", visible, " Modulate: ", modulate))
	
	_reset_auto_hide_timer()

func hide_panel() -> void:
	"""Hide the info panel with glass-morphism exit animation"""
	print("[InfoPanel] Hide panel called")
	if not _is_visible:
		return
	
	_is_visible = false
	
	# Animate out with glass effect
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, ANIMATION_DURATION * 0.8)
	_tween.tween_property(self, "scale", Vector2(0.95, 0.95), ANIMATION_DURATION * 0.9)
	# Animate back to off-screen position
	_tween.tween_property(self, "offset_left", -PANEL_WIDTH + 50, ANIMATION_DURATION)
	_tween.tween_property(self, "offset_right", 50, ANIMATION_DURATION)
	
	# Blur amount animation if shader is available
	if material and material.shader:
		_tween.tween_property(material, "shader_parameter/blur_amount", 8.0, ANIMATION_DURATION * 0.8)
	
	_tween.set_parallel(false)
	_tween.tween_callback(func(): visible = false)
	
	if _auto_hide_timer:
		_auto_hide_timer.stop()

func toggle_panel() -> void:
	"""Toggle panel visibility"""
	if _is_visible:
		hide_panel()
	else:
		show_panel()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup UI elements"""
	# Configure panel
	custom_minimum_size.x = PANEL_WIDTH
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	# Start off-screen (right edge of screen)
	offset_left = PANEL_MARGIN  # This positions it off-screen to the right
	offset_top = PANEL_MARGIN
	offset_right = PANEL_WIDTH + PANEL_MARGIN
	offset_bottom = -PANEL_MARGIN
	
	# Apply theme
	_apply_theme()
	
	# Connect signals
	_close_button.pressed.connect(_on_close_pressed)

func _apply_theme() -> void:
	"""Apply Material 3 theme to panel using M3ComponentApplicator"""
	# Apply M3 glass morphism panel styling
	M3ComponentApplicator.apply_m3_panel_styling(self, M3ComponentApplicator.PanelVariant.GLASS)
	
	# Apply M3 header bar styling
	if _header:
		M3ComponentApplicator.apply_m3_panel_styling(_header, M3ComponentApplicator.PanelVariant.SURFACE_VARIANT)
		# Make header corners match panel
		var header_style = _header.get_theme_stylebox("panel")
		if header_style and header_style is StyleBoxFlat:
			header_style.corner_radius_bottom_left = 0
			header_style.corner_radius_bottom_right = 0
	
	# Apply M3 typography to title
	if _title_label:
		M3ComponentApplicator.apply_m3_text_styling(_title_label, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
		_title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	
	# Style close button as M3 icon button
	if _close_button:
		_close_button.text = "✕"
		_close_button.flat = true
		M3ComponentApplicator.apply_m3_button_styling(_close_button, M3ComponentApplicator.ButtonVariant.ICON)
		_close_button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
		_close_button.add_theme_font_size_override("font_size", 20)
		
		# Add hover effect
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandler.setup_button_hover_animation(_close_button)

func _setup_auto_hide() -> void:
	"""Setup auto-hide timer"""
	print("[InfoPanel] Auto-hide setting: ", auto_hide, " with delay: ", auto_hide_delay)
	if auto_hide:
		_auto_hide_timer = Timer.new()
		_auto_hide_timer.wait_time = auto_hide_delay
		_auto_hide_timer.one_shot = true
		_auto_hide_timer.timeout.connect(hide_panel)
		add_child(_auto_hide_timer)

func _reset_auto_hide_timer() -> void:
	"""Reset the auto-hide timer"""
	if _auto_hide_timer and auto_hide:
		_auto_hide_timer.stop()
		_auto_hide_timer.start()

func _clear_content() -> void:
	"""Clear all content from the panel"""
	for child in _info_content.get_children():
		child.queue_free()

func _add_section(title: String, content: String) -> void:
	"""Add a content section to the panel with M3 styling"""
	# Section title with M3 typography
	var title_label = Label.new()
	title_label.text = title
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	_info_content.add_child(title_label)
	
	# Section content with M3 typography
	var content_label = RichTextLabel.new()
	content_label.text = content
	content_label.fit_content = true
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.add_theme_color_override("default_color", M3DesignTokens.M3_COLORS["on_surface"])
	content_label.add_theme_font_size_override("normal_font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
	content_label.bbcode_enabled = true
	content_label.custom_minimum_size.y = 60
	_info_content.add_child(content_label)
	
	# Spacing using M3 spacing system
	_add_spacer(M3DesignTokens.M3_SPACING["medium"])

func _add_connections_section(connections: Array) -> void:
	"""Add connections section with M3 styling"""
	var title_label = Label.new()
	title_label.text = "Connections"
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	_info_content.add_child(title_label)
	
	for connection in connections:
		var item_label = Label.new()
		item_label.text = "• " + str(connection)
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_info_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_objectives_section(objectives: Array) -> void:
	"""Add learning objectives section with M3 styling"""
	var title_label = Label.new()
	title_label.text = "Learning Objectives"
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["secondary"])
	_info_content.add_child(title_label)
	
	for i in range(objectives.size()):
		var item_label = Label.new()
		item_label.text = str(i + 1) + ". " + str(objectives[i])
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_info_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_spacer(height: int) -> void:
	"""Add vertical spacing"""
	var spacer = Control.new()
	spacer.custom_minimum_size.y = height
	_info_content.add_child(spacer)

func _add_list_section(title: String, items: Array, bullet: String = "•") -> void:
	"""Add a bulleted list section with M3 styling"""
	var title_label = Label.new()
	title_label.text = title
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	_info_content.add_child(title_label)
	
	for item in items:
		var item_label = Label.new()
		item_label.text = bullet + " " + str(item)
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_info_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_category_tag(category: String) -> void:
	"""Add a category tag with M3 chip styling"""
	var tag_container = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = M3DesignTokens.M3_COLORS["primary_container"]
	tag_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["chip"])
	tag_style.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	tag_container.add_theme_stylebox_override("panel", tag_style)
	
	var tag_label = Label.new()
	tag_label.text = category
	M3ComponentApplicator.apply_m3_text_styling(tag_label, M3ComponentApplicator.TypographyScale.LABEL_MEDIUM)
	tag_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_primary_container"])
	tag_container.add_child(tag_label)
	
	_info_content.add_child(tag_container)
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _on_close_pressed() -> void:
	"""Handle close button pressed"""
	hide_panel()
	close_requested.emit()

func _add_quiz_button() -> void:
	"""Add a button to start quiz with M3 styling"""
	_add_spacer(M3DesignTokens.M3_SPACING["large"])
	
	var quiz_button = Button.new()
	quiz_button.text = "Take Quiz"
	quiz_button.custom_minimum_size = Vector2(120, 48)
	
	# Apply M3 primary button styling
	M3ComponentApplicator.apply_m3_button_styling(quiz_button, M3ComponentApplicator.ButtonVariant.PRIMARY)
	
	# Add motion effects
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandler.setup_button_hover_animation(quiz_button)
	
	quiz_button.pressed.connect(_on_quiz_pressed)
	
	# Center the button
	var center_container = CenterContainer.new()
	center_container.add_child(quiz_button)
	_info_content.add_child(center_container)

func _on_quiz_pressed() -> void:
	"""Handle quiz button pressed"""
	if _current_structure_id != "":
		quiz_requested.emit(_current_structure_id)