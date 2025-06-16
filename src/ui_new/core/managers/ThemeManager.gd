## ThemeManager.gd
## Unified theme management system for NeuroVision
##
## This manager consolidates all theme functionality including:
## - Dynamic theme generation and switching
## - Theme preset management
## - Material 3 design system integration
## - Accessibility validation
## - Theme persistence and preferences
## - Real-time theme editing (debug mode)

class_name ThemeManager
extends Node

# === SIGNALS ===
signal theme_changed(theme: Theme)
signal theme_variant_changed(variant: String)
signal theme_preset_changed(preset_name: String)
signal theme_validation_completed(is_valid: bool, issues: Array)
signal theme_animation_started()
signal theme_animation_completed()

# === CONSTANTS ===
const DEFAULT_THEME := "dark"
const THEME_TRANSITION_DURATION := 0.3
const THEME_CACHE_SIZE := 5
const THEME_SAVE_PATH := "user://theme_preferences.save"

# === ENUMS ===
enum ThemeMode {
	SYSTEM,     # Follow system preference
	LIGHT,      # Force light theme
	DARK,       # Force dark theme
	CUSTOM      # User-defined theme
}

enum ThemeVariant {
	DEFAULT,
	HIGH_CONTRAST,
	COLORBLIND_SAFE,
	REDUCED_MOTION,
	CUSTOM
}

# === PRIVATE VARIABLES ===
# Current theme state
var _current_theme: Theme
var _current_theme_name: String = DEFAULT_THEME
var _current_mode: ThemeMode = ThemeMode.DARK
var _current_variant: ThemeVariant = ThemeVariant.DEFAULT
var _current_preset: Dictionary = {}

# Theme resources
var _registered_themes: Dictionary = {}  # theme_name: Theme or generator
var _theme_cache: Dictionary = {}  # cache_key: Theme
var _theme_generators: Dictionary = {}  # name: generator_callable
var _theme_presets: Dictionary = {}  # preset_name: preset_config

# Theme components (migrated from existing system)
var _design_tokens: Resource  # M3DesignTokens
var _color_system: Resource   # UnifiedColorSystem
var _accessibility_validator: Resource  # M3AccessibilityValidator

# Animation
var _transition_tween: Tween
var _is_transitioning: bool = false

# Preferences
var _user_preferences: Dictionary = {
	"theme_mode": ThemeMode.DARK,
	"theme_name": DEFAULT_THEME,
	"theme_variant": ThemeVariant.DEFAULT,
	"custom_colors": {},
	"font_scale": 1.0,
	"animation_speed": 1.0,
	"reduce_motion": false,
	"high_contrast": false
}

# Debug
var _debug_panel: Control
var _enable_live_editing: bool = false

# === INITIALIZATION ===

func _init() -> void:
	name = "ThemeManager"

func _ready() -> void:
	_load_design_system()
	_register_default_themes()
	_load_user_preferences()
	_apply_initial_theme()
	print("[ThemeManager] Theme system initialized")

func _load_design_system() -> void:
	"""Load Material 3 design system components"""
	# Load design tokens
	var tokens_path = "res://src/ui/themes/core/M3DesignTokens.gd"
	if ResourceLoader.exists(tokens_path):
		_design_tokens = load(tokens_path).new()
	
	# Load color system
	var color_path = "res://src/ui/themes/core/UnifiedColorSystem.gd"
	if ResourceLoader.exists(color_path):
		_color_system = load(color_path)
	
	# Load accessibility validator
	var validator_path = "res://src/ui/themes/validation/M3AccessibilityValidator.gd"
	if ResourceLoader.exists(validator_path):
		_accessibility_validator = load(validator_path).new()

# === PUBLIC API ===

## Theme Registration

func register_theme(theme_name: String, theme: Theme) -> void:
	"""Register a static theme"""
	_registered_themes[theme_name] = theme
	print("[ThemeManager] Registered theme: %s" % theme_name)

func register_theme_generator(theme_name: String, generator: Callable) -> void:
	"""Register a dynamic theme generator"""
	_theme_generators[theme_name] = generator
	print("[ThemeManager] Registered theme generator: %s" % theme_name)

func register_theme_preset(preset_name: String, preset_config: Dictionary) -> void:
	"""Register a theme preset configuration"""
	_theme_presets[preset_name] = preset_config
	print("[ThemeManager] Registered theme preset: %s" % preset_name)

## Theme Switching

func set_theme(theme_name: String, animated: bool = true) -> void:
	"""Switch to a different theme"""
	if _is_transitioning:
		await theme_animation_completed
	
	if not _has_theme(theme_name):
		push_error("[ThemeManager] Unknown theme: %s" % theme_name)
		return
	
	var new_theme = _get_or_generate_theme(theme_name)
	if not new_theme:
		return
	
	if animated and _current_theme:
		await _animate_theme_transition(new_theme)
	else:
		_apply_theme_immediate(new_theme)
	
	_current_theme_name = theme_name
	_save_user_preferences()

