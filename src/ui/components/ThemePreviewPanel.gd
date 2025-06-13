class_name ThemePreviewPanel
extends PanelContainer

## Theme Preview Panel for NeuroVision
## Allows real-time theme preview and comparison without global application

# Signals
signal theme_selected(theme: Theme)
signal preview_closed()
signal comparison_requested(theme_a: Theme, theme_b: Theme)

# UI References
@onready var preview_container: Control = $VBoxContainer/PreviewContainer
@onready var controls_container: Control = $VBoxContainer/ControlsContainer
@onready var comparison_toggle: CheckBox = $VBoxContainer/Header/ComparisonToggle
@onready var apply_button: Button = $VBoxContainer/Footer/ApplyButton
@onready var cancel_button: Button = $VBoxContainer/Footer/CancelButton

# Preview components
var preview_panels: Array[PanelContainer] = []
var preview_buttons: Array[Button] = []
var preview_labels: Array[Label] = []
var preview_inputs: Array[LineEdit] = []

# Theme management
var current_preview_theme: Theme = null
var comparison_theme: Theme = null
var original_theme: Theme = null
var is_comparing: bool = false

# Preview configuration
var preview_config = {
	"show_panels": true,
	"show_buttons": true,
	"show_inputs": true,
	"show_labels": true,
	"show_accessibility": true,
	"show_performance": true
}

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize preview panel"""
	_setup_ui()
	_connect_signals()
	_create_preview_elements()
	
	# Store original theme
	original_theme = theme

func _setup_ui() -> void:
	"""Setup UI structure"""
	custom_minimum_size = Vector2(800, 600)
	
	# Create main container if not exists
	if not has_node("VBoxContainer"):
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		add_child(vbox)
		
		# Create header
		var header = _create_header()
		vbox.add_child(header)
		
		# Create preview container
		var preview = _create_preview_container()
		vbox.add_child(preview)
		
		# Create controls
		var controls = _create_controls_container()
		vbox.add_child(controls)
		
		# Create footer
		var footer = _create_footer()
		vbox.add_child(footer)

func _create_header() -> PanelContainer:
	"""Create header with title and options"""
	var header = PanelContainer.new()
	header.name = "Header"
	
	var hbox = HBoxContainer.new()
	header.add_child(hbox)
	
	var title = Label.new()
	title.text = "Theme Preview"
	title.add_theme_font_size_override("font_size", 18)
	hbox.add_child(title)
	
	hbox.add_spacer(false)
	
	var comparison_toggle = CheckBox.new()
	comparison_toggle.name = "ComparisonToggle"
	comparison_toggle.text = "Compare Themes"
	hbox.add_child(comparison_toggle)
	
	return header

func _create_preview_container() -> ScrollContainer:
	"""Create scrollable preview area"""
	var scroll = ScrollContainer.new()
	scroll.name = "PreviewContainer"
	scroll.custom_minimum_size.y = 400
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	scroll.add_child(grid)
	
	return scroll

func _create_controls_container() -> PanelContainer:
	"""Create controls for theme customization"""
	var controls = PanelContainer.new()
	controls.name = "ControlsContainer"
	
	var vbox = VBoxContainer.new()
	controls.add_child(vbox)
	
	# Theme selection
	var theme_selector = _create_theme_selector()
	vbox.add_child(theme_selector)
	
	# Customization options
	var customization = _create_customization_options()
	vbox.add_child(customization)
	
	# Performance indicators
	var performance = _create_performance_indicators()
	vbox.add_child(performance)
	
	return controls

func _create_footer() -> PanelContainer:
	"""Create footer with action buttons"""
	var footer = PanelContainer.new()
	footer.name = "Footer"
	
	var hbox = HBoxContainer.new()
	footer.add_child(hbox)
	
	hbox.add_spacer(false)
	
	var cancel_button = Button.new()
	cancel_button.name = "CancelButton"
	cancel_button.text = "Cancel"
	hbox.add_child(cancel_button)
	
	var apply_button = Button.new()
	apply_button.name = "ApplyButton"
	apply_button.text = "Apply Theme"
	hbox.add_child(apply_button)
	
	return footer

func _connect_signals() -> void:
	"""Connect UI signals"""
	if comparison_toggle:
		comparison_toggle.toggled.connect(_on_comparison_toggled)
	
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
		
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)

# === PREVIEW ELEMENT CREATION ===

func _create_preview_elements() -> void:
	"""Create sample UI elements for preview"""
	var grid = preview_container.get_child(0) if preview_container and preview_container.get_child_count() > 0 else null
	if not grid:
		return
	
	# Create sample panels
	_create_sample_panels(grid)
	
	# Create sample buttons
	_create_sample_buttons(grid)
	
	# Create sample inputs
	_create_sample_inputs(grid)
	
	# Create sample labels
	_create_sample_labels(grid)

func _create_sample_panels(parent: Control) -> void:
	"""Create sample panels for different contexts"""
	var panel_configs = [
		{"title": "Structure Information", "type": "StructureInfoPanel", "content": "Hippocampus - Memory center of the brain"},
		{"title": "Functions", "type": "FunctionPanel", "content": "• Memory formation\n• Spatial navigation\n• Pattern separation"},
		{"title": "Clinical Relevance", "type": "ClinicalPanel", "content": "Associated with Alzheimer's disease and memory disorders"},
		{"title": "Quiz Question", "type": "QuizPanel", "content": "What is the primary function of the hippocampus?"}
	]
	
	for config in panel_configs:
		var panel = _create_preview_panel(config)
		parent.add_child(panel)
		preview_panels.append(panel)

func _create_preview_panel(config: Dictionary) -> PanelContainer:
	"""Create individual preview panel"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(350, 150)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = config.title
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	# Content
	var content = RichTextLabel.new()
	content.text = config.content
	content.fit_content = true
	content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(content)
	
	# Apply panel type class for theming
	panel.set_meta("panel_type", config.type)
	
	return panel

