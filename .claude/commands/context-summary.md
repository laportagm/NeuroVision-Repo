# Context Summary

Generate focused context for specific components or areas of the project.

## Arguments

- `$1` (component): Specific file, directory, or component name (optional)
- `$2` (depth): "shallow", "medium", "deep" (default: "medium")

## Usage

```bash
/context-summary
/context-summary src/main_scene deep
/context-summary scripts/player_controller.gd medium
/context-summary assets shallow
```

## Prompt

Provide a detailed context summary for: $1

Include:
- Purpose and functionality
- Dependencies and relationships
- Key methods/functions/classes
- Usage patterns
- Integration points
- Potential issues or improvements

Analysis depth: $2

If no component specified, analyze the most critical parts of the project focusing on:
- Main game scenes and controllers
- Core interaction systems
- Accessibility implementations
- Key configuration files
- Essential asset dependencies
