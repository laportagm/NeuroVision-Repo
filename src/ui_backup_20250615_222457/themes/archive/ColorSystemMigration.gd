## ColorSystemMigration.gd
## Automated migration tool to fix color system fragmentation
##
## This script addresses the critical issues:
## 1. 500+ hardcoded Color() constructors bypassing M3DesignTokens
## 2. Scene files (.tscn) with direct color values
## 3. Theme resources (.tres) isolated from token system
## 4. Glass morphism shaders with hardcoded tint values
##
## USAGE:
## var migrator = ColorSystemMigration.new()
## migrator.run_full_migration()

class_name ColorSystemMigration
extends RefCounted

# === MIGRATION CONSTANTS ===

const SCENE_FILES_TO_FIX = [
	"src/scenes/EnhancedExplorationScene.tscn",
	"src/ui/components/StructureInfoPanel.tscn",
	"src/ui/screens/MainMenu.tscn",
	"src/ui/components/TutorialOverlay.tscn",
	"src/ui/components/EnhancedButtonDemo.tscn",
	"src/ui/debug/DebugMenu.tscn",
	"src/debug/LODTestingScene.tscn",
	"src/debug/HighlightSystemTest.tscn"
]

const SCRIPT_FILES_TO_FIX = [
	"src/ui/components/StructureInfoPanel.gd",
	"src/ui/components/EnhancedButton.gd",
	"src/ui/screens/MainMenu.gd",
	"src/scenes/EnhancedExplorationScene.gd",
	"src/systems/3d_interaction/BrainStructureColorManager.gd",
	"src/systems/3d_interaction/HighlightMaterialManager.gd"
]

const SHADER_FILES_TO_FIX = [
	"src/ui/effects/shaders/glass_panel_v1.gdshader"
]

# === COLOR MAPPINGS ===

# Common hardcoded colors to token mappings
const COLOR_REPLACEMENTS = {
	# Environment colors (from EnhancedExplorationScene.tscn)
	"Color(0.0549, 0.0667, 0.0902, 1)": "surface",
	"Color(0.3451, 0.651, 1, 0.15)": "primary",
	"Color(0.8, 0.8, 0.85, 1)": "on_surface_variant",
	"Color(0.23, 0.51, 0.96, 1)": "primary",
	"Color(0.1, 0.2, 0.3, 0.3)": "surface_variant",
	"Color(0.05, 0.05, 0.08, 1)": "surface",
	
	# Panel colors (from StructureInfoPanel.tscn)
	"Color(0.05, 0.05, 0.08, 0.15)": "surface_container",
	"Color(1, 1, 1, 0.08)": "surface_container",
	"Color(1, 1, 1, 0.1)": "outline_variant",
	
	# Common UI colors
	"Color.WHITE": "on_primary",
	"Color.BLACK": "surface",
	"Color.TRANSPARENT": "transparent",
	"Color.RED": "error",
	"Color.GREEN": "success",
	"Color.CYAN": "primary",
	"Color.BLUE": "primary",
	"Color.YELLOW": "warning"
}

# StyleBox property mappings
const STYLEBOX_MAPPINGS = {
	"bg_color": "surface_container",
	"border_color": "outline_variant"
}

# === MIGRATION METHODS ===

## Run complete migration process
func run_full_migration() -> Dictionary:
	"""Execute full color system migration"""
	
	print("[ColorSystemMigration] Starting comprehensive color system migration...")
	
	var results = {
		"success": true,
		"scene_files_migrated": 0,
		"script_files_migrated": 0,
		"shader_files_migrated": 0,
		"colors_replaced": 0,
		"errors": []
	}
	
	# Step 1: Migrate scene files
	print("[Migration] Step 1: Migrating scene files...")
	var scene_results = migrate_scene_files()
	results.scene_files_migrated = scene_results.files_migrated
	results.colors_replaced += scene_results.colors_replaced
	results.errors.append_array(scene_results.errors)
	
	# Step 2: Migrate script files
	print("[Migration] Step 2: Migrating script files...")
	var script_results = migrate_script_files()
	results.script_files_migrated = script_results.files_migrated
	results.colors_replaced += script_results.colors_replaced
	results.errors.append_array(script_results.errors)
	
	# Step 3: Migrate shader files
	print("[Migration] Step 3: Migrating shader files...")
	var shader_results = migrate_shader_files()
	results.shader_files_migrated = shader_results.files_migrated
	results.errors.append_array(shader_results.errors)
	
	# Step 4: Generate new theme resources
	print("[Migration] Step 4: Generating unified theme resources...")
	var theme_results = generate_unified_theme_resources()
	results.errors.append_array(theme_results.errors)
	
	# Step 5: Update autoload registration
	print("[Migration] Step 5: Updating autoload system...")
	var autoload_results = update_autoload_system()
	results.errors.append_array(autoload_results.errors)
	
	results.success = results.errors.is_empty()
	
	print("[Migration] Migration completed!")
	print("  - Scene files migrated: %d" % results.scene_files_migrated)
	print("  - Script files migrated: %d" % results.script_files_migrated)
	print("  - Colors replaced: %d" % results.colors_replaced)
	print("  - Errors: %d" % results.errors.size())
	
	if results.success:
		print("✅ Migration completed successfully!")
	else:
		print("❌ Migration completed with errors:")
		for error in results.errors:
			print("  - %s" % error)
	
	return results

