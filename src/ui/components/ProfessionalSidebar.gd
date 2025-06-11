extends PanelContainer
class_name ProfessionalSidebar

## Professional sidebar with search, filters, and structure list

signal structure_selected(structure_id: String)
signal filter_changed(filter_text: String)
signal category_selected(category: String)

# === CONSTANTS ===
const SIDEBAR_WIDTH: int = 320
const ANIMATION_DURATION: float = 0.2
const HOVER_COLOR: Color = Color(0.345098, 0.65098, 1, 0.1)
const SELECTED_COLOR: Color = Color(0.345098, 0.65098, 1, 0.2)

# === EXPORTS ===
@export var auto_collapse: bool = false
@export var show_categories: bool = true
@export var show_search: bool = true
@export var icon_size: int = 24

# === PRIVATE VARIABLES ===
var _structure_items: Dictionary = {}  # structure_id -> Button
var _categories: Dictionary = {}  # category -> Array of structure_ids
var _is_collapsed: bool = false
var _selected_structure: String = ""
var _filter_text: String = ""
var _selected_category: String = "All"

@onready var _search_container: VBoxContainer = VBoxContainer.new()
@onready var _search_input: LineEdit = LineEdit.new()
@onready var _category_filter: OptionButton = OptionButton.new()
@onready var _structure_list: ScrollContainer = ScrollContainer.new()
@onready var _structure_container: VBoxContainer = VBoxContainer.new()
@onready var _toggle_button: Button = Button.new()

# === PUBLIC METHODS ===

func _ready() -> void:
	_setup_ui()
	_apply_theme()
	_connect_signals()
	
func populate_structures(structures: Array) -> void:
	"""Populate the sidebar with brain structures"""
	_clear_structures()
	_categories.clear()
	_categories["All"] = []
	
	for structure in structures:
		var id = structure.get("id", "")
		var name = structure.get("displayName", structure.get("name", "Unknown"))
		var category = structure.get("category", "Other")
		var icon_path = structure.get("icon", "")
		
		# Add to categories
		if not _categories.has(category):
			_categories[category] = []
		_categories[category].append(id)
		_categories["All"].append(id)
		
		# Create structure item
		_create_structure_item(id, name, category, icon_path)
	
	# Update category filter
	_update_category_filter()
	_apply_filter()

func select_structure(structure_id: String) -> void:
	"""Select a structure programmatically"""
	if _selected_structure == structure_id:
		return
		
	_selected_structure = structure_id
	_update_selection_visuals()
	
func toggle_sidebar() -> void:
	"""Toggle sidebar collapsed state"""
	_is_collapsed = not _is_collapsed
	_animate_toggle()

