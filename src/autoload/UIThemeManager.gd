extends Node

## Global theme manager for NeuroVis
## Handles theme switching, transitions, and accessibility features

signal theme_changed(theme_name: String)
signal theme_transition_completed()

# === CONSTANTS ===
const THEMES = {
	"dark": "res://src/ui/themes/themes/DarkTheme.tres",
	"high_contrast": "res://src/ui/themes/themes/HighContrastTheme.tres", 
	"colorblind": "res://src/ui/themes/themes/ColorblindTheme.tres",
	"material3": "dynamic",  # Generated dynamically
	"material3_high_contrast": "dynamic",  # Generated dynamically
	"material3_colorblind": "dynamic"  # Generated dynamically
}

const DEFAULT_THEME = "dark"
const TRANSITION_DURATION = 0.3

# Preload Material 3 generators
const Material3Generator = preload("res://src/ui/themes/Material3ThemeGenerator.gd")
const ContentAdaptiveGenerator = preload("res://src/ui/themes/ContentAdaptiveThemeGenerator.gd")

# === PRIVATE VARIABLES ===
var _current_theme: String = DEFAULT_THEME
var _loaded_themes: Dictionary = {}
var _transition_tween: Tween = null

# Performance-based shader management
var _glass_shader_full: Shader = null
var _glass_shader_lite: Shader = null
var _current_shader_quality: String = "medium"

