extends Control

const ButtonMotionHandlerScript = preload("res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd")

## Enhanced educational information panel for brain structures with tabbed layout

signal close_requested()
signal quiz_requested(structure_id: String)

# === CONSTANTS ===
const PANEL_WIDTH: int = 500
const PANEL_MARGIN: int = 30

# Get animation duration from M3 design tokens
static func _get_animation_duration() -> float:
	return M3DesignTokens.M3_DURATION["medium2"] / 1000.0

# === EXPORTS ===
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 30.0
@export_group("Appearance")
@export var panel_color: Color
@export var header_color: Color
@export var text_color: Color
@export var accent_color: Color

# === PRIVATE VARIABLES ===
@onready var _header: Control = $EducationalContentContainer/AnatomicalHeaderSection
@onready var _structure_title: Label = $EducationalContentContainer/AnatomicalHeaderSection/StructureTitleArea/AnatomicalStructureTitle
@onready var _latin_name: Label = $EducationalContentContainer/AnatomicalHeaderSection/StructureTitleArea/MedicalLatinName
@onready var _structure_icon: TextureRect = $EducationalContentContainer/AnatomicalHeaderSection/AnatomicalStructureIcon
@onready var _bookmark_button: Button = $EducationalContentContainer/AnatomicalHeaderSection/StructureBookmarkButton
@onready var _overview_content: RichTextLabel = $EducationalContentContainer/EducationalTabContainer/OverviewTab/OverviewRichContent
@onready var _detailed_content: RichTextLabel = $EducationalContentContainer/EducationalTabContainer/DetailedInfoTab/DetailedRichContent
@onready var _clinical_content: RichTextLabel = $EducationalContentContainer/EducationalTabContainer/ClinicalRelevanceTab/ClinicalRichContent
@onready var _related_structures: VBoxContainer = $EducationalContentContainer/EducationalTabContainer/RelatedStructuresTab/RelatedStructuresList
@onready var _quiz_button: Button = $EducationalContentContainer/EducationalActionBar/StructureQuizButton
@onready var _notes_button: Button = $EducationalContentContainer/EducationalActionBar/EducationalNotesButton
@onready var _close_button: Button = $EducationalContentContainer/EducationalActionBar/ClosePanelButton

var _auto_hide_timer: Timer = null
var _is_visible: bool = false
var _tween: Tween = null
var _current_structure_id: String = ""

# Enhanced Content Display System
var _content_cache = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	# Initialize theme colors from UnifiedColorSystem if not set
	if panel_color == Color():
		panel_color = UnifiedColorSystem.get_color("surface_container")
	if header_color == Color():
		header_color = UnifiedColorSystem.get_color("surface_container")
	if text_color == Color():
		text_color = UnifiedColorSystem.get_color("on_surface")
	if accent_color == Color():
		accent_color = UnifiedColorSystem.get_color("primary")
	
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
	"""Display structure information with rich tabbed content"""
	print("[InfoPanel] Displaying enhanced structure info: ", structure_data.get("displayName", structure_data.get("name", "Unknown")))
	
	# Store structure ID
	_current_structure_id = structure_data.get("id", "")
	
	# Update header with enhanced styling
	if _structure_title:
		_structure_title.text = structure_data.get("displayName", structure_data.get("name", "Unknown Structure"))
		_structure_title.add_theme_font_size_override("font_size", 24)
		_structure_title.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	
	if _latin_name:
		_latin_name.text = structure_data.get("latinName", "")
		_latin_name.add_theme_font_size_override("font_size", 14)
		_latin_name.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
	
	# Load rich content for each tab
	_load_tab_content("overview", structure_data)
	_load_tab_content("details", structure_data) 
	_load_tab_content("clinical", structure_data)
	_load_related_structures(structure_data)
	
	# Initialize 3D mini-model if available
	_setup_mini_model(structure_data.get("id", ""))
	
	# Show panel
	show_panel()

