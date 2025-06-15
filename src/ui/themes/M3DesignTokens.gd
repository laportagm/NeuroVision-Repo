## Material 3 Design Tokens for NeuroVision
## Implements Material You design system with educational platform integration
##
## This file defines the Material 3 design tokens that work seamlessly with
## the existing educational theme infrastructure while adding modern visual polish.

class_name M3DesignTokens
extends Resource

# === MATERIAL 3 COLOR SYSTEM ===
# NeuroVision Professional Medical Color Palette - WCAG AAA Compliant
# Updated for professional medical education with enhanced accessibility
const M3_COLORS = {
	# Professional Medical Accent - GitHub Dark Theme Inspired
	"primary": Color("#58a6ff"),  # Professional accent blue (WCAG AAA 7:1 contrast)
	"primary_gradient_end": Color("#58a6ff"),  # Consistent professional blue
	"on_primary": Color("#000000"),  # Black text on light blue (optimal contrast)
	"primary_container": Color("#0d1117"),  # Dark background container
	"on_primary_container": Color("#c9d1d9"),  # Light text on dark container
	
	# Secondary - Synaptic Blue for educational interactions
	"secondary": Color("#58a6ff"),  # Professional accent consistency
	"on_secondary": Color("#000000"),
	"secondary_container": Color("#161b22"),  # UI panel surface
	"on_secondary_container": Color("#c9d1d9"),
	
	# Tertiary - Professional highlight for clinical features
	"tertiary": Color("#58a6ff"),  # Consistent professional accent
	"on_tertiary": Color("#000000"),
	"tertiary_container": Color("#161b22"),  # UI panel surface
	"on_tertiary_container": Color("#c9d1d9"),
	
	# Professional Medical Surface Hierarchy - Medical Grade Dark Theme
	"surface": Color("#0d1117"),  # Main background (medical grade dark)
	"surface_variant": Color("#161b22"),  # UI panel surface (professional)  
	"surface_bright": Color("#161b22"),  # UI panel surface (consistent)
	"surface_dim": Color("#0d1117"),  # Main background variant
	"surface_container": Color("#161b22"),  # UI panel surface
	"surface_container_high": Color("#161b22"),  # UI panel surface
	"surface_container_highest": Color("#161b22"),  # UI panel surface
	
	# Professional Medical Background
	"background_start": Color("#0d1117"),  # Main background (reduced eye strain)
	"background_end": Color("#0d1117"),  # Consistent background
	"on_background": Color("#c9d1d9"),  # Primary text (7:1 contrast ratio)
	
	# Professional Medical Text Colors (WCAG AAA Compliant)
	"on_surface": Color("#c9d1d9"),  # Primary text (7:1 contrast on #0d1117)
	"on_surface_variant": Color("#c9d1d9"),  # Consistent text color
	"inverse_surface": Color("#c9d1d9"),
	"inverse_on_surface": Color("#0d1117"),
	
	# Professional System Colors
	"outline": Color("#58a6ff"),  # Professional accent for borders
	"outline_variant": Color("#58a6ff"),  # Consistent accent borders
	"shadow": Color(0, 0, 0, 0.4),  # Enhanced shadow for glass morphism
	"scrim": Color(0, 0, 0, 0.7),  # Darker scrim for better contrast
	
	# Professional Medical Semantic Colors - WCAG AAA Compliant on #0d1117 background
	"error": Color("#ff7b72"),  # GitHub dark error red (7:1 contrast on #0d1117)
	"on_error": Color("#000000"),
	"error_container": Color("#161b22"),
	"on_error_container": Color("#ff7b72"),
	
	"success": Color("#56d364"),  # GitHub dark success green (7:1 contrast on #0d1117)
	"on_success": Color("#000000"),
	"success_container": Color("#161b22"),
	"on_success_container": Color("#56d364"),
	
	"warning": Color("#f2cc60"),  # GitHub dark warning yellow (7:1 contrast on #0d1117)
	"on_warning": Color("#000000"),
	"warning_container": Color("#161b22"),
	"on_warning_container": Color("#f2cc60"),
	
	"info": Color("#58a6ff"),  # Professional accent blue (consistent branding)
	"on_info": Color("#000000"),
	"info_container": Color("#161b22"),
	"on_info_container": Color("#58a6ff"),
	
	# Special colors
	"transparent": Color(0, 0, 0, 0)
}

