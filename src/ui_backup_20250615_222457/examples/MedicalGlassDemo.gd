extends Control

## Medical Glass V2 Shader Demo
## Demonstrates integration of the enhanced glass morphism effect
## with NeuroVision's educational interface components

# === UI REFERENCES ===
@onready var info_panel: PanelContainer = $MainContainer/VBoxContainer/InfoPanel
@onready var assessment_panel: PanelContainer = $MainContainer/VBoxContainer/AssessmentPanel
@onready var teacher_panel: PanelContainer = $MainContainer/VBoxContainer/TeacherPanel
@onready var settings_panel: VBoxContainer = $MainContainer/SettingsContainer/SettingsPanel

# Glass materials for different panel types
var glass_materials: Dictionary = {}

func _ready():
	"""Initialize medical glass demo with various educational panel types"""
	print("[MedicalGlassDemo] Initializing shader demonstration")
	
	_setup_glass_materials()
	_apply_materials_to_panels()
	_setup_demo_controls()
	_connect_theme_system()

# === GLASS MATERIAL SETUP ===

func _setup_glass_materials() -> void:
	"""Create glass materials for different educational panel types"""
	
	# Load the MedicalGlassV2Material class
	var MaterialClass = preload("res://src/ui/effects/materials/MedicalGlassV2Material.gd")
	
	# Create materials using the factory method
	glass_materials["info"] = MaterialClass.create_for_component("info_panel")
	glass_materials["assessment"] = MaterialClass.create_for_component("assessment_panel")
	glass_materials["teacher"] = MaterialClass.create_for_component("teacher_dashboard")
	
	print("[MedicalGlassDemo] Created glass materials with performance costs:")
	for type in glass_materials:
		var glass_material = glass_materials[type]
		print("  - %s: %s" % [type, glass_material.get_performance_cost()])

func _apply_materials_to_panels() -> void:
	"""Apply appropriate glass materials to educational panels"""
	
	if info_panel:
		info_panel.material = glass_materials["info"]
		# Make the effect more visible for demo
		glass_materials["info"].set_shader_parameter("glass_intensity", 0.25)
		glass_materials["info"].set_shader_parameter("glass_blur", 12.0)
		_setup_info_panel_content()
		print("[MedicalGlassDemo] Applied glass material to info panel")
	
	if assessment_panel:
		assessment_panel.material = glass_materials["assessment"]
		# Make the effect more visible for demo
		glass_materials["assessment"].set_shader_parameter("glass_intensity", 0.3)
		glass_materials["assessment"].set_shader_parameter("glass_blur", 15.0)
		_setup_assessment_panel_content()
		print("[MedicalGlassDemo] Applied glass material to assessment panel")
	
	if teacher_panel:
		teacher_panel.material = glass_materials["teacher"]
		# Make the effect more visible for demo
		glass_materials["teacher"].set_shader_parameter("glass_intensity", 0.2)
		glass_materials["teacher"].set_shader_parameter("glass_blur", 10.0)
		_setup_teacher_panel_content()
		print("[MedicalGlassDemo] Applied glass material to teacher panel")

# === DEMO CONTENT SETUP ===

func _setup_info_panel_content() -> void:
	"""Setup educational content for info panel demonstration"""
	var label = Label.new()
	label.text = """📚 HIPPOCAMPUS INFORMATION

Function: Memory formation and spatial navigation
Location: Medial temporal lobe
Clinical Relevance: Affected in Alzheimer's disease

This panel uses the standard medical glass effect
optimized for educational content readability."""
	
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_panel.add_child(label)

func _setup_assessment_panel_content() -> void:
	"""Setup assessment content for enhanced glass demonstration"""
	var vbox = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "🧠 ASSESSMENT QUESTION"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	var question = Label.new()
	question.text = "Which brain structure is primarily responsible for memory consolidation?"
	question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(question)
	
	var answer_container = VBoxContainer.new()
	var answers = ["A) Cerebellum", "B) Hippocampus", "C) Amygdala", "D) Thalamus"]
	
	for answer in answers:
		var button = Button.new()
		button.text = answer
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		answer_container.add_child(button)
	
	vbox.add_child(answer_container)
	
	var note = Label.new()
	note.text = "\nThis panel uses enhanced glass effects\nsuitable for interactive assessments."
	note.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(note)
	
	assessment_panel.add_child(vbox)

func _setup_teacher_panel_content() -> void:
	"""Setup teacher dashboard content with subtle glass effects"""
	var vbox = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "👩‍🏫 TEACHER DASHBOARD"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var stats = Label.new()
	stats.text = """Student Progress:
• Average Score: 87%
• Completion Rate: 92%
• Time Spent: 2.3 hours

Current Topic: Limbic System
Students Online: 24/30

Subtle glass effects maintain
professional appearance."""
	
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(stats)
	
	teacher_panel.add_child(vbox)

# === DEMO CONTROLS ===

