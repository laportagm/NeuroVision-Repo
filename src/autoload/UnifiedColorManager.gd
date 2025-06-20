## UnifiedColorManager.gd
## Global autoload that manages the unified color system
##
## This autoload provides:
## 1. Single entry point for all color management
## 2. Theme switching coordination across all systems
## 3. Real-time validation and error prevention
## 4. Educational color integration for NeuroVision
##
## Add to project.godot as: UnifiedColorManager="*res://src/autoload/UnifiedColorManager.gd"

extends Node

# === SIGNALS ===

## Emitted when theme variant changes
signal theme_changed(new_variant: String)

## Emitted when color validation fails
signal validation_failed(error_details: Dictionary)

## Emitted when accessibility issues are detected
signal accessibility_issue_detected(issue: Dictionary)

# === CONFIGURATION ===

## Current active theme variant
var current_theme_variant: String = "enhanced"

## Validation mode for development
var validation_mode: bool = true

## Accessibility validation enabled
var accessibility_validation: bool = true

## Dynamic brain structure color overrides
var _brain_structure_color_overrides: Dictionary = {}

## Educational color integration enabled
var educational_colors_enabled: bool = true

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize the unified color management system"""
	
	print("[UnifiedColorManager] Initializing unified color system...")
	
	# Set up validation
	_setup_validation()
	
	# Initialize educational colors
	_setup_educational_colors()
	
	# Connect to UIThemeManager if available
	_connect_to_theme_manager()
	
	# Apply initial theme
	apply_theme_variant(current_theme_variant)
	
	print("[UnifiedColorManager] ✅ Unified color system initialized")

# === PUBLIC API ===

## Get a color using the unified system
func get_color(token_name: String, context: String = "") -> Color:
	"""Primary color access method for the entire application"""
	
	return UnifiedColorSystem.get_color(token_name, context)

## Get educational color with enhanced context
func get_educational_color(role: String, context: String = "", state: String = "default") -> Color:
	"""Get color for educational components"""
	
	if not educational_colors_enabled:
		return get_color("primary")
	
	return UnifiedColorSystem.get_educational_color(role, context, state)

## Get brain structure color with theme adaptation
func get_brain_structure_color(structure_name: String) -> Color:
	"""Get brain structure color adapted to current theme"""
	
	# Check for educational overrides first
	if _brain_structure_color_overrides.has(structure_name):
		return _brain_structure_color_overrides[structure_name]
	
	return UnifiedColorSystem.get_brain_structure_color(structure_name, current_theme_variant)

## Switch theme variant across entire application
func set_theme_variant(variant: String) -> void:
	"""Switch theme variant and update all components"""
	
	if variant == current_theme_variant:
		return
	
	print("[UnifiedColorManager] Switching theme to: %s" % variant)
	
	var old_variant = current_theme_variant
	current_theme_variant = variant
	
	# Apply new theme
	apply_theme_variant(variant)
	
	# Emit signal for other systems to update
	theme_changed.emit(variant)
	
	print("[UnifiedColorManager] ✅ Theme switched from %s to %s" % [old_variant, variant])

## Apply theme variant to current scene
func apply_theme_variant(variant: String) -> void:
	"""Apply theme variant to all components in current scene"""
	
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	# Update shader colors
	ShaderColorAdapter.apply_unified_colors_to_scene(current_scene, variant)
	
	# Update UI components
	_apply_theme_to_ui_components(current_scene, variant)
	
	# Clear color cache to force refresh
	M3DesignTokens.clear_color_cache()

## Validate current color system state
func validate_color_system() -> Dictionary:
	"""Run comprehensive color system validation"""
	
	if not validation_mode:
		return {"valid": true, "message": "Validation disabled"}
	
	print("[UnifiedColorManager] Running color system validation...")
	
	var result = ColorSystemValidator.validate_project()
	
	if not result.is_valid:
		validation_failed.emit({
			"violations": result.violations,
			"accessibility_issues": result.accessibility_issues
		})
		
		print("[UnifiedColorManager] ❌ Validation failed:")
		for violation in result.violations:
			print("  - %s:%d - %s" % [violation.file, violation.line, violation.message])
	else:
		print("[UnifiedColorManager] ✅ Validation passed")
	
	return {
		"valid": result.is_valid,
		"total_files": result.total_files_checked,
		"violations": result.violations.size(),
		"accessibility_issues": result.accessibility_issues.size()
	}

## Enable/disable validation mode
func set_validation_enabled(enabled: bool) -> void:
	"""Enable or disable color system validation"""
	
	validation_mode = enabled
	UnifiedColorSystem.set_validation_enabled(enabled)
	
	if enabled:
		print("[UnifiedColorManager] ✅ Validation mode enabled")
	else:
		print("[UnifiedColorManager] ⚠️  Validation mode disabled")

## Generate comprehensive migration report
func generate_migration_report() -> String:
	"""Generate detailed migration report for color system"""
	
	return UnifiedColorSystem.generate_full_migration_report()

# === EDUCATIONAL INTEGRATION ===

## Setup educational color mappings
func setup_educational_structure(structure_name: String, color_override: Color = Color()) -> void:
	"""Setup educational color mapping for a brain structure"""
	
	if color_override != Color():
		# Override with custom color (for special educational contexts)
		_brain_structure_color_overrides[structure_name] = color_override
	
	print("[UnifiedColorManager] Educational structure registered: %s" % structure_name)

## Get all available brain structure colors
func get_brain_structure_colors() -> Dictionary:
	"""Get all brain structure colors for educational UI"""
	
	var colors = {}
	for structure_name in M3DesignTokens.BRAIN_STRUCTURE_COLORS:
		colors[structure_name] = get_brain_structure_color(structure_name)
	
	return colors

## Validate educational accessibility
func validate_educational_accessibility() -> Dictionary:
	"""Validate that educational colors meet accessibility standards"""
	
	var issues = []
	var surface_color = get_color("surface")
	
	for structure_name in M3DesignTokens.BRAIN_STRUCTURE_COLORS:
		var structure_color = get_brain_structure_color(structure_name)
		var contrast_ratio = _calculate_contrast_ratio(structure_color, surface_color)
		
		if contrast_ratio < 3.0:  # WCAG AA minimum for graphics
			issues.append({
				"structure": structure_name,
				"contrast_ratio": contrast_ratio,
				"required": 3.0,
				"severity": "warning"
			})
			
			accessibility_issue_detected.emit({
				"type": "educational_contrast",
				"structure": structure_name,
				"contrast_ratio": contrast_ratio
			})
	
	return {
		"total_structures": M3DesignTokens.BRAIN_STRUCTURE_COLORS.size(),
		"accessibility_issues": issues.size(),
		"issues": issues
	}

# === THEME MANAGEMENT ===

## Get available theme variants
func get_available_theme_variants() -> Array[String]:
	"""Get list of available theme variants"""
	
	return ["enhanced", "minimal", "high_contrast", "colorblind_safe", "educational"]

## Check if theme variant is valid
func is_valid_theme_variant(variant: String) -> bool:
	"""Check if a theme variant is valid"""
	
	return variant in get_available_theme_variants()

## Get current theme variant
func get_current_theme_variant() -> String:
	"""Get the currently active theme variant"""
	
	return current_theme_variant

## Preview theme variant without applying
func preview_theme_colors(variant: String) -> Dictionary:
	"""Preview colors for a theme variant without applying"""
	
	var colors = {}
	
	# Get sample colors for preview
	var sample_tokens = ["primary", "surface", "on_surface", "surface_container", "outline"]
	
	for token in sample_tokens:
		# Simulate theme adaptation
		var base_color = M3DesignTokens.get_color(token)
		var adapted_color = UnifiedColorSystem._adapt_color_for_theme(base_color, variant)
		colors[token] = adapted_color
	
	return colors

# === DEVELOPMENT TOOLS ===

## Quick validation for development
func quick_validate() -> void:
	"""Quick validation for development workflow"""
	
	ColorSystemValidator.quick_validate()

## Enable development mode
func enable_development_mode() -> void:
	"""Enable development features for color system"""
	
	set_validation_enabled(true)
	ColorSystemValidator.enable_development_validation()
	
	print("[UnifiedColorManager] 🔧 Development mode enabled")
	print("  - Real-time validation active")
	print("  - Automatic color fixing enabled")
	print("  - Performance monitoring active")

## Generate color palette preview
func generate_color_palette_preview() -> Dictionary:
	"""Generate color palette preview for UI"""
	
	var palette = {
		"theme_variant": current_theme_variant,
		"primary_colors": {},
		"surface_colors": {},
		"semantic_colors": {},
		"brain_colors": {}
	}
	
	# Primary colors
	palette.primary_colors = {
		"primary": get_color("primary"),
		"secondary": get_color("secondary"),
		"tertiary": get_color("tertiary")
	}
	
	# Surface colors
	palette.surface_colors = {
		"surface": get_color("surface"),
		"surface_container": get_color("surface_container"),
		"surface_variant": get_color("surface_variant")
	}
	
	# Semantic colors
	palette.semantic_colors = {
		"error": get_color("error"),
		"success": get_color("success"),
		"warning": get_color("warning"),
		"info": get_color("info")
	}
	
	# Brain structure colors (sample)
	var brain_samples = ["hippocampus", "amygdala", "cortex", "cerebellum"]
	for structure in brain_samples:
		palette.brain_colors[structure] = get_brain_structure_color(structure)
	
	return palette

# === PRIVATE METHODS ===

func _setup_validation() -> void:
	"""Setup validation systems"""
	
	if validation_mode:
		UnifiedColorSystem.set_validation_enabled(true)
		
		# Connect validation signals
		if has_signal("validation_failed") and not validation_failed.is_connected(_on_validation_failed):
			validation_failed.connect(_on_validation_failed)

func _setup_educational_colors() -> void:
	"""Setup educational color integration"""
	
	if educational_colors_enabled:
		print("[UnifiedColorManager] Educational colors enabled")
		
		# Validate educational accessibility
		call_deferred("validate_educational_accessibility")

func _connect_to_theme_manager() -> void:
	"""Connect to UIThemeManager if available"""
	
	if has_node("/root/UIThemeManager"):
		var theme_manager = get_node("/root/UIThemeManager")
		
		# Connect theme change signals
		if theme_manager and theme_manager.has_signal("theme_changed"):
			if not theme_manager.theme_changed.is_connected(_on_theme_manager_changed):
				theme_manager.theme_changed.connect(_on_theme_manager_changed)
		
		print("[UnifiedColorManager] Connected to UIThemeManager")

func _apply_theme_to_ui_components(node: Node, variant: String) -> void:
	"""Recursively apply theme to UI components"""
	
	# Apply to current node if it's a UI component
	if node is Control:
		var element_type = _determine_element_type(node)
		UnifiedColorSystem.apply_unified_theme(node, element_type)
	
	# Recursively apply to children
	for child in node.get_children():
		_apply_theme_to_ui_components(child, variant)

func _determine_element_type(control: Control) -> String:
	"""Determine the element type for a control"""
	
	if control is Button:
		return "button"
	elif control is Label:
		return "label"
	elif control is PanelContainer or control is Panel:
		return "panel"
	elif control is LineEdit or control is TextEdit:
		return "input"
	else:
		return "default"

func _calculate_contrast_ratio(c1: Color, c2: Color) -> float:
	"""Calculate WCAG contrast ratio"""
	
	return ColorSystemValidator._calculate_contrast_ratio(c1, c2)

# === SIGNAL HANDLERS ===

func _on_validation_failed(error_details: Dictionary) -> void:
	"""Handle validation failures"""
	
	print("[UnifiedColorManager] ❌ Validation failed:")
	
	if error_details.has("violations"):
		for violation in error_details.violations:
			print("  - Violation: %s" % violation.message)
	
	if error_details.has("accessibility_issues"):
		for issue in error_details.accessibility_issues:
			print("  - Accessibility: %s" % issue.issue)

func _on_theme_manager_changed(new_theme: String) -> void:
	"""Handle theme changes from UIThemeManager"""
	
	# Map UIThemeManager themes to unified system variants
	var variant_mapping = {
		"enhanced": "enhanced",
		"minimal": "minimal",
		"dark": "enhanced",
		"light": "minimal"
	}
	
	var mapped_variant = variant_mapping.get(new_theme, "enhanced")
	set_theme_variant(mapped_variant)

# === DEBUGGING ===

func _input(event: InputEvent) -> void:
	"""Handle debug input for color system"""
	
	if not OS.is_debug_build():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				# Quick validation
				quick_validate()
			KEY_F10:
				# Theme switching
				var variants = get_available_theme_variants()
				var current_index = variants.find(current_theme_variant)
				var next_index = (current_index + 1) % variants.size()
				set_theme_variant(variants[next_index])
			KEY_F11:
				# Generate color palette preview
				var palette = generate_color_palette_preview()
				print("[UnifiedColorManager] Color Palette Preview:")
				print("  Theme: %s" % palette.theme_variant)
				for category in palette:
					if category != "theme_variant":
						print("  %s: %s" % [category, palette[category]])

# === INTEGRATION HELPERS ===

## Get unified color system status
func get_system_status() -> Dictionary:
	"""Get comprehensive status of the unified color system"""
	
	return {
		"initialized": true,
		"current_theme": current_theme_variant,
		"validation_enabled": validation_mode,
		"educational_colors": educational_colors_enabled,
		"accessibility_validation": accessibility_validation,
		"available_variants": get_available_theme_variants(),
		"color_cache_size": M3DesignTokens._color_cache.size(),
		"validation_logs": UnifiedColorSystem._color_access_log.size()
	}

# === PHASE 1 ENHANCEMENT: SMART COLOR ADAPTATION SYSTEM ===

# Smart Color Adaptation System
var _color_usage_analytics = {}
var _current_context = "default"
var _adaptation_enabled = true

func enable_smart_color_adaptation(enabled: bool) -> void:
	_adaptation_enabled = enabled
	if enabled:
		print("[ColorManager] Smart color adaptation enabled")
	else:
		print("[ColorManager] Using static color system")

func set_brain_region_context(region: String) -> void:
	if not _adaptation_enabled:
		return
		
	_current_context = region
	var contextual_colors = M3DesignTokens.generate_contextual_palette(region)
	
	# Smoothly transition to contextual colors
	_animate_color_transition(contextual_colors)
	
	print("[ColorManager] Switched to %s context" % region)

func _animate_color_transition(new_colors: Dictionary) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate primary color transition
	var current_primary = get_color("primary")
	var target_primary = new_colors.get("primary", current_primary)
	
	tween.tween_method(_interpolate_primary_color, current_primary, target_primary, 0.8)
	
	# Emit signal for UI components to update
	await tween.finished
	theme_changed.emit(current_theme_variant)

func _interpolate_primary_color(_color: Color) -> void:
	# Update the current primary color for smooth transitions
	# This would integrate with the existing color system
	pass

## Clean up resources on exit
func _exit_tree() -> void:
	"""Clean up resources to prevent RID leaks"""
	print("[UnifiedColorManager] Cleaning up resources...")
	
	# Clear color caches
	if M3DesignTokens._color_cache:
		M3DesignTokens._color_cache.clear()
	
	# Clear any cached materials or styles
	_brain_structure_color_overrides.clear()
	
	# Clear validation logs
	if UnifiedColorSystem._color_access_log:
		UnifiedColorSystem._color_access_log.clear()
	
	# Clear adaptation analytics
	_color_usage_analytics.clear()
	
	print("[UnifiedColorManager] Cleanup complete")