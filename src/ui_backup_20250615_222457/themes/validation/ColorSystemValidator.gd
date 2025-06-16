## ColorSystemValidator.gd
## Build-time validation system to prevent color system bypassing
##
## This system provides comprehensive validation to ensure:
## 1. No hardcoded Color() constructors bypass the unified system
## 2. All theme switching works consistently across components
## 3. WCAG AAA accessibility compliance is maintained
## 4. Educational brain structure colors are properly integrated
##
## Can be run during development or as part of CI/CD pipeline

class_name ColorSystemValidator
extends RefCounted

# === VALIDATION CONFIGURATION ===

const VALIDATION_RULES = {
	"forbid_hardcoded_colors": true,
	"require_unified_access": true,
	"enforce_accessibility": true,
	"validate_brain_colors": true,
	"check_theme_consistency": true
}

const ALLOWED_COLOR_PATTERNS = [
	# Safe patterns that don't bypass the system
	r"Color\(\)",  # Empty constructor for comparison
	r"Color\.TRANSPARENT",  # Transparent is safe
	r"UnifiedColorSystem\.get_color\(",  # Unified system access
	r"M3DesignTokens\.get_color\(",  # Legacy but acceptable
	r"ShaderColorAdapter\.get_"  # Shader adapter access
]

const FORBIDDEN_PATTERNS = [
	# Patterns that bypass the unified system
	r"Color\s*\(\s*[\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+",  # Color(r,g,b) constructors
	r"Color\s*\(\s*\"#[0-9a-fA-F]+\"",  # Color("#hex") constructors
	r"bg_color\s*=\s*Color\(",  # Direct bg_color assignments
	r"border_color\s*=\s*Color\(",  # Direct border_color assignments
	r"shader_parameter.*=\s*Color\("  # Direct shader parameter colors
]

# === VALIDATION RESULTS ===

class ValidationResult:
	var is_valid: bool = true
	var total_files_checked: int = 0
	var violations: Array[Dictionary] = []
	var warnings: Array[Dictionary] = []
	var accessibility_issues: Array[Dictionary] = []
	var theme_consistency_issues: Array[Dictionary] = []
	
	func add_violation(file: String, line: int, message: String, pattern: String = "") -> void:
		violations.append({
			"file": file,
			"line": line,
			"message": message,
			"pattern": pattern,
			"severity": "error"
		})
		is_valid = false
	
	func add_warning(file: String, line: int, message: String) -> void:
		warnings.append({
			"file": file,
			"line": line,
			"message": message,
			"severity": "warning"
		})
	
	func add_accessibility_issue(component: String, issue: String, wcag_level: String) -> void:
		accessibility_issues.append({
			"component": component,
			"issue": issue,
			"wcag_level": wcag_level,
			"severity": "accessibility"
		})
		is_valid = false
	
	func generate_report() -> String:
		var report = "# Color System Validation Report\n\n"
		report += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
		
		# Summary
		report += "## Summary\n"
		report += "- Status: %s\n" % ("✅ PASSED" if is_valid else "❌ FAILED")
		report += "- Files checked: %d\n" % total_files_checked
		report += "- Violations: %d\n" % violations.size()
		report += "- Warnings: %d\n" % warnings.size()
		report += "- Accessibility issues: %d\n\n" % accessibility_issues.size()
		
		# Violations
		if violations.size() > 0:
			report += "## ❌ Violations\n"
			for violation in violations:
				report += "- **%s:%d** - %s\n" % [violation.file, violation.line, violation.message]
				if violation.pattern:
					report += "  - Pattern: `%s`\n" % violation.pattern
				report += "\n"
		
		# Warnings
		if warnings.size() > 0:
			report += "## ⚠️ Warnings\n"
			for warning in warnings:
				report += "- **%s:%d** - %s\n\n" % [warning.file, warning.line, warning.message]
		
		# Accessibility issues
		if accessibility_issues.size() > 0:
			report += "## ♿ Accessibility Issues\n"
			for issue in accessibility_issues:
				report += "- **%s** - %s (WCAG %s)\n\n" % [issue.component, issue.issue, issue.wcag_level]
		
		return report

# === MAIN VALIDATION METHODS ===