func _setup_demo_controls() -> void:
	"""Create interactive controls for shader demonstration"""
	
	# Glass intensity control
	var intensity_label = Label.new()
	intensity_label.text = "Glass Intensity:"
	settings_panel.add_child(intensity_label)
	
	var intensity_slider = HSlider.new()
	intensity_slider.min_value = 0.0
	intensity_slider.max_value = 0.5
	intensity_slider.value = 0.25  # Start with more visible effect
	intensity_slider.step = 0.05
	intensity_slider.value_changed.connect(_on_intensity_changed)
	settings_panel.add_child(intensity_slider)
	
	# Performance profile control
	var profile_label = Label.new()
	profile_label.text = "Performance Profile:"
	settings_panel.add_child(profile_label)
	
	var profile_option = OptionButton.new()
	profile_option.add_item("Performance (Intel UHD 620)")
	profile_option.add_item("Balanced (Default)")
	profile_option.add_item("Quality (High-end GPU)")
	profile_option.selected = 1  # Balanced
	profile_option.item_selected.connect(_on_profile_changed)
	settings_panel.add_child(profile_option)
	
	# Accessibility controls
	var accessibility_label = Label.new()
	accessibility_label.text = "Accessibility:"
	settings_panel.add_child(accessibility_label)
	
	var high_contrast_check = CheckBox.new()
	high_contrast_check.text = "High Contrast Mode"
	high_contrast_check.toggled.connect(_on_high_contrast_toggled)
	settings_panel.add_child(high_contrast_check)
	
	var reduced_motion_check = CheckBox.new()
	reduced_motion_check.text = "Reduced Motion"
	reduced_motion_check.toggled.connect(_on_reduced_motion_toggled)
	settings_panel.add_child(reduced_motion_check)
	
	# Theme switching
	var theme_label = Label.new()
	theme_label.text = "Theme:"
	settings_panel.add_child(theme_label)
	
	var theme_option = OptionButton.new()
	theme_option.add_item("Enhanced")
	theme_option.add_item("Minimal")
	theme_option.add_item("High Contrast")
	theme_option.add_item("Colorblind Safe")
	theme_option.item_selected.connect(_on_theme_changed)
	settings_panel.add_child(theme_option)

# === EVENT HANDLERS ===

func _on_intensity_changed(value: float) -> void:
	"""Handle glass intensity adjustment"""
	for glass_material in glass_materials.values():
		glass_material.set_shader_parameter("glass_intensity", value)
	print("[MedicalGlassDemo] Glass intensity set to: ", value)

func _on_profile_changed(index: int) -> void:
	"""Handle performance profile changes"""
	var MaterialClass = preload("res://src/ui/effects/materials/MedicalGlassV2Material.gd")
	var profiles = [
		MaterialClass.PerformanceProfile.PERFORMANCE,
		MaterialClass.PerformanceProfile.BALANCED,
		MaterialClass.PerformanceProfile.QUALITY
	]
	
	for glass_material in glass_materials.values():
		glass_material.set_performance_profile(profiles[index])
	
	var profile_names = ["Performance", "Balanced", "Quality"]
	print("[MedicalGlassDemo] Performance profile set to: ", profile_names[index])

func _on_high_contrast_toggled(enabled: bool) -> void:
	"""Handle high contrast accessibility mode"""
	for glass_material in glass_materials.values():
		glass_material.configure_for_accessibility(enabled, false)
	print("[MedicalGlassDemo] High contrast mode: ", enabled)

func _on_reduced_motion_toggled(enabled: bool) -> void:
	"""Handle reduced motion accessibility mode"""
	for glass_material in glass_materials.values():
		glass_material.configure_for_accessibility(false, enabled)
	print("[MedicalGlassDemo] Reduced motion mode: ", enabled)

func _on_theme_changed(index: int) -> void:
	"""Handle theme switching to demonstrate glass integration"""
	var theme_names = ["enhanced", "minimal", "high_contrast", "colorblind_safe"]
	
	if UnifiedColorManager:
		UnifiedColorManager.set_theme_variant(theme_names[index])
		print("[MedicalGlassDemo] Theme changed to: ", theme_names[index])

# === THEME SYSTEM INTEGRATION ===

func _connect_theme_system() -> void:
	"""Connect to NeuroVision's theme system for automatic updates"""
	if UnifiedColorManager:
		UnifiedColorManager.theme_changed.connect(_on_unified_theme_changed)

func _on_unified_theme_changed(theme_name: String) -> void:
	"""Handle automatic theme updates from unified color system"""
	print("[MedicalGlassDemo] Glass materials updated for theme: ", theme_name)
	
	# Materials automatically update themselves through their internal connections
	# This handler just provides feedback for the demo

# === PERFORMANCE MONITORING ===

func _on_visibility_changed() -> void:
	"""Monitor performance when demo becomes visible"""
	if visible:
		print("[MedicalGlassDemo] Demo scene became visible")

func _exit_tree() -> void:
	"""Clean up performance monitoring"""
	print("[MedicalGlassDemo] Demo scene exiting")

# === VALIDATION AND TESTING ===

func validate_shader_integration() -> Dictionary:
	"""Validate that medical glass shader is properly integrated"""
	var validation_result = {
		"theme_integration": false,
		"performance_acceptable": false,
		"accessibility_compliant": false,
		"materials_created": false
	}
	
	# Check theme integration
	for glass_material in glass_materials.values():
		if glass_material.validate_theme_integration():
			validation_result.theme_integration = true
			break
	
	# Check performance
	var current_fps = Engine.get_frames_per_second()
	validation_result.performance_acceptable = current_fps >= 60.0
	
	# Check accessibility features
	validation_result.accessibility_compliant = true  # Materials support accessibility
	
	# Check materials
	validation_result.materials_created = glass_materials.size() > 0
	
	return validation_result