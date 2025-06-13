# Execute Cleanup

Execute cleanup operations based on previous scan results.

## Arguments

- `$1` (category): "safe", "medium-risk", "high-risk", "all" (default: "safe")
- `$2` (backup): "true", "false" (default: "true")

## Usage

```bash
/execute-cleanup
/execute-cleanup safe true
/execute-cleanup medium-risk true
/execute-cleanup all false
```

## Prompt

Execute cleanup operations for category: $1

Create backup before changes: $2

Perform these cleanup actions:
1. Remove definitely unused files
2. Delete dead code
3. Clean up imports
4. Remove deprecated functions
5. Update or remove outdated documentation
6. Consolidate duplicate code
7. Clean up unused assets
8. Remove orphaned scene files
9. Clean up autoload entries

For this Godot project, be especially careful with:
- Scene files that might be referenced indirectly
- Assets that might be loaded dynamically
- Scripts that might be used via string references
- Autoload scripts that might be accessed globally

Start with the safest removals and work up to riskier ones based on the category selected.

Safety guidelines:
- Always verify asset dependencies before removal
- Check for dynamic loading patterns in GDScript
- Preserve any files that might be used in builds
- Maintain version control history
- Test functionality after cleanup

Provide a detailed summary of all changes made including:
- Files removed
- Code cleaned up
- Space saved
- Potential impact on project