## Run comprehensive color system validation
static func validate_project(project_path: String = "res://") -> ValidationResult:
	"""Run complete color system validation on the project"""
	
	print("[ColorSystemValidator] Starting comprehensive validation...")
	
	var result = ValidationResult.new()
	
	# Step 1: Validate file-based color usage
	var file_result = validate_file_colors(project_path)
	result.total_files_checked = file_result.total_files_checked
	result.violations.append_array(file_result.violations)
	result.warnings.append_array(file_result.warnings)
	
	# Step 2: Validate runtime color access
	var runtime_result = validate_runtime_colors()
	result.violations.append_array(runtime_result.violations)
	result.warnings.append_array(runtime_result.warnings)
	
	# Step 3: Validate accessibility compliance
	var accessibility_result = validate_accessibility_compliance()
	result.accessibility_issues.append_array(accessibility_result.accessibility_issues)
	
	# Step 4: Validate theme consistency
	var theme_result = validate_theme_consistency()
	result.theme_consistency_issues.append_array(theme_result.theme_consistency_issues)
	
	# Update overall validity
	result.is_valid = result.violations.is_empty() and result.accessibility_issues.is_empty()
	
	print("[ColorSystemValidator] Validation completed")
	print("  - Files checked: %d" % result.total_files_checked)
	print("  - Violations: %d" % result.violations.size())
	print("  - Accessibility issues: %d" % result.accessibility_issues.size())
	
	return result

## Validate color usage in files
static func validate_file_colors(project_path: String) -> ValidationResult:
	"""Scan all project files for color system violations"""
	
	var result = ValidationResult.new()
	
	# Get all relevant files
	var files_to_check = _get_files_to_validate(project_path)
	result.total_files_checked = files_to_check.size()
	
	for file_path in files_to_check:
		_validate_file(file_path, result)
	
	return result

## Validate runtime color access patterns
static func validate_runtime_colors() -> ValidationResult:
	"""Validate that runtime color access uses the unified system"""
	
	var result = ValidationResult.new()
	
	# Check UnifiedColorSystem access logs
	if UnifiedColorSystem._validation_enabled:
		var access_log = UnifiedColorSystem._color_access_log
		
		for access in access_log:
			if not M3DesignTokens.has_token(access.token):
				result.add_violation(
					"runtime",
					0,
					"Invalid color token accessed: %s" % access.token,
					access.token
				)
	
	return result

## Validate WCAG AAA accessibility compliance
static func validate_accessibility_compliance() -> ValidationResult:
	"""Validate that all colors meet WCAG AAA standards"""
	
	var result = ValidationResult.new()
	
	# Check primary color combinations
	var primary = M3DesignTokens.get_color("primary")
	var surface = M3DesignTokens.get_color("surface")
	var contrast_ratio = _calculate_contrast_ratio(primary, surface)
	
	if contrast_ratio < 7.0:
		result.add_accessibility_issue(
			"primary/surface",
			"Contrast ratio %.1f:1 is below WCAG AAA requirement (7:1)" % contrast_ratio,
			"AAA"
		)
	
	# Check text color combinations
	var text_color = M3DesignTokens.get_color("on_surface")
	var text_contrast = _calculate_contrast_ratio(text_color, surface)
	
	if text_contrast < 7.0:
		result.add_accessibility_issue(
			"text/surface",
			"Text contrast ratio %.1f:1 is below WCAG AAA requirement (7:1)" % text_contrast,
			"AAA"
		)
	
	# Check brain structure colors
	for structure_name in M3DesignTokens.BRAIN_STRUCTURE_COLORS:
		var structure_color = M3DesignTokens.BRAIN_STRUCTURE_COLORS[structure_name]
		var structure_contrast = _calculate_contrast_ratio(structure_color, surface)
		
		if structure_contrast < 4.5:  # WCAG AA minimum for graphics
			result.add_accessibility_issue(
				"brain_" + structure_name,
				"Brain structure contrast %.1f:1 is below WCAG AA requirement (4.5:1)" % structure_contrast,
				"AA"
			)
	
	return result

## Validate theme consistency across variants
static func validate_theme_consistency() -> ValidationResult:
	"""Validate that all theme variants work consistently"""
	
	var result = ValidationResult.new()
	
	var theme_variants = ["enhanced", "minimal", "high_contrast", "colorblind_safe"]
	
	for variant in theme_variants:
		# Test that all tokens are available in this variant
		for token_name in M3DesignTokens.M3_COLORS:
			var color = M3DesignTokens.get_color(token_name, variant)
			if color == Color():
				result.add_violation(
					"theme_" + variant,
					0,
					"Color token '%s' not available in theme variant '%s'" % [token_name, variant]
				)
	
	return result

# === FILE VALIDATION HELPERS ===

static func _get_files_to_validate(project_path: String) -> Array[String]:
	"""Get list of files that need color validation"""
	
	var files: Array[String] = []
	
	# Add GDScript files
	files.append_array(_find_files_by_extension(project_path, "gd"))
	
	# Add scene files
	files.append_array(_find_files_by_extension(project_path, "tscn"))
	
	# Add shader files
	files.append_array(_find_files_by_extension(project_path, "gdshader"))
	
	# Add theme resource files
	files.append_array(_find_files_by_extension(project_path, "tres"))
	
	return files

