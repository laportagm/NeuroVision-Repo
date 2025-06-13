extends PanelContainer

## Progressive disclosure panel for educational content hierarchy
## Integrates with LearningContentManager to display content based on learning levels

signal close_requested()
signal quiz_requested(structure_id: String)
signal disclosure_level_changed(structure_id: String, level: int)
signal learning_level_adjusted(new_level: int)

# === CONSTANTS ===
const PANEL_WIDTH: int = 480
const ANIMATION_DURATION: float = 0.4
const PANEL_MARGIN: int = 20
const EXPAND_ICON: String = "▶"
const COLLAPSE_ICON: String = "▼"
const MORE_ICON: String = "+"
const LEVEL_INDICATOR_HEIGHT: int = 4

# === EXPORTS ===
@export var auto_hide: bool = true
@export var auto_hide_delay: float = 45.0
@export_group("Progressive Disclosure")
@export var enable_progressive_disclosure: bool = true
@export var show_level_indicators: bool = true
@export var animate_content_changes: bool = true
@export_group("Appearance")
@export var panel_color: Color = Color(0.08, 0.08, 0.12, 0.96)
@export var header_color: Color = Color(0.15, 0.15, 0.2, 1.0)
@export var text_color: Color = Color.WHITE
@export var accent_color: Color = Color.CYAN
@export var secondary_color: Color = Color(0.7, 0.7, 0.8, 1.0)

# === PRIVATE VARIABLES ===
@onready var _header: PanelContainer = $VBoxContainer/Header
@onready var _title_label: Label = $VBoxContainer/Header/HBoxContainer/TitleLabel
@onready var _level_indicator: Control = $VBoxContainer/Header/HBoxContainer/LevelIndicator
@onready var _close_button: Button = $VBoxContainer/Header/HBoxContainer/CloseButton
@onready var _content_scroll: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var _content_container: VBoxContainer = $VBoxContainer/ScrollContainer/ContentContainer

