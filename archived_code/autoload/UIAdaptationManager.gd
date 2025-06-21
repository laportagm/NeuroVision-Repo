extends Node

## Manages UI adaptation for different devices, learning levels, and accessibility needs
## Complements UIThemeManager by handling layout modes and educational content hierarchy

signal layout_mode_changed(mode: LayoutMode)
signal learning_level_changed(level: LearningLevel)
signal content_hierarchy_updated(hierarchy: Dictionary)
signal ui_adaptation_applied(adaptation_data: Dictionary)
signal educational_theme_changed(theme: Theme, variant: int)

# === ENUMS ===

enum LayoutMode {
	COMPACT,        ## Mobile/tablet optimized layout with overlay panels
	STANDARD,       ## Desktop layout with docked sidebars
	PRESENTATION,   ## Teaching mode with minimal UI and large content
	MULTI_MONITOR   ## Multi-screen setup with distributed interface
}

enum LearningLevel {
	BEGINNER,       ## Basic concepts and simplified information
	INTERMEDIATE,   ## Standard educational content with details
	ADVANCED        ## Complete information including research and technical details
}

enum ThemeVariant {
	AUTO,           ## Automatically select theme based on system preferences
	LIGHT,          ## Light theme for normal lighting conditions
	DARK,           ## Dark theme for low-light environments
	HIGH_CONTRAST   ## High contrast theme for accessibility
}

# === CONSTANTS ===

const DEFAULT_LAYOUT_MODE = LayoutMode.STANDARD
const DEFAULT_LEARNING_LEVEL = LearningLevel.INTERMEDIATE
const DEFAULT_THEME_VARIANT = ThemeVariant.AUTO

## Screen size breakpoints for automatic layout adaptation
const SCREEN_BREAKPOINTS = {
	"mobile": 768,
	"tablet": 1024, 
	"desktop": 1440,
	"ultrawide": 1920
}

## Panel configurations for different layout modes
const LAYOUT_CONFIGURATIONS = {
	LayoutMode.COMPACT: {
		"sidebar_width": 280,
		"info_panel_width": 350,
		"info_panel_position": "overlay",
		"quiz_panel_position": "fullscreen",
		"minimize_chrome": true
	},
	LayoutMode.STANDARD: {
		"sidebar_width": 320,
		"info_panel_width": 450,
		"info_panel_position": "docked_right",
		"quiz_panel_position": "modal",
		"minimize_chrome": false
	},
	LayoutMode.PRESENTATION: {
		"sidebar_width": 0,
		"info_panel_width": 600,
		"info_panel_position": "overlay_center",
		"quiz_panel_position": "hidden",
		"minimize_chrome": true,
		"annotations_enabled": true
	},
	LayoutMode.MULTI_MONITOR: {
		"sidebar_width": 400,
		"info_panel_width": 500,
		"info_panel_position": "secondary_screen",
		"quiz_panel_position": "secondary_screen",
		"minimize_chrome": false
	}
}

## Content hierarchy definitions for learning levels
const CONTENT_HIERARCHY = {
	LearningLevel.BEGINNER: {
		"primary": ["structure_name", "primary_function", "key_facts"],
		"secondary": ["basic_description", "simple_diagram"],
		"hidden": ["technical_details", "research_notes", "advanced_pathology"],
		"max_info_items": 5
	},
	LearningLevel.INTERMEDIATE: {
		"primary": ["structure_name", "primary_function", "clinical_relevance"],
		"secondary": ["detailed_description", "anatomical_relations", "common_pathology"],
		"tertiary": ["development", "variations"],
		"hidden": ["molecular_details", "advanced_research"],
		"max_info_items": 10
	},
	LearningLevel.ADVANCED: {
		"primary": ["structure_name", "comprehensive_function", "clinical_significance"],
		"secondary": ["detailed_anatomy", "pathophysiology", "research_findings"],
		"tertiary": ["molecular_basis", "developmental_biology", "comparative_anatomy"],
		"hidden": [],
		"max_info_items": -1  # unlimited
	}
}

