class_name M3ComponentIntegrator
extends Resource

const ButtonMotionHandler = preload("res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd")

## Universal Material 3 integration utility for NeuroVision components
## Provides consistent M3 styling across all UI elements while preserving educational functionality

# === COMPONENT INTEGRATION METHODS ===

## Apply M3 styling to any panel component
static func apply_m3_to_panel(panel: PanelContainer, variant: String = "surface") -> void:
	"""Apply M3 panel styling with specified variant"""
	if not panel:
		push_error("[M3ComponentIntegrator] Null panel provided")
		return
	
	var panel_variant: M3ComponentApplicator.PanelVariant
	match variant.to_lower():
		"surface":
			panel_variant = M3ComponentApplicator.PanelVariant.SURFACE
		"surface_container":
			panel_variant = M3ComponentApplicator.PanelVariant.SURFACE_CONTAINER
		"surface_variant":
			panel_variant = M3ComponentApplicator.PanelVariant.SURFACE_VARIANT
		"modal":
			panel_variant = M3ComponentApplicator.PanelVariant.MODAL
		"glass":
			panel_variant = M3ComponentApplicator.PanelVariant.GLASS
		_:
			panel_variant = M3ComponentApplicator.PanelVariant.SURFACE
	
	M3ComponentApplicator.apply_m3_panel_styling(panel, panel_variant)

## Apply M3 styling to any button component
static func apply_m3_to_button(button: Button, variant: String = "primary") -> void:
	"""Apply M3 button styling with specified variant"""
	if not button:
		push_error("[M3ComponentIntegrator] Null button provided")
		return
	
	var button_variant: M3ComponentApplicator.ButtonVariant
	match variant.to_lower():
		"primary":
			button_variant = M3ComponentApplicator.ButtonVariant.PRIMARY
		"secondary":
			button_variant = M3ComponentApplicator.ButtonVariant.SECONDARY
		"tertiary":
			button_variant = M3ComponentApplicator.ButtonVariant.TERTIARY
		"icon":
			button_variant = M3ComponentApplicator.ButtonVariant.ICON
		_:
			button_variant = M3ComponentApplicator.ButtonVariant.PRIMARY
	
	M3ComponentApplicator.apply_m3_button_styling(button, button_variant)
	
	# Add motion effects if available
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandler.setup_button_hover_animation(button)

## Apply M3 typography to any label component
static func apply_m3_to_label(label: Label, typography: String = "body") -> void:
	"""Apply M3 typography styling to label"""
	if not label:
		push_error("[M3ComponentIntegrator] Null label provided")
		return
	
	var typo_scale: M3ComponentApplicator.TypographyScale
	match typography.to_lower():
		"display_large":
			typo_scale = M3ComponentApplicator.TypographyScale.DISPLAY_LARGE
		"display_medium":
			typo_scale = M3ComponentApplicator.TypographyScale.DISPLAY_MEDIUM
		"display_small":
			typo_scale = M3ComponentApplicator.TypographyScale.DISPLAY_SMALL
		"headline_large":
			typo_scale = M3ComponentApplicator.TypographyScale.HEADLINE_LARGE
		"headline_medium":
			typo_scale = M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM
		"headline_small":
			typo_scale = M3ComponentApplicator.TypographyScale.HEADLINE_SMALL
		"title_large":
			typo_scale = M3ComponentApplicator.TypographyScale.TITLE_LARGE
		"title_medium":
			typo_scale = M3ComponentApplicator.TypographyScale.TITLE_MEDIUM
		"title_small":
			typo_scale = M3ComponentApplicator.TypographyScale.TITLE_SMALL
		"label_large":
			typo_scale = M3ComponentApplicator.TypographyScale.LABEL_LARGE
		"label_medium":
			typo_scale = M3ComponentApplicator.TypographyScale.LABEL_MEDIUM
		"label_small":
			typo_scale = M3ComponentApplicator.TypographyScale.LABEL_SMALL
		"body_large":
			typo_scale = M3ComponentApplicator.TypographyScale.BODY_LARGE
		"body_medium":
			typo_scale = M3ComponentApplicator.TypographyScale.BODY_MEDIUM
		"body_small":
			typo_scale = M3ComponentApplicator.TypographyScale.BODY_SMALL
		_:
			typo_scale = M3ComponentApplicator.TypographyScale.BODY_MEDIUM
	
	M3ComponentApplicator.apply_m3_text_styling(label, typo_scale)