func set_theme_mode(mode: ThemeMode) -> void:
	"""Set the theme mode (light/dark/system)"""
	_current_mode = mode
	_user_preferences.theme_mode = mode
	
	# Apply appropriate theme based on mode
	match mode:
		ThemeMode.LIGHT:
			set_theme("light")
		ThemeMode.DARK:
			set_theme("dark")
		ThemeMode.SYSTEM:
			_apply_system_theme()
		ThemeMode.CUSTOM:
			_apply_custom_theme()

func set_theme_variant(variant: ThemeVariant) -> void:
	"""Set theme variant (high contrast, colorblind, etc)"""
	_current_variant = variant
	_user_preferences.theme_variant = variant
	
	# Regenerate current theme with new variant
	_invalidate_theme_cache()
	set_theme(_current_theme_name)
	
	theme_variant_changed.emit(ThemeVariant.keys()[variant])

func apply_theme_preset(preset_name: String) -> void:
	"""Apply a predefined theme preset"""
	if not _theme_presets.has(preset_name):
		push_error("[ThemeManager] Unknown preset: %s" % preset_name)
		return
	
	var preset = _theme_presets[preset_name]
	_current_preset = preset
	
	# Apply preset configuration
	if preset.has("theme"):
		set_theme(preset.theme)
	if preset.has("variant"):
		set_theme_variant(preset.variant)
	if preset.has("font_scale"):
		set_font_scale(preset.font_scale)
	
	theme_preset_changed.emit(preset_name)

## Theme Properties

func get_current_theme() -> Theme:
	"""Get the currently active theme"""
	return _current_theme

func get_current_theme_name() -> String:
	"""Get the name of the current theme"""
	return _current_theme_name

func get_design_token(token_path: String) -> Variant:
	"""Get a design token value (e.g., 'colors.primary')"""
	if not _design_tokens:
		return null
	
	var parts = token_path.split(".")
	var value = _design_tokens
	
	for part in parts:
		if value is Dictionary and value.has(part):
			value = value[part]
		elif value is Object and value.has(part):
			value = value.get(part)
		else:
			return null
	
	return value

func get_theme_color(color_name: String) -> Color:
	"""Get a color from the current theme"""
	if _color_system and _color_system.has_method("get_color"):
		return _color_system.get_color(color_name)
	
	if _current_theme:
		return _current_theme.get_color(color_name, "")
	
	return Color.WHITE

func set_font_scale(scale: float) -> void:
	"""Set global font scale for accessibility"""
	_user_preferences.font_scale = clamp(scale, 0.75, 2.0)
	_regenerate_current_theme()

func set_animation_speed(speed: float) -> void:
	"""Set animation speed multiplier"""
	_user_preferences.animation_speed = clamp(speed, 0.0, 2.0)

## Theme Validation

func validate_theme_accessibility(theme: Theme = null) -> Dictionary:
	"""Validate theme for accessibility compliance"""
	if not theme:
		theme = _current_theme
	
	if not theme or not _accessibility_validator:
		return {"valid": false, "errors": ["No theme or validator available"]}
	
	var validation_result = _accessibility_validator.validate_theme(theme)
	theme_validation_completed.emit(
		validation_result.valid, 
		validation_result.get("issues", [])
	)
	
	return validation_result

func check_contrast_ratio(foreground: Color, background: Color) -> float:
	"""Check WCAG contrast ratio between two colors"""
	if _accessibility_validator and _accessibility_validator.has_method("calculate_contrast"):
		return _accessibility_validator.calculate_contrast(foreground, background)
	
	# Fallback calculation
	return _calculate_contrast_ratio(foreground, background)

## Theme Customization

func set_custom_color(color_key: String, color: Color) -> void:
	"""Set a custom color override"""
	if not _user_preferences.custom_colors is Dictionary:
		_user_preferences.custom_colors = {}
	
	_user_preferences.custom_colors[color_key] = color
	_regenerate_current_theme()

func reset_custom_colors() -> void:
	"""Reset all custom color overrides"""
	_user_preferences.custom_colors.clear()
	_regenerate_current_theme()

func export_theme(file_path: String) -> void:
	"""Export current theme configuration to file"""
	var config = {
		"name": _current_theme_name,
		"mode": _current_mode,
		"variant": _current_variant,
		"custom_colors": _user_preferences.custom_colors,
		"font_scale": _user_preferences.font_scale
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config, "\t"))
		file.close()

