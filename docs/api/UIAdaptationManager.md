# UIAdaptationManager API Documentation

## Overview

The UIAdaptationManager is a foundational autoload service that manages UI adaptation for different devices, learning levels, and accessibility needs. It complements the existing UIThemeManager by handling layout modes and educational content hierarchy.

## Core Functionality

### Layout Mode Management
- **COMPACT**: Mobile/tablet optimized with overlay panels
- **STANDARD**: Desktop layout with docked sidebars
- **PRESENTATION**: Teaching mode with minimal UI
- **MULTI_MONITOR**: Distributed interface across multiple displays

### Learning Level Adaptation
- **BEGINNER**: Essential concepts with simplified explanations
- **INTERMEDIATE**: Standard educational content with clinical context
- **ADVANCED**: Comprehensive information including research details

### Content Hierarchy System
Automatically filters and prioritizes educational content based on user's learning level, ensuring appropriate information density and complexity.

## Public API

### Enums

```gdscript
enum LayoutMode {
    COMPACT,        # Mobile/tablet optimized layout
    STANDARD,       # Desktop layout with docked sidebars
    PRESENTATION,   # Teaching mode with minimal UI
    MULTI_MONITOR   # Multi-screen distributed interface
}

enum LearningLevel {
    BEGINNER,       # Basic concepts and simplified information
    INTERMEDIATE,   # Standard educational content with details
    ADVANCED        # Complete information including research details
}
```

### Signals

```gdscript
signal layout_mode_changed(mode: LayoutMode)
signal learning_level_changed(level: LearningLevel)
signal content_hierarchy_updated(hierarchy: Dictionary)
signal ui_adaptation_applied(adaptation_data: Dictionary)
```

### Core Methods

#### Layout Mode Management

```gdscript
func set_layout_mode(mode: LayoutMode, force: bool = false) -> void
```
Sets the current layout mode. Will automatically validate if the mode is supported for the current configuration.

```gdscript
func get_layout_mode() -> LayoutMode
```
Returns the current layout mode.

```gdscript
func get_layout_configuration() -> Dictionary
```
Returns the configuration settings for the current layout mode, including panel sizes and positions.

#### Learning Level Management

```gdscript
func set_learning_level(level: LearningLevel) -> void
```
Sets the current learning level and updates content hierarchy accordingly.

```gdscript
func get_learning_level() -> LearningLevel
```
Returns the current learning level.

```gdscript
func get_content_hierarchy() -> Dictionary
```
Returns the content hierarchy configuration for the current learning level.

#### Content Filtering

```gdscript
func should_show_content(content_type: String) -> bool
```
Determines if a specific content type should be displayed based on the current learning level.

```gdscript
func get_content_priority(content_type: String) -> int
```
Returns the display priority for a content type (lower numbers = higher priority).

#### Screen Adaptation

```gdscript
func adapt_to_screen_size(size: Vector2) -> void
```
Manually triggers adaptation to a specific screen size.

```gdscript
func enable_auto_adaptation(enabled: bool) -> void
```
Enables or disables automatic layout adaptation based on screen size changes.

```gdscript
func get_recommended_layout_mode() -> LayoutMode
```
Returns the recommended layout mode for the current screen configuration.

#### Utility Methods

```gdscript
func get_layout_mode_display_name(mode: LayoutMode) -> String
func get_learning_level_display_name(level: LearningLevel) -> String
func get_layout_mode_description(mode: LayoutMode) -> String
func get_learning_level_description(level: LearningLevel) -> String
func get_adaptation_status() -> Dictionary
```

## Integration with Existing Systems

### SettingsManager Integration
The UIAdaptationManager automatically integrates with SettingsManager for persistence:
- `ui_layout_mode`: Saves current layout mode preference
- `ui_learning_level`: Saves current learning level preference  
- `ui_auto_adapt`: Saves auto-adaptation enabled state

### AccessibilityManager Integration
When accessibility features are enabled:
- Automatically switches from COMPACT to STANDARD layout for better accessibility
- Respects reduce-motion preferences
- Integrates with high-contrast mode

### UIThemeManager Integration
Works alongside UIThemeManager without conflicts:
- UIThemeManager handles visual themes (dark, high_contrast, colorblind)
- UIAdaptationManager handles layout structure and content hierarchy
- Both systems can be used simultaneously

## Configuration Constants

### Screen Breakpoints
```gdscript
const SCREEN_BREAKPOINTS = {
    "mobile": 768,
    "tablet": 1024,
    "desktop": 1440,
    "ultrawide": 1920
}
```

### Layout Configurations
Each layout mode has specific configuration parameters:

#### COMPACT Mode
```gdscript
{
    "sidebar_width": 280,
    "info_panel_width": 350,
    "info_panel_position": "overlay",
    "quiz_panel_position": "fullscreen",
    "minimize_chrome": true
}
```

#### STANDARD Mode
```gdscript
{
    "sidebar_width": 320,
    "info_panel_width": 450,
    "info_panel_position": "docked_right",
    "quiz_panel_position": "modal",
    "minimize_chrome": false
}
```

#### PRESENTATION Mode
```gdscript
{
    "sidebar_width": 0,
    "info_panel_width": 600,
    "info_panel_position": "overlay_center",
    "quiz_panel_position": "hidden",
    "minimize_chrome": true,
    "annotations_enabled": true
}
```