func display_enhanced_structure_info(structure_data: Dictionary) -> void:
	"""Enhanced display with intelligent content caching"""
	# Cache the content for quick access
	_content_cache[structure_data.get("id", "")] = structure_data
	display_structure_info(structure_data)

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
	
	# Animate with glass morphism effect using M3 timing
	var anim_duration = _get_animation_duration()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, anim_duration * 0.8)
	_tween.tween_property(self, "offset_left", target_offset_left, anim_duration)
	_tween.tween_property(self, "offset_right", target_offset_right, anim_duration)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), anim_duration * 0.9)
	_tween.set_parallel(false)
	
	# Subtle blur amount animation if shader is available
	if material and material.shader:
		_tween.set_parallel(true)
		_tween.tween_property(material, "shader_parameter/blur_amount", 4.0, anim_duration * 1.2).from(8.0)
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
	
	var anim_duration = _get_animation_duration()
	_tween.tween_property(self, "modulate:a", 0.0, anim_duration * 0.8)
	_tween.tween_property(self, "scale", Vector2(0.95, 0.95), anim_duration * 0.9)
	# Animate back to off-screen position
	_tween.tween_property(self, "offset_left", -PANEL_WIDTH + 50, anim_duration)
	_tween.tween_property(self, "offset_right", 50, anim_duration)
	
	# Blur amount animation if shader is available
	if material and material.shader:
		_tween.tween_property(material, "shader_parameter/blur_amount", 8.0, anim_duration * 0.8)
	
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
	_quiz_button.pressed.connect(_on_quiz_pressed)
	_notes_button.pressed.connect(_on_notes_pressed)
	_bookmark_button.pressed.connect(_on_bookmark_pressed)

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
	if _structure_title:
		M3ComponentApplicator.apply_m3_text_styling(_structure_title, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
		_structure_title.add_theme_color_override("font_color", UnifiedColorSystem.get_color("primary"))
	
	# Style close button as M3 icon button
	if _close_button:
		_close_button.text = "✕"
		_close_button.flat = true
		M3ComponentApplicator.apply_m3_button_styling(_close_button, M3ComponentApplicator.ButtonVariant.ICON)
		_close_button.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
		_close_button.add_theme_font_size_override("font_size", 20)
		
		# Add hover effect
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandlerScript.setup_button_hover_animation(_close_button)

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

func _load_tab_content(tab_name: String, data: Dictionary) -> void:
	"""Load rich content for specific tab"""
	var content_node: RichTextLabel
	
	match tab_name:
		"overview":
			content_node = _overview_content
			var overview_text = "[font_size=16]%s[/font_size]\n\n" % data.get("description", data.get("shortDescription", ""))
			overview_text += "[font_size=14][color=#666]Key Functions:[/color][/font_size]\n"
			var functions = data.get("functions", data.get("function", "").split("\n") if data.get("function", "") != "" else [])
			for function in functions:
				if function.strip_edges() != "":
					overview_text += "• %s\n" % function.strip_edges()
			content_node.text = overview_text
		
		"details":
			content_node = _detailed_content
			var details_text = "[font_size=16][color=#1976d2]Detailed Information[/color][/font_size]\n\n"
			
			# Add key facts
			var key_facts = data.get("keyFacts", [])
			if key_facts.size() > 0:
				details_text += "[font_size=14][color=#666]Key Facts:[/color][/font_size]\n"
				for fact in key_facts:
					details_text += "• %s\n" % fact
				details_text += "\n"
			
			# Add connections
			var connections = data.get("connections", [])
			if connections.size() > 0:
				details_text += "[font_size=14][color=#666]Neural Connections:[/color][/font_size]\n"
				for connection in connections:
					details_text += "• %s\n" % connection
				details_text += "\n"
			
			# Add learning objectives
			var objectives = data.get("learningObjectives", [])
			if objectives.size() > 0:
				details_text += "[font_size=14][color=#666]Learning Objectives:[/color][/font_size]\n"
				for i in range(objectives.size()):
					details_text += "%d. %s\n" % [i + 1, objectives[i]]
			
			content_node.text = details_text
		
		"clinical":
			content_node = _clinical_content
			var clinical_text = "[font_size=16][color=#c41e3a]Clinical Significance[/color][/font_size]\n\n"
			clinical_text += data.get("clinicalRelevance", "Clinical information being prepared.")
			
			if data.has("commonPathologies"):
				clinical_text += "\n\n[font_size=14][color=#666]Associated Pathologies:[/color][/font_size]\n"
				for pathology in data.commonPathologies:
					clinical_text += "• %s\n" % pathology
			
			content_node.text = clinical_text

func _load_related_structures(data: Dictionary) -> void:
	"""Load related structures into the Related tab"""
	# Clear existing related structures
	for child in _related_structures.get_children():
		child.queue_free()
	
	var related = data.get("relatedStructures", [])
	if related.size() == 0:
		var no_related_label = Label.new()
		no_related_label.text = "No related structures available."
		no_related_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
		_related_structures.add_child(no_related_label)
		return
	
	for structure_name in related:
		var structure_button = Button.new()
		structure_button.text = structure_name
		structure_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		structure_button.custom_minimum_size = Vector2(200, 40)
		
		# Style as related structure button
		M3ComponentApplicator.apply_m3_button_styling(structure_button, M3ComponentApplicator.ButtonVariant.SECONDARY)
		
		# Connect to structure selection
		structure_button.pressed.connect(_on_related_structure_pressed.bind(structure_name))
		
		_related_structures.add_child(structure_button)

func _setup_mini_model(_structure_id: String) -> void:
	"""Setup 3D mini-model in info panel"""
	var structure_icon = _structure_icon
	if structure_icon and structure_icon is TextureRect:
		# For now, use a placeholder. In full implementation, 
		# this would render the 3D structure to a ViewportTexture
		# TODO: Use _structure_id to load specific 3D model preview
		structure_icon.modulate = M3DesignTokens.M3_COLORS["primary"]

func _clear_content() -> void:
	"""Clear all content from the tabs"""
	_overview_content.text = "Loading overview..."
	_detailed_content.text = "Loading detailed information..."
	_clinical_content.text = "Loading clinical information..."
	
	for child in _related_structures.get_children():
		child.queue_free()

func _add_section(title: String, content: String) -> void:
	"""Add a content section to the panel with M3 styling"""
	# Section title with M3 typography
	var title_label = Label.new()
	title_label.text = title
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("primary"))
	_overview_content.add_child(title_label)
	
	# Section content with M3 typography
	var content_label = RichTextLabel.new()
	content_label.text = content
	content_label.fit_content = true
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.add_theme_color_override("default_color", UnifiedColorSystem.get_color("on_surface"))
	content_label.add_theme_font_size_override("normal_font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
	content_label.bbcode_enabled = true
	content_label.custom_minimum_size.y = 60
	_overview_content.add_child(content_label)
	
	# Spacing using M3 spacing system
	_add_spacer(M3DesignTokens.M3_SPACING["medium"])

func _add_connections_section(connections: Array) -> void:
	"""Add connections section with M3 styling"""
	var title_label = Label.new()
	title_label.text = "Connections"
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("primary"))
	_overview_content.add_child(title_label)
	
	for connection in connections:
		var item_label = Label.new()
		item_label.text = "• " + str(connection)
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_overview_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_objectives_section(objectives: Array) -> void:
	"""Add learning objectives section with M3 styling"""
	var title_label = Label.new()
	title_label.text = "Learning Objectives"
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("secondary"))
	_overview_content.add_child(title_label)
	
	for i in range(objectives.size()):
		var item_label = Label.new()
		item_label.text = str(i + 1) + ". " + str(objectives[i])
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_overview_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_spacer(height: int) -> void:
	"""Add vertical spacing"""
	var spacer = Control.new()
	spacer.custom_minimum_size.y = height
	_overview_content.add_child(spacer)

