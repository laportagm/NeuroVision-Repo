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

func apply_theme(theme: Theme, theme_name: String = "custom") -> void:
	"""Apply a Theme resource directly (used for dynamically generated themes)"""
	if not theme:
		push_error("[UIThemeManager] Cannot apply null theme")
		return
	
	print("[UIThemeManager] Applying custom theme: " + theme_name)
	
	# Store the custom theme in our loaded themes cache
	_loaded_themes[theme_name] = theme
	
	# Apply the theme directly without validation since it's a custom theme
	current_theme_resource = theme
	_current_theme = theme_name
	
	# Apply to all UI nodes
	_apply_theme_to_tree(get_tree().root, theme)
	
	# Don't save custom themes to settings
	theme_changed.emit(theme_name)
	theme_transition_completed.emit()

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

# === ENHANCED THEME MANAGEMENT ===

## Apply enhanced styling to all UI elements immediately
func apply_enhanced_styling_immediately() -> void:
	"""Apply modern visual enhancements to all UI elements"""
	print("[UIThemeManager] Applying enhanced styling immediately")
	
	# Create enhanced style for panels
	var enhanced_panel_style = StyleBoxFlat.new()
	enhanced_panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	enhanced_panel_style.set_corner_radius_all(12)
	enhanced_panel_style.shadow_color = Color(0, 0, 0, 0.3)
	enhanced_panel_style.shadow_size = 8
	enhanced_panel_style.shadow_offset = Vector2(0, 4)
	enhanced_panel_style.border_color = Color(0.3, 0.3, 0.35, 0.5)
	enhanced_panel_style.border_width_left = 1
	enhanced_panel_style.border_width_top = 1
	enhanced_panel_style.border_width_right = 1
	enhanced_panel_style.border_width_bottom = 1
	
	# Create enhanced button styles
	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	button_normal.set_corner_radius_all(8)
	button_normal.shadow_color = Color(0, 0, 0, 0.2)
	button_normal.shadow_size = 4
	button_normal.shadow_offset = Vector2(0, 2)
	
	var button_hover = button_normal.duplicate()
	button_hover.bg_color = Color(0.3, 0.3, 0.35, 0.95)
	button_hover.shadow_size = 6
	button_hover.border_color = Color.CYAN
	button_hover.border_width_left = 2
	button_hover.border_width_top = 2
	button_hover.border_width_right = 2
	button_hover.border_width_bottom = 2
	
	var button_pressed = button_normal.duplicate()
	button_pressed.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	button_pressed.shadow_size = 2
	button_pressed.shadow_offset = Vector2(0, 1)
	
	# Create or update current theme
	if not current_theme_resource:
		current_theme_resource = Theme.new()
	
	# Apply panel styles
	current_theme_resource.set_stylebox("panel", "PanelContainer", enhanced_panel_style)
	current_theme_resource.set_stylebox("panel", "Panel", enhanced_panel_style)
	
	# Apply button styles
	current_theme_resource.set_stylebox("normal", "Button", button_normal)
	current_theme_resource.set_stylebox("hover", "Button", button_hover)
	current_theme_resource.set_stylebox("pressed", "Button", button_pressed)
	
	# Apply enhanced colors
	current_theme_resource.set_color("font_color", "Button", Color.WHITE)
	current_theme_resource.set_color("font_hover_color", "Button", Color.CYAN)
	current_theme_resource.set_color("font_pressed_color", "Button", Color(0.8, 0.8, 0.9))
	
	# Apply to all UI nodes immediately
	_apply_theme_to_tree(get_tree().root, current_theme_resource)
	
	# Apply glass morphism effect to panels if ThemeEffectsManager is available
	var effects_manager = get_node_or_null("/root/ThemeEffectsManager")
	if not effects_manager:
		# Skip creating ThemeEffectsManager dynamically to avoid shader warnings
		# It should be added as an autoload in project.godot if glass effects are desired
		print("[UIThemeManager] ThemeEffectsManager not found - glass effects disabled")
	
	if effects_manager:
		# Apply glass morphism to all panels
		_apply_glass_morphism_to_panels(get_tree().root, effects_manager)
	
	print("[UIThemeManager] Enhanced styling applied successfully")