## Setup M3 focus handling for accessibility
static func setup_m3_focus_handling(control: Control) -> void:
	"""Setup M3-compliant focus handling for accessibility"""
	if not control:
		return
	
	control.focus_mode = Control.FOCUS_ALL
	
	# Create M3 focus indicator style
	var focus_style = StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = M3DesignTokens.M3_COLORS["primary"]
	focus_style.set_border_width_all(M3DesignTokens.M3_ACCESSIBILITY["focus_indicator_width"])
	focus_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
	focus_style.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	
	control.add_theme_stylebox_override("focus", focus_style)

## Apply educational context-specific M3 overrides
static func apply_m3_educational_overrides(control: Control, edu_context: String) -> void:
	"""Apply educational context-specific M3 styling overrides"""
	if not control:
		return
	
	match edu_context.to_lower():
		"medical":
			# Clinical/professional context - use minimal, clean styling
			_apply_medical_context_styling(control)
		"student":
			# Student-friendly context - use enhanced, engaging styling
			_apply_student_context_styling(control)
		"assessment":
			# Quiz/assessment context - use focused, clear styling
			_apply_assessment_context_styling(control)
		"research":
			# Research context - use detailed, information-dense styling
			_apply_research_context_styling(control)

# === SPECIALIZED APPLICATION METHODS ===

## Apply M3 styling to entire UI hierarchies
static func apply_m3_to_scene_hierarchy(root_node: Node, recursive: bool = true) -> void:
	"""Apply M3 styling to entire scene hierarchy automatically"""
	if not root_node:
		return
	
	_apply_m3_to_node(root_node)
	
	if recursive:
		for child in root_node.get_children():
			apply_m3_to_scene_hierarchy(child, true)

## Convert legacy UI components to M3
static func convert_legacy_ui_to_m3(ui_node: Control, conversion_rules: Dictionary = {}) -> void:
	"""Convert legacy UI components to M3 styling with custom rules"""
	if not ui_node:
		return
	
	# Default conversion rules
	var default_rules = {
		"buttons": "primary",
		"panels": "surface",
		"labels": "body_medium",
		"educational_context": "student"
	}
	
	# Merge with provided rules
	for key in conversion_rules:
		default_rules[key] = conversion_rules[key]
	
	_apply_conversion_rules(ui_node, default_rules)

## Batch update multiple components with M3
static func batch_apply_m3_styling(components: Array, styling_config: Dictionary) -> void:
	"""Apply M3 styling to multiple components with batch configuration"""
	for component in components:
		if not component is Control:
			continue
		
		var component_type = component.get_class()
		var config = styling_config.get(component_type, {})
		
		_apply_component_specific_styling(component, config)

# === PRIVATE HELPER METHODS ===

static func _apply_medical_context_styling(control: Control) -> void:
	"""Apply medical/clinical context styling"""
	# Use minimal theme colors for professional appearance
	if control is Label:
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	elif control is Button:
		# Subtle, professional button styling
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])

static func _apply_student_context_styling(control: Control) -> void:
	"""Apply student-friendly context styling"""
	# Use more vibrant, engaging colors for student interface
	if control is Label:
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	elif control is Button:
		# More prominent, engaging button styling
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])

static func _apply_assessment_context_styling(control: Control) -> void:
	"""Apply assessment/quiz context styling"""
	# High contrast, clear styling for assessment focus
	if control is Label:
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	elif control is Button:
		# Clear, focused button styling for assessments
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])

static func _apply_research_context_styling(control: Control) -> void:
	"""Apply research context styling"""
	# Information-dense, detailed styling for research use
	if control is Label:
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	elif control is Button:
		# Subtle, non-distracting button styling for research
		control.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

static func _apply_m3_to_node(node: Node) -> void:
	"""Apply appropriate M3 styling to individual node based on type"""
	if node is PanelContainer:
		apply_m3_to_panel(node as PanelContainer)
	elif node is Button:
		apply_m3_to_button(node as Button)
	elif node is Label:
		apply_m3_to_label(node as Label)
	elif node is Control:
		setup_m3_focus_handling(node as Control)

