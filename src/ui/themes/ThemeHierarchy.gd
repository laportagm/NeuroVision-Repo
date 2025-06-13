class_name ThemeHierarchy
extends Resource

## Theme Hierarchy System for NeuroVision
## Implements inheritance-based theme organization for educational contexts

# Preload dependencies
const EducationalThemeGenerator = preload("res://src/ui/themes/EducationalThemeGenerator.gd")
const ColorSystem = preload("res://src/ui/themes/EducationalColorSystem.gd")
const DesignTokens = preload("res://src/ui/themes/DesignTokens.gd")

# === BASE EDUCATIONAL THEME CLASS ===

class BaseEducationalTheme:
	extends Resource
	
	# Core properties
	var theme_name: String = "BaseEducational"
	var theme_description: String = "Base theme for all educational themes"
	var base_variant: EducationalThemeGenerator.ThemeVariant = EducationalThemeGenerator.ThemeVariant.DARK
	var learning_level: int = 1  # Default to intermediate
	
	# Theme customization properties
	var primary_color: Color = Color.CYAN
	var secondary_color: Color = Color.BLUE
	var accent_color: Color = Color.PURPLE
	var background_tint: Color = Color(1, 1, 1, 0.05)
	
	# Visual properties
	var enable_glass_morphism: bool = true
	var glass_intensity: float = 0.5
	var enable_animations: bool = true
	var animation_speed: float = 1.0
	var enable_shadows: bool = true
	var shadow_intensity: float = 1.0
	
	# Accessibility properties
	var high_contrast_mode: bool = false
	var color_blind_safe: bool = false
	var reduced_motion: bool = false
	var font_size_multiplier: float = 1.0
	
	# Generated theme cache
	var _generated_theme: Theme = null
	var _theme_dirty: bool = true
	
	## Generate the theme based on current settings
	func generate() -> Theme:
		"""Generate theme with current configuration"""
		if not _theme_dirty and _generated_theme:
			return _generated_theme
		
		# Generate base theme
		_generated_theme = EducationalThemeGenerator.generate_educational_theme(base_variant, learning_level)
		
		# Apply customizations
		_apply_customizations(_generated_theme)
		
		# Apply glass morphism if enabled
		if enable_glass_morphism:
			_generated_theme = EducationalThemeGenerator.generate_glass_morphism_theme(
				base_variant, learning_level, glass_intensity
			)
		
		# Add metadata
		_add_theme_metadata(_generated_theme)
		
		_theme_dirty = false
		return _generated_theme
	
	## Customize theme with modifications
	func customize(modifications: Dictionary) -> void:
		"""Apply modifications to theme configuration"""
		for key in modifications:
			if key in self:
				set(key, modifications[key])
				_theme_dirty = true
		
		# Regenerate if needed
		if _theme_dirty:
			generate()
	
	## Apply customizations to generated theme
	func _apply_customizations(theme: Theme) -> void:
		"""Apply custom colors and properties to theme"""
		
		# Apply primary color to main interactive elements
		var button_normal = theme.get_stylebox("normal", "Button") as StyleBoxFlat
		if button_normal:
			button_normal.bg_color = primary_color
			theme.set_stylebox("normal", "Button", button_normal)
		
		# Apply secondary color to secondary elements
		theme.set_color("font_hover_color", "Button", secondary_color)
		
		# Apply accent color to focus states
		theme.set_color("font_focus_color", "Button", accent_color)
		theme.set_color("selection_color", "LineEdit", accent_color)
		
		# Apply accessibility settings
		if high_contrast_mode:
			_apply_high_contrast(theme)
		
		if reduced_motion:
			_apply_reduced_motion(theme)
		
		# Apply shadow settings
		if not enable_shadows:
			_remove_all_shadows(theme)
		elif shadow_intensity != 1.0:
			_adjust_shadow_intensity(theme, shadow_intensity)
	
	## Apply high contrast modifications
	func _apply_high_contrast(theme: Theme) -> void:
		"""Enhance contrast for accessibility"""
		# Use pure white/black for maximum contrast
		theme.set_color("font_color", "Label", Color.WHITE)
		theme.set_color("font_color", "Button", Color.BLACK)
		
		# Increase border visibility
		var panel = theme.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
		if panel:
			panel.border_width_left = 3
			panel.border_width_top = 3
			panel.border_width_right = 3
			panel.border_width_bottom = 3
			panel.border_color = Color.WHITE
	
	## Apply reduced motion settings
	func _apply_reduced_motion(theme: Theme) -> void:
		"""Disable animations for accessibility"""
		theme.set_meta("animations_enabled", false)
		theme.set_meta("transition_duration", 0.0)
	
	## Remove shadows from theme
	func _remove_all_shadows(theme: Theme) -> void:
		"""Remove all shadows for performance"""
		var types = ["PanelContainer", "Button", "LineEdit"]
		var styleboxes = ["panel", "normal", "hover", "pressed", "focus"]
		
		for type in types:
			for stylebox_name in styleboxes:
				if theme.has_stylebox(stylebox_name, type):
					var stylebox = theme.get_stylebox(stylebox_name, type) as StyleBoxFlat
					if stylebox:
						stylebox.shadow_size = 0
						stylebox.shadow_color.a = 0
	
	## Adjust shadow intensity
	func _adjust_shadow_intensity(theme: Theme, intensity: float) -> void:
		"""Adjust shadow intensity throughout theme"""
		var types = ["PanelContainer", "Button", "LineEdit"]
		var styleboxes = ["panel", "normal", "hover", "pressed", "focus"]
		
		for type in types:
			for stylebox_name in styleboxes:
				if theme.has_stylebox(stylebox_name, type):
					var stylebox = theme.get_stylebox(stylebox_name, type) as StyleBoxFlat
					if stylebox and stylebox.shadow_size > 0:
						stylebox.shadow_color.a *= intensity
	
	## Add metadata to generated theme
	func _add_theme_metadata(theme: Theme) -> void:
		"""Add identifying metadata to theme"""
		theme.set_meta("theme_class", theme_name)
		theme.set_meta("theme_description", theme_description)
		theme.set_meta("learning_level", learning_level)
		theme.set_meta("accessibility_features", {
			"high_contrast": high_contrast_mode,
			"color_blind_safe": color_blind_safe,
			"reduced_motion": reduced_motion
		})
		theme.set_meta("generation_time", Time.get_unix_time_from_system())