#### MULTI_MONITOR Mode
```gdscript
{
    "sidebar_width": 400,
    "info_panel_width": 500,
    "info_panel_position": "secondary_screen",
    "quiz_panel_position": "secondary_screen",
    "minimize_chrome": false
}
```

### Content Hierarchy Definitions

#### BEGINNER Level
```gdscript
{
    "primary": ["structure_name", "primary_function", "key_facts"],
    "secondary": ["basic_description", "simple_diagram"],
    "hidden": ["technical_details", "research_notes", "advanced_pathology"],
    "max_info_items": 5
}
```

#### INTERMEDIATE Level
```gdscript
{
    "primary": ["structure_name", "primary_function", "clinical_relevance"],
    "secondary": ["detailed_description", "anatomical_relations", "common_pathology"],
    "tertiary": ["development", "variations"],
    "hidden": ["molecular_details", "advanced_research"],
    "max_info_items": 10
}
```

#### ADVANCED Level
```gdscript
{
    "primary": ["structure_name", "comprehensive_function", "clinical_significance"],
    "secondary": ["detailed_anatomy", "pathophysiology", "research_findings"],
    "tertiary": ["molecular_basis", "developmental_biology", "comparative_anatomy"],
    "hidden": [],
    "max_info_items": -1  # unlimited
}
```

## Usage Examples

### Basic Layout Mode Change
```gdscript
# Switch to compact mode for mobile
UIAdaptationManager.set_layout_mode(UIAdaptationManager.LayoutMode.COMPACT)

# Get current configuration
var config = UIAdaptationManager.get_layout_configuration()
sidebar.custom_minimum_size.x = config.sidebar_width
```

### Learning Level Adaptation
```gdscript
# Set learning level based on user profile
UIAdaptationManager.set_learning_level(UIAdaptationManager.LearningLevel.BEGINNER)

# Filter content based on level
if UIAdaptationManager.should_show_content("technical_details"):
    technical_panel.show()
else:
    technical_panel.hide()
```

### Content Priority Sorting
```gdscript
# Sort content by educational priority
var content_items = ["structure_name", "technical_details", "primary_function"]
content_items.sort_custom(func(a, b):
    return UIAdaptationManager.get_content_priority(a) < UIAdaptationManager.get_content_priority(b)
)
```

### Screen Size Adaptation
```gdscript
# Enable automatic adaptation
UIAdaptationManager.enable_auto_adaptation(true)

# Or manually trigger adaptation
UIAdaptationManager.adapt_to_screen_size(get_viewport().size)

# Get recommended mode
var recommended = UIAdaptationManager.get_recommended_layout_mode()
if recommended != UIAdaptationManager.get_layout_mode():
    UIAdaptationManager.set_layout_mode(recommended)
```

### Signal Handling
```gdscript
func _ready():
    # Connect to adaptation signals
    UIAdaptationManager.layout_mode_changed.connect(_on_layout_changed)
    UIAdaptationManager.learning_level_changed.connect(_on_level_changed)
    UIAdaptationManager.content_hierarchy_updated.connect(_on_hierarchy_updated)

func _on_layout_changed(mode: UIAdaptationManager.LayoutMode):
    match mode:
        UIAdaptationManager.LayoutMode.COMPACT:
            setup_compact_layout()
        UIAdaptationManager.LayoutMode.PRESENTATION:
            setup_presentation_mode()

func _on_level_changed(level: UIAdaptationManager.LearningLevel):
    update_content_complexity(level)

func _on_hierarchy_updated(hierarchy: Dictionary):
    reorganize_content_panels(hierarchy)
```

## Best Practices

### 1. Use Signals for Reactive Updates
Always connect to UIAdaptationManager signals rather than polling for changes.

### 2. Respect Content Hierarchy
Use `should_show_content()` and `get_content_priority()` to filter and sort educational content appropriately.

### 3. Enable Auto-Adaptation
For most use cases, enable auto-adaptation to automatically handle screen size changes.

### 4. Test All Layout Modes
Ensure your UI components work correctly in all layout modes, especially COMPACT and PRESENTATION.

### 5. Consider Accessibility
The system automatically adjusts for accessibility needs, but test with accessibility features enabled.

## Testing

The UIAdaptationManager includes comprehensive unit tests covering:
- Layout mode switching and validation
- Learning level adaptation and content filtering
- Signal emission and integration
- Screen size adaptation logic
- Error handling and edge cases

Run tests with:
```gdscript
# In Godot's test runner
var test = preload("res://tests/unit/test_ui_adaptation_manager.gd").new()
```

## Performance Considerations

- Layout adaptations are applied immediately without heavy computation
- Content hierarchy is cached to avoid repeated calculations
- Auto-adaptation only triggers on actual screen size changes
- Signal emissions are optimized to prevent unnecessary updates

## Future Enhancements

The UIAdaptationManager is designed to be extensible for future features:
- VR/AR layout modes
- Voice-controlled adaptations
- Machine learning-based personalization
- Advanced multi-user collaboration modes
- Integration with external LMS systems

## Troubleshooting

### Layout Mode Not Applying
Check if the layout mode is supported for current screen configuration using `get_adaptation_status()`.

### Content Not Filtering Correctly
Verify content type names match those defined in the content hierarchy constants.

### Auto-Adaptation Not Working
Ensure auto-adaptation is enabled and screen size changes are being detected properly.

### Signals Not Emitting
Check that you're not setting the same values repeatedly, as the system prevents redundant signal emissions.