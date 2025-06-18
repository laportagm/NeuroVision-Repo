## M3ColorMigrator.gd
## Utility class for migrating hardcoded colors to M3DesignTokens references
##
## This class provides tools to analyze, map, and migrate color definitions
## from various sources (hardcoded, .tres files) to the centralized M3DesignTokens
## system, ensuring consistency and maintainability.
##
## @tutorial: Color Migration Guide
## @tutorial: M3 Design System Integration

class_name M3ColorMigrator
extends RefCounted

# === COLOR ANALYSIS STRUCTURES ===

## Represents a color found in the codebase
class ColorInstance:
	var color: Color
	var source_file: String
	var line_number: int
	var context: String  # Code snippet around the color
	var suggested_token: String = ""  # Suggested M3 token replacement
	
	func _init(p_color: Color, p_file: String, p_line: int, p_context: String = ""):
		color = p_color
		source_file = p_file
		line_number = p_line
		context = p_context

## Color mapping entry for migration
class ColorMapping:
	var original_color: Color
	var token_path: String  # e.g., "primary", "surface", "error"
	var theme_variant: String = ""  # e.g., "dark", "light", "colorblind"
	var confidence: float = 0.0  # 0.0 to 1.0
	
	func _init(p_color: Color, p_token: String, p_confidence: float = 1.0):
		original_color = p_color
		token_path = p_token
		confidence = p_confidence

# === CONSTANTS ===

const COLOR_TOLERANCE: float = 0.05  # Tolerance for color matching
const MIN_CONFIDENCE: float = 0.7  # Minimum confidence for auto-migration

# Pre-built mappings for common colors
const COMMON_COLOR_MAPPINGS = {
	Color.WHITE: "on_primary",
	Color.BLACK: "shadow",  # Better match for pure black
	Color.TRANSPARENT: "transparent",
	Color.RED: "error",
	Color.GREEN: "success",
	Color.CYAN: "primary",
}

# === PUBLIC METHODS ===

## Analyze a file for hardcoded colors
static func analyze_file(file_path: String) -> Array[ColorInstance]:
	"""Scan a file for hardcoded color definitions"""
	var instances: Array[ColorInstance] = []
	
	if not FileAccess.file_exists(file_path):
		push_error("[M3ColorMigrator] File not found: " + file_path)
		return instances
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[M3ColorMigrator] Cannot open file: " + file_path)
		return instances
	
	var line_number = 0
	while not file.eof_reached():
		line_number += 1
		var line = file.get_line()
		
		# Check for Color() constructor
		var color_matches = _find_color_constructors(line)
		for color_data in color_matches:
			var instance = ColorInstance.new(
				color_data.color,
				file_path,
				line_number,
				line.strip_edges()
			)
			instance.suggested_token = _suggest_token_for_color(color_data.color)
			instances.append(instance)
		
		# Check for Color. constants
		var constant_matches = _find_color_constants(line)
		for color_data in constant_matches:
			var instance = ColorInstance.new(
				color_data.color,
				file_path,
				line_number,
				line.strip_edges()
			)
			instance.suggested_token = _suggest_token_for_color(color_data.color)
			instances.append(instance)
	
	file.close()
	return instances

## Map a color to its closest M3 token
static func find_closest_token(color: Color, theme_name: String = "default") -> ColorMapping:
	"""Find the best matching M3 token for a given color"""
	var best_match = ColorMapping.new(color, "", 0.0)
	var m3_colors = M3DesignTokens.M3_COLORS
	
	# First check exact matches
	for token_name in m3_colors:
		if _colors_match(color, m3_colors[token_name], 0.001):
			return ColorMapping.new(color, token_name, 1.0)
	
	# Then check common mappings
	for common_color in COMMON_COLOR_MAPPINGS:
		if _colors_match(color, common_color, COLOR_TOLERANCE):
			return ColorMapping.new(color, COMMON_COLOR_MAPPINGS[common_color], 0.9)
	
	# Finally, find closest match
	var min_distance = INF
	for token_name in m3_colors:
		var distance = _color_distance(color, m3_colors[token_name])
		if distance < min_distance:
			min_distance = distance
			best_match.token_path = token_name
			best_match.confidence = 1.0 - min(distance, 1.0)
	
	# Check brain structure colors if confidence is low
	if best_match.confidence < MIN_CONFIDENCE:
		var brain_colors = M3DesignTokens.BRAIN_STRUCTURE_COLORS
		for structure_name in brain_colors:
			var distance = _color_distance(color, brain_colors[structure_name])
			if distance < min_distance:
				min_distance = distance
				best_match.token_path = "brain_" + structure_name
				best_match.confidence = 1.0 - min(distance, 1.0)
	
	return best_match

