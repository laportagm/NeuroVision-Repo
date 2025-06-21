extends Node

## Consolidated UI system management
## Combines UIThemeManager, ThemeEffectsManager, UIAdaptationManager, UIPoolManager, and OnboardingManager

signal theme_changed(theme_name: String)
signal theme_transition_completed()
signal adaptation_level_changed(level: int)
signal onboarding_completed()
signal ui_element_pooled(element_type: String, count: int)

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
const POOL_INITIAL_SIZE = 10
const ONBOARDING_SAVE_PATH = "user://onboarding_progress.save"

# Material 3 generator (loaded dynamically to avoid circular dependencies)
var Material3Generator = null

# === ENUMS ===

enum AdaptationLevel {
	BEGINNER = 0,    ## Simplified UI, guided interactions
	INTERMEDIATE = 1,## Standard UI with optional guidance
	ADVANCED = 2     ## Full UI, minimal guidance
}

enum OnboardingStep {
	WELCOME,
	NAVIGATION_TUTORIAL,
	SELECTION_TUTORIAL,
	INFORMATION_PANEL,
	QUIZ_INTRODUCTION,
	COMPLETED
}

# === PRIVATE VARIABLES ===

# Theme Management
var _current_theme: String = DEFAULT_THEME
var _loaded_themes: Dictionary = {}
var _transition_tween: Tween = null
var _current_shader_quality: String = "medium"
var current_theme_resource: Theme = null
var theme_transition_duration: float = TRANSITION_DURATION

# UI Adaptation
var _current_adaptation_level: AdaptationLevel = AdaptationLevel.INTERMEDIATE
var _ui_complexity_enabled: bool = true
var _guided_interactions: bool = false
var _accessibility_features: Dictionary = {}

# UI Pooling
var _ui_pools: Dictionary = {}
var _pool_usage_stats: Dictionary = {}

# Onboarding
var _onboarding_progress: Dictionary = {}
var _current_onboarding_step: OnboardingStep = OnboardingStep.WELCOME
var _onboarding_completed: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[UISystemManager] Initializing consolidated UI system")
	
	# Load Material3 generator dynamically
	var generator_path = "res://src/ui_atomic/themes/generators/Material3ThemeGenerator.gd"
	if ResourceLoader.exists(generator_path):
		Material3Generator = load(generator_path)
		if Material3Generator:
			print("[UISystemManager] Material3 generator loaded successfully")
		else:
			push_warning("[UISystemManager] Failed to load Material3 generator")
	
	_initialize_theme_system()
	_initialize_ui_pools()
	_load_onboarding_progress()
	_apply_adaptation_settings()

## Theme Management Methods

func set_theme(theme_name: String) -> bool:
	"""Set the current theme"""
	if not THEMES.has(theme_name):
		push_warning("[UISystemManager] Unknown theme: " + theme_name)
		return false
	
	if _current_theme == theme_name:
		return true
	
	var old_theme = _current_theme
	_current_theme = theme_name
	
	var theme_resource = _get_theme_resource(theme_name)
	if theme_resource == null:
		_current_theme = old_theme
		return false
	
	_apply_theme_transition(theme_resource)
	return true

func get_current_theme() -> String:
	"""Get current theme name"""
	return _current_theme

func get_theme_resource() -> Theme:
	"""Get current theme resource"""
	return current_theme_resource

func is_material3_active() -> bool:
	"""Check if Material 3 theme system is currently active"""
	return _current_theme.begins_with("material3")

func get_available_themes() -> Array[String]:
	"""Get list of all available themes"""
	var themes: Array[String] = []
	for theme_name in THEMES.keys():
		themes.append(theme_name)
	return themes

func get_theme_display_name(theme_name: String) -> String:
	"""Get user-friendly display name for theme"""
	match theme_name:
		"dark": return "Dark Theme"
		"high_contrast": return "High Contrast"
		"colorblind": return "Colorblind Safe"
		"material3": return "Material 3"
		"material3_high_contrast": return "Material 3 High Contrast"
		"material3_colorblind": return "Material 3 Colorblind Safe"
		_: return theme_name.capitalize()