static func _apply_conversion_rules(ui_node: Control, rules: Dictionary) -> void:
	"""Apply conversion rules to UI node hierarchy"""
	# Apply rules based on node type and educational context
	if ui_node is Button:
		apply_m3_to_button(ui_node, rules.get("buttons", "primary"))
	elif ui_node is PanelContainer:
		apply_m3_to_panel(ui_node, rules.get("panels", "surface"))
	elif ui_node is Label:
		apply_m3_to_label(ui_node, rules.get("labels", "body_medium"))
	
	# Apply educational context overrides
	var edu_context = rules.get("educational_context", "student")
	apply_m3_educational_overrides(ui_node, edu_context)
	
	# Recursively apply to children
	for child in ui_node.get_children():
		if child is Control:
			_apply_conversion_rules(child, rules)

static func _apply_component_specific_styling(component: Control, config: Dictionary) -> void:
	"""Apply component-specific M3 styling configuration"""
	var variant = config.get("variant", "primary")
	var typography = config.get("typography", "body_medium")
	var edu_context = config.get("educational_context", "student")
	
	if component is Button:
		apply_m3_to_button(component, variant)
	elif component is PanelContainer:
		apply_m3_to_panel(component, variant)
	elif component is Label:
		apply_m3_to_label(component, typography)
	
	apply_m3_educational_overrides(component, edu_context)
	setup_m3_focus_handling(component)

# === VALIDATION AND TESTING METHODS ===

## Validate M3 integration across components
static func validate_m3_integration(root_node: Node) -> Dictionary:
	"""Validate M3 integration status across component hierarchy"""
	var validation_result = {
		"total_components": 0,
		"m3_integrated": 0,
		"missing_m3": [],
		"integration_percentage": 0.0
	}
	
	_validate_node_m3_integration(root_node, validation_result)
	
	if validation_result.total_components > 0:
		validation_result.integration_percentage = (float(validation_result.m3_integrated) / float(validation_result.total_components)) * 100.0
	
	return validation_result

static func _validate_node_m3_integration(node: Node, result: Dictionary) -> void:
	"""Recursively validate M3 integration for nodes"""
	if node is Control:
		result.total_components += 1
		
		# Check if node has M3 styling applied
		var has_m3_styling = _check_m3_styling_applied(node as Control)
		if has_m3_styling:
			result.m3_integrated += 1
		else:
			result.missing_m3.append(node.get_path())
	
	for child in node.get_children():
		_validate_node_m3_integration(child, result)

static func _check_m3_styling_applied(control: Control) -> bool:
	"""Check if control has M3 styling applied"""
	# Check for common M3 style indicators
	var has_m3_colors = false
	var has_m3_typography = false
	
	# Check for M3 color overrides
	if control.has_theme_color_override("font_color"):
		var color = control.get_theme_color("font_color")
		# Check if color matches M3 design tokens
		for token_name in M3DesignTokens.M3_COLORS:
			if color.is_equal_approx(M3DesignTokens.M3_COLORS[token_name]):
				has_m3_colors = true
				break
	
	# Check for M3 typography
	if control.has_theme_font_size_override("font_size"):
		var font_size = control.get_theme_font_size("font_size")
		# Check if font size matches M3 type scale
		for scale_name in M3DesignTokens.M3_TYPE_SCALE:
			if font_size == M3DesignTokens.M3_TYPE_SCALE[scale_name]["size"]:
				has_m3_typography = true
				break
	
	return has_m3_colors or has_m3_typography

# === DEBUGGING AND DEVELOPMENT METHODS ===

## Generate M3 integration report
static func generate_integration_report(root_node: Node) -> String:
	"""Generate detailed M3 integration report for debugging"""
	var validation = validate_m3_integration(root_node)
	
	var report = "=== M3 INTEGRATION REPORT ===\n"
	report += "Total Components: %d\n" % validation.total_components
	report += "M3 Integrated: %d\n" % validation.m3_integrated
	report += "Integration Percentage: %.1f%%\n\n" % validation.integration_percentage
	
	if validation.missing_m3.size() > 0:
		report += "COMPONENTS MISSING M3 INTEGRATION:\n"
		for missing_path in validation.missing_m3:
			report += "  - %s\n" % missing_path
	
	report += "\n=== END REPORT ==="
	
	return report

## Print M3 integration status to console
static func debug_print_m3_status(root_node: Node) -> void:
	"""Print M3 integration status to console for debugging"""
	var report = generate_integration_report(root_node)
	print("[M3ComponentIntegrator] ", report)