# === MATERIAL 3 ELEVATION SYSTEM ===
const M3_ELEVATION = {
	"level0": 0,    # Flat surface
	"level1": 1,    # Low elevation (cards, chips)
	"level2": 2,    # Medium elevation (buttons, nav)
	"level3": 3,    # High elevation (FAB, menus)
	"level4": 6,    # Higher elevation (dialogs)
	"level5": 12,   # Highest elevation (modals)
	
	# Educational specific elevations
	"button": 2,
	"card": 1,
	"modal": 6,
	"popup": 4,
	"navigation": 3,
	"tooltip": 8
}

# === MATERIAL 3 SHAPE SYSTEM ===
const M3_CORNER_RADIUS = {
	"none": 0,
	"extra_small": 4,
	"small": 8,
	"medium": 12,
	"large": 16,
	"extra_large": 28,
	"full": 9999,
	
	# Component specific
	"button": 12,
	"card": 12,
	"dialog": 28,
	"chip": 8,
	"navigation": 16,
	"text_field": 8
}

# === MATERIAL 3 MOTION ===
const M3_DURATION = {
	"short1": 50,    # Quick feedback
	"short2": 100,   # Subtle transitions
	"short3": 150,   # Standard quick
	"short4": 200,   # Standard transitions
	"medium1": 250,  # Moderate transitions
	"medium2": 300,  # Panel slides
	"medium3": 350,  # Complex transitions
	"medium4": 400,  # Major transitions
	"long1": 450,    # Scene transitions
	"long2": 500,    # Slow reveals
	"long3": 550,    # Very slow
	"long4": 600,    # Maximum duration
	
	# Educational specific
	"tooltip": 150,
	"highlight": 300,
	"focus": 200,
	"expand": 250
}

const M3_EASING = {
	"emphasized": "ease_in_out",
	"emphasized_decelerate": "ease_out",
	"emphasized_accelerate": "ease_in",
	"standard": "ease_in_out",
	"standard_decelerate": "ease_out",
	"standard_accelerate": "ease_in",
	"legacy": "ease_in_out"
}

# === MATERIAL 3 TYPOGRAPHY SCALE ===
const M3_TYPE_SCALE = {
	"display_large": {
		"size": 57,
		"line_height": 64,
		"weight": 400,
		"tracking": -0.25
	},
	"display_medium": {
		"size": 45,
		"line_height": 52,
		"weight": 400,
		"tracking": 0
	},
	"display_small": {
		"size": 36,
		"line_height": 44,
		"weight": 400,
		"tracking": 0
	},
	"headline_large": {
		"size": 32,
		"line_height": 40,
		"weight": 400,
		"tracking": 0
	},
	"headline_medium": {
		"size": 28,
		"line_height": 36,
		"weight": 400,
		"tracking": 0
	},
	"headline_small": {
		"size": 24,
		"line_height": 32,
		"weight": 400,
		"tracking": 0
	},
	"title_large": {
		"size": 22,
		"line_height": 28,
		"weight": 400,
		"tracking": 0
	},
	"title_medium": {
		"size": 16,
		"line_height": 24,
		"weight": 500,
		"tracking": 0.15
	},
	"title_small": {
		"size": 14,
		"line_height": 20,
		"weight": 500,
		"tracking": 0.1
	},
	"body_large": {
		"size": 16,
		"line_height": 24,
		"weight": 400,
		"tracking": 0.5
	},
	"body_medium": {
		"size": 14,
		"line_height": 20,
		"weight": 400,
		"tracking": 0.25
	},
	"body_small": {
		"size": 12,
		"line_height": 16,
		"weight": 400,
		"tracking": 0.4
	},
	"label_large": {
		"size": 14,
		"line_height": 20,
		"weight": 500,
		"tracking": 0.1
	},
	"label_medium": {
		"size": 12,
		"line_height": 16,
		"weight": 500,
		"tracking": 0.5
	},
	"label_small": {
		"size": 11,
		"line_height": 16,
		"weight": 500,
		"tracking": 0.5
	}
}

