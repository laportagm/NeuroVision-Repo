# NeuroVision Color System Guide

## Overview

The NeuroVision color system is built on Material 3 design principles with a centralized token-based architecture. All colors in the application are managed through the `M3DesignTokens` class, ensuring consistency, maintainability, and support for theming.

## Architecture

### Core Components

1. **M3DesignTokens** (`src/ui/themes/M3DesignTokens.gd`)
   - Central source of truth for all colors
   - Provides semantic color resolution
   - Supports caching for performance
   - Handles brain structure color mappings

2. **M3ColorMigrator** (`src/ui/themes/M3ColorMigrator.gd`)
   - Utility for migrating hardcoded colors
   - Finds closest token matches
   - Generates migration code
   - Provides confidence scoring

3. **ThemeResourceGenerator** (`src/ui/themes/ThemeResourceGenerator.gd`)
   - Generates theme resources programmatically
   - Creates .tres files from tokens
   - Supports multiple theme variants

## Color Token Structure

### Base M3 Colors
```gdscript
# Primary colors
"primary": Color(0, 0.8, 0.752941)          # Cyan - main brand color
"on_primary": Color(1, 1, 1)                # White text on primary
"primary_container": Color(0, 0.243137, 0.227451)
"on_primary_container": Color(0.533333, 1, 0.988235)

# Secondary colors
"secondary": Color(0.678431, 0.827451, 0.815686)
"on_secondary": Color(0.00392157, 0.207843, 0.192157)
"secondary_container": Color(0.129412, 0.345098, 0.321569)
"on_secondary_container": Color(0.831373, 0.984314, 0.968627)

# Surface colors
"surface": Color(0.0705882, 0.0823529, 0.101961)
"on_surface": Color(0.886275, 0.890196, 0.898039)
"surface_variant": Color(0.254902, 0.270588, 0.294118)
"on_surface_variant": Color(0.745098, 0.768627, 0.796078)
```

### Brain Structure Colors
```gdscript
"hippocampus": Color(1, 0.419608, 0.419608)      # Salmon
"amygdala": Color(1, 0.709804, 0.219608)         # Gold
"thalamus": Color(0.678431, 0.419608, 1)         # Purple
"hypothalamus": Color(1, 0.549020, 0.000000)     # Orange
"cortex": Color(0.529412, 0.807843, 0.921569)    # Sky blue
"brainstem": Color(0.486275, 0.788235, 0.486275) # Sage green
"cerebellum": Color(0.941176, 0.627451, 0.627451) # Pink
"corpus_callosum": Color(0.737255, 0.560784, 0.560784) # Taupe
"basal_ganglia": Color(0.580392, 0.403922, 0.741176) # Indigo
"frontal_lobe": Color(0.000000, 0.749020, 0.647059) # Teal
"parietal_lobe": Color(0.545098, 0.000000, 0.545098) # Purple
"temporal_lobe": Color(1.000000, 0.843137, 0.000000) # Gold
"occipital_lobe": Color(0.854902, 0.439216, 0.839216) # Orchid
```

### Educational Mappings
```gdscript
"brain_structure_highlight": "primary"     # Highlighted structures
"brain_structure_normal": "surface_variant" # Non-highlighted structures
"brain_structure_hover": "secondary"       # Hovered structures
"brain_structure_selected": "tertiary"     # Selected structures
```

## Usage Guide

### Basic Color Resolution

```gdscript
# Get a standard M3 color
var primary_color = M3DesignTokens.get_color("primary")

# Get a brain structure color
var hippo_color = M3DesignTokens.get_color("hippocampus")

# Get with brain prefix (also works)
var hippo_color2 = M3DesignTokens.get_color("brain_hippocampus")
```

### Semantic Colors

```gdscript
# Button colors
var button_bg = M3DesignTokens.get_semantic_color("button_primary")
var button_text = M3DesignTokens.get_semantic_color("button_text_primary")

# Text colors
var primary_text = M3DesignTokens.get_semantic_color("text_primary")
var secondary_text = M3DesignTokens.get_semantic_color("text_secondary")

# State colors
var error_color = M3DesignTokens.get_semantic_color("state_error")
var success_color = M3DesignTokens.get_semantic_color("state_success")
```

### UI Element Colors

```gdscript
# Get colors for specific UI elements
var panel_bg = M3DesignTokens.get_ui_color("panel")
var card_bg = M3DesignTokens.get_ui_color("card")
var button_color = M3DesignTokens.get_ui_color("button", "hover")
```

### Token Validation

```gdscript
# Check if a token exists
if M3DesignTokens.has_token("my_custom_color"):
    var color = M3DesignTokens.get_color("my_custom_color")

# Get all available tokens
var all_tokens = M3DesignTokens.get_available_tokens()
```