## Apply glass morphism effect to all panel containers
func _apply_glass_morphism_to_panels(node: Node, effects_manager: Node) -> void:
	"""Recursively apply glass morphism to panel containers"""
	if node is PanelContainer or node is Panel:
		if effects_manager.has_method("apply_glass_morphism"):
			effects_manager.apply_glass_morphism(node, 0.5)
	
	for child in node.get_children():
		_apply_glass_morphism_to_panels(child, effects_manager)

## Preview a theme temporarily without applying globally
func preview_theme(theme: Theme, preview_duration: float = 5.0) -> void:
	"""Preview a theme temporarily before committing to change"""
	if not theme:
		push_error("[UIThemeManager] Cannot preview null theme")
		return
	
	print("[UIThemeManager] Previewing theme for " + str(preview_duration) + " seconds")
	
	# Store current theme for restoration
	var previous_theme = current_theme_resource
	var previous_name = _current_theme
	
	# Apply preview theme without saving
	current_theme_resource = theme
	_apply_theme_to_tree(get_tree().root, theme)
	
	# Create timer for automatic restoration
	var timer = Timer.new()
	timer.wait_time = preview_duration
	timer.one_shot = true
	timer.timeout.connect(func():
		print("[UIThemeManager] Preview ended, restoring previous theme")
		current_theme_resource = previous_theme
		_current_theme = previous_name
		_apply_theme_to_tree(get_tree().root, previous_theme)
		timer.queue_free()
	)
	
	add_child(timer)
	timer.start()

## Save user theme preferences
func save_user_theme_preferences(preferences: Dictionary) -> void:
	"""Save comprehensive theme preferences"""
	if not SettingsManager:
		push_warning("[UIThemeManager] SettingsManager not available")
		return
	
	# Save individual preferences
	for key in preferences:
		SettingsManager.set_setting("theme_" + key, preferences[key])
	
	# Save timestamp
	SettingsManager.set_setting("theme_preferences_updated", Time.get_unix_time_from_system())
	
	print("[UIThemeManager] Saved theme preferences: " + str(preferences.keys()))

## Create custom theme variant based on modifications
func create_custom_theme_variant(base_theme: String, modifications: Dictionary) -> Theme:
	"""Create a custom variant of a base theme with modifications"""
	
	# Get base theme
	var base = _get_theme(base_theme)
	if not base:
		push_error("[UIThemeManager] Base theme not found: " + base_theme)
		return null
	
	# Duplicate base theme
	var custom_theme = base.duplicate(true)
	
	# Apply modifications
	for mod_type in modifications:
		var mod_data = modifications[mod_type]
		
		match mod_type:
			"colors":
				_apply_color_modifications(custom_theme, mod_data)
			"fonts":
				_apply_font_modifications(custom_theme, mod_data)
			"styleboxes":
				_apply_stylebox_modifications(custom_theme, mod_data)
			"constants":
				_apply_constant_modifications(custom_theme, mod_data)
	
	# Add metadata
	custom_theme.set_meta("base_theme", base_theme)
	custom_theme.set_meta("modifications", modifications)
	custom_theme.set_meta("created_at", Time.get_unix_time_from_system())
	
	return custom_theme

## Monitor theme performance impact
func monitor_theme_performance() -> Dictionary:
	"""Monitor performance impact of current theme"""
	var performance_data = {
		"fps": Engine.get_frames_per_second(),
		"render_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"video_mem": OS.get_static_memory_usage() / 1024.0 / 1024.0,
		"theme_complexity": _calculate_theme_complexity(current_theme_resource),
		"active_effects": _count_active_effects()
	}
	
	# Check if theme is impacting performance
	if performance_data.fps < 30:
		push_warning("[UIThemeManager] Low FPS detected: " + str(performance_data.fps))
		performance_data["performance_warning"] = true
	
	return performance_data