## Generate migration code for a color instance
static func generate_migration_code(instance: ColorInstance) -> String:
	"""Generate the replacement code for a color instance"""
	var token = instance.suggested_token
	if token.is_empty():
		var mapping = find_closest_token(instance.color)
		token = mapping.token_path
	
	# Handle brain structure colors
	if token.begins_with("brain_"):
		var structure = token.substr(6)  # Remove "brain_" prefix
		return "M3DesignTokens.BRAIN_STRUCTURE_COLORS[\"%s\"]" % structure
	
	# Handle regular M3 colors
	return "M3DesignTokens.M3_COLORS[\"%s\"]" % token

## Migrate colors in a control node
static func migrate_control_colors(control: Control, dry_run: bool = true) -> Dictionary:
	"""Migrate all color overrides in a control to use M3 tokens"""
	var changes = {
		"theme_overrides": [],
		"modulate": null,
		"self_modulate": null
	}
	
	# Check modulate colors
	if control.modulate != Color.WHITE:
		var mapping = find_closest_token(control.modulate)
		if mapping.confidence >= MIN_CONFIDENCE:
			changes.modulate = mapping
			if not dry_run:
				control.modulate = M3DesignTokens.M3_COLORS[mapping.token_path]
	
	# Check theme overrides
	var overrides = _get_color_overrides(control)
	for override_name in overrides:
		var color = control.get_theme_color(override_name)
		var mapping = find_closest_token(color)
		if mapping.confidence >= MIN_CONFIDENCE:
			changes.theme_overrides.append({
				"name": override_name,
				"original": color,
				"mapping": mapping
			})
			if not dry_run:
				control.add_theme_color_override(
					override_name,
					M3DesignTokens.M3_COLORS[mapping.token_path]
				)
	
	return changes

## Parse .tres file colors
static func parse_tres_colors(file_path: String) -> Dictionary:
	"""Extract all color definitions from a .tres theme file"""
	var colors = {}
	
	if not FileAccess.file_exists(file_path):
		push_error("[M3ColorMigrator] File not found: " + file_path)
		return colors
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[M3ColorMigrator] Cannot open file: " + file_path)
		return colors
	
	var current_section = ""
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# Track sections
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			continue
		
		# Find color definitions
		if "Color(" in line:
			var parts = line.split("=", true, 1)
			if parts.size() >= 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				# Parse the color
				var color = _parse_color_string(value)
				if color != null:
					var full_key = current_section + "/" + key if current_section else key
					colors[full_key] = color
	
	file.close()
	return colors

## Generate a migration report
static func generate_migration_report(files: Array[String]) -> String:
	"""Generate a comprehensive migration report for given files"""
	var report = "# Color Migration Report\n\n"
	report += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	
	var total_colors = 0
	var migratable_colors = 0
	var file_reports = []
	
	for file_path in files:
		var instances = analyze_file(file_path)
		if instances.is_empty():
			continue
		
		var file_report = "## %s\n" % file_path
		file_report += "Found %d color instances\n\n" % instances.size()
		
		for instance in instances:
			total_colors += 1
			var mapping = find_closest_token(instance.color)
			
			file_report += "- Line %d: `%s`\n" % [instance.line_number, instance.context]
			file_report += "  - Color: %s\n" % str(instance.color)
			file_report += "  - Suggested: `%s` (confidence: %.1f%%)\n" % [
				generate_migration_code(instance),
				mapping.confidence * 100
			]
			
			if mapping.confidence >= MIN_CONFIDENCE:
				migratable_colors += 1
			else:
				file_report += "  - ⚠️ Low confidence - manual review required\n"
			
			file_report += "\n"
		
		file_reports.append(file_report)
	
	# Summary
	report += "## Summary\n\n"
	report += "- Total colors found: %d\n" % total_colors
	report += "- Auto-migratable: %d (%.1f%%)\n" % [
		migratable_colors,
		(migratable_colors / float(total_colors) * 100) if total_colors > 0 else 0
	]
	report += "- Manual review needed: %d\n\n" % (total_colors - migratable_colors)
	
	# File reports
	for file_report in file_reports:
		report += file_report + "\n"
	
	return report

