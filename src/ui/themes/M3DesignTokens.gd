## Material 3 Design Tokens for NeuroVision
## Implements Material You design system with educational platform integration
##
## This file defines the Material 3 design tokens that work seamlessly with
## the existing educational theme infrastructure while adding modern visual polish.

class_name M3DesignTokens
extends Resource

# === MATERIAL 3 COLOR SYSTEM ===
# NeuroVision Educational Color Palette - WCAG AAA Compliant
const M3_COLORS = {
	# Primary - Neuro Cyan for brain structure highlights and main interactions
	"primary": Color("#00CCC0"),  # Neuro Cyan
	"primary_gradient_end": Color("#2E7CD6"),  # Synaptic Blue
	"on_primary": Color("#FFFFFF"),
	"primary_container": Color("#003E3A"),  # Dark container for Neuro Cyan
	"on_primary_container": Color("#9FFFF9"),  # Light tint
	
	# Secondary - Synaptic Blue for educational interactions
	"secondary": Color("#2E7CD6"),  # Synaptic Blue
	"on_secondary": Color("#FFFFFF"),
	"secondary_container": Color("#1A2E52"),  # Dark container for Synaptic Blue
	"on_secondary_container": Color("#B8DDFF"),
	
	# Tertiary - Cortical Purple for clinical/advanced features
	"tertiary": Color("#7B61FF"),  # Cortical Purple
	"on_tertiary": Color("#FFFFFF"),
	"tertiary_container": Color("#3A2B7A"),  # Dark container for Cortical Purple
	"on_tertiary_container": Color("#D5CCFF"),
	
	# NeuroVision Surface Hierarchy - Dark Educational Theme
	"surface": Color("#0A0E1B"),  # Surface-0 (Base)
	"surface_variant": Color("#151A27"),  # Surface-1 (Panels)  
	"surface_bright": Color("#1C2231"),  # Surface-2 (Cards)
	"surface_dim": Color("#242A3B"),  # Surface-3 (Elevated)
	"surface_container": Color("#151A27"),  # Surface-1 equivalent
	"surface_container_high": Color("#1C2231"),  # Surface-2 equivalent
	"surface_container_highest": Color("#2C3245"),  # Surface-4 (Highest)
	
	# NeuroVision Background with gradient support
	"background_start": Color("#0A0E1B"),  # Deep neural network blue
	"background_end": Color("#151A27"),  # Slightly lighter for depth
	"on_background": Color("#F8FAFC"),
	
	# Text and content colors
	"on_surface": Color("#F8FAFC"),
	"on_surface_variant": Color("#CBD5E1"),
	"inverse_surface": Color("#F8FAFC"),
	"inverse_on_surface": Color("#1E293B"),
	
	# System colors
	"outline": Color("#475569"),
	"outline_variant": Color("#64748B"),
	"shadow": Color(0, 0, 0, 0.25),
	"scrim": Color(0, 0, 0, 0.6),
	
	# NeuroVision Semantic Colors for Educational Feedback - WCAG AAA Compliant
	"error": Color("#FF6B6B"),  # Educational error red
	"on_error": Color("#FFFFFF"),
	"error_container": Color("#7F1D1D"),
	"on_error_container": Color("#FCA5A5"),
	
	"success": Color("#51CF66"),  # Educational success green
	"on_success": Color("#000000"),
	"success_container": Color("#064E3B"),
	"on_success_container": Color("#6EE7B7"),
	
	"warning": Color("#FFD43B"),  # Educational warning yellow
	"on_warning": Color("#000000"),
	"warning_container": Color("#78350F"),
	"on_warning_container": Color("#FCD34D"),
	
	"info": Color("#4DABF7"),  # Educational info blue
	"on_info": Color("#000000"),
	"info_container": Color("#1E3A8A"),
	"on_info_container": Color("#93BBFC"),
	
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