func get_theme_description(theme_name: String) -> String:
	"""Get description of theme features"""
	match theme_name:
		"dark": return "Classic dark theme with blue accents"
		"high_contrast": return "High contrast theme for improved visibility"
		"colorblind": return "Colorblind-friendly theme with distinguishable colors"
		"material3": return "Modern Material 3 design with dynamic colors"
		"material3_high_contrast": return "Material 3 with enhanced contrast"
		"material3_colorblind": return "Material 3 with colorblind-safe palette"
		_: return "Custom theme variant"

func set_shader_quality(quality: String) -> void:
	"""Set shader quality (low, medium, high)"""
	_current_shader_quality = quality
	_update_shader_quality()

## UI Adaptation Methods

func set_adaptation_level(level: AdaptationLevel) -> void:
	"""Set UI adaptation level"""
	if _current_adaptation_level == level:
		return
	
	_current_adaptation_level = level
	_apply_adaptation_settings()
	adaptation_level_changed.emit(level)

func get_adaptation_level() -> AdaptationLevel:
	"""Get current adaptation level"""
	return _current_adaptation_level

func enable_guided_interactions(enabled: bool) -> void:
	"""Enable or disable guided interactions"""
	_guided_interactions = enabled
	_apply_adaptation_settings()

func set_accessibility_feature(feature: String, enabled: bool) -> void:
	"""Set accessibility feature state"""
	_accessibility_features[feature] = enabled
	_apply_accessibility_settings()

## UI Pooling Methods

func get_pooled_element(element_type: String) -> Control:
	"""Get a pooled UI element"""
	if not _ui_pools.has(element_type):
		_create_pool(element_type)
	
	var pool = _ui_pools[element_type]
	if pool.available.is_empty():
		_expand_pool(element_type)
	
	var element = pool.available.pop_back()
	pool.in_use.append(element)
	
	# Update usage stats
	if not _pool_usage_stats.has(element_type):
		_pool_usage_stats[element_type] = 0
	_pool_usage_stats[element_type] += 1
	
	return element

func return_pooled_element(element: Control, element_type: String) -> void:
	"""Return a pooled UI element"""
	if not _ui_pools.has(element_type):
		return
	
	var pool = _ui_pools[element_type]
	var index = pool.in_use.find(element)
	if index >= 0:
		pool.in_use.remove_at(index)
		pool.available.append(element)
		_reset_element(element)

func get_pool_stats() -> Dictionary:
	"""Get pooling statistics"""
	return _pool_usage_stats.duplicate()

## Onboarding Methods

func start_onboarding() -> void:
	"""Start the onboarding process"""
	_current_onboarding_step = OnboardingStep.WELCOME
	_onboarding_completed = false
	_save_onboarding_progress()

func advance_onboarding() -> void:
	"""Advance to next onboarding step"""
	if _onboarding_completed:
		return
	
	match _current_onboarding_step:
		OnboardingStep.WELCOME:
			_current_onboarding_step = OnboardingStep.NAVIGATION_TUTORIAL
		OnboardingStep.NAVIGATION_TUTORIAL:
			_current_onboarding_step = OnboardingStep.SELECTION_TUTORIAL
		OnboardingStep.SELECTION_TUTORIAL:
			_current_onboarding_step = OnboardingStep.INFORMATION_PANEL
		OnboardingStep.INFORMATION_PANEL:
			_current_onboarding_step = OnboardingStep.QUIZ_INTRODUCTION
		OnboardingStep.QUIZ_INTRODUCTION:
			_current_onboarding_step = OnboardingStep.COMPLETED
			_onboarding_completed = true
			onboarding_completed.emit()
	
	_save_onboarding_progress()

