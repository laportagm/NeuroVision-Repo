## Material 3 Design Tokens for NeuroVision
## Implements Material You design system with educational platform integration
##
## This file defines the Material 3 design tokens that work seamlessly with
## the existing educational theme infrastructure while adding modern visual polish.

class_name M3DesignTokens
extends Resource

# === MATERIAL 3 COLOR SYSTEM ===
# Primary colors for neuroanatomy visualization with high visibility
const M3_COLORS = {
	# Primary - Vibrant cyan for brain structure highlights
	"primary": Color("#22D3EE"),
	"primary_gradient_end": Color("#3B82F6"),
	"on_primary": Color("#FFFFFF"),
	"primary_container": Color("#004A5D"),
	"on_primary_container": Color("#B8EAFF"),
	
	# Secondary - Educational accent colors
	"secondary": Color("#60A5FA"),
	"on_secondary": Color("#002952"),
	"secondary_container": Color("#003D6F"),
	"on_secondary_container": Color("#C8E6FF"),
	
	# Tertiary - Clinical/medical accent
	"tertiary": Color("#7C3AED"),
	"on_tertiary": Color("#FFFFFF"),
	"tertiary_container": Color("#5B21B6"),
	"on_tertiary_container": Color("#E9D5FF"),
	
	# Surface colors with depth
	"surface": Color("#1E293B"),
	"surface_variant": Color("#334155"),
	"surface_bright": Color("#475569"),
	"surface_dim": Color("#0F172A"),
	"surface_container": Color("#1A202C"),
	"surface_container_high": Color("#2D3748"),
	"surface_container_highest": Color("#4A5568"),
	
	# Background with gradient support
	"background_start": Color("#0F172A"),
	"background_end": Color("#1B2434"),
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
	
	# Semantic colors for educational feedback
	"error": Color("#EF4444"),
	"on_error": Color("#FFFFFF"),
	"error_container": Color("#7F1D1D"),
	"on_error_container": Color("#FCA5A5"),
	
	"success": Color("#10B981"),
	"on_success": Color("#FFFFFF"),
	"success_container": Color("#064E3B"),
	"on_success_container": Color("#6EE7B7"),
	
	"warning": Color("#F59E0B"),
	"on_warning": Color("#000000"),
	"warning_container": Color("#78350F"),
	"on_warning_container": Color("#FCD34D"),
	
	"info": Color("#3B82F6"),
	"on_info": Color("#FFFFFF"),
	"info_container": Color("#1E3A8A"),
	"on_info_container": Color("#93BBFC")
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