## ThemeResourceGenerator.gd
## Generates Godot Theme resources (.tres) from M3DesignTokens
##
## This tool creates theme resource files programmatically using the centralized
## M3DesignTokens color system, ensuring consistency and maintainability across
## all themes in the NeuroVision educational platform.
##
## @tutorial: Theme Generation Guide
## @tutorial: M3 Design System Integration

@tool
class_name ThemeResourceGenerator
extends RefCounted

# === CONSTANTS ===

const THEME_OUTPUT_PATH = "res://src/ui/themes/themes/"
const BACKUP_PATH = "res://backups/themes/"

# Theme configurations
const THEME_CONFIGS = {
	"dark": {
		"name": "NeuroVision Dark Theme",
		"description": "Modern dark theme with vibrant accents",
		"base_scheme": "dark",
		"overrides": {
			"primary": Color(0, 0.8, 0.753, 1),  # Custom cyan
			"on_primary": Color.WHITE,
			"surface": Color(0.082, 0.102, 0.168, 1),  # Dark blue-gray
		}
	},
	"high_contrast": {
		"name": "NeuroVision High Contrast Theme",
		"description": "Maximum contrast for accessibility",
		"base_scheme": "high_contrast",
		"overrides": {
			"primary": Color.YELLOW,
			"on_primary": Color.BLACK,
			"surface": Color(0.1, 0.1, 0.1, 1),
			"on_surface": Color.WHITE,
			"outline": Color.WHITE
		}
	},
	"colorblind": {
		"name": "NeuroVision Colorblind Safe Theme",
		"description": "Optimized for color vision deficiencies",
		"base_scheme": "colorblind",
		"overrides": {
			"primary": Color(0.006, 0.451, 0.698, 1),  # Deep blue
			"error": Color(0.871, 0.561, 0.020, 1),  # Orange instead of red
		}
	}
}

# === PUBLIC METHODS ===

## Generate all theme resources
static func generate_all_themes() -> void:
	"""Generate all configured theme .tres files from M3DesignTokens"""
	print("[ThemeResourceGenerator] Starting theme generation...")
	
	# Create backup directory if needed
	_ensure_directory_exists(BACKUP_PATH)
	
	# Backup existing themes
	_backup_existing_themes()
	
	# Generate each theme
	for theme_key in THEME_CONFIGS:
		var config = THEME_CONFIGS[theme_key]
		var success = generate_theme(theme_key, config)
		if success:
			print("[ThemeResourceGenerator] Generated theme: " + theme_key)
		else:
			push_error("[ThemeResourceGenerator] Failed to generate theme: " + theme_key)
	
	print("[ThemeResourceGenerator] Theme generation complete!")

## Generate a single theme resource
static func generate_theme(theme_key: String, config: Dictionary) -> bool:
	"""Generate a single theme .tres file"""
	var theme = Theme.new()
	
	# Set theme metadata
	theme.set_meta("name", config.get("name", "Unnamed Theme"))
	theme.set_meta("description", config.get("description", ""))
	theme.set_meta("generated_from", "M3DesignTokens")
	theme.set_meta("generation_time", Time.get_datetime_string_from_system())
	
	# Get color scheme
	var colors = _get_color_scheme(config)
	
	# Generate theme components
	_generate_buttons(theme, colors)
	_generate_panels(theme, colors)
	_generate_labels(theme, colors)
	_generate_inputs(theme, colors)
	_generate_educational_components(theme, colors)
	_generate_brain_structure_colors(theme, colors, config.get("base_scheme", "dark"))
	
	# Save theme
	var file_path = THEME_OUTPUT_PATH + theme_key.capitalize() + "Theme.tres"
	var error = ResourceSaver.save(theme, file_path)
	
	return error == OK

## Update existing theme with M3 colors
static func update_theme_colors(theme_path: String) -> bool:
	"""Update an existing theme file with M3DesignTokens colors"""
	var theme = load(theme_path) as Theme
	if not theme:
		push_error("[ThemeResourceGenerator] Failed to load theme: " + theme_path)
		return false
	
	# Backup first
	_backup_theme_file(theme_path)
	
	# Parse existing colors and find mappings
	var color_mappings = {}
	var theme_items = _get_all_theme_items(theme)
	
	for item in theme_items:
		if item.type == "color":
			var current_color = theme.get_color(item.name, item.class_name)
			var mapping = M3ColorMigrator.find_closest_token(current_color)
			if mapping.confidence >= 0.7:
				color_mappings[item] = mapping
	
	# Apply mappings
	for item in color_mappings:
		var mapping = color_mappings[item]
		var new_color = M3DesignTokens.get_color(mapping.token_path)
		theme.set_color(item.name, item.class_name, new_color)
	
	# Update metadata
	theme.set_meta("last_updated", Time.get_datetime_string_from_system())
	theme.set_meta("color_source", "M3DesignTokens")
	
	# Save updated theme
	var error = ResourceSaver.save(theme, theme_path)
	return error == OK