# === PRIVATE VARIABLES ===
var _current_layout_mode: LayoutMode = DEFAULT_LAYOUT_MODE
var _current_learning_level: LearningLevel = DEFAULT_LEARNING_LEVEL
var _current_theme_variant: ThemeVariant = DEFAULT_THEME_VARIANT
var _screen_size: Vector2
var _is_touch_device: bool = false
var _auto_adapt_enabled: bool = true
var _content_hierarchy_cache: Dictionary = {}
var _current_educational_theme: Theme = null

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize UI adaptation manager"""
	print("[UIAdaptationManager] Initializing UI adaptation system")
	
	# Connect to existing systems
	_connect_to_existing_systems()
	
	# Load saved preferences
	_load_adaptation_settings()
	
	# Detect initial screen configuration
	_detect_screen_configuration()
	
	# Apply initial adaptations
	_apply_initial_adaptations()
	
	# Initialize educational theme
	_apply_educational_theme()
	
	print("[UIAdaptationManager] UI adaptation system ready")

func set_layout_mode(mode: LayoutMode, force: bool = false) -> void:
	"""Set the current layout mode"""
	if mode == _current_layout_mode and not force:
		return
		
	if not _is_layout_mode_supported(mode):
		push_warning("[UIAdaptationManager] Layout mode not supported for current configuration: " + str(mode))
		return
		
	print("[UIAdaptationManager] Switching layout mode to: " + str(mode))
	
	var old_mode = _current_layout_mode
	_current_layout_mode = mode
	
	# Apply layout adaptations
	_apply_layout_adaptations()
	
	# Save preference
	_save_layout_preference()
	
	# Emit signal
	layout_mode_changed.emit(mode)
	
	print("[UIAdaptationManager] Layout mode changed from " + str(old_mode) + " to " + str(mode))

func get_layout_mode() -> LayoutMode:
	"""Get the current layout mode"""
	return _current_layout_mode

func set_learning_level(level: LearningLevel) -> void:
	"""Set the current learning level"""
	if level == _current_learning_level:
		return
		
	print("[UIAdaptationManager] Switching learning level to: " + str(level))
	
	var old_level = _current_learning_level
	_current_learning_level = level
	
	# Update content hierarchy
	_update_content_hierarchy()
	
	# Save preference
	_save_learning_level_preference()
	
	# Emit signals
	learning_level_changed.emit(level)
	
	print("[UIAdaptationManager] Learning level changed from " + str(old_level) + " to " + str(level))
	
	# Update educational theme for new learning level
	_apply_educational_theme()

func get_learning_level() -> LearningLevel:
	"""Get the current learning level"""
	return _current_learning_level

func set_theme_variant(variant: ThemeVariant) -> void:
	"""Set the current theme variant"""
	if variant == _current_theme_variant:
		return
		
	print("[UIAdaptationManager] Switching theme variant to: " + str(variant))
	
	var old_variant = _current_theme_variant
	_current_theme_variant = variant
	
	# Apply new educational theme
	_apply_educational_theme()
	
	# Save preference
	_save_theme_preference()
	
	print("[UIAdaptationManager] Theme variant changed from " + str(old_variant) + " to " + str(variant))

func get_theme_variant() -> ThemeVariant:
	"""Get the current theme variant"""
	return _current_theme_variant

func get_current_educational_theme() -> Theme:
	"""Get the currently applied educational theme"""
	return _current_educational_theme

func get_layout_configuration() -> Dictionary:
	"""Get current layout configuration settings"""
	return LAYOUT_CONFIGURATIONS.get(_current_layout_mode, {})

func get_content_hierarchy() -> Dictionary:
	"""Get current content hierarchy for learning level"""
	return CONTENT_HIERARCHY.get(_current_learning_level, {})

func should_show_content(content_type: String) -> bool:
	"""Check if content type should be shown for current learning level"""
	var hierarchy = get_content_hierarchy()
	
	if content_type in hierarchy.get("hidden", []):
		return false
		
	return (content_type in hierarchy.get("primary", []) or 
			content_type in hierarchy.get("secondary", []) or
			content_type in hierarchy.get("tertiary", []))

func get_content_priority(content_type: String) -> int:
	"""Get display priority for content type (lower = higher priority)"""
	var hierarchy = get_content_hierarchy()
	
	if content_type in hierarchy.get("primary", []):
		return 1
	elif content_type in hierarchy.get("secondary", []):
		return 2
	elif content_type in hierarchy.get("tertiary", []):
		return 3
	else:
		return 4

func adapt_to_screen_size(size: Vector2) -> void:
	"""Manually trigger adaptation to specific screen size"""
	_screen_size = size
	
	if _auto_adapt_enabled:
		_auto_adapt_layout_for_screen()

func enable_auto_adaptation(enabled: bool) -> void:
	"""Enable or disable automatic layout adaptation"""
	_auto_adapt_enabled = enabled
	
	if enabled:
		_auto_adapt_layout_for_screen()

func get_recommended_layout_mode() -> LayoutMode:
	"""Get recommended layout mode for current screen configuration"""
	if _screen_size.x < SCREEN_BREAKPOINTS.mobile:
		return LayoutMode.COMPACT
	elif _screen_size.x < SCREEN_BREAKPOINTS.desktop:
		return LayoutMode.COMPACT if _is_touch_device else LayoutMode.STANDARD
	elif DisplayServer.get_screen_count() > 1:
		return LayoutMode.MULTI_MONITOR
	else:
		return LayoutMode.STANDARD

func get_adaptation_status() -> Dictionary:
	"""Get current adaptation status for debugging"""
	return {
		"layout_mode": _current_layout_mode,
		"learning_level": _current_learning_level,
		"theme_variant": _current_theme_variant,
		"screen_size": _screen_size,
		"is_touch_device": _is_touch_device,
		"auto_adapt_enabled": _auto_adapt_enabled,
		"screen_count": DisplayServer.get_screen_count(),
		"recommended_mode": get_recommended_layout_mode(),
		"has_educational_theme": _current_educational_theme != null
	}

# === PRIVATE METHODS ===

func _connect_to_existing_systems() -> void:
	"""Connect to existing autoload systems"""
	# Connect to SettingsManager
	if has_node("/root/SettingsManager"):
		var settings_mgr = get_node_or_null("/root/SettingsManager")
		settings_mgr.setting_changed.connect(_on_setting_changed)
		print("[UIAdaptationManager] Connected to SettingsManager")
	
	# Connect to AccessibilityManager
	if has_node("/root/AccessibilityManager"):
		var accessibility_mgr = get_node_or_null("/root/AccessibilityManager")
		accessibility_mgr.accessibility_mode_changed.connect(_on_accessibility_changed)
		print("[UIAdaptationManager] Connected to AccessibilityManager")
	
	# Connect to window size changes
	get_viewport().size_changed.connect(_on_window_size_changed)

func _load_adaptation_settings() -> void:
	"""Load UI adaptation settings from SettingsManager"""
	if not has_node("/root/SettingsManager"):
		print("[UIAdaptationManager] SettingsManager not available, using defaults")
		return
	
	var settings_mgr = get_node_or_null("/root/SettingsManager")
	
	# Load layout mode
	var saved_layout = settings_mgr.get_setting("ui_layout_mode", str(DEFAULT_LAYOUT_MODE))
	if saved_layout is String and saved_layout.is_valid_int():
		_current_layout_mode = int(saved_layout) as LayoutMode
	
	# Load learning level
	var saved_level = settings_mgr.get_setting("ui_learning_level", str(DEFAULT_LEARNING_LEVEL))
	if saved_level is String and saved_level.is_valid_int():
		_current_learning_level = int(saved_level) as LearningLevel
	
	# Load theme variant
	var saved_theme = settings_mgr.get_setting("ui_theme_variant", str(DEFAULT_THEME_VARIANT))
	if saved_theme is String and saved_theme.is_valid_int():
		_current_theme_variant = int(saved_theme) as ThemeVariant
	
	# Load auto adaptation setting
	_auto_adapt_enabled = settings_mgr.get_setting("ui_auto_adapt", true)
	
	print("[UIAdaptationManager] Loaded settings - Layout: " + str(_current_layout_mode) + 
		  ", Level: " + str(_current_learning_level) + ", Theme: " + str(_current_theme_variant) + ", Auto: " + str(_auto_adapt_enabled))

func _detect_screen_configuration() -> void:
	"""Detect screen size and input capabilities"""
	_screen_size = DisplayServer.window_get_size()
	_is_touch_device = DisplayServer.is_touchscreen_available()
	
	print("[UIAdaptationManager] Screen configuration - Size: " + str(_screen_size) + 
		  ", Touch: " + str(_is_touch_device) + ", Screens: " + str(DisplayServer.get_screen_count()))

func _apply_initial_adaptations() -> void:
	"""Apply initial UI adaptations"""
	if _auto_adapt_enabled:
		_auto_adapt_layout_for_screen()
	else:
		_apply_layout_adaptations()
	
	_update_content_hierarchy()

func _is_layout_mode_supported(mode: LayoutMode) -> bool:
	"""Check if layout mode is supported for current configuration"""
	match mode:
		LayoutMode.MULTI_MONITOR:
			return DisplayServer.get_screen_count() > 1
		LayoutMode.COMPACT:
			return true  # Always supported
		LayoutMode.STANDARD:
			# In headless mode or very small screens, allow but warn
			return _screen_size.x >= SCREEN_BREAKPOINTS.tablet or _screen_size.x == 0
		LayoutMode.PRESENTATION:
			# Allow in headless mode for testing purposes
			return _screen_size.x >= SCREEN_BREAKPOINTS.desktop or _screen_size.x == 0
		_:
			return false

func _auto_adapt_layout_for_screen() -> void:
	"""Automatically adapt layout based on screen configuration"""
	var recommended_mode = get_recommended_layout_mode()
	
	if recommended_mode != _current_layout_mode:
		print("[UIAdaptationManager] Auto-adapting layout from " + str(_current_layout_mode) + 
			  " to " + str(recommended_mode))
		set_layout_mode(recommended_mode, false)

func _apply_layout_adaptations() -> void:
	"""Apply current layout mode adaptations"""
	var config = get_layout_configuration()
	
	var adaptation_data = {
		"layout_mode": _current_layout_mode,
		"configuration": config,
		"screen_size": _screen_size,
		"timestamp": Time.get_ticks_msec()
	}
	
	ui_adaptation_applied.emit(adaptation_data)
	print("[UIAdaptationManager] Applied layout adaptations for mode: " + str(_current_layout_mode))

func _update_content_hierarchy() -> void:
	"""Update content hierarchy based on learning level"""
	var hierarchy = get_content_hierarchy()
	_content_hierarchy_cache = hierarchy.duplicate()
	
	content_hierarchy_updated.emit(hierarchy)
	print("[UIAdaptationManager] Updated content hierarchy for level: " + str(_current_learning_level))

func _save_layout_preference() -> void:
	"""Save layout mode preference"""
	if has_node("/root/SettingsManager"):
		var settings_mgr = get_node_or_null("/root/SettingsManager")
		settings_mgr.set_setting("ui_layout_mode", str(_current_layout_mode))

func _save_learning_level_preference() -> void:
	"""Save learning level preference"""
	if has_node("/root/SettingsManager"):
		var settings_mgr = get_node_or_null("/root/SettingsManager")
		settings_mgr.set_setting("ui_learning_level", str(_current_learning_level))

func _save_theme_preference() -> void:
	"""Save theme variant preference"""
	if has_node("/root/SettingsManager"):
		var settings_mgr = get_node_or_null("/root/SettingsManager")
		settings_mgr.set_setting("ui_theme_variant", str(_current_theme_variant))

func _apply_educational_theme() -> void:
	"""Apply educational theme based on current variant and learning level"""
	var resolved_variant = _resolve_theme_variant()
	var generator_variant = _convert_to_generator_variant(resolved_variant)
	
	# EducationalThemeGenerator not implemented yet - use fallback
	push_warning("[UIAdaptationManager] EducationalThemeGenerator not available, using Material3Generator fallback")
	
	# Use Material3Generator as fallback
	const Material3Generator = preload("res://src/ui_atomic/themes/generators/Material3ThemeGenerator.gd")
	var fallback_theme = Material3Generator.new().generate_theme()
	_current_educational_theme = fallback_theme
	
	# Apply theme to UI system
	if has_node("/root/UIThemeManager"):
		var theme_mgr = get_node("/root/UIThemeManager")
		var theme_name = "educational_" + str(resolved_variant).to_lower() + "_level" + str(_current_learning_level)
		theme_mgr.apply_theme(_current_educational_theme, theme_name)
		print("[UIAdaptationManager] Applied fallback educational theme - Variant: " + str(resolved_variant) + ", Level: " + str(_current_learning_level))
	else:
		push_warning("[UIAdaptationManager] UIThemeManager not available for educational theme application")
	
	# Emit signal for components that need theme updates
	educational_theme_changed.emit(_current_educational_theme, generator_variant)

func _resolve_theme_variant() -> ThemeVariant:
	"""Resolve AUTO theme variant to specific variant based on system preferences"""
	if _current_theme_variant != ThemeVariant.AUTO:
		return _current_theme_variant
	
	# Auto-detect based on system preferences and accessibility needs
	if has_node("/root/AccessibilityManager"):
		var accessibility_mgr = get_node_or_null("/root/AccessibilityManager")
		if accessibility_mgr.is_high_contrast_enabled():
			return ThemeVariant.HIGH_CONTRAST
	
	# Check system theme preference (if available)
	# For now, default to light theme - could be enhanced with OS theme detection
	return ThemeVariant.LIGHT

func _convert_to_generator_variant(variant: ThemeVariant) -> int:
	"""Convert UIAdaptationManager ThemeVariant to EducationalThemeGenerator ThemeVariant"""
	match variant:
		ThemeVariant.LIGHT:
			return 0  # EducationalThemeGenerator.ThemeVariant.LIGHT
		ThemeVariant.DARK:
			return 1  # EducationalThemeGenerator.ThemeVariant.DARK
		ThemeVariant.HIGH_CONTRAST:
			return 2  # EducationalThemeGenerator.ThemeVariant.HIGH_CONTRAST
		_:
			return 0  # EducationalThemeGenerator.ThemeVariant.LIGHT

# === SIGNAL HANDLERS ===

func _on_setting_changed(setting_name: String, value: Variant) -> void:
	"""Handle settings changes from SettingsManager"""
	match setting_name:
		"ui_layout_mode":
			if value is String and value.is_valid_int():
				var new_mode = int(value) as LayoutMode
				if new_mode != _current_layout_mode:
					set_layout_mode(new_mode)
		"ui_learning_level":
			if value is String and value.is_valid_int():
				var new_level = int(value) as LearningLevel
				if new_level != _current_learning_level:
					set_learning_level(new_level)
		"ui_theme_variant":
			if value is String and value.is_valid_int():
				var new_variant = int(value) as ThemeVariant
				if new_variant != _current_theme_variant:
					set_theme_variant(new_variant)
		"ui_auto_adapt":
			if value is bool:
				enable_auto_adaptation(value)

func _on_accessibility_changed(enabled: bool) -> void:
	"""Handle accessibility mode changes"""
	if enabled:
		# When accessibility is enabled, prefer more spacious layouts
		if _current_layout_mode == LayoutMode.COMPACT:
			set_layout_mode(LayoutMode.STANDARD)
		
		# Auto-switch to high contrast theme if accessibility is enabled
		if _current_theme_variant == ThemeVariant.AUTO:
			_apply_educational_theme()  # Re-apply theme with accessibility consideration
	
	print("[UIAdaptationManager] Adapted to accessibility change: " + str(enabled))

func _on_window_size_changed() -> void:
	"""Handle window size changes"""
	var new_size = get_viewport().size
	adapt_to_screen_size(new_size)
	print("[UIAdaptationManager] Window size changed to: " + str(new_size))

# === UTILITY METHODS ===

func get_layout_mode_display_name(mode: LayoutMode) -> String:
	"""Get user-friendly display name for layout mode"""
	match mode:
		LayoutMode.COMPACT:
			return "Compact"
		LayoutMode.STANDARD:
			return "Standard"
		LayoutMode.PRESENTATION:
			return "Presentation"
		LayoutMode.MULTI_MONITOR:
			return "Multi-Monitor"
		_:
			return "Unknown"

func get_learning_level_display_name(level: LearningLevel) -> String:
	"""Get user-friendly display name for learning level"""
	match level:
		LearningLevel.BEGINNER:
			return "Beginner"
		LearningLevel.INTERMEDIATE:
			return "Intermediate"
		LearningLevel.ADVANCED:
			return "Advanced"
		_:
			return "Unknown"

func get_layout_mode_description(mode: LayoutMode) -> String:
	"""Get description of layout mode features"""
	match mode:
		LayoutMode.COMPACT:
			return "Optimized for mobile and small screens with overlay panels"
		LayoutMode.STANDARD:
			return "Traditional desktop layout with docked sidebars"
		LayoutMode.PRESENTATION:
			return "Minimal interface for teaching and presentations"
		LayoutMode.MULTI_MONITOR:
			return "Distributed interface across multiple displays"
		_:
			return ""

func get_learning_level_description(level: LearningLevel) -> String:
	"""Get description of learning level content"""
	match level:
		LearningLevel.BEGINNER:
			return "Essential concepts with simplified explanations"
		LearningLevel.INTERMEDIATE:
			return "Standard educational content with clinical context"
		LearningLevel.ADVANCED:
			return "Comprehensive information including research details"
		_:
			return ""

func get_theme_variant_display_name(variant: ThemeVariant) -> String:
	"""Get user-friendly display name for theme variant"""
	match variant:
		ThemeVariant.AUTO:
			return "Auto"
		ThemeVariant.LIGHT:
			return "Light"
		ThemeVariant.DARK:
			return "Dark"
		ThemeVariant.HIGH_CONTRAST:
			return "High Contrast"
		_:
			return "Unknown"

func get_theme_variant_description(variant: ThemeVariant) -> String:
	"""Get description of theme variant features"""
	match variant:
		ThemeVariant.AUTO:
			return "Automatically adapt theme based on system preferences and accessibility needs"
		ThemeVariant.LIGHT:
			return "Light theme optimized for normal lighting conditions"
		ThemeVariant.DARK:
			return "Dark theme for low-light environments and reduced eye strain"
		ThemeVariant.HIGH_CONTRAST:
			return "High contrast theme for accessibility and visual impairments"
		_:
			return ""