## Reset to default theme
func reset_to_default_theme() -> void:
	"""Reset theme to default settings"""
	print("[UIThemeManager] Resetting to default theme")
	
	# Clear any custom themes from cache
	for theme_name in _loaded_themes:
		if not theme_name in THEMES:
			_loaded_themes.erase(theme_name)
	
	# Reset to default
	set_theme(DEFAULT_THEME, true)
	
	# Clear saved preferences
	if SettingsManager:
		SettingsManager.set_setting("ui_theme", DEFAULT_THEME)
		SettingsManager.set_setting("theme_preferences_updated", 0)

# === ENHANCED TRANSITION SYSTEM ===

func _animate_theme_transition(new_theme: Theme, theme_name: String) -> void:
	"""Enhanced theme transition with shader effects"""
	if _transition_tween and _transition_tween.is_running():
		_transition_tween.kill()
	
	# Check if we have ThemeEffectsManager available
	var effects_manager = get_node_or_null("/root/ThemeEffectsManager")
	if effects_manager and effects_manager.has_method("animate_theme_transition"):
		# Use advanced transition if available
		effects_manager.animate_theme_transition(current_theme_resource, new_theme, theme_transition_duration)
		
		# Apply theme after effect starts
		get_tree().create_timer(theme_transition_duration * 0.5).timeout.connect(func():
			_apply_theme_immediate(new_theme, theme_name)
		)
	else:
		# Fallback to simple transition
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

# === PRIVATE HELPER METHODS ===

func _apply_color_modifications(theme: Theme, color_mods: Dictionary) -> void:
	"""Apply color modifications to theme"""
	for node_type in color_mods:
		var type_mods = color_mods[node_type]
		for color_name in type_mods:
			var color_value = type_mods[color_name]
			if color_value is Color:
				theme.set_color(color_name, node_type, color_value)
			elif color_value is String:
				# Handle hex color strings
				theme.set_color(color_name, node_type, Color(color_value))

func _apply_font_modifications(theme: Theme, font_mods: Dictionary) -> void:
	"""Apply font modifications to theme"""
	for node_type in font_mods:
		var type_mods = font_mods[node_type]
		for font_name in type_mods:
			var font_data = type_mods[font_name]
			if font_data is Font:
				theme.set_font(font_name, node_type, font_data)

func _apply_stylebox_modifications(theme: Theme, stylebox_mods: Dictionary) -> void:
	"""Apply stylebox modifications to theme"""
	for node_type in stylebox_mods:
		var type_mods = stylebox_mods[node_type]
		for stylebox_name in type_mods:
			var stylebox_data = type_mods[stylebox_name]
			if stylebox_data is StyleBox:
				theme.set_stylebox(stylebox_name, node_type, stylebox_data)

func _apply_constant_modifications(theme: Theme, constant_mods: Dictionary) -> void:
	"""Apply constant modifications to theme"""
	for node_type in constant_mods:
		var type_mods = constant_mods[node_type]
		for constant_name in type_mods:
			var constant_value = type_mods[constant_name]
			if constant_value is int:
				theme.set_constant(constant_name, node_type, constant_value)

func _calculate_theme_complexity(theme: Theme) -> int:
	"""Calculate complexity score for theme"""
	if not theme:
		return 0
	
	var complexity = 0
	
	# Count styleboxes with effects
	var types = ["Button", "Panel", "LineEdit", "Label"]
	var stylebox_names = ["normal", "hover", "pressed", "focus", "disabled"]
	
	for type in types:
		for stylebox_name in stylebox_names:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat:
					if stylebox.shadow_size > 0:
						complexity += 2
					if stylebox.border_width_left > 0:
						complexity += 1
					if stylebox.bg_color.a < 1.0:
						complexity += 1
	
	return complexity

func _count_active_effects() -> int:
	"""Count active visual effects"""
	var count = 0
	
	# Check for active transitions
	if _transition_tween and _transition_tween.is_running():
		count += 1
	
	# Check ThemeEffectsManager if available
	var effects_manager = get_node_or_null("/root/ThemeEffectsManager")
	if effects_manager and effects_manager.has_method("get_active_effects_count"):
		var effects_data = effects_manager.get_active_effects_count()
		count += effects_data.get("total", 0)
	
	return count
