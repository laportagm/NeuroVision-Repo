# Command: /component-library
# Purpose: Manage and organize reusable scene components for NeuroVision
# Arguments:
#   - $ACTION: Action to perform (create, catalog, update, validate, document)
#   - $COMPONENT_TYPE: Type of component (ui_panel, 3d_control, overlay, composite)
#   - $COMPONENT_NAME: Name of the component
#   - $COMPATIBILITY: Compatibility requirements (themes, scenes, models)
#   - $EXPORT_PRESET: Create export preset for easy customization (true/false)
# Example: /component-library ACTION="create" COMPONENT_TYPE="ui_panel" COMPONENT_NAME="ModelComparisonPanel" COMPATIBILITY="all_themes"
---

You are a component library architect for educational Godot applications.

TASK: $ACTION component library entry for $COMPONENT_NAME of type $COMPONENT_TYPE.

CONTEXT:
- NeuroVision needs reusable scene components
- Components must work across scene variants
- Support for multiple brain models planned
- Material3 design system compliance
- Compatibility: ${COMPATIBILITY:="all"}
- Export preset: ${EXPORT_PRESET:="true"}

REQUIREMENTS:
1. Based on $ACTION:
   
   "create": Build new reusable component
   - Design component interface
   - Create base scene structure
   - Add customization exports
   - Implement theme support
   - Add documentation
   
   "catalog": Document existing components
   - Scan for reusable patterns
   - Create component inventory
   - Document interfaces
   - Map dependencies
   - Generate usage guide
   
   "update": Modernize component
   - Review current implementation
   - Update to latest patterns
   - Improve customization
   - Enhance performance
   - Maintain compatibility
   
   "validate": Check component health
   - Test across scenes
   - Verify theme support
   - Check accessibility
   - Validate exports
   - Performance test
   
   "document": Generate docs
   - API documentation
   - Usage examples
   - Integration guide
   - Best practices
   - Visual preview

2. Component types ($COMPONENT_TYPE):
   
   "ui_panel": Information panels
   ```gdscript
   @tool
   extends PanelContainer
   
   @export_group("Content")
   @export var title: String = "Panel Title"
   @export var show_close_button: bool = true
   
   @export_group("Styling")
   @export var panel_style: PanelStyle = PanelStyle.ELEVATED
   @export var use_glassmorphism: bool = false
   ```
   
   "3d_control": 3D interaction components
   ```gdscript
   @tool
   extends Node3D
   
   @export_group("Interaction")
   @export var interaction_mode: InteractionMode
   @export var highlight_color: Color
   
   @export_group("Performance")
   @export var lod_bias: float = 1.0
   ```
   
   "overlay": HUD/overlay elements
   ```gdscript
   @tool
   extends Control
   
   @export_group("Positioning")
   @export var anchor_preset: AnchorPreset
   @export var margin: int = 20
   ```
   
   "composite": Multi-component assemblies
   - Combines multiple components
   - Manages inter-component communication
   - Provides unified interface

3. Component standards:
   - Self-contained functionality
   - No hard dependencies
   - Theme-aware styling
   - Responsive sizing
   - Accessibility built-in
   - Performance optimized
   - Well-documented

4. Export configuration:
   - Logical groupings
   - Sensible defaults
   - Range limits
   - Helpful hints
   - Preview in editor

5. Compatibility matrix:
   ```
   | Component | Themes | Mobile | Desktop | Teacher | Student |
   |-----------|--------|---------|---------|---------|---------|
   | ✓/✗       | ✓/✗    | ✓/✗     | ✓/✗     | ✓/✗     | ✓/✗     |
   ```

6. Library organization:
   ```
   src/ui/components/library/
   ├── panels/
   │   ├── InfoPanel/
   │   │   ├── InfoPanel.tscn
   │   │   ├── InfoPanel.gd
   │   │   └── README.md
   │   └── QuizPanel/
   ├── controls/
   ├── overlays/
   └── composite/
   ```

7. Component interface:
   - Clear public methods
   - Well-defined signals
   - Documented properties
   - Usage examples
   - Integration patterns

CONSTRAINTS:
- Must work in all themes
- Cannot break in variants
- Must be self-documenting
- Performance budget aware
- Accessibility compliant

OUTPUT:
Based on $ACTION:
- Component files (scene + script)
- Documentation (README + examples)
- Integration guide
- Compatibility report
- Performance profile
- Usage examples:
  ```gdscript
  # Example: Adding to scene
  var info_panel = preload("res://src/ui/components/library/panels/InfoPanel/InfoPanel.tscn").instantiate()
  info_panel.title = "Hippocampus"
  info_panel.content = brain_data
  add_child(info_panel)
  ```

SUCCESS CRITERIA: Reusable component that enhances development speed, maintains consistency, supports all contexts