# Fix Structure

Fix identified structural issues in the project organization.

## Arguments

- `$1` (priority): "high", "medium", "low", "all" (default: "high")
- `$2` (create_plan): "true", "false" (default: "true")

## Usage

```bash
/fix-structure
/fix-structure medium true
/fix-structure all false
/fix-structure high true
```

## Prompt

Fix structural issues in the project with priority level: $1

Actions to take:
1. Reorganize files and directories for better structure
2. Fix naming inconsistencies
3. Improve import/export patterns
4. Separate concerns properly
5. Update configuration files
6. Fix circular dependencies
7. Reorganize scene files and scripts
8. Improve asset organization

Create step-by-step plan: $2

For this Godot project, focus on:
- Proper scene and script organization
- Consistent naming for scenes, scripts, and assets
- Clear separation between game logic, UI, and systems
- Proper autoload organization
- Clean asset folder structure
- Consistent coding patterns across GDScript files

Focus on issues that will have the most positive impact on:
- Code maintainability and developer experience
- Game performance and loading times
- Team collaboration and onboarding
- Build and deployment efficiency