func set_filter(text: String) -> void:
	"""Set search filter text"""
	_search_input.text = text
	_filter_text = text
	_apply_filter()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup UI structure"""
	custom_minimum_size.x = SIDEBAR_WIDTH
	
	# Main container
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# Header with toggle button
	var header = HBoxContainer.new()
	header.custom_minimum_size.y = 48
	main_vbox.add_child(header)
	
	var title = Label.new()
	title.text = "Brain Structures"
	title.add_theme_font_size_override("font_size", 18)
	header.add_child(title)
	
	header.add_spacer(false)
	
	_toggle_button.text = "◀"
	_toggle_button.flat = true
	_toggle_button.custom_minimum_size = Vector2(32, 32)
	header.add_child(_toggle_button)
	
	# Add separator
	var sep1 = HSeparator.new()
	main_vbox.add_child(sep1)
	
	# Search and filter section
	if show_search:
		_search_container.add_theme_constant_override("separation", 8)
		var search_margin = MarginContainer.new()
		search_margin.add_theme_constant_override("margin_left", 16)
		search_margin.add_theme_constant_override("margin_right", 16)
		search_margin.add_theme_constant_override("margin_top", 16)
		search_margin.add_theme_constant_override("margin_bottom", 8)
		search_margin.add_child(_search_container)
		main_vbox.add_child(search_margin)
		
		# Search input
		_search_input.placeholder_text = "🔍 Search structures..."
		_search_input.clear_button_enabled = true
		_search_container.add_child(_search_input)
		
		# Category filter
		if show_categories:
			_category_filter.text = "All Categories"
			_search_container.add_child(_category_filter)
		
		# Add separator
		var sep2 = HSeparator.new()
		main_vbox.add_child(sep2)
	
	# Structure list
	_structure_list.custom_minimum_size.y = 400
	main_vbox.add_child(_structure_list)
	
	_structure_container.add_theme_constant_override("separation", 2)
	_structure_list.add_child(_structure_container)

func _apply_theme() -> void:
	"""Apply professional theme styling"""
	# Load and apply theme if it exists
	var theme_path = "res://assets/themes/professional_theme.tres"
	if ResourceLoader.exists(theme_path):
		theme = load(theme_path)
	
	# Custom panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0862745, 0.105882, 0.133333, 1)
	panel_style.corner_radius_top_left = 0
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_bottom_left = 0
	panel_style.shadow_color = Color(0, 0, 0, 0.3)
	panel_style.shadow_size = 4
	panel_style.shadow_offset = Vector2(2, 0)
	add_theme_stylebox_override("panel", panel_style)

func _connect_signals() -> void:
	"""Connect internal signals"""
	_toggle_button.pressed.connect(toggle_sidebar)
	_search_input.text_changed.connect(_on_search_text_changed)
	_category_filter.item_selected.connect(_on_category_selected)

func _create_structure_item(id: String, name: String, category: String, icon_path: String) -> void:
	"""Create a structure list item with glass panel and hover animation"""
	var button = Button.new()
	button.text = name
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.toggle_mode = true
	button.add_theme_constant_override("h_separation", 12)
	button.flat = true
	
	# Add icon if available
	if icon_path and ResourceLoader.exists(icon_path):
		var icon = load(icon_path)
		button.icon = icon
		button.icon_max_width = icon_size
	
	# Glass panel style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.1, 0.1, 0.12, 0.6)
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.corner_radius_bottom_left = 12
	normal_style.border_width_left = 1
	normal_style.border_width_top = 1
	normal_style.border_width_right = 1
	normal_style.border_width_bottom = 1
	normal_style.border_color = Color(1, 1, 1, 0.05)
	normal_style.content_margin_left = 16
	normal_style.content_margin_right = 16
	normal_style.content_margin_top = 12
	normal_style.content_margin_bottom = 12
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.23, 0.51, 0.96, 0.15)
	hover_style.border_color = Color(0.23, 0.51, 0.96, 0.3)
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.23, 0.51, 0.96, 0.25)
	pressed_style.border_color = Color(0.23, 0.51, 0.96, 0.5)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Store metadata
	button.set_meta("structure_id", id)
	button.set_meta("category", category)
	
	# Add hover animation handlers
	button.mouse_entered.connect(_on_button_hover_start.bind(button))
	button.mouse_exited.connect(_on_button_hover_end.bind(button))
	
	# Connect signal
	button.pressed.connect(_on_structure_button_pressed.bind(id))
	
	_structure_container.add_child(button)
	_structure_items[id] = button

func _clear_structures() -> void:
	"""Clear all structure items"""
	for child in _structure_container.get_children():
		child.queue_free()
	_structure_items.clear()

func _update_category_filter() -> void:
	"""Update category filter options"""
	_category_filter.clear()
	for category in _categories.keys():
		_category_filter.add_item(category)

func _apply_filter() -> void:
	"""Apply search and category filters"""
	var search_lower = _filter_text.to_lower()
	
	for id in _structure_items:
		var button = _structure_items[id]
		var visible = true
		
		# Category filter
		if _selected_category != "All":
			var item_category = button.get_meta("category", "")
			if item_category != _selected_category:
				visible = false
		
		# Search filter
		if visible and search_lower.length() > 0:
			var name_lower = button.text.to_lower()
			if not name_lower.contains(search_lower):
				visible = false
		
		button.visible = visible

func _update_selection_visuals() -> void:
	"""Update visual state of selected item"""
	for id in _structure_items:
		var button = _structure_items[id]
		button.button_pressed = (id == _selected_structure)

func _animate_toggle() -> void:
	"""Animate sidebar toggle"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if _is_collapsed:
		tween.tween_property(self, "custom_minimum_size:x", 48, ANIMATION_DURATION)
		_toggle_button.text = "▶"
		# Hide content
		for child in get_children():
			if child != _toggle_button.get_parent():
				child.visible = false
	else:
		tween.tween_property(self, "custom_minimum_size:x", SIDEBAR_WIDTH, ANIMATION_DURATION)
		_toggle_button.text = "◀"
		# Show content after animation
		tween.tween_callback(func():
			for child in get_children():
				child.visible = true
		)

# === SIGNAL HANDLERS ===

func _on_structure_button_pressed(structure_id: String) -> void:
	"""Handle structure button press"""
	select_structure(structure_id)
	structure_selected.emit(structure_id)

func _on_search_text_changed(text: String) -> void:
	"""Handle search text change"""
	_filter_text = text
	_apply_filter()
	filter_changed.emit(text)

func _on_category_selected(index: int) -> void:
	"""Handle category selection"""
	_selected_category = _category_filter.get_item_text(index)
	_apply_filter()
	category_selected.emit(_selected_category)

func _on_button_hover_start(button: Button) -> void:
	"""Handle button hover start with 4px translateX animation"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "position:x", 4, 0.2)

func _on_button_hover_end(button: Button) -> void:
	"""Handle button hover end"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "position:x", 0, 0.15)