# === PRIVATE METHODS ===

static func _find_color_constructors(line: String) -> Array:
	"""Find Color() constructor calls in a line of code"""
	var matches = []
	var regex = RegEx.new()
	regex.compile(r"Color\s*\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+))?\s*\)")
	
	for result in regex.search_all(line):
		var r = float(result.get_string(1))
		var g = float(result.get_string(2))
		var b = float(result.get_string(3))
		var a = float(result.get_string(4)) if result.get_string(4) else 1.0
		
		matches.append({
			"color": Color(r, g, b, a),
			"match": result.get_string()
		})
	
	return matches

static func _find_color_constants(line: String) -> Array:
	"""Find Color.CONSTANT references in a line of code"""
	var matches = []
	var constants = {
		"BLACK": Color.BLACK,
		"WHITE": Color.WHITE,
		"TRANSPARENT": Color.TRANSPARENT,
		"RED": Color.RED,
		"GREEN": Color.GREEN,
		"BLUE": Color.BLUE,
		"CYAN": Color.CYAN,
		"MAGENTA": Color.MAGENTA,
		"YELLOW": Color.YELLOW,
		"GRAY": Color.GRAY,
	}
	
	for const_name in constants:
		if "Color." + const_name in line:
			matches.append({
				"color": constants[const_name],
				"match": "Color." + const_name
			})
	
	return matches

static func _colors_match(c1: Color, c2: Color, tolerance: float) -> bool:
	"""Check if two colors match within tolerance"""
	return abs(c1.r - c2.r) <= tolerance and \
		   abs(c1.g - c2.g) <= tolerance and \
		   abs(c1.b - c2.b) <= tolerance and \
		   abs(c1.a - c2.a) <= tolerance

static func _color_distance(c1: Color, c2: Color) -> float:
	"""Calculate Euclidean distance between two colors"""
	var dr = c1.r - c2.r
	var dg = c1.g - c2.g
	var db = c1.b - c2.b
	var da = c1.a - c2.a
	return sqrt(dr*dr + dg*dg + db*db + da*da)

static func _suggest_token_for_color(color: Color) -> String:
	"""Suggest the most appropriate token for a color"""
	var mapping = find_closest_token(color)
	return mapping.token_path if mapping.confidence >= MIN_CONFIDENCE else ""

static func _parse_color_string(color_str: String) -> Color:
	"""Parse a color from a string like 'Color(1, 0, 0, 1)'"""
	color_str = color_str.strip_edges()
	if not color_str.begins_with("Color("):
		return Color()
	
	# Extract values between parentheses
	var start = color_str.find("(") + 1
	var end = color_str.rfind(")")
	if start < 0 or end < 0:
		return Color()
	
	var values_str = color_str.substr(start, end - start)
	var values = values_str.split(",")
	
	if values.size() < 3:
		return Color()
	
	var r = float(values[0].strip_edges())
	var g = float(values[1].strip_edges())
	var b = float(values[2].strip_edges())
	var a = float(values[3].strip_edges()) if values.size() > 3 else 1.0
	
	return Color(r, g, b, a)

static func _get_color_overrides(control: Control) -> Array[String]:
	"""Get all color theme overrides on a control"""
	var overrides = []
	
	# Common color override properties
	var possible_overrides = [
		"font_color",
		"font_color_hover",
		"font_color_pressed",
		"font_color_disabled",
		"font_color_focus",
		"font_shadow_color",
		"font_outline_color",
		"bg_color",
		"border_color",
		"selection_color",
		"clear_button_color",
		"caret_color"
	]
	
	for override_name in possible_overrides:
		if control.has_theme_color_override(override_name):
			overrides.append(override_name)
	
	return overrides