func is_onboarding_completed() -> bool:
	"""Check if onboarding is completed"""
	return _onboarding_completed

func get_current_onboarding_step() -> OnboardingStep:
	"""Get current onboarding step"""
	return _current_onboarding_step

# === PRIVATE METHODS ===

func _initialize_theme_system() -> void:
	"""Initialize the theme system"""
	_preload_shaders()
	_preload_themes()
	_load_saved_theme()

func _initialize_ui_pools() -> void:
	"""Initialize UI element pools"""
	var pool_types = ["Button", "Label", "Panel", "ProgressBar", "Slider"]
	for pool_type in pool_types:
		_create_pool(pool_type)

func _preload_shaders() -> void:
	"""Preload glass morphism shaders - DISABLED for performance"""
	# Glass shaders replaced with StyleBoxFlat for GPU performance
	# var shader_path = "res://src/ui_atomic/effects/shaders/glass_panel.gdshader"
	# if ResourceLoader.exists(shader_path):
	# 	_glass_shader_full = load(shader_path)
	
	# var lite_shader_path = "res://src/ui/effects/shaders/glass_panel_lite.gdshader"
	# if ResourceLoader.exists(lite_shader_path):
	# 	_glass_shader_lite = load(lite_shader_path)
	pass  # Keep function for future shader preloading if needed

func _preload_themes() -> void:
	"""Preload static themes"""
	for theme_name in THEMES:
		var theme_path = THEMES[theme_name]
		if theme_path != "dynamic" and ResourceLoader.exists(theme_path):
			_loaded_themes[theme_name] = load(theme_path)

func _get_theme_resource(theme_name: String) -> Theme:
	"""Get theme resource by name"""
	if _loaded_themes.has(theme_name):
		return _loaded_themes[theme_name]
	
	# Generate dynamic themes
	if theme_name.begins_with("material3"):
		return _generate_material3_theme(theme_name)
	
	return null

func _generate_material3_theme(theme_name: String) -> Theme:
	"""Generate Material 3 theme dynamically"""
	if not Material3Generator:
		push_error("[UISystemManager] Material3Generator not loaded")
		return _get_fallback_theme()
	
	var generator = Material3Generator.new()
	
	# Extract variant from theme name
	var variant = "default"
	if theme_name.contains("high_contrast"):
		variant = "high_contrast"
	elif theme_name.contains("colorblind"):
		variant = "colorblind_safe"
	
	var theme = generator.generate_theme(variant)
	
	# Apply accessibility modifications if needed
	if theme_name.contains("high_contrast"):
		theme = _apply_high_contrast(theme)
	elif theme_name.contains("colorblind"):
		theme = _apply_colorblind_friendly(theme)
	
	_loaded_themes[theme_name] = theme
	return theme

func _apply_theme_transition(new_theme: Theme) -> void:
	"""Apply theme with transition effect"""
	if _transition_tween:
		_transition_tween.kill()
	
	# Apply theme immediately for now
	current_theme_resource = new_theme
	
	# Create a simple transition tween to avoid empty tween warning
	_transition_tween = create_tween()
	_transition_tween.tween_callback(func(): theme_transition_completed.emit()).set_delay(0.1)
	
	theme_changed.emit(_current_theme)

func _apply_adaptation_settings() -> void:
	"""Apply UI adaptation settings based on level"""
	match _current_adaptation_level:
		AdaptationLevel.BEGINNER:
			_ui_complexity_enabled = false
			_guided_interactions = true
		AdaptationLevel.INTERMEDIATE:
			_ui_complexity_enabled = true
			_guided_interactions = false
		AdaptationLevel.ADVANCED:
			_ui_complexity_enabled = true
			_guided_interactions = false

func _apply_accessibility_settings() -> void:
	"""Apply accessibility settings"""
	# Apply accessibility features from _accessibility_features dictionary
	for feature in _accessibility_features:
		var enabled = _accessibility_features[feature]
		match feature:
			"high_contrast":
				if enabled:
					set_theme("high_contrast")
			"large_text":
				_adjust_font_sizes(enabled)
			"reduced_motion":
				_disable_animations(enabled)