var _auto_hide_timer: Timer = null
var _is_visible: bool = false
var _tween: Tween = null
var _current_structure_id: String = ""
var _current_learning_level: int = UIAdaptationManager.LearningLevel.INTERMEDIATE
var _current_disclosure_level: int = LearningContentManager.DisclosureLevel.BASIC
var _content_sections: Dictionary = {}  # Track expandable sections
var _is_content_loading: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize progressive disclosure panel"""
	_setup_ui()
	_setup_auto_hide()
	_connect_signals()
	visible = false
	modulate.a = 0.0
	
	# Get current learning level from UIAdaptationManager
	if UIAdaptationManager:
		_current_learning_level = UIAdaptationManager.get_learning_level()
	
	print("[ProgressiveDisclosurePanel] Panel initialized for learning level: " + str(_current_learning_level))

func display_structure_content(structure_id: String) -> void:
	"""Display structure content with progressive disclosure"""
	if _is_content_loading:
		return
	
	_is_content_loading = true
	_current_structure_id = structure_id
	_clear_content()
	
	print("[ProgressiveDisclosurePanel] Displaying content for: " + structure_id)
	
	# Get filtered content from LearningContentManager
	if not LearningContentManager:
		push_error("[ProgressiveDisclosurePanel] LearningContentManager not available")
		_is_content_loading = false
		return
	
	var filtered_content = LearningContentManager.get_filtered_content(structure_id)
	if filtered_content.is_empty():
		push_warning("[ProgressiveDisclosurePanel] No content found for: " + structure_id)
		_is_content_loading = false
		return
	
	# Display content with current learning level
	_display_filtered_content(filtered_content)
	
	# Update level indicator
	_update_level_indicator()
	
	# Show panel
	show_panel()
	
	_is_content_loading = false

func advance_disclosure_level() -> void:
	"""Advance to next disclosure level"""
	if not LearningContentManager or _current_structure_id == "":
		return
	
	var progressive_content = LearningContentManager.advance_disclosure_level(_current_structure_id)
	if not progressive_content.is_empty():
		_current_disclosure_level = progressive_content.get("_metadata", {}).get("disclosure_level", _current_disclosure_level)
		_update_content_with_animation(progressive_content)
		disclosure_level_changed.emit(_current_structure_id, _current_disclosure_level)

func set_disclosure_level(level: LearningContentManager.DisclosureLevel) -> void:
	"""Set specific disclosure level"""
	if not LearningContentManager or _current_structure_id == "":
		return
	
	_current_disclosure_level = level
	var progressive_content = LearningContentManager.get_progressive_content(_current_structure_id, level)
	_update_content_with_animation(progressive_content)
	disclosure_level_changed.emit(_current_structure_id, level)

func refresh_content() -> void:
	"""Refresh content for current structure with updated learning level"""
	if _current_structure_id != "":
		display_structure_content(_current_structure_id)

func show_panel() -> void:
	"""Show panel with enhanced animation"""
	if _is_visible:
		_reset_auto_hide_timer()
		return
	
	_is_visible = true
	visible = true
	
	# Enhanced entrance animation
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	
	# Initial state
	var initial_offset_left = -PANEL_WIDTH + 30
	var initial_offset_right = 30
	offset_left = initial_offset_left
	offset_right = initial_offset_right
	scale = Vector2(0.92, 0.92)
	modulate.a = 0.0
	
	# Target positions
	var target_offset_left = -PANEL_WIDTH - PANEL_MARGIN
	var target_offset_right = -PANEL_MARGIN
	
	# Animate with enhanced glass morphism
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, ANIMATION_DURATION * 0.9)
	_tween.tween_property(self, "offset_left", target_offset_left, ANIMATION_DURATION)
	_tween.tween_property(self, "offset_right", target_offset_right, ANIMATION_DURATION)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION * 1.1)
	_tween.set_parallel(false)
	
	# Add subtle content animation
	_animate_content_entrance()
	
	_reset_auto_hide_timer()

func hide_panel() -> void:
	"""Hide panel with animation"""
	if not _is_visible:
		return
	
	_is_visible = false
	
	# Animate out
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, ANIMATION_DURATION * 0.7)
	_tween.tween_property(self, "scale", Vector2(0.92, 0.92), ANIMATION_DURATION)
	_tween.tween_property(self, "offset_left", -PANEL_WIDTH + 30, ANIMATION_DURATION)
	_tween.tween_property(self, "offset_right", 30, ANIMATION_DURATION)
	_tween.set_parallel(false)
	_tween.tween_callback(func(): visible = false)
	
	if _auto_hide_timer:
		_auto_hide_timer.stop()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup UI elements and styling"""
	# Configure panel dimensions and position
	custom_minimum_size.x = PANEL_WIDTH
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = PANEL_MARGIN
	offset_top = PANEL_MARGIN
	offset_right = PANEL_WIDTH + PANEL_MARGIN
	offset_bottom = -PANEL_MARGIN
	
	# Apply advanced styling
	_apply_theme()

func _apply_theme() -> void:
	"""Apply enhanced visual theme"""
	# Main panel style with glass morphism
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = panel_color
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 15
	panel_style.shadow_offset = Vector2(3, 3)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(1, 1, 1, 0.1)
	add_theme_stylebox_override("panel", panel_style)
	
	# Header style
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = header_color
	header_style.corner_radius_top_left = 12
	header_style.corner_radius_top_right = 12
	header_style.content_margin_left = 20
	header_style.content_margin_right = 20
	header_style.content_margin_top = 16
	header_style.content_margin_bottom = 16
	_header.add_theme_stylebox_override("panel", header_style)
	
	# Title styling
	_title_label.add_theme_color_override("font_color", text_color)
	_title_label.add_theme_font_size_override("font_size", 22)
	
	# Close button styling
	_close_button.text = "✕"
	_close_button.flat = true
	_close_button.add_theme_color_override("font_color", secondary_color)
	_close_button.add_theme_font_size_override("font_size", 20)

func _setup_auto_hide() -> void:
	"""Setup enhanced auto-hide functionality"""
	if auto_hide:
		_auto_hide_timer = Timer.new()
		_auto_hide_timer.wait_time = auto_hide_delay
		_auto_hide_timer.one_shot = true
		_auto_hide_timer.timeout.connect(hide_panel)
		add_child(_auto_hide_timer)