func _add_list_section(title: String, items: Array, bullet: String = "•") -> void:
	"""Add a bulleted list section with M3 styling"""
	var title_label = Label.new()
	title_label.text = title
	M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
	title_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("primary"))
	_overview_content.add_child(title_label)
	
	for item in items:
		var item_label = Label.new()
		item_label.text = bullet + " " + str(item)
		M3ComponentApplicator.apply_m3_text_styling(item_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		item_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_overview_content.add_child(item_label)
	
	_add_spacer(M3DesignTokens.M3_SPACING["small"])

func _add_category_tag(category: String) -> void:
	"""Add a category tag with M3 chip styling"""
	var tag_container = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = UnifiedColorSystem.get_color("primary_container")
	tag_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["chip"])
	tag_style.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	tag_container.add_theme_stylebox_override("panel", tag_style)
	
	var tag_label = Label.new()
	tag_label.text = category
	M3ComponentApplicator.apply_m3_text_styling(tag_label, M3ComponentApplicator.TypographyScale.LABEL_MEDIUM)
	tag_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_primary_container"))
	tag_container.add_child(tag_label)
	
	_overview_content.add_child(tag_container)
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
		ButtonMotionHandlerScript.setup_button_hover_animation(quiz_button)
	
	quiz_button.pressed.connect(_on_quiz_pressed)
	
	# Center the button
	var center_container = CenterContainer.new()
	center_container.add_child(quiz_button)
	_overview_content.add_child(center_container)

func _on_quiz_pressed() -> void:
	"""Handle quiz button pressed"""
	if _current_structure_id != "":
		quiz_requested.emit(_current_structure_id)

func _on_notes_pressed() -> void:
	"""Handle notes button pressed"""
	print("[InfoPanel] Notes button pressed for structure: ", _current_structure_id)
	# TODO: Implement notes functionality

func _on_bookmark_pressed() -> void:
	"""Handle bookmark button pressed"""
	print("[InfoPanel] Bookmark button pressed for structure: ", _current_structure_id)
	# TODO: Implement bookmark functionality
	
	# Visual feedback for bookmark toggle
	if _bookmark_button.text == "★":
		_bookmark_button.text = "☆"
		_bookmark_button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
	else:
		_bookmark_button.text = "★"
		_bookmark_button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["tertiary"])

func _on_related_structure_pressed(structure_name: String) -> void:
	"""Handle related structure button pressed"""
	print("[InfoPanel] Related structure selected: ", structure_name)
	# TODO: Emit signal to load related structure