# === STRUCTURAL THEME CLASS ===

class StructuralTheme:
	extends BaseEducationalTheme
	
	func _init():
		theme_name = "StructuralTheme"
		theme_description = "Theme optimized for anatomical structure exploration"
		primary_color = Color("#42A5F5")  # Blue for structure
		secondary_color = Color("#66BB6A")  # Green for connections
		accent_color = Color("#AB47BC")    # Purple for highlights
		glass_intensity = 0.3  # Subtle glass for clarity
		
	func _apply_customizations(theme: Theme) -> void:
		super._apply_customizations(theme)
		
		# Enhanced borders for structure delineation
		var panel = theme.get_stylebox("panel", "StructureInfoPanel") as StyleBoxFlat
		if panel:
			panel.border_width_left = 2
			panel.border_width_top = 2
			panel.border_width_right = 2
			panel.border_width_bottom = 2
			panel.border_color = primary_color
			panel.corner_radius_top_left = 8
			panel.corner_radius_top_right = 8
			panel.corner_radius_bottom_left = 8
			panel.corner_radius_bottom_right = 8
		
		# Special highlighting for selected structures
		theme.set_color("selection_color", "RichTextLabel", primary_color)
		theme.set_color("font_selected_color", "RichTextLabel", Color.WHITE)

# === FUNCTIONAL THEME CLASS ===