# === PUBLIC VARIABLES ===
var current_theme_resource: Theme = null
var theme_transition_duration: float = TRANSITION_DURATION

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize theme manager"""
	print("[UIThemeManager] Initializing NeuroVision theme system")
	_preload_shaders()
	_preload_themes()
	_load_saved_theme()
	
	# Connect to ThemeEffectsManager for glass morphism integration
	if has_node("/root/ThemeEffectsManager"):
		_setup_effects_integration()
	
	# Connect to settings manager if available
	if SettingsManager:
		SettingsManager.setting_changed.connect(_on_setting_changed)
	
	# Connect to performance monitor for quality-based shader switching
	if PerformanceMonitor:
		PerformanceMonitor.quality_level_changed.connect(_on_quality_level_changed)

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
		"material3":
			return "Material 3"
		"material3_high_contrast":
			return "Material 3 (High Contrast)"
		"material3_colorblind":
			return "Material 3 (Colorblind Safe)"
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
		"material3":
			return "Google's Material You design system with adaptive colors"
		"material3_high_contrast":
			return "Material 3 with enhanced contrast for accessibility"
		"material3_colorblind":
			return "Material 3 optimized for color vision deficiencies"
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
		# Skip dynamic themes - they'll be generated on demand
		if theme_path == "dynamic":
			continue
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
	
	# Handle Material 3 dynamic theme generation
	if theme_name.begins_with("material3"):
		return _generate_material3_theme(theme_name)
		
	# Try to load if not preloaded
	if theme_name in THEMES:
		var theme_path = THEMES[theme_name]
		if theme_path != "dynamic" and ResourceLoader.exists(theme_path):
			var theme = load(theme_path)
			_loaded_themes[theme_name] = theme
			return theme
			
	return null

func _generate_material3_theme(theme_name: String) -> Theme:
	"""Generate Material 3 theme dynamically"""
	var m3_generator = Material3Generator.new()
	m3_generator.setup_dependencies()
	
	var variant = "default"
	match theme_name:
		"material3_high_contrast":
			variant = "high_contrast"
		"material3_colorblind":
			variant = "colorblind_safe"
	
	var theme = m3_generator.generate_material3_theme(variant)
	
	# Cache the generated theme
	_loaded_themes[theme_name] = theme
	
	# Add metadata for theme identification
	theme.set_meta("is_material3", true)
	theme.set_meta("m3_variant", variant)
	
	print("[UIThemeManager] Generated Material 3 theme: " + theme_name)
	return theme

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
	"""Recursively apply theme to all Control nodes while preserving scene-specific overrides"""
	if node is Control:
		# Only apply theme if the control doesn't have a scene-specific theme override
		# This preserves editor styling while applying runtime themes appropriately
		if not node.theme or node.theme == current_theme_resource:
			node.theme = theme
		else:
			# For controls with existing custom themes, merge with the global theme
			# by setting it as a fallback while preserving local overrides
			var existing_theme = node.theme
			if existing_theme != theme:
				# Create a composite theme that respects both global and local styling
				_apply_composite_theme(node, theme, existing_theme)
		
	for child in node.get_children():
		_apply_theme_to_tree(child, theme)

func _apply_composite_theme(control: Control, global_theme: Theme, local_theme: Theme) -> void:
	"""Apply a composite theme that preserves local overrides while using global fallbacks"""
	if not control or not global_theme:
		return
	
	# Create a merged theme that respects local customizations
	var composite_theme = local_theme.duplicate(true) if local_theme else Theme.new()
	
	# For each theme property type, use local override if it exists, otherwise use global
	var node_types = ["Button", "Panel", "PanelContainer", "Label", "LineEdit", "TextEdit", "OptionButton", "CheckBox", "SpinBox", "ProgressBar", "ScrollContainer", "Tree", "ItemList"]
	
	for node_type in node_types:
		# Merge styleboxes - preserve local overrides, add global as fallback
		_merge_theme_property(composite_theme, "stylebox", node_type, global_theme, local_theme)
		
		# Merge colors - preserve local overrides, add global as fallback  
		_merge_theme_property(composite_theme, "color", node_type, global_theme, local_theme)
		
		# Merge fonts - preserve local overrides, add global as fallback
		_merge_theme_property(composite_theme, "font", node_type, global_theme, local_theme)
		
		# Merge constants - preserve local overrides, add global as fallback
		_merge_theme_property(composite_theme, "constant", node_type, global_theme, local_theme)
	
	# Apply the composite theme to the control
	control.theme = composite_theme

func _merge_theme_property(target_theme: Theme, property_type: String, node_type: String, global_theme: Theme, local_theme: Theme) -> void:
	"""Merge a specific theme property type, preserving local overrides"""
	if not target_theme or not global_theme:
		return
	
	var property_list: Array = []
	
	# Get property names based on type
	match property_type:
		"stylebox":
			property_list = ["normal", "hover", "pressed", "focus", "disabled", "panel", "background", "fg", "bg"]
		"color":
			property_list = ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "background_color", "selection_color"]
		"font":
			property_list = ["font"]
		"constant":
			property_list = ["margin_left", "margin_right", "margin_top", "margin_bottom", "separation", "line_spacing"]
	
	# Apply global theme properties if not overridden locally
	for property_name in property_list:
		var has_local_override = local_theme and _theme_has_property(local_theme, property_type, property_name, node_type)
		var has_global_property = _theme_has_property(global_theme, property_type, property_name, node_type)
		
		# If there's no local override but global has the property, use global
		if not has_local_override and has_global_property:
			match property_type:
				"stylebox":
					target_theme.set_stylebox(property_name, node_type, global_theme.get_stylebox(property_name, node_type))
				"color":
					target_theme.set_color(property_name, node_type, global_theme.get_color(property_name, node_type))
				"font":
					target_theme.set_font(property_name, node_type, global_theme.get_font(property_name, node_type))
				"constant":
					target_theme.set_constant(property_name, node_type, global_theme.get_constant(property_name, node_type))

func _theme_has_property(theme: Theme, property_type: String, property_name: String, node_type: String) -> bool:
	"""Check if a theme has a specific property"""
	if not theme:
		return false
		
	match property_type:
		"stylebox":
			return theme.has_stylebox(property_name, node_type)
		"color":
			return theme.has_color(property_name, node_type)
		"font":
			return theme.has_font(property_name, node_type)
		"constant":
			return theme.has_constant(property_name, node_type)
	
	return false

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
		"reduced_motion": false,
		"wcag_aaa_compliant": false
	}
	
	match theme_name:
		"high_contrast":
			features.high_contrast = true
			features.large_text = true
		"colorblind":
			features.colorblind_safe = true
		"material3_high_contrast":
			features.high_contrast = true
			features.wcag_aaa_compliant = true
		"material3_colorblind":
			features.colorblind_safe = true
			features.wcag_aaa_compliant = true
		"material3":
			features.wcag_aaa_compliant = true
			
	return features

func is_current_theme_accessible() -> bool:
	"""Check if current theme has accessibility features"""
	var features = get_theme_accessibility_features(_current_theme)
	return features.high_contrast or features.colorblind_safe

# === MATERIAL 3 INTEGRATION ===

## Generate Material 3 theme for specific brain structure
func generate_m3_brain_region_theme(region_name: String, complexity_level: int = 1) -> void:
	"""Generate and apply Material 3 theme adapted for brain region"""
	var theme = ContentAdaptiveGenerator.generate_brain_region_theme(
		region_name, complexity_level, true
	)
	
	# Apply the generated theme
	apply_theme(theme, "material3_" + region_name.to_lower())
	
	print("[UIThemeManager] Applied Material 3 theme for region: " + region_name)

## Check if current theme is Material 3
func is_material3_active() -> bool:
	"""Check if current theme uses Material 3 design system"""
	return _current_theme.begins_with("material3")

## Get Material 3 adaptive color for structure
func get_m3_adaptive_color(structure_name: String) -> Color:
	"""Get Material 3 adaptive color for a brain structure"""
	if not is_material3_active():
		return Color.WHITE
		
	var m3_generator = Material3Generator.new()
	return m3_generator.generate_adaptive_color(structure_name)

## Apply Material 3 glass morphism to control
func apply_m3_glass_morphism(control: Control, intensity: float = 0.85) -> void:
	"""Apply Material 3 glass morphism effect to a control"""
	if not control:
		return
		
	var m3_generator = Material3Generator.new()
	var base_color = M3DesignTokens.M3_COLORS["surface"]
	base_color.a = intensity
	
	var glass_style = m3_generator.create_glass_morphism_style(base_color)
	
	# Apply to different control types
	if control is Panel or control is PanelContainer:
		control.add_theme_stylebox_override("panel", glass_style)
	elif control is Button:
		control.add_theme_stylebox_override("normal", glass_style)

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

# === PERFORMANCE-BASED SHADER MANAGEMENT ===

func apply_quality_based_shaders(quality_level: String) -> void:
	"""Apply appropriate shaders based on quality level from PerformanceMonitor"""
	print("[UIThemeManager] Applying quality-based shaders: " + quality_level)
	
	_current_shader_quality = quality_level
	
	# Determine which shader to use based on quality
	var target_shader: Shader = null
	match quality_level.to_lower():
		"low", "0":
			target_shader = _glass_shader_lite
			print("[UIThemeManager] Using LITE glass morphism shader for low-end hardware")
		"medium", "1":
			target_shader = _glass_shader_lite  # Use lite for medium as well for better compatibility
			print("[UIThemeManager] Using LITE glass morphism shader for medium quality")
		"high", "2", "ultra", "3":
			target_shader = _glass_shader_full
			print("[UIThemeManager] Using FULL glass morphism shader for high quality")
		_:
			target_shader = _glass_shader_lite  # Default to lite for unknown quality
			print("[UIThemeManager] Unknown quality level, defaulting to LITE shader")
	
	if not target_shader:
		push_warning("[UIThemeManager] Target shader not loaded, skipping shader update")
		return
	
	# Apply shader to all UI panels in the 'ui_panels' group
	_apply_shader_to_ui_panels(target_shader)
	
	# Update any shader materials that might be cached
	_update_cached_shader_materials(target_shader)

func get_current_shader_quality() -> String:
	"""Get the currently active shader quality level"""
	return _current_shader_quality

func force_shader_quality(quality_level: String) -> void:
	"""Force a specific shader quality level regardless of performance"""
	print("[UIThemeManager] Forcing shader quality to: " + quality_level)
	apply_quality_based_shaders(quality_level)
	
	# Save the forced setting
	if SettingsManager:
		SettingsManager.set_setting("forced_shader_quality", quality_level)

func is_lite_shader_active() -> bool:
	"""Check if the lite shader is currently active"""
	return _current_shader_quality in ["low", "medium", "0", "1"]

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

# === PERFORMANCE-BASED SHADER PRIVATE METHODS ===

func _preload_shaders() -> void:
	"""Preload both shader variants for performance switching"""
	print("[UIThemeManager] Preloading glass morphism shaders")
	
	# Load full quality shader
	var full_shader_path = "res://src/ui/effects/shaders/glass_morphism_ui.gdshader"
	if ResourceLoader.exists(full_shader_path):
		_glass_shader_full = load(full_shader_path)
		print("[UIThemeManager] Loaded full quality glass shader")
	else:
		push_warning("[UIThemeManager] Full quality glass shader not found: " + full_shader_path)
	
	# Load lite shader
	var lite_shader_path = "res://src/ui/effects/shaders/glass_morphism_ui_lite.gdshader"
	if ResourceLoader.exists(lite_shader_path):
		_glass_shader_lite = load(lite_shader_path)
		print("[UIThemeManager] Loaded lite quality glass shader")
	else:
		push_warning("[UIThemeManager] Lite quality glass shader not found: " + lite_shader_path)
	
	# Set initial quality based on saved settings or default to medium
	var initial_quality = "medium"
	if SettingsManager:
		initial_quality = SettingsManager.get_setting("forced_shader_quality", "medium")
	
	_current_shader_quality = initial_quality

func _apply_shader_to_ui_panels(shader: Shader) -> void:
	"""Apply shader to all nodes in the 'ui_panels' group"""
	if not shader:
		push_warning("[UIThemeManager] Cannot apply null shader to UI panels")
		return
	
	var ui_panels = get_tree().get_nodes_in_group("ui_panels")
	var panels_updated = 0
	
	for panel in ui_panels:
		if panel is Control:
			_apply_shader_to_control(panel, shader)
			panels_updated += 1
	
	print("[UIThemeManager] Applied shader to " + str(panels_updated) + " UI panels")

func _apply_shader_to_control(control: Control, shader: Shader) -> void:
	"""Apply shader to a specific control node"""
	if not control or not shader:
		return
	
	# Create or update shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Set default shader parameters for the lite shader with validation
	if shader == _glass_shader_lite:
		_set_shader_parameter_safely(shader_material, "glass_opacity", 0.25)
		_set_shader_parameter_safely(shader_material, "tint_color", Color(0.8, 0.9, 1.0, 0.15))
		_set_shader_parameter_safely(shader_material, "gradient_strength", 0.3)
		_set_shader_parameter_safely(shader_material, "enable_subtle_noise", true)
	elif shader == _glass_shader_full:
		# Set default parameters for full shader with validation
		_set_shader_parameter_safely(shader_material, "blur_amount", 4.0)  # Reduced from 8.0 for better performance
		_set_shader_parameter_safely(shader_material, "glass_opacity", 0.3)
		_set_shader_parameter_safely(shader_material, "tint_color", Color(1.0, 1.0, 1.0, 0.1))
		_set_shader_parameter_safely(shader_material, "noise_amount", 0.02)
		_set_shader_parameter_safely(shader_material, "saturation_boost", 1.2)
		_set_shader_parameter_safely(shader_material, "brightness", 1.1)
		_set_shader_parameter_safely(shader_material, "enable_chromatic_aberration", false)
		_set_shader_parameter_safely(shader_material, "blur_quality", 1)  # Use low quality for better performance
	
	# Apply to the control's material
	control.material = shader_material

func _set_shader_parameter_safely(material: ShaderMaterial, param_name: String, value: Variant) -> void:
	"""Safely set shader parameter only if it exists in the shader"""
	if not material or not material.shader:
		return
	
	# Get the shader's param list and check if parameter exists
	var shader_params = material.shader.get_shader_uniform_list()
	var param_exists = false
	
	for param_info in shader_params:
		if param_info.name == param_name:
			param_exists = true
			break
	
	if param_exists:
		material.set_shader_parameter(param_name, value)
	else:
		# Log but don't error - this is expected for different shader variants
		print("[UIThemeManager] Shader parameter '%s' not found in current shader variant" % param_name)

func _update_cached_shader_materials(shader: Shader) -> void:
	"""Update any cached shader materials that might exist"""
	if not shader:
		return
	
	# This method can be extended to update any cached materials
	# For now, we'll just log that materials were updated
	print("[UIThemeManager] Updated cached shader materials to use: " + ("LITE" if shader == _glass_shader_lite else "FULL"))

func _on_quality_level_changed(new_level: int) -> void:
	"""Handle quality level changes from PerformanceMonitor"""
	var quality_names = ["low", "medium", "high", "ultra"]
	if new_level >= 0 and new_level < quality_names.size():
		var quality_name = quality_names[new_level]
		print("[UIThemeManager] Performance quality changed to: " + quality_name)
		apply_quality_based_shaders(quality_name)
	else:
		push_warning("[UIThemeManager] Invalid quality level received: " + str(new_level))

# === NEUROVISION THEME EFFECTS INTEGRATION ===

func _setup_effects_integration() -> void:
	"""Setup integration with ThemeEffectsManager for NeuroVision visual effects"""
	var effects_manager = get_node("/root/ThemeEffectsManager")
	
	if not effects_manager:
		push_warning("[UIThemeManager] ThemeEffectsManager not found")
		return
	
	print("[UIThemeManager] Setting up NeuroVision effects integration")
	
	# Configure glass morphism quality based on current performance
	var quality_level = 2  # Default to medium
	if PerformanceMonitor and PerformanceMonitor.has_method("get_current_quality_level"):
		quality_level = PerformanceMonitor.get_current_quality_level()
	
	effects_manager.set_glass_quality(quality_level)
	
	# Configure NeuroVision specific effects
	var neurovision_config = {
		"glass_opacity": 0.85,
		"tint_color": M3DesignTokens.M3_COLORS["primary"],
		"blur_amount": 12.0,
		"enable_chromatic_aberration": quality_level > 2,
		"transition_duration": theme_transition_duration
	}
	
	effects_manager.configure_transition(neurovision_config)
	
	print("[UIThemeManager] NeuroVision effects configured for quality level: %d" % quality_level)

## Apply NeuroVision glass morphism to UI panels
func apply_neurovision_glass_effect(control: Control, structure_type: String = "panel") -> void:
	"""Apply NeuroVision-themed glass morphism effect"""
	var effects_manager = get_node("/root/ThemeEffectsManager")
	if not effects_manager:
		push_warning("[UIThemeManager] ThemeEffectsManager not available")
		return
	
	# Determine intensity based on structure type
	var intensity = 0.85
	match structure_type:
		"navigation":
			intensity = 0.9
		"modal":
			intensity = 0.95
		"panel":
			intensity = 0.85
		"button":
			intensity = 0.7
	
	effects_manager.apply_glass_morphism(control, intensity)

## Create NeuroVision-themed transition between themes
func apply_neurovision_theme_transition(from_theme: String, to_theme: String) -> void:
	"""Apply NeuroVision-specific theme transition effect"""
	var effects_manager = get_node("/root/ThemeEffectsManager")
	if not effects_manager:
		_set_theme_immediately(to_theme)
		return
	
	var from_theme_resource = _get_theme_resource(from_theme)
	var to_theme_resource = _get_theme_resource(to_theme)
	
	if from_theme_resource and to_theme_resource:
		effects_manager.animate_theme_transition(
			from_theme_resource, 
			to_theme_resource, 
			theme_transition_duration,
			1  # Ripple transition for neural network aesthetic
		)
	else:
		_set_theme_immediately(to_theme)

## Apply brain structure highlight effects
func apply_brain_structure_highlight(control: Control, structure_name: String) -> void:
	"""Apply NeuroVision brain structure specific highlighting"""
	var effects_manager = get_node("/root/ThemeEffectsManager")
	if not effects_manager:
		return
	
	# Get structure-specific color
	var structure_color = Color.CYAN  # Default
	if M3DesignTokens.BRAIN_STRUCTURE_COLORS.has(structure_name):
		structure_color = M3DesignTokens.BRAIN_STRUCTURE_COLORS[structure_name]
	
	# Apply hover glow with structure color
	effects_manager.apply_hover_glow(control, structure_color, 0.8)
	
	# Create selection particles at control center
	var center_pos = control.global_position + control.size / 2
	effects_manager.create_selection_particles(center_pos, {
		"color": structure_color,
		"particle_count": 20,
		"lifetime": 1.5
	})

## Update effects quality based on performance
func update_effects_quality(quality_level: int) -> void:
	"""Update visual effects quality based on performance level"""
	var effects_manager = get_node("/root/ThemeEffectsManager")
	if not effects_manager:
		return
	
	effects_manager.set_glass_quality(quality_level)
	
	# Update shader quality as well
	var quality_names = ["low", "medium", "high", "ultra"]
	if quality_level >= 0 and quality_level < quality_names.size():
		apply_quality_based_shaders(quality_names[quality_level])
	
	print("[UIThemeManager] Updated NeuroVision effects quality to level: %d" % quality_level)

# === WRAPPER FUNCTIONS ===

func _set_theme_immediately(theme_name: String) -> void:
	"""Wrapper function to set theme immediately without animation"""
	set_theme(theme_name, false)

func _get_theme_resource(theme_name: String) -> Theme:
	"""Wrapper function to get theme resource by name"""
	return _get_theme(theme_name)
