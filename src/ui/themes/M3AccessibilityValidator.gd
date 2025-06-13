## Material 3 Accessibility Validator for NeuroVision
## Ensures Material 3 themes maintain WCAG AAA compliance
##
## This validator works with AccessibilityManager to ensure all Material 3
## design tokens and generated themes meet educational accessibility standards.

class_name M3AccessibilityValidator
extends Resource

# Preload dependencies
const M3Tokens = preload("res://src/ui/themes/M3DesignTokens.gd")

# === WCAG AAA REQUIREMENTS ===
const WCAG_AAA_CONTRAST_NORMAL = 7.0
const WCAG_AAA_CONTRAST_LARGE = 4.5
const WCAG_AAA_LARGE_TEXT_SIZE = 18
const WCAG_AAA_BOLD_TEXT_SIZE = 14

# === VALIDATION RESULTS STRUCTURE ===
class ValidationResult:
	var is_compliant: bool = true
	var issues: Array = []
	var warnings: Array = []
	var suggestions: Array = []
	
	func add_issue(description: String, severity: String = "error") -> void:
		issues.append({"description": description, "severity": severity})
		if severity == "error":
			is_compliant = false

# === MAIN VALIDATION METHODS ===

## Validate a Material 3 theme for WCAG AAA compliance
static func validate_theme(theme: Theme) -> ValidationResult:
	"""Comprehensive validation of Material 3 theme accessibility"""
	var result = ValidationResult.new()
	
	# Validate color contrasts
	_validate_color_contrasts(theme, result)
	
	# Validate text sizes
	_validate_text_sizes(theme, result)
	
	# Validate interactive elements
	_validate_interactive_elements(theme, result)
	
	# Validate focus indicators
	_validate_focus_indicators(theme, result)
	
	# Validate animations
	_validate_animations(theme, result)
	
	return result

## Validate Material 3 color palette for accessibility
static func validate_m3_colors() -> ValidationResult:
	"""Validate the base Material 3 color tokens"""
	var result = ValidationResult.new()
	var colors = M3Tokens.M3_COLORS
	
	# Check primary color contrasts
	var primary_contrast = calculate_contrast(colors["on_primary"], colors["primary"])
	if primary_contrast < WCAG_AAA_CONTRAST_NORMAL:
		result.add_issue(
			"Primary color contrast too low: %.2f (required: %.1f)" % [primary_contrast, WCAG_AAA_CONTRAST_NORMAL]
		)
	
	# Check surface color contrasts
	var surface_contrast = calculate_contrast(colors["on_surface"], colors["surface"])
	if surface_contrast < WCAG_AAA_CONTRAST_NORMAL:
		result.add_issue(
			"Surface color contrast too low: %.2f (required: %.1f)" % [surface_contrast, WCAG_AAA_CONTRAST_NORMAL]
		)
	
	# Check error state contrasts
	var error_contrast = calculate_contrast(colors["on_error"], colors["error"])
	if error_contrast < WCAG_AAA_CONTRAST_NORMAL:
		result.add_issue(
			"Error color contrast too low: %.2f (required: %.1f)" % [error_contrast, WCAG_AAA_CONTRAST_NORMAL]
		)
	
	# Add suggestions for improvements
	if not result.is_compliant:
		result.suggestions.append("Consider using M3 high contrast variant for better accessibility")
		result.suggestions.append("Adjust color luminance values to meet WCAG AAA standards")
	
	return result

# === COLOR CONTRAST VALIDATION ===

static func _validate_color_contrasts(theme: Theme, result: ValidationResult) -> void:
	"""Validate all color contrasts in theme"""
	
	# Text on backgrounds
	var text_bg_pairs = [
		["font_color", "Label", "background", "Control"],
		["font_color", "Button", "normal", "Button"],
		["font_selected_color", "Tree", "selection_color", "Tree"]
	]
	
	for pair in text_bg_pairs:
		var fg_color = theme.get_color(pair[0], pair[1])
		var bg_color: Color
		
		if pair[2] == "normal":
			var stylebox = theme.get_stylebox(pair[2], pair[3])
			if stylebox is StyleBoxFlat:
				bg_color = stylebox.bg_color
		else:
			bg_color = theme.get_color(pair[2], pair[3])
		
		if fg_color and bg_color:
			var contrast = calculate_contrast(fg_color, bg_color)
			if contrast < WCAG_AAA_CONTRAST_NORMAL:
				result.add_issue(
					"%s on %s contrast too low: %.2f" % [pair[0], pair[2], contrast]
				)

