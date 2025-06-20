# Command: /create-ui-component
# Purpose: Create a new UI component with scene, script, and theme integration
# Arguments:
#   - $COMPONENT_NAME: Name of the component (e.g., "QuizResultPanel")
#   - $COMPONENT_TYPE: Type of component (panel, button, card, dialog)
#   - $PARENT_CLASS: Parent class to extend (default: "PanelContainer")
#   - $FEATURES: Comma-separated features (responsive, poolable, accessible)
# Example: /create-ui-component COMPONENT_NAME="BrainFactCard" COMPONENT_TYPE="card" FEATURES="responsive,accessible"
---

You are an expert Godot UI developer specializing in educational interfaces with Material3 design and accessibility.

TASK: Create a new $COMPONENT_TYPE UI component named $COMPONENT_NAME for the NeuroVision brain anatomy education app.

CONTEXT:
- NeuroVision uses Material3 design system with educational adaptations
- All UI components must be theme-aware (Material3 color tokens)
- Components live in src/ui/components/ with matching scenes
- Must integrate with UIThemeManager autoload
- Features requested: ${FEATURES:="responsive,accessible"}
- Parent class: ${PARENT_CLASS:="PanelContainer"}

REQUIREMENTS:
1. Create GDScript file: src/ui/components/$COMPONENT_NAME.gd
2. Create scene file: src/ui/components/$COMPONENT_NAME.tscn
3. Implement Material3 theme integration using color tokens
4. Add responsive sizing with UIComponentScaling
5. Include accessibility features (focus, screen reader)
6. Add to component pooling if "poolable" in features
7. Create comprehensive documentation header
8. Add signal definitions for component events
9. Implement proper cleanup in _exit_tree()

CONSTRAINTS:
- Must follow NeuroVision UI patterns (see StructureInfoPanel.gd for reference)
- Must use theme colors from UIThemeManager (primary, secondary, surface, etc.)
- Cannot hardcode colors - must use theme.get_color()
- Must handle theme changes via UIThemeManager.theme_changed signal
- Must include @tool annotation for editor preview
- Must follow GDScript style guide (snake_case variables, PascalCase classes)

OUTPUT:
- Complete $COMPONENT_NAME.gd with Material3 integration
- Complete $COMPONENT_NAME.tscn with proper node structure
- Usage example showing integration in parent scene
- List of emitted signals and their purposes

SUCCESS CRITERIA: Component works in editor preview, responds to theme changes, accessible, follows NeuroVision patterns