func _create_pool(element_type: String) -> void:
	"""Create a new UI element pool"""
	_ui_pools[element_type] = {
		"available": [],
		"in_use": [],
		"prototype": _create_element_prototype(element_type)
	}
	
	_expand_pool(element_type, POOL_INITIAL_SIZE)

func _expand_pool(element_type: String, count: int = 5) -> void:
	"""Expand a UI element pool"""
	var pool = _ui_pools[element_type]
	var prototype = pool.prototype
	
	for i in count:
		var element = prototype.duplicate()
		pool.available.append(element)
	
	ui_element_pooled.emit(element_type, pool.available.size())

func _create_element_prototype(element_type: String) -> Control:
	"""Create a prototype element for pooling"""
	match element_type:
		"Button":
			return Button.new()
		"Label":
			return Label.new()
		"Panel":
			return Panel.new()
		"ProgressBar":
			return ProgressBar.new()
		"Slider":
			return HSlider.new()
		_:
			return Control.new()

func _reset_element(element: Control) -> void:
	"""Reset a pooled element to default state"""
	if element.get_parent():
		element.get_parent().remove_child(element)
	
	element.visible = true
	element.modulate = Color.WHITE
	
	if element is Button:
		element.text = ""
		element.disabled = false
	elif element is Label:
		element.text = ""

func _load_saved_theme() -> void:
	"""Load saved theme from settings"""
	# TODO: Load from SettingsManager when available
	set_theme(DEFAULT_THEME)

func _update_shader_quality() -> void:
	"""Update shader quality based on setting"""
	# TODO: Implement shader quality switching
	pass

func _apply_high_contrast(theme: Theme) -> Theme:
	"""Apply high contrast modifications to theme"""
	# TODO: Implement high contrast theme modifications
	return theme

func _apply_colorblind_friendly(theme: Theme) -> Theme:
	"""Apply colorblind-friendly modifications to theme"""
	# TODO: Implement colorblind-friendly theme modifications
	return theme

func _adjust_font_sizes(_large_text: bool) -> void:
	"""Adjust font sizes for accessibility"""
	# TODO: Implement font size adjustment
	pass

func _disable_animations(_disabled: bool) -> void:
	"""Disable animations for accessibility"""
	# TODO: Implement animation disabling
	pass

func _load_onboarding_progress() -> void:
	"""Load onboarding progress from save file"""
	if not FileAccess.file_exists(ONBOARDING_SAVE_PATH):
		return
	
	var file = FileAccess.open(ONBOARDING_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data = json.data
		_current_onboarding_step = data.get("current_step", OnboardingStep.WELCOME)
		_onboarding_completed = data.get("completed", false)
		_onboarding_progress = data.get("progress", {})

func _save_onboarding_progress() -> void:
	"""Save onboarding progress to file"""
	var save_data = {
		"current_step": _current_onboarding_step,
		"completed": _onboarding_completed,
		"progress": _onboarding_progress,
		"last_saved": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(ONBOARDING_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	
	file.store_string(JSON.stringify(save_data))
	file.close()

func _get_fallback_theme() -> Theme:
	"""Return a basic fallback theme if Material3 generation fails"""
	var theme = Theme.new()
	
	# Set basic colors
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(0.7, 0.7, 0.7))
	
	# Set basic styleboxes
	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = Color(0.2, 0.2, 0.3)
	button_normal.corner_radius_top_left = 4
	button_normal.corner_radius_top_right = 4
	button_normal.corner_radius_bottom_left = 4
	button_normal.corner_radius_bottom_right = 4
	theme.set_stylebox("normal", "Button", button_normal)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15)
	theme.set_stylebox("panel", "Panel", panel_style)
	
	return theme