func _connect_signals() -> void:
	"""Connect to external signals"""
	_close_button.pressed.connect(_on_close_pressed)
	
	# Connect to LearningContentManager
	if LearningContentManager:
		LearningContentManager.learning_level_content_updated.connect(_on_learning_level_updated)
		LearningContentManager.content_filtered.connect(_on_content_filtered)
	
	# Connect to UIAdaptationManager
	if UIAdaptationManager:
		UIAdaptationManager.learning_level_changed.connect(_on_ui_learning_level_changed)

func _display_filtered_content(content: Dictionary) -> void:
	"""Display content with progressive disclosure structure"""
	_clear_content()
	_content_sections.clear()
	
	# Set title
	var title = content.get("displayName", "Unknown Structure")
	_title_label.text = title
	
	# Get metadata for content organization
	var metadata = content.get("_metadata", {})
	var learning_level = metadata.get("learning_level", _current_learning_level)
	
	# Create content sections based on available fields
	_create_essential_section(content)
	_create_functional_section(content)
	_create_educational_section(content)
	_create_clinical_section(content)
	_create_advanced_section(content)
	
	# Add level progression controls if appropriate
	if enable_progressive_disclosure:
		_add_level_controls()
	
	# Add quiz button
	if _current_structure_id != "":
		_add_quiz_section()

func _create_essential_section(content: Dictionary) -> void:
	"""Create essential information section (always visible)"""
	var section = _create_section("Essential Information", true, LearningContentManager.ContentPriority.ESSENTIAL)
	
	# Key facts (prioritized)
	var key_facts = content.get("keyFacts", [])
	if key_facts.size() > 0:
		_add_key_facts_display(section, key_facts)
	
	# Category tag
	var category = content.get("category", "")
	if category != "":
		_add_category_tag(section, category)

func _create_functional_section(content: Dictionary) -> void:
	"""Create functional information section"""
	var has_content = content.has("function") or content.has("description")
	if not has_content:
		return
	
	var is_expanded = _current_learning_level >= UIAdaptationManager.LearningLevel.INTERMEDIATE
	var section = _create_section("Function & Description", is_expanded, LearningContentManager.ContentPriority.IMPORTANT)
	
	# Function
	var function = content.get("function", "")
	if function != "":
		_add_rich_content(section, "Function", function)
	
	# Description  
	var description = content.get("description", "")
	if description != "":
		_add_rich_content(section, "Description", description)

func _create_educational_section(content: Dictionary) -> void:
	"""Create educational content section"""
	var objectives = content.get("learningObjectives", [])
	if objectives.size() == 0:
		return
	
	var is_expanded = _current_learning_level >= UIAdaptationManager.LearningLevel.INTERMEDIATE
	var section = _create_section("Learning Objectives", is_expanded, LearningContentManager.ContentPriority.SUPPLEMENTARY)
	
	_add_numbered_list(section, objectives)

func _create_clinical_section(content: Dictionary) -> void:
	"""Create clinical relevance section"""
	var clinical = content.get("clinicalRelevance", "")
	if clinical == "":
		return
	
	var is_expanded = _current_learning_level >= UIAdaptationManager.LearningLevel.INTERMEDIATE
	var section = _create_section("Clinical Relevance", is_expanded, LearningContentManager.ContentPriority.IMPORTANT)
	
	_add_rich_content(section, "", clinical)

func _create_advanced_section(content: Dictionary) -> void:
	"""Create advanced information section"""
	var connections = content.get("connections", [])
	var alt_names = content.get("alternateNames", [])
	
	if connections.size() == 0 and alt_names.size() == 0:
		return
	
	var is_expanded = _current_learning_level >= UIAdaptationManager.LearningLevel.ADVANCED
	var section = _create_section("Advanced Information", is_expanded, LearningContentManager.ContentPriority.ADVANCED)
	
	# Connections
	if connections.size() > 0:
		_add_rich_content(section, "Anatomical Connections", "")
		_add_bulleted_list(section, connections)
	
	# Alternate names
	if alt_names.size() > 0:
		_add_rich_content(section, "Alternate Names", alt_names.join(", "))