func _create_sample_buttons(parent: Control) -> void:
	"""Create sample buttons"""
	var button_configs = [
		{"text": "Select Structure", "type": "primary"},
		{"text": "Learn More", "type": "secondary"},
		{"text": "Take Quiz", "type": "accent"},
		{"text": "Reset View", "type": "default"}
	]
	
	var button_container = VBoxContainer.new()
	button_container.add_theme_constant_override("separation", 10)
	parent.add_child(button_container)
	
	for config in button_configs:
		var button = Button.new()
		button.text = config.text
		button.set_meta("button_type", config.type)
		button_container.add_child(button)
		preview_buttons.append(button)

func _create_sample_inputs(parent: Control) -> void:
	"""Create sample input fields"""
	var input_container = VBoxContainer.new()
	parent.add_child(input_container)
	
	# Search input
	var search_label = Label.new()
	search_label.text = "Search structures:"
	input_container.add_child(search_label)
	
	var search_input = LineEdit.new()
	search_input.placeholder_text = "Type to search..."
	input_container.add_child(search_input)
	preview_inputs.append(search_input)
	
	# Quiz answer input
	var answer_label = Label.new()
	answer_label.text = "Your answer:"
	input_container.add_child(answer_label)
	
	var answer_input = LineEdit.new()
	answer_input.placeholder_text = "Enter your answer..."
	input_container.add_child(answer_input)
	preview_inputs.append(answer_input)

func _create_sample_labels(parent: Control) -> void:
	"""Create sample labels with different styles"""
	var label_container = VBoxContainer.new()
	parent.add_child(label_container)
	
	var label_configs = [
		{"text": "Critical Concept", "type": "critical"},
		{"text": "Supporting Detail", "type": "detail"},
		{"text": "Clinical Note", "type": "clinical"},
		{"text": "Learning Objective", "type": "learning"}
	]
	
	for config in label_configs:
		var label = Label.new()
		label.text = config.text
		label.set_meta("label_type", config.type)
		label_container.add_child(label)
		preview_labels.append(label)

# === THEME APPLICATION ===

