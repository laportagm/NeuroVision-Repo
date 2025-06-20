# Structure Audit

Review and analyze project structure for organization and best practices.

## Arguments

- `$1` (focus): "all", "files", "directories", "naming", "imports" (default: "all")
- `$2` (suggestions): "true", "false" (default: "true")

## Usage

```bash
/structure-audit
/structure-audit files true
/structure-audit directories false
/structure-audit naming true
```

## Prompt

Perform a comprehensive structure audit focusing on: $1

Analyze:
- Directory organization and hierarchy
- File naming conventions
- Code organization within files
- Import/require patterns (for GDScript)
- Separation of concerns
- Modularity and coupling
- Configuration file placement
- Asset organization
- Scene file structure
- Autoload organization

Provide actionable suggestions: $2

For this Godot project, specifically check:
- Scene hierarchy and organization
- Script attachment patterns
- Asset folder structure (textures, sounds, models)
- Autoload script organization
- Plugin and addon structure
- Test file organization

Identify any structural issues that could impact:
- Maintainability
- Scalability
- Developer experience
- Build/deployment processes
- Game performance