func _create_section(title: String, is_expanded: bool, priority: LearningContentManager.ContentPriority) -> VBoxContainer:
	"""Create an expandable content section"""
	var section_container = VBoxContainer.new()
	section_container.add_theme_constant_override("separation", 8)
	
	# Section header with expand/collapse
	var header_container = HBoxContainer.new()
	header_container.add_theme_constant_override("separation", 12)
	
	# Expand/collapse button
	var expand_button = Button.new()
	expand_button.text = COLLAPSE_ICON if is_expanded else EXPAND_ICON
	expand_button.flat = true
	expand_button.custom_minimum_size = Vector2(24, 24)
	expand_button.add_theme_color_override("font_color", accent_color)
	expand_button.add_theme_font_size_override("font_size", 14)
	
	# Section title
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", accent_color)
	title_label.add_theme_font_size_override("font_size", 18)
	
	# Priority indicator
	var priority_indicator = _create_priority_indicator(priority)
	
	header_container.add_child(expand_button)
	header_container.add_child(title_label)
	header_container.add_child(priority_indicator)
	
	# Content container
	var content_container = VBoxContainer.new()
	content_container.visible = is_expanded
	content_container.add_theme_constant_override("separation", 6)
	
	# Store section state
	_content_sections[title] = {
		"expand_button": expand_button,
		"content_container": content_container,
		"is_expanded": is_expanded,
		"priority": priority
	}
	
	# Connect expand/collapse
	expand_button.pressed.connect(_toggle_section.bind(title))
	
	section_container.add_child(header_container)
	section_container.add_child(content_container)
	_content_container.add_child(section_container)
	
	# Add separator
	_add_separator()
	
	return content_container

func _toggle_section(section_title: String) -> void:
	"""Toggle section expansion with animation"""
	var section = _content_sections.get(section_title, {})
	if section.is_empty():
		return
	
	var expand_button = section.expand_button
	var content_container = section.content_container
	var was_expanded = section.is_expanded
	
	# Update state
	_content_sections[section_title].is_expanded = not was_expanded
	expand_button.text = EXPAND_ICON if was_expanded else COLLAPSE_ICON
	
	# Animate content visibility
	if animate_content_changes:
		_animate_section_toggle(content_container, not was_expanded)
	else:
		content_container.visible = not was_expanded
	
	_reset_auto_hide_timer()