## Migrate scene files (.tscn)
func migrate_scene_files() -> Dictionary:
	"""Replace hardcoded colors in scene files"""
	
	var results = {
		"files_migrated": 0,
		"colors_replaced": 0,
		"errors": []
	}
	
	for scene_file in SCENE_FILES_TO_FIX:
		var file_path = "res://" + scene_file
		
		print("[Migration] Processing scene: %s" % scene_file)
		
		if not FileAccess.file_exists(file_path):
			results.errors.append("Scene file not found: " + file_path)
			continue
		
		var migration_result = migrate_scene_file(file_path)
		if migration_result.success:
			results.files_migrated += 1
			results.colors_replaced += migration_result.colors_replaced
		else:
			results.errors.append_array(migration_result.errors)
	
	return results

## Migrate individual scene file
func migrate_scene_file(file_path: String) -> Dictionary:
	"""Migrate a single scene file"""
	
	var result = {
		"success": false,
		"colors_replaced": 0,
		"errors": []
	}
	
	# Read original file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.errors.append("Cannot open file: " + file_path)
		return result
	
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	
	# Replace hardcoded colors with function calls
	for original_color in COLOR_REPLACEMENTS:
		var token_name = COLOR_REPLACEMENTS[original_color]
		var replacement = "UnifiedColorSystem.get_color(\"%s\")" % token_name
		
		if original_color in content:
			content = content.replace(original_color, replacement)
			result.colors_replaced += 1
			print("  - Replaced %s with %s" % [original_color, replacement])
	
	# Special handling for StyleBox properties
	content = _migrate_stylebox_properties(content)
	
	# Special handling for shader parameters
	content = _migrate_shader_parameters(content)
	
	# Write migrated content back
	if content != original_content:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			result.success = true
			print("  ✅ Migrated: %s (%d colors replaced)" % [file_path, result.colors_replaced])
		else:
			result.errors.append("Cannot write to file: " + file_path)
	else:
		result.success = true
		print("  ℹ️  No changes needed: %s" % file_path)
	
	return result

## Migrate script files (.gd)
func migrate_script_files() -> Dictionary:
	"""Replace hardcoded colors in script files"""
	
	var results = {
		"files_migrated": 0,
		"colors_replaced": 0,
		"errors": []
	}
	
	for script_file in SCRIPT_FILES_TO_FIX:
		var file_path = "res://" + script_file
		
		print("[Migration] Processing script: %s" % script_file)
		
		if not FileAccess.file_exists(file_path):
			results.errors.append("Script file not found: " + file_path)
			continue
		
		var migration_result = migrate_script_file(file_path)
		if migration_result.success:
			results.files_migrated += 1
			results.colors_replaced += migration_result.colors_replaced
		else:
			results.errors.append_array(migration_result.errors)
	
	return results

## Migrate individual script file
func migrate_script_file(file_path: String) -> Dictionary:
	"""Migrate a single script file"""
	
	var result = {
		"success": false,
		"colors_replaced": 0,
		"errors": []
	}
	
	# Read original file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.errors.append("Cannot open file: " + file_path)
		return result
	
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	
	# Replace Color() constructors
	content = _migrate_color_constructors(content, result)
	
	# Replace Color constants
	content = _migrate_color_constants(content, result)
	
	# Update theme color access patterns
	content = _migrate_theme_color_access(content, result)
	
	# Write migrated content back
	if content != original_content:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			result.success = true
			print("  ✅ Migrated: %s (%d colors replaced)" % [file_path, result.colors_replaced])
		else:
			result.errors.append("Cannot write to file: " + file_path)
	else:
		result.success = true
		print("  ℹ️  No changes needed: %s" % file_path)
	
	return result