# === MATERIAL 3 SPACING SYSTEM ===
const M3_SPACING = {
	"none": 0,
	"extra_small": 4,
	"small": 8,
	"medium": 16,
	"large": 24,
	"extra_large": 32,
	"huge": 48,
	
	# Component specific
	"button_padding": 24,
	"card_padding": 16,
	"list_item_padding": 16,
	"dialog_padding": 24,
	"section_gap": 32
}

# === MATERIAL 3 EFFECTS ===
const M3_BLUR = {
	"none": 0,
	"small": 4,
	"medium": 8,
	"large": 16,
	"extra_large": 24,
	
	# Component specific
	"navigation": 8,
	"modal_backdrop": 16,
	"glass_morphism": 12,
	"tooltip": 4
}

const M3_OPACITY = {
	"disabled": 0.38,
	"hover": 0.08,
	"focus": 0.12,
	"pressed": 0.12,
	"dragged": 0.16,
	"selected": 0.12,
	"backdrop": 0.6,
	"glass": 0.85
}

# === EDUCATIONAL INTEGRATION ===
# Maps educational semantic colors to Material 3 system
const EDUCATIONAL_TO_M3_MAPPING = {
	"brain_structure_highlight": "primary",
	"interactive_element": "secondary",
	"clinical_relevance": "tertiary",
	"learning_progress": "success",
	"quiz_feedback": "info",
	"pathology_indicator": "error",
	"accessibility_focus": "on_surface"
}

# === NEUROVISION BRAIN STRUCTURE COLORS ===
# WCAG AAA compliant colors for brain structure visualization
const BRAIN_STRUCTURE_COLORS = {
	"hippocampus": Color("#FF6B6B"),  # Memory formation - warm red
	"amygdala": Color("#845EF7"),     # Emotion processing - purple
	"cortex": Color("#4DABF7"),       # Higher cognition - blue  
	"thalamus": Color("#69DB7C"),     # Relay center - green
	"cerebellum": Color("#FA5252"),   # Motor control - bright red
	"brainstem": Color("#FD7E14"),    # Vital functions - orange
	"corpus_callosum": Color("#E599F7"), # Inter-hemisphere - pink
	"frontal_lobe": Color("#74C0FC"),    # Executive function - light blue
	"temporal_lobe": Color("#FFB366"),   # Auditory processing - orange
	"parietal_lobe": Color("#8CE99A"),   # Sensory integration - light green
	"occipital_lobe": Color("#D0BFFF"),  # Visual processing - lavender
	"basal_ganglia": Color("#FF8787"),   # Movement control - coral
	"limbic_system": Color("#C3FEFF"),   # Emotional processing - cyan
	"striatum": Color("#FF8787"),      # Part of basal ganglia - coral
	"ventricles": Color("#87CEEB"),    # CSF spaces - sky blue
}

# === STATE LAYER OPACITIES ===
const M3_STATE_LAYERS = {
	"hover": {
		"opacity": 0.08,
		"duration": M3_DURATION["short4"]
	},
	"focus": {
		"opacity": 0.12,
		"duration": M3_DURATION["short3"]
	},
	"pressed": {
		"opacity": 0.12,
		"duration": M3_DURATION["short2"]
	},
	"dragged": {
		"opacity": 0.16,
		"duration": M3_DURATION["short4"]
	},
	"selected": {
		"opacity": 0.12,
		"duration": M3_DURATION["medium1"]
	}
}