class FunctionalTheme:
	extends BaseEducationalTheme
	
	func _init():
		theme_name = "FunctionalTheme"
		theme_description = "Theme optimized for neural function and pathway visualization"
		primary_color = Color("#FF9800")   # Orange for function
		secondary_color = Color("#FFB74D")  # Light orange for pathways
		accent_color = Color("#FF5722")     # Deep orange for active states
		glass_intensity = 0.6  # More glass for dynamic feel
		enable_animations = true
		animation_speed = 1.2
		
	func _apply_customizations(theme: Theme) -> void:
		super._apply_customizations(theme)
		
		# Dynamic visual elements for functions
		var function_panel = theme.get_stylebox("panel", "FunctionPanel") as StyleBoxFlat
		if function_panel:
			# Gradient-like effect using glass
			function_panel.bg_color = primary_color.lightened(0.8)
			function_panel.border_color = primary_color
			function_panel.shadow_color = primary_color
			function_panel.shadow_size = 12
			
		# Animated hover states
		theme.set_meta("hover_scale", 1.05)
		theme.set_meta("hover_transition_speed", 0.2)

# === CLINICAL THEME CLASS ===

class ClinicalTheme:
	extends BaseEducationalTheme
	
	func _init():
		theme_name = "ClinicalTheme"
		theme_description = "Professional theme for clinical and medical contexts"
		base_variant = EducationalThemeGenerator.ThemeVariant.LIGHT  # Light for clinical clarity
		primary_color = Color("#1565C0")    # Professional blue
		secondary_color = Color("#0277BD")   # Medical blue
		accent_color = Color("#C62828")      # Red for pathology
		glass_intensity = 0.1  # Minimal glass for professionalism
		enable_animations = false  # No distractions
		high_contrast_mode = true  # Enhanced readability
		
	func _apply_customizations(theme: Theme) -> void:
		super._apply_customizations(theme)
		
		# Clean, professional styling
		var clinical_panel = theme.get_stylebox("panel", "ClinicalPanel") as StyleBoxFlat
		if clinical_panel:
			clinical_panel.bg_color = Color.WHITE
			clinical_panel.border_color = Color("#E0E0E0")
			clinical_panel.border_width_left = 1
			clinical_panel.border_width_top = 1
			clinical_panel.border_width_right = 1
			clinical_panel.border_width_bottom = 1
			clinical_panel.shadow_size = 2
			clinical_panel.corner_radius_top_left = 4
			clinical_panel.corner_radius_top_right = 4
			clinical_panel.corner_radius_bottom_left = 4
			clinical_panel.corner_radius_bottom_right = 4
		
		# High contrast text
		theme.set_color("font_color", "Label", Color("#212121"))
		theme.set_color("font_color", "RichTextLabel", Color("#212121"))
		
		# Pathology highlighting
		theme.set_color("font_color_error", "Label", accent_color)

# === ASSESSMENT THEME CLASS ===