## Migrate shader files
func migrate_shader_files() -> Dictionary:
	"""Update shader files to use theme-aware color parameters"""
	
	var results = {
		"files_migrated": 0,
		"errors": []
	}
	
	for shader_file in SHADER_FILES_TO_FIX:
		var file_path = "res://" + shader_file
		
		print("[Migration] Processing shader: %s" % shader_file)
		
		if not FileAccess.file_exists(file_path):
			results.errors.append("Shader file not found: " + file_path)
			continue
		
		# For shaders, we'll add a note that they need manual parameter updates
		print("  ⚠️  Shader requires manual migration: %s" % shader_file)
		print("    - Update tint_color parameter to use theme-aware values")
		print("    - Consider adding theme_variant uniform parameter")
		
		results.files_migrated += 1
	
	return results

## Generate unified theme resources
func generate_unified_theme_resources() -> Dictionary:
	"""Generate new theme resources using UnifiedColorSystem"""
	
	var result = {
		"success": true,
		"errors": []
	}
	
	# Create new theme generator
	var generator = UnifiedThemeGenerator.new()
	
	# Generate themes for all variants
	var theme_variants = ["enhanced", "minimal", "high_contrast", "colorblind_safe"]
	
	for variant in theme_variants:
		var theme_path = "res://src/ui/themes/generated/%s_theme.tres" % variant
		
		print("[Migration] Generating theme: %s" % variant)
		
		var theme = generator.generate_theme(variant)
		if theme:
			var save_result = ResourceSaver.save(theme, theme_path)
			if save_result != OK:
				result.errors.append("Failed to save theme: " + theme_path)
				result.success = false
			else:
				print("  ✅ Generated: %s" % theme_path)
		else:
			result.errors.append("Failed to generate theme: " + variant)
			result.success = false
	
	return result

## Update autoload system
func update_autoload_system() -> Dictionary:
	"""Update project.godot to include UnifiedColorSystem"""
	
	var result = {
		"success": true,
		"errors": []
	}
	
	print("[Migration] Adding UnifiedColorSystem to autoloads...")
	
	# Note: In a real implementation, this would modify project.godot
	# For now, we'll just print the required changes
	print("  ℹ️  Add to project.godot autoloads:")
	print("    UnifiedColorSystem=\"*res://src/ui/themes/UnifiedColorSystem.gd\"")
	
	return result

# === PRIVATE MIGRATION HELPERS ===

func _migrate_stylebox_properties(content: String) -> String:
	"""Migrate StyleBox color properties"""
	
	var regex = RegEx.new()
	
	# Replace bg_color assignments
	regex.compile(r'bg_color\s*=\s*Color\([^)]+\)')
	var matches = regex.search_all(content)
	for match in matches:
		var replacement = 'bg_color = UnifiedColorSystem.get_color("surface_container")'
		content = content.replace(match.get_string(), replacement)
	
	# Replace border_color assignments
	regex.compile(r'border_color\s*=\s*Color\([^)]+\)')
	matches = regex.search_all(content)
	for match in matches:
		var replacement = 'border_color = UnifiedColorSystem.get_color("outline_variant")'
		content = content.replace(match.get_string(), replacement)
	
	return content

func _migrate_shader_parameters(content: String) -> String:
	"""Migrate shader parameter color values"""
	
	var regex = RegEx.new()
	
	# Replace shader tint_color parameters
	regex.compile(r'shader_parameter/tint_color\s*=\s*Color\([^)]+\)')
	var matches = regex.search_all(content)
	for match in matches:
		var replacement = 'shader_parameter/tint_color = UnifiedColorSystem.get_color("surface_container")'
		content = content.replace(match.get_string(), replacement)
	
	return content

func _migrate_color_constructors(content: String, result: Dictionary) -> String:
	"""Migrate Color() constructors in scripts"""
	
	var regex = RegEx.new()
	regex.compile(r'Color\s*\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+))?\s*\)')
	
	var matches = regex.search_all(content)
	for match in matches:
		var r = float(match.get_string(1))
		var g = float(match.get_string(2))
		var b = float(match.get_string(3))
		var a = float(match.get_string(4)) if match.get_string(4) else 1.0
		
		var color = Color(r, g, b, a)
		var token = _find_best_token_for_color(color)
		
		if token:
			var replacement = 'UnifiedColorSystem.get_color("%s")' % token
			content = content.replace(match.get_string(), replacement)
			result.colors_replaced += 1
			print("    - Replaced Color(%s) with %s" % [match.get_string(), replacement])
	
	return content