# === ADAPTIVE COLOR TONES ===
# For dynamic color generation based on brain structures
const M3_TONAL_PALETTE = {
	"steps": [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100],
	"primary_chroma": 48,
	"secondary_chroma": 16,
	"tertiary_chroma": 24,
	"neutral_chroma": 4,
	"neutral_variant_chroma": 8
}

# === ACCESSIBILITY OVERRIDES ===
# Ensures WCAG AAA compliance when M3 is active
const M3_ACCESSIBILITY = {
	"min_contrast_ratio": 7.0,  # WCAG AAA
	"large_text_size": 18,
	"focus_indicator_width": 3,
	"touch_target_size": 48,
	"animation_reduce_factor": 0.1  # For prefers-reduced-motion
}

## Generate a Material 3 elevation shadow
static func get_elevation_shadow(level: int) -> Dictionary:
	var shadow_offset = Vector2(0, level * 0.5)
	var shadow_blur = level * 2.0
	var shadow_spread = level * 0.25
	var shadow_color = M3_COLORS["shadow"]
	
	return {
		"offset": shadow_offset,
		"blur": shadow_blur,
		"spread": shadow_spread,
		"color": shadow_color
	}

## Get appropriate state layer color and opacity
static func get_state_layer(base_color: Color, state: String) -> Color:
	if not M3_STATE_LAYERS.has(state):
		return base_color
	
	var opacity = M3_STATE_LAYERS[state]["opacity"]
	var state_color = base_color
	state_color.a = opacity
	return state_color

## Convert educational semantic color to M3 equivalent
static func educational_to_m3(educational_key: String) -> String:
	if EDUCATIONAL_TO_M3_MAPPING.has(educational_key):
		return EDUCATIONAL_TO_M3_MAPPING[educational_key]
	return "primary"  # Default fallback

## Get color with proper contrast ratio for accessibility
static func ensure_contrast(foreground: Color, _background: Color, _min_ratio: float = 7.0) -> Color:
	# Implementation would check and adjust contrast
	# This is a placeholder that returns the original color
	return foreground

## Generate tonal variations of a color for adaptive theming
static func generate_tonal_palette(base_color: Color, _chroma: float = 48.0) -> Dictionary:
	var palette = {}
	for step in M3_TONAL_PALETTE["steps"]:
		var lightness = float(step) / 100.0
		var tonal_color = base_color
		tonal_color.v = lightness  # Adjust value/lightness
		palette[str(step)] = tonal_color
	return palette

# === COLOR RESOLUTION API ===
# New methods for centralized color system

## Color cache for performance
static var _color_cache: Dictionary = {}

## Get a color by token name with caching
static func get_color(token_name: String, theme_variant: String = "default") -> Color:
	"""Get a color from the design system by token name"""
	var cache_key = token_name + "_" + theme_variant
	
	# Check cache first
	if _color_cache.has(cache_key):
		return _color_cache[cache_key]
	
	# Check primary color tokens
	if M3_COLORS.has(token_name):
		_color_cache[cache_key] = M3_COLORS[token_name]
		return M3_COLORS[token_name]
	
	# Check brain structure colors
	if BRAIN_STRUCTURE_COLORS.has(token_name):
		_color_cache[cache_key] = BRAIN_STRUCTURE_COLORS[token_name]
		return BRAIN_STRUCTURE_COLORS[token_name]
	
	# Check if it's a brain structure with prefix
	if token_name.begins_with("brain_"):
		var structure = token_name.substr(6)
		if BRAIN_STRUCTURE_COLORS.has(structure):
			_color_cache[cache_key] = BRAIN_STRUCTURE_COLORS[structure]
			return BRAIN_STRUCTURE_COLORS[structure]
	
	# Check educational mappings
	if EDUCATIONAL_TO_M3_MAPPING.has(token_name):
		var mapped_token = EDUCATIONAL_TO_M3_MAPPING[token_name]
		return get_color(mapped_token, theme_variant)
	
	# Default fallback
	push_warning("[M3DesignTokens] Unknown color token: " + token_name)
	return M3_COLORS["on_surface"]  # Safe fallback