func _animate_section_toggle(container: Control, show: bool) -> void:
	"""Animate section expand/collapse"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	if show:
		container.visible = true
		container.modulate.a = 0.0
		container.scale.y = 0.8
		tween.parallel().tween_property(container, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(container, "scale:y", 1.0, 0.3)
	else:
		tween.parallel().tween_property(container, "modulate:a", 0.0, 0.2)
		tween.parallel().tween_property(container, "scale:y", 0.8, 0.2)
		tween.tween_callback(func(): container.visible = false)

func _update_level_indicator() -> void:
	"""Update visual level indicator"""
	if not show_level_indicators:
		return
	
	# Clear existing indicator
	for child in _level_indicator.get_children():
		child.queue_free()
	
	# Create level dots
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	
	for i in range(3):  # 3 learning levels
		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(8, 8)
		
		if i <= _current_learning_level:
			dot.color = accent_color
		else:
			dot.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.3)
		
		hbox.add_child(dot)
	
	_level_indicator.add_child(hbox)

func _add_level_controls() -> void:
	"""Add controls for adjusting learning level"""
	var controls_container = HBoxContainer.new()
	controls_container.add_theme_constant_override("separation", 12)
	
	# Learning level label
	var level_label = Label.new()
	level_label.text = "Learning Level:"
	level_label.add_theme_color_override("font_color", secondary_color)
	level_label.add_theme_font_size_override("font_size", 14)
	
	# Level buttons
	var beginner_btn = _create_level_button("Beginner", UIAdaptationManager.LearningLevel.BEGINNER)
	var intermediate_btn = _create_level_button("Intermediate", UIAdaptationManager.LearningLevel.INTERMEDIATE)
	var advanced_btn = _create_level_button("Advanced", UIAdaptationManager.LearningLevel.ADVANCED)
	
	controls_container.add_child(level_label)
	controls_container.add_child(beginner_btn)
	controls_container.add_child(intermediate_btn)
	controls_container.add_child(advanced_btn)
	
	_content_container.add_child(controls_container)
	_add_separator()

func _create_level_button(text: String, level: int) -> Button:
	"""Create a learning level selection button"""
	var button = Button.new()
	button.text = text
	button.toggle_mode = true
	button.button_pressed = (level == _current_learning_level)
	button.add_theme_font_size_override("font_size", 12)
	
	# Style based on current level
	if level == _current_learning_level:
		button.add_theme_color_override("font_color", accent_color)
	else:
		button.add_theme_color_override("font_color", secondary_color)
	
	button.pressed.connect(_on_level_button_pressed.bind(level))
	return button

func _create_priority_indicator(priority: LearningContentManager.ContentPriority) -> Control:
	"""Create visual priority indicator"""
	var indicator = ColorRect.new()
	indicator.custom_minimum_size = Vector2(3, 16)
	
	match priority:
		LearningContentManager.ContentPriority.ESSENTIAL:
			indicator.color = Color.RED
		LearningContentManager.ContentPriority.IMPORTANT:
			indicator.color = Color.ORANGE
		LearningContentManager.ContentPriority.SUPPLEMENTARY:
			indicator.color = Color.YELLOW
		LearningContentManager.ContentPriority.ADVANCED:
			indicator.color = Color.CYAN
		_:
			indicator.color = Color.GRAY
	
	return indicator

# === CONTENT CREATION HELPERS ===

func _add_rich_content(parent: Node, title: String, content: String) -> void:
	"""Add rich text content with optional title"""
	if title != "":
		var title_label = Label.new()
		title_label.text = title
		title_label.add_theme_color_override("font_color", accent_color)
		title_label.add_theme_font_size_override("font_size", 16)
		parent.add_child(title_label)
	
	if content != "":
		var content_label = RichTextLabel.new()
		content_label.text = content
		content_label.fit_content = true
		content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_label.add_theme_color_override("default_color", text_color)
		content_label.add_theme_font_size_override("normal_font_size", 14)
		content_label.bbcode_enabled = true
		content_label.custom_minimum_size.y = 40
		parent.add_child(content_label)

func _add_key_facts_display(parent: Node, facts: Array) -> void:
	"""Add visually enhanced key facts display"""
	for fact in facts:
		var fact_container = HBoxContainer.new()
		fact_container.add_theme_constant_override("separation", 8)
		
		# Bullet point
		var bullet = Label.new()
		bullet.text = "●"
		bullet.add_theme_color_override("font_color", accent_color)
		bullet.add_theme_font_size_override("font_size", 12)
		
		# Fact text
		var fact_label = Label.new()
		fact_label.text = str(fact)
		fact_label.add_theme_color_override("font_color", text_color)
		fact_label.add_theme_font_size_override("font_size", 14)
		fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		fact_container.add_child(bullet)
		fact_container.add_child(fact_label)
		parent.add_child(fact_container)

func _add_numbered_list(parent: Node, items: Array) -> void:
	"""Add numbered list"""
	for i in range(items.size()):
		var item_container = HBoxContainer.new()
		item_container.add_theme_constant_override("separation", 8)
		
		# Number
		var number_label = Label.new()
		number_label.text = str(i + 1) + "."
		number_label.add_theme_color_override("font_color", accent_color)
		number_label.add_theme_font_size_override("font_size", 14)
		number_label.custom_minimum_size.x = 24
		
		# Item text
		var item_label = Label.new()
		item_label.text = str(items[i])
		item_label.add_theme_color_override("font_color", text_color)
		item_label.add_theme_font_size_override("font_size", 14)
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		item_container.add_child(number_label)
		item_container.add_child(item_label)
		parent.add_child(item_container)

func _add_bulleted_list(parent: Node, items: Array) -> void:
	"""Add bulleted list"""
	for item in items:
		var item_container = HBoxContainer.new()
		item_container.add_theme_constant_override("separation", 8)
		
		# Bullet
		var bullet = Label.new()
		bullet.text = "•"
		bullet.add_theme_color_override("font_color", accent_color)
		bullet.add_theme_font_size_override("font_size", 14)
		
		# Item text
		var item_label = Label.new()
		item_label.text = str(item)
		item_label.add_theme_color_override("font_color", text_color)
		item_label.add_theme_font_size_override("font_size", 14)
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		item_container.add_child(bullet)
		item_container.add_child(item_label)
		parent.add_child(item_container)

func _add_category_tag(parent: Node, category: String) -> void:
	"""Add category tag"""
	var tag_container = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.2)
	tag_style.corner_radius_top_left = 6
	tag_style.corner_radius_top_right = 6
	tag_style.corner_radius_bottom_left = 6
	tag_style.corner_radius_bottom_right = 6
	tag_style.content_margin_left = 12
	tag_style.content_margin_right = 12
	tag_style.content_margin_top = 6
	tag_style.content_margin_bottom = 6
	tag_container.add_theme_stylebox_override("panel", tag_style)
	
	var tag_label = Label.new()
	tag_label.text = category
	tag_label.add_theme_color_override("font_color", accent_color)
	tag_label.add_theme_font_size_override("font_size", 13)
	tag_container.add_child(tag_label)
	
	parent.add_child(tag_container)

func _add_quiz_section() -> void:
	"""Add quiz section"""
	_add_separator()
	
	var quiz_container = CenterContainer.new()
	var quiz_button = Button.new()
	quiz_button.text = "Take Quiz"
	quiz_button.add_theme_font_size_override("font_size", 16)
	quiz_button.custom_minimum_size = Vector2(140, 44)
	
	# Enhanced button styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = accent_color
	button_style.corner_radius_top_left = 6
	button_style.corner_radius_top_right = 6
	button_style.corner_radius_bottom_left = 6
	button_style.corner_radius_bottom_right = 6
	quiz_button.add_theme_stylebox_override("normal", button_style)
	
	var hover_style = button_style.duplicate()
	hover_style.bg_color = accent_color * 1.3
	quiz_button.add_theme_stylebox_override("hover", hover_style)
	
	quiz_button.pressed.connect(_on_quiz_pressed)
	quiz_container.add_child(quiz_button)
	_content_container.add_child(quiz_container)

func _add_separator() -> void:
	"""Add visual separator"""
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color(1, 1, 1, 0.1))
	separator.add_theme_constant_override("separation", 2)
	_content_container.add_child(separator)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 12
	_content_container.add_child(spacer)

func _clear_content() -> void:
	"""Clear all content"""
	for child in _content_container.get_children():
		child.queue_free()
	_content_sections.clear()

func _reset_auto_hide_timer() -> void:
	"""Reset auto-hide timer"""
	if _auto_hide_timer and auto_hide:
		_auto_hide_timer.stop()
		_auto_hide_timer.start()

func _animate_content_entrance() -> void:
	"""Animate content entrance"""
	for i in range(_content_container.get_child_count()):
		var child = _content_container.get_child(i)
		child.modulate.a = 0.0
		child.position.x = 10
		
		var delay = i * 0.05
		var tween = create_tween()
		tween.tween_delay(delay)
		tween.tween_property(child, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(child, "position:x", 0, 0.3)

func _update_content_with_animation(new_content: Dictionary) -> void:
	"""Update content with smooth animation"""
	# Fade out current content
	var fade_tween = create_tween()
	fade_tween.tween_property(_content_container, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(func():
		_display_filtered_content(new_content)
		# Fade in new content
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(_content_container, "modulate:a", 1.0, 0.3)
	)

# === SIGNAL HANDLERS ===

func _on_close_pressed() -> void:
	"""Handle close button"""
	hide_panel()
	close_requested.emit()

func _on_quiz_pressed() -> void:
	"""Handle quiz button"""
	if _current_structure_id != "":
		quiz_requested.emit(_current_structure_id)

func _on_level_button_pressed(level: int) -> void:
	"""Handle learning level change"""
	if level != _current_learning_level:
		if UIAdaptationManager:
			UIAdaptationManager.set_learning_level(level)
		learning_level_adjusted.emit(level)

func _on_learning_level_updated(level: int) -> void:
	"""Handle learning level update from LearningContentManager"""
	_current_learning_level = level
	refresh_content()
	_update_level_indicator()

func _on_content_filtered(structure_id: String, filtered_content: Dictionary) -> void:
	"""Handle content filtering completion"""
	if structure_id == _current_structure_id:
		# Content has been updated, could refresh if needed
		pass

func _on_ui_learning_level_changed(level: UIAdaptationManager.LearningLevel) -> void:
	"""Handle learning level changes from UIAdaptationManager"""
	_current_learning_level = level
	refresh_content()
	_update_level_indicator()