## Migration Guide

### Migrating Hardcoded Colors

1. **Identify hardcoded colors**:
```gdscript
# Old way (avoid this)
label.modulate = Color(0, 0.8, 0.752941)
panel.self_modulate = Color.WHITE
```

2. **Use M3ColorMigrator to find matches**:
```gdscript
var old_color = Color(0, 0.8, 0.752941)
var mapping = M3ColorMigrator.find_closest_token(old_color)
print("Use token: " + mapping.token_path)
print("Confidence: " + str(mapping.confidence))
```

3. **Replace with token reference**:
```gdscript
# New way (recommended)
label.modulate = M3DesignTokens.get_color("primary")
panel.self_modulate = M3DesignTokens.get_color("on_primary")
```

### Common Migrations

| Old Color | Token Path | Usage |
|-----------|------------|-------|
| `Color.WHITE` | `"on_primary"` | Text on primary surfaces |
| `Color.BLACK` | `"shadow"` | Shadows and dark overlays |
| `Color.TRANSPARENT` | `"transparent"` | Transparent backgrounds |
| `Color.RED` | `"error"` | Error states |
| `Color.GREEN` | `"success"` | Success states |
| `Color.CYAN` | `"primary"` | Primary brand color |

## Theme Integration

### Creating Theme Resources

```gdscript
# Generate theme programmatically
var theme = ThemeResourceGenerator.generate_theme("enhanced")

# Or manually create with tokens
var button_style = StyleBoxFlat.new()
button_style.bg_color = M3DesignTokens.get_color("primary")
button_style.border_color = M3DesignTokens.get_color("outline")
```

### Theme Variants

The system supports multiple theme variants:

1. **Enhanced Theme**: Gaming-style with glassmorphism
2. **Minimal Theme**: Clean, professional appearance
3. **High Contrast**: Accessibility-focused
4. **Colorblind**: Optimized for color vision deficiencies

## Best Practices

### DO:
- ✅ Always use token references for colors
- ✅ Use semantic colors for UI elements
- ✅ Check token existence before use
- ✅ Leverage caching for performance
- ✅ Use migration tools for legacy code

### DON'T:
- ❌ Hardcode Color values directly
- ❌ Mix token and hardcoded colors
- ❌ Create custom colors without tokens
- ❌ Bypass the centralized system
- ❌ Modify token values at runtime

## Performance Considerations

The color system includes built-in optimizations:

1. **Caching**: Color lookups are cached after first access
2. **Static Methods**: No instantiation overhead
3. **Efficient Lookups**: O(1) dictionary access
4. **Lazy Loading**: Colors computed only when needed

### Cache Management

```gdscript
# Clear cache if needed (rare)
M3DesignTokens.clear_color_cache()

# Cache is automatically managed
# No manual intervention needed
```

## Extending the System

### Adding New Tokens

1. Add to `M3_COLORS` dictionary in M3DesignTokens.gd:
```gdscript
const M3_COLORS = {
    # ... existing colors ...
    "my_custom_color": Color(0.5, 0.5, 0.5),
}
```

2. Add semantic mappings if needed:
```gdscript
const SEMANTIC_COLORS = {
    # ... existing mappings ...
    "my_element_primary": "my_custom_color",
}
```

### Creating Custom Themes

1. Extend the base token set
2. Override specific tokens for variants
3. Generate theme resources
4. Apply to UI elements

## Troubleshooting

### Common Issues

1. **Color not found**: Check token name spelling and availability
2. **Wrong color applied**: Verify semantic mapping is correct
3. **Performance issues**: Clear cache if extremely large
4. **Migration confidence low**: Manual review recommended

### Debug Commands

In debug console (F1):
```
# Check color resolution
print(M3DesignTokens.get_color("primary"))

# List all tokens
print(M3DesignTokens.get_available_tokens())

# Test migration
var mapping = M3ColorMigrator.find_closest_token(Color.WHITE)
print(mapping)
```

## Unit Testing

The color system includes comprehensive unit tests:

1. **test_m3_design_tokens_unit.gd**: Tests core token resolution
2. **test_m3_color_migrator_unit.gd**: Tests migration utilities
3. **test_color_system_unit_runner.gd**: Orchestrates all tests

Run tests:
```bash
godot --headless --scene tests/unit/test_color_system_unit_runner.tscn
```

## Future Enhancements

Planned improvements:
- Dynamic theme generation from user preferences
- Color accessibility validation
- Runtime theme switching
- Custom token import/export
- Visual theme editor

---

**Version**: 1.0.0  
**Last Updated**: 2024-12-28  
**Maintainer**: NeuroVision Team