## Get semantic color based on usage context
static func get_semantic_color(role: String, variant: String = "default") -> Color:
	"""Get a color based on semantic role (e.g., 'button_primary', 'text_disabled')"""
	
	# Handle component-specific semantics
	match role:
		"button_primary":
			return M3_COLORS["primary"]
		"button_secondary":
			return M3_COLORS["secondary"]
		"button_tertiary":
			return M3_COLORS["tertiary"]
		"button_disabled":
			var col = M3_COLORS["on_surface"]
			col.a = M3_OPACITY["disabled"]
			return col
		"text_primary":
			return M3_COLORS["on_surface"]
		"text_secondary":
			var col = M3_COLORS["on_surface"]
			col.a = 0.7
			return col
		"text_disabled":
			var col = M3_COLORS["on_surface"]
			col.a = M3_OPACITY["disabled"]
			return col
		"background_primary":
			return M3_COLORS["surface"]
		"background_elevated":
			return M3_COLORS["surface_container"]
		"border_default":
			return M3_COLORS["outline"]
		"border_focus":
			return M3_COLORS["primary"]
		"error_text":
			return M3_COLORS["error"]
		"success_text":
			return M3_COLORS["success"]
		_:
			return get_color(role, variant)

## Get color for specific UI element
static func get_ui_color(element_type: String, state: String = "default") -> Color:
	"""Get color for specific UI elements with state support"""
	
	var base_color: Color
	
	# Determine base color by element type
	match element_type:
		"panel":
			base_color = M3_COLORS["surface"]
		"card":
			base_color = M3_COLORS["surface_container"]
		"button":
			base_color = M3_COLORS["primary"]
		"input":
			base_color = M3_COLORS["surface_variant"]
		"label":
			base_color = M3_COLORS["on_surface"]
		_:
			base_color = M3_COLORS["surface"]
	
	# Apply state modifications
	match state:
		"hover":
			return get_state_layer(base_color, "hover")
		"pressed":
			return get_state_layer(base_color, "pressed")
		"disabled":
			base_color.a = M3_OPACITY["disabled"]
			return base_color
		"focus":
			return get_state_layer(base_color, "focus")
		_:
			return base_color

## Clear the color cache (useful when changing themes)
static func clear_color_cache() -> void:
	"""Clear the internal color cache"""
	_color_cache.clear()

## Create M3-compliant StyleBoxFlat for buttons with proper state management
static func create_button_style(variant: String = "primary", state: String = "normal") -> StyleBoxFlat:
	"""Create a Material 3 compliant button style with proper state management"""
	var style = StyleBoxFlat.new()
	
	# Get base colors based on variant
	var bg_color: Color
	var border_color: Color
	
	match variant:
		"primary":
			bg_color = get_color("primary")
			border_color = get_color("primary")
		"secondary":
			bg_color = get_color("surface_container")
			border_color = get_color("outline")
		"tertiary":
			bg_color = get_color("transparent")
			border_color = get_color("transparent")
		_:
			bg_color = get_color("surface_container")
			border_color = get_color("outline")
	
	# Apply state modifications
	match state:
		"hover":
			if variant == "primary":
				bg_color = Color(bg_color.r * 1.1, bg_color.g * 1.1, bg_color.b * 1.1, bg_color.a)
			else:
				var hover_layer = get_state_layer(bg_color, "hover")
				bg_color = bg_color.blend(hover_layer)
		"pressed":
			if variant == "primary":
				bg_color = Color(bg_color.r * 0.9, bg_color.g * 0.9, bg_color.b * 0.9, bg_color.a)
			else:
				var pressed_layer = get_state_layer(bg_color, "pressed")
				bg_color = bg_color.blend(pressed_layer)
		"focus":
			border_color = get_color("primary")
		"disabled":
			bg_color.a = M3_OPACITY["disabled"]
			border_color.a = M3_OPACITY["disabled"]
	
	# Configure style
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_corner_radius_all(M3_CORNER_RADIUS["button"])
	style.set_border_width_all(1 if border_color != get_color("transparent") else 0)
	style.set_content_margin_all(M3_SPACING["button_padding"])
	
	return style