func import_theme(file_path: String) -> bool:
	"""Import theme configuration from file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return false
	
	var config = json.data
	if config.has("name"):
		set_theme(config.name)
	if config.has("custom_colors"):
		_user_preferences.custom_colors = config.custom_colors
	if config.has("font_scale"):
		set_font_scale(config.font_scale)
	
	_regenerate_current_theme()
	return true

# === PRIVATE METHODS ===

func _register_default_themes() -> void:
	"""Register built-in themes"""
	# Register static theme files
	var theme_files = {
		"dark": "res://src/ui/themes/resources/themes/DarkTheme.tres",
		"high_contrast": "res://src/ui/themes/resources/themes/HighContrastTheme.tres",
		"colorblind": "res://src/ui/themes/resources/themes/ColorblindTheme.tres"
	}
	
	for theme_name in theme_files:
		if ResourceLoader.exists(theme_files[theme_name]):
			register_theme(theme_name, load(theme_files[theme_name]))
	
	# Register Material 3 generator
	register_theme_generator("material3", _generate_material3_theme)
	
	# Register default presets
	_register_default_presets()

func _register_default_presets() -> void:
	"""Register default theme presets"""
	register_theme_preset("professional", {
		"theme": "dark",
		"variant": ThemeVariant.DEFAULT,
		"font_scale": 1.0
	})
	
	register_theme_preset("accessible", {
		"theme": "high_contrast",
		"variant": ThemeVariant.HIGH_CONTRAST,
		"font_scale": 1.2
	})
	
	register_theme_preset("presentation", {
		"theme": "material3",
		"variant": ThemeVariant.DEFAULT,
		"font_scale": 1.1
	})

func _has_theme(theme_name: String) -> bool:
	"""Check if a theme is available"""
	return _registered_themes.has(theme_name) or _theme_generators.has(theme_name)

func _get_or_generate_theme(theme_name: String) -> Theme:
	"""Get theme from cache or generate it"""
	var cache_key = _get_cache_key(theme_name)
	
	# Check cache
	if _theme_cache.has(cache_key):
		return _theme_cache[cache_key]
	
	# Get or generate theme
	var theme: Theme
	
	if _registered_themes.has(theme_name):
		theme = _registered_themes[theme_name]
	elif _theme_generators.has(theme_name):
		theme = _theme_generators[theme_name].call()
	else:
		return null
	
	# Apply variant modifications
	theme = _apply_variant_to_theme(theme)
	
	# Apply custom colors
	theme = _apply_custom_colors_to_theme(theme)
	
	# Apply font scale
	theme = _apply_font_scale_to_theme(theme)
	
	# Cache the result
	_cache_theme(cache_key, theme)
	
	return theme

func _generate_material3_theme() -> Theme:
	"""Generate Material 3 theme dynamically"""
	# This would integrate with existing Material3ThemeGenerator
	var generator_path = "res://src/ui/themes/generators/Material3ThemeGenerator.gd"
	if ResourceLoader.exists(generator_path):
		var generator = load(generator_path).new()
		return generator.generate_theme("default")
	
	# Fallback to default dark theme
	return _registered_themes.get("dark", Theme.new())

func _apply_variant_to_theme(theme: Theme) -> Theme:
	"""Apply variant modifications to theme"""
	match _current_variant:
		ThemeVariant.HIGH_CONTRAST:
			return _apply_high_contrast(theme)
		ThemeVariant.COLORBLIND_SAFE:
			return _apply_colorblind_safe(theme)
		ThemeVariant.REDUCED_MOTION:
			return _apply_reduced_motion(theme)
		_:
			return theme

func _apply_high_contrast(theme: Theme) -> Theme:
	"""Apply high contrast modifications"""
	# Would modify colors for higher contrast
	# This is a simplified example
	var modified = theme.duplicate()
	# Increase contrast logic here
	return modified

func _apply_colorblind_safe(theme: Theme) -> Theme:
	"""Apply colorblind-safe color modifications"""
	var modified = theme.duplicate()
	# Colorblind-safe palette logic here
	return modified

func _apply_reduced_motion(theme: Theme) -> Theme:
	"""Apply reduced motion settings"""
	var modified = theme.duplicate()
	# Disable or reduce animations
	return modified

func _apply_custom_colors_to_theme(theme: Theme) -> Theme:
	"""Apply user's custom color overrides"""
	if _user_preferences.custom_colors.is_empty():
		return theme
	
	var modified = theme.duplicate()
	for color_key in _user_preferences.custom_colors:
		# Apply custom color logic
		pass
	
	return modified

func _apply_font_scale_to_theme(theme: Theme) -> Theme:
	"""Apply font scaling to theme"""
	if abs(_user_preferences.font_scale - 1.0) < 0.01:
		return theme
	
	var modified = theme.duplicate()
	# Scale all font sizes
	return modified