func preview_theme(theme: Theme) -> void:
	"""Apply theme to preview elements only"""
	if not theme:
		return
	
	current_preview_theme = theme
	
	# Apply to preview container
	_apply_theme_recursive(preview_container, theme)
	
	# Update accessibility indicators
	_update_accessibility_indicators(theme)
	
	# Update performance metrics
	_update_performance_metrics(theme)

func _apply_theme_recursive(node: Node, theme: Theme) -> void:
	"""Recursively apply theme to node tree"""
	if node is Control:
		node.theme = theme
	
	for child in node.get_children():
		_apply_theme_recursive(child, theme)

# === THEME COMPARISON ===

func enable_comparison(theme_a: Theme, theme_b: Theme) -> void:
	"""Enable side-by-side theme comparison"""
	is_comparing = true
	current_preview_theme = theme_a
	comparison_theme = theme_b
	
	# Split preview area
	_split_preview_for_comparison()
	
	# Apply themes to respective sides
	_apply_comparison_themes()

func _split_preview_for_comparison() -> void:
	"""Split preview area into two columns"""
	var grid = preview_container.get_child(0)
	if grid is GridContainer:
		grid.columns = 4  # Double the columns for side-by-side
		
		# Duplicate preview elements for comparison
		_duplicate_preview_elements()

func _duplicate_preview_elements() -> void:
	"""Duplicate all preview elements for comparison"""
	var elements_to_duplicate = []
	
	# Collect all preview elements
	elements_to_duplicate.append_array(preview_panels)
	elements_to_duplicate.append_array(preview_buttons)
	elements_to_duplicate.append_array(preview_inputs)
	elements_to_duplicate.append_array(preview_labels)
	
	# Duplicate each element
	for element in elements_to_duplicate:
		var duplicate = element.duplicate()
		element.get_parent().add_child(duplicate)

func _apply_comparison_themes() -> void:
	"""Apply different themes to each side"""
	var grid = preview_container.get_child(0)
	if not grid:
		return
	
	var children = grid.get_children()
	var half_point = children.size() / 2
	
	for i in range(children.size()):
		var child = children[i]
		if i < half_point:
			_apply_theme_recursive(child, current_preview_theme)
		else:
			_apply_theme_recursive(child, comparison_theme)

# === CONTROLS CREATION ===

func _create_theme_selector() -> Control:
	"""Create theme selection dropdown"""
	var container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = "Theme Type:"
	container.add_child(label)
	
	var dropdown = OptionButton.new()
	dropdown.add_item("Educational Dark")
	dropdown.add_item("Educational Light")
	dropdown.add_item("High Contrast")
	dropdown.add_item("Clinical")
	dropdown.add_item("Assessment")
	
	dropdown.selected = 0
	dropdown.item_selected.connect(_on_theme_selected)
	container.add_child(dropdown)
	
	return container

func _create_customization_options() -> Control:
	"""Create theme customization controls"""
	var container = VBoxContainer.new()
	
	# Glass morphism slider
	var glass_container = _create_slider_control("Glass Effect:", 0.0, 1.0, 0.5, _on_glass_changed)
	container.add_child(glass_container)
	
	# Animation speed slider
	var anim_container = _create_slider_control("Animation Speed:", 0.5, 2.0, 1.0, _on_animation_speed_changed)
	container.add_child(anim_container)
	
	# Contrast level
	var contrast_container = _create_option_control("Contrast:", ["Standard", "High", "Low"], _on_contrast_changed)
	container.add_child(contrast_container)
	
	return container

func _create_slider_control(label_text: String, min_val: float, max_val: float, default: float, callback: Callable) -> Control:
	"""Create slider control with label"""
	var container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 120
	container.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = 0.01
	slider.custom_minimum_size.x = 200
	slider.value_changed.connect(callback)
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(default)
	value_label.custom_minimum_size.x = 50
	container.add_child(value_label)
	
	# Update value label when slider changes
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
	return container

func _create_option_control(label_text: String, options: Array, callback: Callable) -> Control:
	"""Create option button control"""
	var container = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 120
	container.add_child(label)
	
	var option_button = OptionButton.new()
	for option in options:
		option_button.add_item(option)
	option_button.selected = 0
	option_button.item_selected.connect(callback)
	container.add_child(option_button)
	
	return container