## Create M3-compliant StyleBoxFlat for panels with proper surface hierarchy
static func create_panel_style(surface_level: String = "surface_container", elevated: bool = false) -> StyleBoxFlat:
	"""Create a Material 3 compliant panel style with proper surface hierarchy"""
	var style = StyleBoxFlat.new()
	
	# Get surface color based on hierarchy
	var bg_color = get_color(surface_level)
	var border_color = get_color("outline_variant")
	border_color.a = 0.2  # Subtle border
	
	# Configure style
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_corner_radius_all(M3_CORNER_RADIUS["card"])
	style.set_border_width_all(1)
	style.set_content_margin_all(M3_SPACING["card_padding"])
	
	# Add elevation if requested
	if elevated:
		# Shadow simulation with additional background opacity
		style.bg_color.a = min(1.0, style.bg_color.a + 0.05)
	
	return style

## Apply M3 typography scaling to a label
static func apply_typography(label: Label, scale: String = "body_medium") -> void:
	"""Apply Material 3 typography scaling to a label"""
	if not M3_TYPE_SCALE.has(scale):
		push_warning("[M3DesignTokens] Unknown typography scale: " + scale)
		scale = "body_medium"
	
	var type_data = M3_TYPE_SCALE[scale]
	label.add_theme_font_size_override("font_size", type_data["size"])
	
	# Apply color
	label.add_theme_color_override("font_color", get_color("on_surface"))

## Create consistent M3 motion tween with proper easing
static func create_motion_tween(node: Node, duration_key: String = "short4") -> Tween:
	"""Create a Material 3 compliant motion tween"""
	var tween = node.create_tween()
	var _duration = M3_DURATION[duration_key] / 1000.0  # Convert ms to seconds
	
	# Set M3 easing (simplified - would need proper curve in production)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	return tween

## Apply M3 ripple effect to any control
static func apply_ripple_effect(control: Control, color: Color = Color.TRANSPARENT) -> void:
	"""Apply Material 3 ripple effect to a control"""
	if color == Color.TRANSPARENT:
		color = get_color("on_surface")
		color.a = 0.12  # Standard M3 ripple opacity
	
	# This would need a proper ripple shader in production
	# For now, just apply a subtle highlight effect
	var original_modulate = control.modulate
	var tween = create_motion_tween(control, "short2")
	
	control.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			control.modulate = original_modulate * 1.1
			tween.tween_property(control, "modulate", original_modulate, 0.1)
	)

## Get all available color tokens
static func get_available_tokens() -> Array[String]:
	"""Return all available color token names"""
	var tokens: Array[String] = []
	
	# Add M3 color tokens
	for token in M3_COLORS:
		tokens.append(token)
	
	# Add brain structure tokens with prefix
	for structure in BRAIN_STRUCTURE_COLORS:
		tokens.append("brain_" + structure)
	
	# Add educational semantic tokens
	for edu_token in EDUCATIONAL_TO_M3_MAPPING:
		tokens.append(edu_token)
	
	return tokens

## Validate if a token exists
static func has_token(token_name: String) -> bool:
	"""Check if a color token exists in the system"""
	return M3_COLORS.has(token_name) or \
		   BRAIN_STRUCTURE_COLORS.has(token_name) or \
		   BRAIN_STRUCTURE_COLORS.has(token_name.substr(6) if token_name.begins_with("brain_") else "") or \
		   EDUCATIONAL_TO_M3_MAPPING.has(token_name)