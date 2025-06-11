class_name DesignTokens
extends Resource

## Design token constants for NeuroVis UI
## Central source of truth for all design values

# === COLOR SYSTEM ===
const COLORS = {
	# Background colors
	"background": {
		"primary": Color("#0A0E17"),      # Deep dark blue
		"secondary": Color("#131922"),    # Slightly lighter
		"tertiary": Color("#1C2333"),     # Panel backgrounds
		"overlay": Color(0, 0, 0, 0.7),   # Modal overlays
		"glass": Color(1, 1, 1, 0.05)     # Glass morphism base
	},
	
	# Accent colors
	"accent": {
		"primary": Color("#00D4FF"),      # Cyan - main brand color
		"secondary": Color("#7B61FF"),    # Purple - secondary actions
		"tertiary": Color("#FF6B9D"),     # Pink - special elements
		"quaternary": Color("#00FF88")    # Green - success states
	},
	
	# Semantic colors
	"semantic": {
		"success": Color("#00FF88"),
		"warning": Color("#FFB800"),
		"error": Color("#FF3B5C"),
		"info": Color("#00D4FF")
	},
	
	# Text colors
	"text": {
		"primary": Color("#F0F6FC"),      # Main text
		"secondary": Color("#8B949E"),    # Subdued text
		"disabled": Color("#484F58"),     # Disabled state
		"inverse": Color("#0A0E17"),      # On light backgrounds
		"accent": Color("#00D4FF")        # Highlighted text
	},
	
	# Border colors
	"border": {
		"default": Color(1, 1, 1, 0.1),   # Default borders
		"hover": Color(1, 1, 1, 0.2),     # Hover state
		"focus": Color("#00D4FF"),        # Focus state
		"error": Color("#FF3B5C")         # Error state
	}
}

# === SPACING SYSTEM (4px base) ===
const SPACING = {
	"xs": 4,    # Tight spacing
	"sm": 8,    # Small elements
	"md": 16,   # Default spacing
	"lg": 24,   # Section spacing
	"xl": 32,   # Large gaps
	"xxl": 48,  # Major sections
	"xxxl": 64  # Page margins
}

# === TYPOGRAPHY ===
const TYPOGRAPHY = {
	"h1": {
		"size": 32,
		"weight": 700,
		"line_height": 1.2,
		"letter_spacing": -0.02
	},
	"h2": {
		"size": 24,
		"weight": 600,
		"line_height": 1.3,
		"letter_spacing": -0.01
	},
	"h3": {
		"size": 20,
		"weight": 600,
		"line_height": 1.4,
		"letter_spacing": 0
	},
	"body": {
		"size": 14,
		"weight": 400,
		"line_height": 1.6,
		"letter_spacing": 0
	},
	"body_large": {
		"size": 16,
		"weight": 400,
		"line_height": 1.6,
		"letter_spacing": 0
	},
	"caption": {
		"size": 12,
		"weight": 400,
		"line_height": 1.5,
		"letter_spacing": 0.01
	},
	"button": {
		"size": 14,
		"weight": 500,
		"line_height": 1,
		"letter_spacing": 0.02
	}
}

# === EFFECTS ===
const EFFECTS = {
	# Shadow definitions
	"shadow": {
		"sm": {
			"offset": Vector2(0, 2),
			"size": 4,
			"color": Color(0, 0, 0, 0.1)
		},
		"md": {
			"offset": Vector2(0, 4),
			"size": 8,
			"color": Color(0, 0, 0, 0.15)
		},
		"lg": {
			"offset": Vector2(0, 8),
			"size": 16,
			"color": Color(0, 0, 0, 0.2)
		},
		"xl": {
			"offset": Vector2(0, 16),
			"size": 32,
			"color": Color(0, 0, 0, 0.25)
		}
	},
	
	# Blur amounts
	"blur": {
		"sm": 4.0,
		"md": 8.0,
		"lg": 16.0,
		"xl": 24.0
	},
	
	# Animation durations
	"animation": {
		"instant": 0.0,
		"fast": 0.15,
		"normal": 0.3,
		"slow": 0.6,
		"very_slow": 1.0
	},
	
	# Easing curves
	"easing": {
		"ease_out": Tween.EASE_OUT,
		"ease_in_out": Tween.EASE_IN_OUT,
		"bounce": Tween.TRANS_BOUNCE,
		"elastic": Tween.TRANS_ELASTIC
	}
}

# === BORDERS ===
const BORDERS = {
	"radius": {
		"sm": 4,
		"md": 8,
		"lg": 12,
		"xl": 16,
		"pill": 999
	},
	"width": {
		"thin": 1,
		"medium": 2,
		"thick": 3
	}
}

# === Z-INDEX LAYERS ===
const Z_INDEX = {
	"background": -1,
	"content": 0,
	"elevated": 10,
	"overlay": 100,
	"modal": 200,
	"tooltip": 300,
	"notification": 400,
	"debug": 999
}

# === BREAKPOINTS ===
const BREAKPOINTS = {
	"mobile": 480,
	"tablet": 768,
	"desktop": 1024,
	"wide": 1440,
	"ultrawide": 1920
}

# === HELPER FUNCTIONS ===

static func get_spacing_string(size: String) -> int:
	"""Get spacing value by name"""
	return SPACING.get(size, SPACING.md)

static func get_color(category: String, name: String) -> Color:
	"""Get color by category and name"""
	if category in COLORS and name in COLORS[category]:
		return COLORS[category][name]
	return Color.WHITE

static func get_font_size(style: String) -> int:
	"""Get font size for typography style"""
	if style in TYPOGRAPHY:
		return TYPOGRAPHY[style]["size"]
	return TYPOGRAPHY.body["size"]

static func get_animation_duration(speed: String) -> float:
	"""Get animation duration by speed name"""
	return EFFECTS["animation"].get(speed, EFFECTS["animation"]["normal"])

static func apply_glass_effect(stylebox: StyleBoxFlat, intensity: float = 0.05) -> void:
	"""Apply glass morphism effect to a StyleBox"""
	stylebox.bg_color = Color(1, 1, 1, intensity)
	stylebox.border_color = Color(1, 1, 1, intensity * 2)
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.shadow_color = Color(0, 0, 0, 0.2)
	stylebox.shadow_size = 8
	stylebox.shadow_offset = Vector2(0, 4)