class AssessmentTheme:
	extends BaseEducationalTheme
	
	func _init():
		theme_name = "AssessmentTheme"
		theme_description = "Theme optimized for quizzes and learning assessments"
		primary_color = Color("#4CAF50")    # Green for correct
		secondary_color = Color("#2196F3")   # Blue for information
		accent_color = Color("#F44336")      # Red for incorrect
		glass_intensity = 0.7  # High glass for engaging feel
		enable_animations = true
		animation_speed = 1.5  # Faster animations for feedback
		
	func _apply_customizations(theme: Theme) -> void:
		super._apply_customizations(theme)
		
		# Quiz panel styling
		var quiz_panel = theme.get_stylebox("panel", "QuizPanel") as StyleBoxFlat
		if quiz_panel:
			quiz_panel.bg_color = Color("#F5F5F5")
			quiz_panel.border_width_left = 3
			quiz_panel.border_width_top = 3
			quiz_panel.border_width_right = 3
			quiz_panel.border_width_bottom = 3
			quiz_panel.corner_radius_top_left = 12
			quiz_panel.corner_radius_top_right = 12
			quiz_panel.corner_radius_bottom_left = 12
			quiz_panel.corner_radius_bottom_right = 12
		
		# Feedback colors
		theme.set_color("font_color_success", "Label", primary_color)
		theme.set_color("font_color_error", "Label", accent_color)
		theme.set_color("font_color_warning", "Label", Color("#FF9800"))
		
		# Interactive button states
		var button_hover = theme.get_stylebox("hover", "Button") as StyleBoxFlat
		if button_hover:
			button_hover.bg_color = secondary_color
			button_hover.border_color = secondary_color.darkened(0.2)
			
		# Success/error feedback panels
		_create_feedback_panels(theme)
	
	func _create_feedback_panels(theme: Theme) -> void:
		"""Create specialized panels for assessment feedback"""
		
		# Success panel
		var success_panel = StyleBoxFlat.new()
		success_panel.bg_color = primary_color.lightened(0.9)
		success_panel.border_color = primary_color
		success_panel.border_width_left = 3
		success_panel.corner_radius_top_left = 8
		success_panel.corner_radius_top_right = 8
		success_panel.corner_radius_bottom_left = 8
		success_panel.corner_radius_bottom_right = 8
		theme.set_stylebox("panel", "SuccessPanel", success_panel)
		
		# Error panel
		var error_panel = StyleBoxFlat.new()
		error_panel.bg_color = accent_color.lightened(0.9)
		error_panel.border_color = accent_color
		error_panel.border_width_left = 3
		error_panel.corner_radius_top_left = 8
		error_panel.corner_radius_top_right = 8
		error_panel.corner_radius_bottom_left = 8
		error_panel.corner_radius_bottom_right = 8
		theme.set_stylebox("panel", "ErrorPanel", error_panel)

# === THEME FACTORY ===

## Create theme instance by type
static func create_theme(theme_type: String, learning_level: int = 1) -> BaseEducationalTheme:
	"""Factory method to create theme instances"""
	var theme_instance: BaseEducationalTheme
	
	match theme_type.to_lower():
		"structural":
			theme_instance = StructuralTheme.new()
		"functional":
			theme_instance = FunctionalTheme.new()
		"clinical":
			theme_instance = ClinicalTheme.new()
		"assessment":
			theme_instance = AssessmentTheme.new()
		_:
			theme_instance = BaseEducationalTheme.new()
	
	theme_instance.learning_level = learning_level
	return theme_instance

## Get all available theme types
static func get_available_themes() -> Array[String]:
	"""Return list of available theme types"""
	return ["base", "structural", "functional", "clinical", "assessment"]

## Get theme description
static func get_theme_description(theme_type: String) -> String:
	"""Get description for theme type"""
	match theme_type.to_lower():
		"base":
			return "Base educational theme with standard styling"
		"structural":
			return "Optimized for anatomical structure exploration"
		"functional":
			return "Enhanced for neural function and pathway visualization"
		"clinical":
			return "Professional theme for medical and clinical contexts"
		"assessment":
			return "Engaging theme for quizzes and learning assessments"
		_:
			return "Unknown theme type"

## Create composite theme combining multiple theme aspects
static func create_composite_theme(primary_type: String, secondary_type: String, blend_ratio: float = 0.5) -> Theme:
	"""Create a theme that blends characteristics of two theme types"""
	
	var primary_theme = create_theme(primary_type)
	var secondary_theme = create_theme(secondary_type)
	
	var primary_generated = primary_theme.generate()
	var secondary_generated = secondary_theme.generate()
	
	# Create new theme as base
	var composite = primary_generated.duplicate(true)
	
	# Blend colors
	var primary_color = primary_theme.primary_color.lerp(secondary_theme.primary_color, blend_ratio)
	var secondary_color = primary_theme.secondary_color.lerp(secondary_theme.secondary_color, blend_ratio)
	var accent_color = primary_theme.accent_color.lerp(secondary_theme.accent_color, blend_ratio)
	
	# Apply blended colors
	var modifications = {
		"primary_color": primary_color,
		"secondary_color": secondary_color,
		"accent_color": accent_color,
		"glass_intensity": lerp(primary_theme.glass_intensity, secondary_theme.glass_intensity, blend_ratio)
	}
	
	var composite_theme = BaseEducationalTheme.new()
	composite_theme.customize(modifications)
	
	return composite_theme.generate()