static func calculate_contrast(fg: Color, bg: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var l1 = _get_relative_luminance(fg)
	var l2 = _get_relative_luminance(bg)
	
	var lighter = max(l1, l2)
	var darker = min(l1, l2)
	
	return (lighter + 0.05) / (darker + 0.05)

static func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance per WCAG formula"""
	var r = _linearize_color_component(color.r)
	var g = _linearize_color_component(color.g)
	var b = _linearize_color_component(color.b)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

static func _linearize_color_component(value: float) -> float:
	"""Linearize color component for luminance calculation"""
	if value <= 0.03928:
		return value / 12.92
	else:
		return pow((value + 0.055) / 1.055, 2.4)

# === TEXT SIZE VALIDATION ===

static func _validate_text_sizes(theme: Theme, result: ValidationResult) -> void:
	"""Validate text sizes meet minimum requirements"""
	
	var min_text_size = 12  # Absolute minimum for body text
	var recommended_min = 14  # Recommended minimum
	
	# Check common text sizes
	var text_types = ["Label", "Button", "LineEdit", "RichTextLabel"]
	
	for text_type in text_types:
		if theme.has_font_size("font_size", text_type):
			var size = theme.get_font_size("font_size", text_type)
			if size < min_text_size:
				result.add_issue(
					"%s font size too small: %d px (minimum: %d px)" % [text_type, size, min_text_size]
				)
			elif size < recommended_min:
				result.warnings.append(
					"%s font size below recommended: %d px (recommended: %d px)" % [text_type, size, recommended_min]
				)

# === INTERACTIVE ELEMENT VALIDATION ===

static func _validate_interactive_elements(theme: Theme, result: ValidationResult) -> void:
	"""Validate interactive elements meet accessibility standards"""
	
	var min_touch_target = M3Tokens.M3_ACCESSIBILITY["touch_target_size"]
	
	# Check button sizes
	var button_style = theme.get_stylebox("normal", "Button")
	if button_style is StyleBoxFlat:
		var total_height = button_style.content_margin_top + button_style.content_margin_bottom
		
		# Assume minimum font size + padding
		var estimated_height = theme.get_font_size("font_size", "Button") + total_height
		
		if estimated_height < min_touch_target:
			result.warnings.append(
				"Button touch target may be too small. Ensure minimum %d px height" % min_touch_target
			)

# === FOCUS INDICATOR VALIDATION ===

static func _validate_focus_indicators(theme: Theme, result: ValidationResult) -> void:
	"""Validate focus indicators are visible and meet standards"""
	
	var min_focus_width = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	
	# Check focus styles for common controls
	var focus_controls = ["Button", "LineEdit", "TextEdit", "ItemList"]
	
	for control in focus_controls:
		if theme.has_stylebox("focus", control):
			var focus_style = theme.get_stylebox("focus", control)
			if focus_style is StyleBoxFlat:
				var border_width = max(
					focus_style.border_width_left,
					focus_style.border_width_top,
					focus_style.border_width_right,
					focus_style.border_width_bottom
				)
				
				if border_width < min_focus_width:
					result.add_issue(
						"%s focus indicator too thin: %d px (minimum: %d px)" % [control, border_width, min_focus_width]
					)
				
				# Check focus color contrast
				var focus_color = focus_style.border_color
				var bg_color = focus_style.bg_color
				var contrast = calculate_contrast(focus_color, bg_color)
				
				if contrast < 3.0:  # WCAG minimum for UI components
					result.warnings.append(
						"%s focus indicator contrast too low: %.2f" % [control, contrast]
					)

# === ANIMATION VALIDATION ===

static func _validate_animations(theme: Theme, result: ValidationResult) -> void:
	"""Validate animations respect prefers-reduced-motion"""
	
	# Check if theme has animation metadata
	if theme.has_meta("enable_micro_animations"):
		result.suggestions.append(
			"Ensure animations respect user's prefers-reduced-motion setting"
		)
	
	# Check transition durations
	if theme.has_constant("transition_duration_long", "Effects"):
		var long_duration = theme.get_constant("transition_duration_long", "Effects")
		if long_duration > 1000:  # 1 second
			result.warnings.append(
				"Long animations may be disorienting. Consider shorter durations or disable option"
			)

# === UTILITY METHODS ===

## Suggest color adjustments to meet WCAG AAA
static func suggest_accessible_color(original: Color, background: Color, target_contrast: float = WCAG_AAA_CONTRAST_NORMAL) -> Color:
	"""Suggest an adjusted color that meets contrast requirements"""
	
	var current_contrast = calculate_contrast(original, background)
	if current_contrast >= target_contrast:
		return original
	
	var adjusted = original
	var bg_luminance = _get_relative_luminance(background)
	
	# Determine if we need lighter or darker
	if bg_luminance > 0.5:  # Light background, need dark text
		# Darken the color
		while calculate_contrast(adjusted, background) < target_contrast and adjusted.v > 0.0:
			adjusted = adjusted.darkened(0.1)
	else:  # Dark background, need light text
		# Lighten the color
		while calculate_contrast(adjusted, background) < target_contrast and adjusted.v < 1.0:
			adjusted = adjusted.lightened(0.1)
	
	return adjusted

## Generate accessibility report for theme
static func generate_accessibility_report(theme: Theme) -> String:
	"""Generate human-readable accessibility report"""
	
	var validation = validate_theme(theme)
	var report = "=== Material 3 Accessibility Report ===\n\n"
	
	report += "Overall Compliance: %s\n\n" % ["PASSED" if validation.is_compliant else "FAILED"]
	
	if validation.issues.size() > 0:
		report += "CRITICAL ISSUES:\n"
		for issue in validation.issues:
			report += "- %s\n" % issue.description
		report += "\n"
	
	if validation.warnings.size() > 0:
		report += "WARNINGS:\n"
		for warning in validation.warnings:
			report += "- %s\n" % warning
		report += "\n"
	
	if validation.suggestions.size() > 0:
		report += "SUGGESTIONS:\n"
		for suggestion in validation.suggestions:
			report += "- %s\n" % suggestion
		report += "\n"
	
	report += "Validated against WCAG AAA standards\n"
	report += "Minimum contrast ratio: %.1f:1\n" % WCAG_AAA_CONTRAST_NORMAL
	report += "Minimum touch target: %d px\n" % M3Tokens.M3_ACCESSIBILITY["touch_target_size"]
	
	return report

## Check if color pair meets WCAG AAA
static func is_color_pair_accessible(foreground: Color, background: Color, is_large_text: bool = false) -> bool:
	"""Quick check if color pair meets WCAG AAA standards"""
	var required_contrast = WCAG_AAA_CONTRAST_LARGE if is_large_text else WCAG_AAA_CONTRAST_NORMAL
	return calculate_contrast(foreground, background) >= required_contrast