func _create_performance_indicators() -> Control:
	"""Create performance metric display"""
	var container = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "Performance Impact"
	title.add_theme_font_size_override("font_size", 14)
	container.add_child(title)
	
	# FPS indicator
	var fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: Calculating..."
	container.add_child(fps_label)
	
	# Memory usage
	var memory_label = Label.new()
	memory_label.name = "MemoryLabel"
	memory_label.text = "Memory: Calculating..."
	container.add_child(memory_label)
	
	# Complexity score
	var complexity_label = Label.new()
	complexity_label.name = "ComplexityLabel"
	complexity_label.text = "Complexity: Calculating..."
	container.add_child(complexity_label)
	
	return container

# === CALLBACKS ===

func _on_comparison_toggled(pressed: bool) -> void:
	"""Handle comparison mode toggle"""
	if pressed and comparison_theme:
		enable_comparison(current_preview_theme, comparison_theme)
	else:
		is_comparing = false
		# TODO: Restore single theme preview

func _on_apply_pressed() -> void:
	"""Handle apply button press"""
	if current_preview_theme:
		theme_selected.emit(current_preview_theme)
		preview_closed.emit()

func _on_cancel_pressed() -> void:
	"""Handle cancel button press"""
	# Restore original theme to preview
	preview_theme(original_theme)
	preview_closed.emit()

func _on_theme_selected(index: int) -> void:
	"""Handle theme selection from dropdown"""
	# Generate theme based on selection
	var theme_generator = preload("res://src/ui/themes/EducationalThemeGenerator.gd")
	var variant = theme_generator.ThemeVariant.DARK
	
	match index:
		0: variant = theme_generator.ThemeVariant.DARK
		1: variant = theme_generator.ThemeVariant.LIGHT
		2: variant = theme_generator.ThemeVariant.HIGH_CONTRAST
		3: variant = theme_generator.ThemeVariant.LIGHT  # Clinical uses light
		4: variant = theme_generator.ThemeVariant.DARK   # Assessment uses dark
	
	var new_theme = theme_generator.generate_educational_theme(variant, 1)
	preview_theme(new_theme)

func _on_glass_changed(value: float) -> void:
	"""Handle glass effect intensity change"""
	if current_preview_theme:
		# Regenerate theme with new glass intensity
		# This would require modifying the theme generation
		pass

func _on_animation_speed_changed(value: float) -> void:
	"""Handle animation speed change"""
	if current_preview_theme:
		current_preview_theme.set_meta("animation_speed", value)

func _on_contrast_changed(index: int) -> void:
	"""Handle contrast level change"""
	# Apply contrast modifications to current theme
	pass

# === METRICS UPDATE ===

func _update_accessibility_indicators(theme: Theme) -> void:
	"""Update accessibility compliance indicators"""
	# This would analyze the theme for WCAG compliance
	# For now, just show placeholder
	pass

func _update_performance_metrics(theme: Theme) -> void:
	"""Update performance impact metrics"""
	var fps_label = get_node_or_null("VBoxContainer/ControlsContainer/VBoxContainer/FPSLabel")
	var memory_label = get_node_or_null("VBoxContainer/ControlsContainer/VBoxContainer/MemoryLabel")
	var complexity_label = get_node_or_null("VBoxContainer/ControlsContainer/VBoxContainer/ComplexityLabel")
	
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if memory_label:
		var mem_usage = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
		memory_label.text = "Memory: %.1f MB" % mem_usage
	
	if complexity_label:
		# Calculate theme complexity
		var complexity = _calculate_theme_complexity(theme)
		complexity_label.text = "Complexity: " + _get_complexity_rating(complexity)

func _calculate_theme_complexity(theme: Theme) -> int:
	"""Calculate complexity score for theme"""
	# Simplified complexity calculation
	return 50  # Placeholder

func _get_complexity_rating(score: int) -> String:
	"""Convert complexity score to rating"""
	if score < 30:
		return "Low"
	elif score < 70:
		return "Medium"
	else:
		return "High"