func _apply_theme_immediate(theme: Theme) -> void:
	"""Apply theme without animation"""
	_current_theme = theme
	
	# Emit to all listeners
	theme_changed.emit(theme)
	
	# Apply to root if exists
	var root = get_tree().root
	if root:
		root.theme = theme

func _animate_theme_transition(new_theme: Theme) -> void:
	"""Animate theme transition"""
	if _transition_tween:
		_transition_tween.kill()
	
	_is_transitioning = true
	theme_animation_started.emit()
	
	# For now, just fade transition
	# In a full implementation, this could interpolate colors
	_transition_tween = create_tween()
	
	# Simple fade out/in
	var viewport = get_viewport()
	_transition_tween.tween_method(
		func(alpha): viewport.gui_disable_input = alpha < 0.5,
		1.0, 0.0, THEME_TRANSITION_DURATION / 2
	)
	_transition_tween.tween_callback(_apply_theme_immediate.bind(new_theme))
	_transition_tween.tween_method(
		func(alpha): viewport.gui_disable_input = false,
		0.0, 1.0, THEME_TRANSITION_DURATION / 2
	)
	
	await _transition_tween.finished
	
	_is_transitioning = false
	theme_animation_completed.emit()

func _regenerate_current_theme() -> void:
	"""Regenerate current theme with updated settings"""
	_invalidate_theme_cache()
	set_theme(_current_theme_name, false)

func _get_cache_key(theme_name: String) -> String:
	"""Generate cache key for current settings"""
	return "%s_%d_%d_%.2f" % [
		theme_name,
		_current_variant,
		_user_preferences.custom_colors.hash(),
		_user_preferences.font_scale
	]

func _cache_theme(key: String, theme: Theme) -> void:
	"""Cache generated theme"""
	_theme_cache[key] = theme
	
	# Limit cache size
	if _theme_cache.size() > THEME_CACHE_SIZE:
		var keys = _theme_cache.keys()
		_theme_cache.erase(keys[0])

func _invalidate_theme_cache() -> void:
	"""Clear theme cache"""
	_theme_cache.clear()

func _apply_system_theme() -> void:
	"""Apply theme based on system preference"""
	# This would detect system dark/light mode
	# For now, default to dark
	set_theme("dark")

func _apply_custom_theme() -> void:
	"""Apply user's fully custom theme"""
	# Would load user-created theme
	pass

func _calculate_contrast_ratio(fg: Color, bg: Color) -> float:
	"""Calculate WCAG contrast ratio"""
	var l1 = _get_relative_luminance(fg)
	var l2 = _get_relative_luminance(bg)
	
	var lighter = max(l1, l2)
	var darker = min(l1, l2)
	
	return (lighter + 0.05) / (darker + 0.05)

func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance of a color"""
	var r = _get_srgb_component(color.r)
	var g = _get_srgb_component(color.g)
	var b = _get_srgb_component(color.b)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _get_srgb_component(value: float) -> float:
	"""Convert sRGB component for luminance calculation"""
	if value <= 0.03928:
		return value / 12.92
	else:
		return pow((value + 0.055) / 1.055, 2.4)

func _load_user_preferences() -> void:
	"""Load saved theme preferences"""
	if FileAccess.file_exists(THEME_SAVE_PATH):
		var file = FileAccess.open(THEME_SAVE_PATH, FileAccess.READ)
		if file:
			var saved_prefs = file.get_var()
			if saved_prefs is Dictionary:
				_user_preferences.merge(saved_prefs, true)
			file.close()

func _save_user_preferences() -> void:
	"""Save theme preferences"""
	var file = FileAccess.open(THEME_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(_user_preferences)
		file.close()

func _apply_initial_theme() -> void:
	"""Apply theme on startup"""
	set_theme_mode(_user_preferences.theme_mode)

# === DEBUG METHODS ===

func enable_live_editing(enabled: bool) -> void:
	"""Enable/disable live theme editing"""
	_enable_live_editing = enabled
	
	if enabled and not _debug_panel:
		_create_debug_panel()
	elif not enabled and _debug_panel:
		_debug_panel.queue_free()
		_debug_panel = null

func _create_debug_panel() -> void:
	"""Create debug theme editing panel"""
	# Would create a debug UI for live theme editing
	pass

func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"current_theme": _current_theme_name,
		"theme_mode": ThemeMode.keys()[_current_mode],
		"theme_variant": ThemeVariant.keys()[_current_variant],
		"registered_themes": _registered_themes.keys(),
		"theme_generators": _theme_generators.keys(),
		"cache_size": _theme_cache.size(),
		"custom_colors": _user_preferences.custom_colors.size()
	}