## Generate theme from custom color palette
static func generate_custom_theme(name: String, primary_color: Color, scheme: String = "dark") -> Theme:
	"""Generate a theme with custom primary color"""
	var theme = Theme.new()
	
	# Generate tonal palette from primary
	var palette = M3DesignTokens.generate_tonal_palette(primary_color)
	
	# Create color scheme
	var colors = _get_base_color_scheme(scheme)
	colors["primary"] = primary_color
	colors["primary_container"] = palette["30"]
	colors["on_primary"] = _get_contrast_color(primary_color)
	colors["on_primary_container"] = palette["90"]
	
	# Set metadata
	theme.set_meta("name", name)
	theme.set_meta("custom_primary", primary_color)
	theme.set_meta("base_scheme", scheme)
	
	# Generate components
	_generate_buttons(theme, colors)
	_generate_panels(theme, colors)
	_generate_labels(theme, colors)
	_generate_inputs(theme, colors)
	
	return theme

# === PRIVATE METHODS ===

static func _get_color_scheme(config: Dictionary) -> Dictionary:
	"""Get color scheme for a theme configuration"""
	var base_scheme = config.get("base_scheme", "dark")
	var colors = _get_base_color_scheme(base_scheme)
	
	# Apply overrides
	var overrides = config.get("overrides", {})
	for key in overrides:
		colors[key] = overrides[key]
	
	return colors

static func _get_base_color_scheme(scheme: String) -> Dictionary:
	"""Get base color scheme from M3DesignTokens"""
	var colors = {}
	
	# Copy all M3 colors
	for token in M3DesignTokens.M3_COLORS:
		colors[token] = M3DesignTokens.M3_COLORS[token]
	
	# Adjust for scheme type
	match scheme:
		"light":
			# Invert surface colors for light theme
			colors["surface"] = Color(0.98, 0.98, 0.98)
			colors["on_surface"] = Color(0.1, 0.1, 0.1)
			colors["surface_variant"] = Color(0.9, 0.9, 0.9)
		"high_contrast":
			# Maximum contrast adjustments
			colors["surface"] = Color.BLACK
			colors["on_surface"] = Color.WHITE
			colors["primary"] = Color.YELLOW
			colors["on_primary"] = Color.BLACK
	
	return colors

static func _generate_buttons(theme: Theme, colors: Dictionary) -> void:
	"""Generate button styles"""
	# Primary button
	var button_normal = _create_button_stylebox(colors["primary"], colors)
	var button_hover = _create_button_stylebox(colors["primary"], colors, "hover")
	var button_pressed = _create_button_stylebox(colors["primary"], colors, "pressed")
	var button_disabled = _create_button_stylebox(colors["on_surface"], colors, "disabled")
	
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("disabled", "Button", button_disabled)
	
	# Button colors
	theme.set_color("font_color", "Button", colors["on_primary"])
	theme.set_color("font_hover_color", "Button", colors["on_primary"])
	theme.set_color("font_pressed_color", "Button", colors["on_primary"])
	theme.set_color("font_disabled_color", "Button", _with_opacity(colors["on_surface"], 0.38))
	
	# Font settings
	theme.set_font_size("font_size", "Button", M3DesignTokens.M3_TYPE_SCALE["label_large"]["size"])

static func _generate_panels(theme: Theme, colors: Dictionary) -> void:
	"""Generate panel styles"""
	# Base panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = colors["surface"]
	panel_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	panel_style.set_border_width_all(1)
	panel_style.border_color = colors["outline"]
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	# Card variant
	var card_style = panel_style.duplicate()
	card_style.bg_color = colors["surface_container"]
	card_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["large"])
	theme.set_stylebox("panel", "Card", card_style)

static func _generate_labels(theme: Theme, colors: Dictionary) -> void:
	"""Generate label styles"""
	theme.set_color("font_color", "Label", colors["on_surface"])
	theme.set_color("font_shadow_color", "Label", _with_opacity(colors["shadow"], 0.25))
	theme.set_font_size("font_size", "Label", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])

static func _generate_inputs(theme: Theme, colors: Dictionary) -> void:
	"""Generate input field styles"""
	var input_normal = StyleBoxFlat.new()
	input_normal.bg_color = colors["surface_variant"]
	input_normal.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
	input_normal.set_border_width_all(1)
	input_normal.border_color = colors["outline"]
	input_normal.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	
	var input_focus = input_normal.duplicate()
	input_focus.border_color = colors["primary"]
	input_focus.border_width_bottom = 2
	
	theme.set_stylebox("normal", "LineEdit", input_normal)
	theme.set_stylebox("focus", "LineEdit", input_focus)
	
	theme.set_color("font_color", "LineEdit", colors["on_surface"])
	theme.set_color("font_placeholder_color", "LineEdit", _with_opacity(colors["on_surface_variant"], 0.6))

