extends Node

## Global theme manager for NeuroVis
## Handles theme switching, transitions, and accessibility features

signal theme_changed(theme_name: String)
signal theme_transition_completed()

# === CONSTANTS ===
const THEMES = {
	"dark": "res://src/ui/themes/themes/DarkTheme.tres",
	"high_contrast": "res://src/ui/themes/themes/HighContrastTheme.tres", 
	"colorblind": "res://src/ui/themes/themes/ColorblindTheme.tres"
}

const DEFAULT_THEME = "dark"
const TRANSITION_DURATION = 0.3

# === PRIVATE VARIABLES ===
var _current_theme: String = DEFAULT_THEME
var _loaded_themes: Dictionary = {}
var _transition_tween: Tween = null

# === PUBLIC VARIABLES ===
var current_theme_resource: Theme = null
var theme_transition_duration: float = TRANSITION_DURATION

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize theme manager"""
	print("[UIThemeManager] Initializing theme system")
	_preload_themes()
	_load_saved_theme()
	
	# Connect to settings manager if available
	if SettingsManager:
		SettingsManager.setting_changed.connect(_on_setting_changed)

func set_theme(theme_name: String, animated: bool = true) -> void:
	"""Change the current theme"""
	if not theme_name in THEMES:
		push_error("[UIThemeManager] Unknown theme: " + theme_name)
		return
		
	if theme_name == _current_theme:
		return
		
	print("[UIThemeManager] Switching theme to: " + theme_name)
	
	var new_theme = _get_theme(theme_name)
	if not new_theme:
		push_error("[UIThemeManager] Failed to load theme: " + theme_name)
		return
	
	if animated and _current_theme != "":
		_animate_theme_transition(new_theme, theme_name)
	else:
		_apply_theme_immediate(new_theme, theme_name)

func get_current_theme() -> String:
	"""Get the name of the current theme"""
	return _current_theme

func get_available_themes() -> Array:
	"""Get list of available theme names"""
	return THEMES.keys()

func get_theme_display_name(theme_name: String) -> String:
	"""Get user-friendly display name for theme"""
	match theme_name:
		"dark":
			return "Dark Mode"
		"high_contrast":
			return "High Contrast"
		"colorblind":
			return "Colorblind Safe"
		_:
			return theme_name.capitalize()

func get_theme_description(theme_name: String) -> String:
	"""Get description of theme features"""
	match theme_name:
		"dark":
			return "Modern dark theme with glass morphism effects"
		"high_contrast":
			return "Enhanced contrast for better visibility"
		"colorblind":
			return "Optimized colors for colorblind users"
		_:
			return ""

func reload_current_theme() -> void:
	"""Force reload of current theme"""
	var theme_name = _current_theme
	_current_theme = ""
	set_theme(theme_name, false)

# === PRIVATE METHODS ===

func _preload_themes() -> void:
	"""Preload all theme resources"""
	for theme_name in THEMES:
		var theme_path = THEMES[theme_name]
		if ResourceLoader.exists(theme_path):
			_loaded_themes[theme_name] = load(theme_path)
			print("[UIThemeManager] Preloaded theme: " + theme_name)
		else:
			push_warning("[UIThemeManager] Theme file not found: " + theme_path)

func _load_saved_theme() -> void:
	"""Load the saved theme preference"""
	var saved_theme = DEFAULT_THEME
	
	if SettingsManager:
		saved_theme = SettingsManager.get_setting("ui_theme", DEFAULT_THEME)
	
	set_theme(saved_theme, false)

func _get_theme(theme_name: String) -> Theme:
	"""Get theme resource by name"""
	if theme_name in _loaded_themes:
		return _loaded_themes[theme_name]
		
	# Try to load if not preloaded
	if theme_name in THEMES:
		var theme_path = THEMES[theme_name]
		if ResourceLoader.exists(theme_path):
			var theme = load(theme_path)
			_loaded_themes[theme_name] = theme
			return theme
			
	return null

func _apply_theme_immediate(theme: Theme, theme_name: String) -> void:
	"""Apply theme immediately without animation"""
	current_theme_resource = theme
	_current_theme = theme_name
	
	# Apply to all UI nodes
	_apply_theme_to_tree(get_tree().root, theme)
	
	# Save preference
	if SettingsManager:
		SettingsManager.set_setting("ui_theme", theme_name)
	
	theme_changed.emit(theme_name)
	theme_transition_completed.emit()

func _animate_theme_transition(new_theme: Theme, theme_name: String) -> void:
	"""Animate theme transition with fade effect"""
	if _transition_tween and _transition_tween.is_running():
		_transition_tween.kill()
	
	_transition_tween = create_tween()
	
	# Create overlay for transition
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(overlay)
	
	# Fade to black
	_transition_tween.tween_property(overlay, "modulate:a", 1.0, theme_transition_duration * 0.5)
	_transition_tween.tween_callback(func():
		_apply_theme_immediate(new_theme, theme_name)
	)
	
	# Fade back
	_transition_tween.tween_property(overlay, "modulate:a", 0.0, theme_transition_duration * 0.5)
	_transition_tween.tween_callback(func():
		overlay.queue_free()
		theme_transition_completed.emit()
	)

func _apply_theme_to_tree(node: Node, theme: Theme) -> void:
	"""Recursively apply theme to all Control nodes"""
	if node is Control:
		node.theme = theme
		
	for child in node.get_children():
		_apply_theme_to_tree(child, theme)

func _on_setting_changed(setting_name: String, value: Variant) -> void:
	"""Handle settings changes"""
	if setting_name == "ui_theme" and value is String:
		set_theme(value)

# === ACCESSIBILITY HELPERS ===

func get_theme_accessibility_features(theme_name: String) -> Dictionary:
	"""Get accessibility features for a theme"""
	var features = {
		"high_contrast": false,
		"colorblind_safe": false,
		"large_text": false,
		"reduced_motion": false
	}
	
	match theme_name:
		"high_contrast":
			features.high_contrast = true
			features.large_text = true
		"colorblind":
			features.colorblind_safe = true
			
	return features

func is_current_theme_accessible() -> bool:
	"""Check if current theme has accessibility features"""
	var features = get_theme_accessibility_features(_current_theme)
	return features.high_contrast or features.colorblind_safe