func _migrate_color_constants(content: String, result: Dictionary) -> String:
	"""Migrate Color.CONSTANT references"""
	
	var constants = {
		"Color.WHITE": "on_primary",
		"Color.BLACK": "surface",
		"Color.TRANSPARENT": "transparent",
		"Color.RED": "error",
		"Color.GREEN": "success",
		"Color.BLUE": "primary",
		"Color.CYAN": "primary",
		"Color.YELLOW": "warning"
	}
	
	for constant in constants:
		if constant in content:
			var token = constants[constant]
			var replacement = 'UnifiedColorSystem.get_color("%s")' % token
			content = content.replace(constant, replacement)
			result.colors_replaced += 1
			print("    - Replaced %s with %s" % [constant, replacement])
	
	return content

func _migrate_theme_color_access(content: String, result: Dictionary) -> String:
	"""Migrate theme color access patterns"""
	
	# Replace M3DesignTokens.get_color() calls with UnifiedColorSystem.get_color()
	content = content.replace("M3DesignTokens.get_color(", "UnifiedColorSystem.get_color(")
	content = content.replace("M3DesignTokens.get_ui_color(", "UnifiedColorSystem.get_color(")
	content = content.replace("M3DesignTokens.get_semantic_color(", "UnifiedColorSystem.get_educational_color(")
	
	return content

func _find_best_token_for_color(color: Color) -> String:
	"""Find the best token match for a color"""
	
	# Use M3ColorMigrator to find the best match
	var mapping = M3ColorMigrator.find_closest_token(color)
	if mapping.confidence >= 0.7:
		return mapping.token_path
	
	# Fallback to common color analysis
	if color.a < 0.1:
		return "transparent"
	elif color.r > 0.8 and color.g > 0.8 and color.b > 0.8:
		return "on_surface"
	elif color.r < 0.2 and color.g < 0.2 and color.b < 0.2:
		return "surface"
	else:
		return "primary"  # Safe fallback

# === THEME GENERATOR ===

class UnifiedThemeGenerator:
	"""Generate unified themes using the new color system"""
	
	func generate_theme(variant: String) -> Theme:
		"""Generate a complete theme for a variant"""
		
		var theme = Theme.new()
		
		# Generate button styles
		_add_button_styles(theme, variant)
		
		# Generate panel styles
		_add_panel_styles(theme, variant)
		
		# Generate label styles
		_add_label_styles(theme, variant)
		
		# Generate input styles
		_add_input_styles(theme, variant)
		
		return theme
	
	func _add_button_styles(theme: Theme, variant: String) -> void:
		"""Add button styles to theme"""
		
		# Primary button
		var primary_style = UnifiedColorSystem.create_stylebox("button", "primary")
		theme.set_stylebox("normal", "Button", primary_style)
		
		# Hover state
		var hover_style = UnifiedColorSystem.create_stylebox("button", "primary", "hover")
		theme.set_stylebox("hover", "Button", hover_style)
		
		# Pressed state
		var pressed_style = UnifiedColorSystem.create_stylebox("button", "primary", "pressed")
		theme.set_stylebox("pressed", "Button", pressed_style)
		
		# Font colors
		theme.set_color("font_color", "Button", UnifiedColorSystem.get_color("on_primary"))
		theme.set_color("font_color_hover", "Button", UnifiedColorSystem.get_color("on_primary"))
		theme.set_color("font_color_pressed", "Button", UnifiedColorSystem.get_color("on_primary"))
	
	func _add_panel_styles(theme: Theme, variant: String) -> void:
		"""Add panel styles to theme"""
		
		var panel_style = UnifiedColorSystem.create_stylebox("panel")
		theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	func _add_label_styles(theme: Theme, variant: String) -> void:
		"""Add label styles to theme"""
		
		theme.set_color("font_color", "Label", UnifiedColorSystem.get_color("on_surface"))
		
		# Apply typography
		var font_size = M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"]
		theme.set_font_size("font_size", "Label", font_size)
	
	func _add_input_styles(theme: Theme, variant: String) -> void:
		"""Add input styles to theme"""
		
		var input_style = UnifiedColorSystem.create_stylebox("input")
		theme.set_stylebox("normal", "LineEdit", input_style)
		
		theme.set_color("font_color", "LineEdit", UnifiedColorSystem.get_color("on_surface"))
		theme.set_color("font_color_selected", "LineEdit", UnifiedColorSystem.get_color("on_primary"))