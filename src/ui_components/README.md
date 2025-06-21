# NeuroVision UI Components Library

## Overview
This directory contains reusable UI components following atomic design principles, optimized for Claude Code usage.

## Structure

### `/base/` - Base Classes
Foundation classes that all UI components inherit from:
- `BasePanel.gd` - Base for all panels with animation and theming
- `BaseButton.gd` - Base for all interactive buttons
- `BaseCard.gd` - Base for card-style containers
- `BaseModal.gd` - Base for modal dialogs

### `/atoms/` - Atomic Components
Smallest UI building blocks:
- `IconButton.gd` - Simple icon button with hover states
- `ThemedLabel.gd` - Label with automatic theme support
- `GlassCard.gd` - Card with glass morphism effect

### `/molecules/` - Molecular Components
Combinations of atoms:
- `SearchBar.gd` - Icon + Input field
- `TabBar.gd` - Tab navigation component
- `NavigationItem.gd` - Navigation drawer item

### `/organisms/` - Organism Components
Complete UI features:
- `NavigationDrawer.gd` - Full navigation sidebar
- `SettingsPanel.gd` - Complete settings interface

### `/composite/` - Composite Components
Complex components composed of multiple parts:
- `InfoPanel/` - Brain structure information panel
- `QuizPanel/` - Educational quiz interface
- `SettingsPanel/` - Application settings

## Usage Examples

### Creating a New Panel
```gdscript
extends BasePanel

func _setup_content() -> void:
    # Configure your panel
    panel_width = 400
    use_glass_effect = true
    
    # Add your content
    var label = Label.new()
    label.text = "My Custom Panel"
    add_child(label)

func _load_content(data: Dictionary) -> void:
    # Handle data loading
    pass
```

### Using the Registry
```gdscript
# In your scene
@onready var ui_registry = UIComponentRegistry.new()

func _ready():
    # Create component programmatically
    var info_panel = ui_registry.create_component("InfoPanel", self)
    info_panel.display_structure(brain_data)
    
    # Or from template
    var quiz = ui_registry.create_from_template("quiz_panel", self)
```

### Theme Integration
All components automatically:
- Connect to `UnifiedColorManager` for theme changes
- Support Enhanced/Minimal theme variants
- Apply consistent Material Design 3 styling
- Handle accessibility requirements

## Best Practices

1. **Always extend base classes** - Don't start from scratch
2. **Use the registry** - Makes components discoverable
3. **Keep components focused** - Single responsibility
4. **Document exports** - Clear configuration options
5. **Handle null gracefully** - Components should work with missing data

## Performance Considerations

- Components lazy-load their content
- Animations use Godot's tween system
- Glass effects can be disabled for performance
- Auto-hide timers prevent memory leaks

## Adding New Components

1. Choose appropriate base class
2. Create in correct directory (atoms/molecules/organisms)
3. Register in `UIComponentRegistry.gd`
4. Add usage example to this README
5. Test with both theme variants