static func _generate_educational_components(theme: Theme, colors: Dictionary) -> void:
	"""Generate educational-specific components"""
	# Info panel colors
	theme.set_color("structure_label_color", "StructureInfoPanel", colors["on_surface"])
	theme.set_color("clinical_note_color", "StructureInfoPanel", colors["tertiary"])
	theme.set_color("learning_objective_color", "StructureInfoPanel", colors["secondary"])
	
	# Quiz panel colors
	theme.set_color("correct_answer_color", "QuizPanel", colors["success"])
	theme.set_color("incorrect_answer_color", "QuizPanel", colors["error"])
	theme.set_color("quiz_progress_color", "QuizPanel", colors["primary"])

static func _generate_brain_structure_colors(theme: Theme, colors: Dictionary, base_scheme: String) -> void:
	"""Generate brain structure colors based on scheme"""
	var brain_colors = M3DesignTokens.BRAIN_STRUCTURE_COLORS
	
	# Adjust brain colors for different schemes
	if base_scheme == "high_contrast":
		# Use high contrast versions
		theme.set_color("hippocampus_color", "BrainStructures", Color.YELLOW)
		theme.set_color("amygdala_color", "BrainStructures", Color.MAGENTA)
		theme.set_color("cortex_color", "BrainStructures", Color.CYAN)
		theme.set_color("thalamus_color", "BrainStructures", Color.GREEN)
	elif base_scheme == "colorblind":
		# Use colorblind-safe palette
		theme.set_color("hippocampus_color", "BrainStructures", Color(0.006, 0.451, 0.698, 1))
		theme.set_color("amygdala_color", "BrainStructures", Color(0.871, 0.561, 0.020, 1))
		theme.set_color("cortex_color", "BrainStructures", Color(0.011, 0.620, 0.451, 1))
		theme.set_color("thalamus_color", "BrainStructures", Color(0.337, 0.706, 0.914, 1))
	else:
		# Use default M3 brain colors
		for structure in brain_colors:
			theme.set_color(structure + "_color", "BrainStructures", brain_colors[structure])

static func _create_button_stylebox(base_color: Color, colors: Dictionary, state: String = "normal") -> StyleBoxFlat:
	"""Create a button stylebox for a given state"""
	var style = StyleBoxFlat.new()
	
	match state:
		"hover":
			style.bg_color = _lighten_color(base_color, 0.08)
		"pressed":
			style.bg_color = _darken_color(base_color, 0.08)
		"disabled":
			style.bg_color = _with_opacity(base_color, 0.38)
		_:
			style.bg_color = base_color
	
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	
	# Add elevation shadow
	if state != "disabled":
		var shadow = M3DesignTokens.get_elevation_shadow(2 if state == "normal" else 4)
		style.shadow_size = int(shadow["blur"])
		style.shadow_color = shadow["color"]
		style.shadow_offset = shadow["offset"]
	
	return style

static func _backup_existing_themes() -> void:
	"""Backup existing theme files"""
	var dir = DirAccess.open(THEME_OUTPUT_PATH)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			_backup_theme_file(THEME_OUTPUT_PATH + file_name)
		file_name = dir.get_next()

static func _backup_theme_file(file_path: String) -> void:
	"""Backup a single theme file"""
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var file_name = file_path.get_file()
	var backup_name = file_name.get_basename() + "_" + timestamp + ".tres"
	var backup_path = BACKUP_PATH + backup_name
	
	DirAccess.copy_absolute(file_path, backup_path)

static func _ensure_directory_exists(path: String) -> void:
	"""Ensure a directory exists"""
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

static func _get_all_theme_items(theme: Theme) -> Array:
	"""Get all theme items from a theme"""
	var items = []
	
	# Get all theme types
	var types = theme.get_type_list()
	
	for type in types:
		# Colors
		var colors = theme.get_color_list(type)
		for color_name in colors:
			items.append({
				"type": "color",
				"class_name": type,
				"name": color_name
			})
		
		# Add other theme item types as needed...
	
	return items

static func _get_contrast_color(color: Color) -> Color:
	"""Get contrasting color (black or white) for given color"""
	# Calculate relative luminance
	var luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	return Color.BLACK if luminance > 0.5 else Color.WHITE

static func _with_opacity(color: Color, opacity: float) -> Color:
	"""Return color with specified opacity"""
	var new_color = color
	new_color.a = opacity
	return new_color

static func _lighten_color(color: Color, amount: float) -> Color:
	"""Lighten a color by amount (0-1)"""
	return color.lerp(Color.WHITE, amount)

static func _darken_color(color: Color, amount: float) -> Color:
	"""Darken a color by amount (0-1)"""
	return color.lerp(Color.BLACK, amount)