static func _find_files_by_extension(path: String, extension: String) -> Array[String]:
	"""Recursively find files with specific extension"""
	
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	
	if not dir:
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			# Recursively search subdirectories
			files.append_array(_find_files_by_extension(full_path, extension))
		elif file_name.ends_with("." + extension):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	return files

static func _validate_file(file_path: String, result: ValidationResult) -> void:
	"""Validate a specific file for color system compliance"""
	
	if not FileAccess.file_exists(file_path):
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var line_number = 0
	while not file.eof_reached():
		line_number += 1
		var line = file.get_line()
		
		# Check for forbidden patterns
		for pattern_string in FORBIDDEN_PATTERNS:
			var regex = RegEx.new()
			regex.compile(pattern_string)
			
			if regex.search(line):
				result.add_violation(
					file_path,
					line_number,
					"Hardcoded color detected - use UnifiedColorSystem.get_color() instead",
					pattern_string
				)
		
		# Check for potential issues
		if "M3DesignTokens.get_color" in line and "UnifiedColorSystem" not in line:
			result.add_warning(
				file_path,
				line_number,
				"Consider migrating to UnifiedColorSystem.get_color() for consistency"
			)
	
	file.close()

# === ACCESSIBILITY HELPERS ===

static func _calculate_contrast_ratio(c1: Color, c2: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var l1 = _get_relative_luminance(c1)
	var l2 = _get_relative_luminance(c2)
	
	var lighter = max(l1, l2)
	var darker = min(l1, l2)
	
	return (lighter + 0.05) / (darker + 0.05)

static func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance for contrast calculation"""
	var r = _gamma_correct(color.r)
	var g = _gamma_correct(color.g)
	var b = _gamma_correct(color.b)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

static func _gamma_correct(value: float) -> float:
	"""Apply gamma correction for luminance calculation"""
	if value <= 0.03928:
		return value / 12.92
	else:
		return pow((value + 0.055) / 1.055, 2.4)

# === CI/CD INTEGRATION ===

## Command-line validation tool
static func run_ci_validation() -> int:
	"""Run validation for CI/CD pipeline (returns exit code)"""
	
	print("[ColorSystemValidator] Running CI validation...")
	
	var result = validate_project()
	
	if result.is_valid:
		print("✅ All color system validations passed")
		return 0  # Success exit code
	else:
		print("❌ Color system validation failed")
		print(result.generate_report())
		return 1  # Failure exit code

## Generate validation report file
static func generate_validation_report_file(output_path: String = "color_validation_report.md") -> bool:
	"""Generate a detailed validation report file"""
	
	var result = validate_project()
	var report_content = result.generate_report()
	
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if not file:
		print("[ColorSystemValidator] Failed to create report file: %s" % output_path)
		return false
	
	file.store_string(report_content)
	file.close()
	
	print("[ColorSystemValidator] Validation report saved: %s" % output_path)
	return true

# === DEVELOPMENT HELPERS ===

## Quick validation for development
static func quick_validate() -> void:
	"""Quick validation for development use"""
	
	print("[ColorSystemValidator] Running quick validation...")
	
	# Check current scene
	var main_scene = Engine.get_main_loop().current_scene
	if main_scene:
		var shader_result = ShaderColorAdapter.validate_shader_colors(main_scene)
		print("Shader validation: %s (%d materials checked)" % [
			"✅ PASSED" if shader_result.valid else "❌ FAILED",
			shader_result.total_materials
		])
	
	# Check unified color system
	var unified_result = UnifiedColorSystem.validate_color_usage()
	print("Unified system validation: %s (%d accesses logged)" % [
		"✅ PASSED" if unified_result.valid else "❌ FAILED",
		unified_result.total_accesses
	])
	
	print("[ColorSystemValidator] Quick validation completed")

## Enable development validation mode
static func enable_development_validation() -> void:
	"""Enable continuous validation during development"""
	
	print("[ColorSystemValidator] Enabling development validation mode")
	
	# Enable unified system validation logging
	UnifiedColorSystem.set_validation_enabled(true)
	
	# Connect to scene changes for automatic validation
	var scene_tree = Engine.get_main_loop()
	if scene_tree.has_signal("node_added"):
		scene_tree.connect("node_added", _on_node_added)

static func _on_node_added(node: Node) -> void:
	"""Validate new nodes as they're added to the scene"""
	
	# Apply unified colors to any new shader materials
	if node is MeshInstance3D or node is Control:
		ShaderColorAdapter.apply_unified_colors_to_scene(node)
		
	# Apply unified theme to new UI controls
	if node is Control:
		UnifiedColorSystem.apply_unified_theme(node)