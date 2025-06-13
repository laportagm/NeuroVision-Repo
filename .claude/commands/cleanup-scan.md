# Cleanup Scan

Identify files and code that can be removed or cleaned up.

## Arguments

- `$1` (target): "all", "files", "code", "dependencies", "docs" (default: "all")
- `$2` (aggressive): "false", "true" (default: "false")

## Usage

```bash
/cleanup-scan
/cleanup-scan files false
/cleanup-scan code true
/cleanup-scan dependencies false
```

## Prompt

Scan for cleanup opportunities in: $1

Identify:
- Unused files and directories
- Dead/unreachable code
- Deprecated functions and classes
- Unused imports and dependencies
- Outdated documentation
- Duplicate code
- Legacy configuration files
- Commented-out code blocks
- Unused assets (images, sounds, models, textures)
- Orphaned scene files
- Unused autoload scripts

Aggressive mode: $2 (if true, be more thorough but potentially risky)

For this Godot project, specifically look for:
- Unused .tscn scene files
- Orphaned .gd script files
- Unused assets in the assets folder
- Deprecated or unused autoload entries
- Old test files that are no longer relevant
- Unused addon/plugin files
- Redundant configuration files
- Unused import files (.import)

Provide a prioritized list with confidence levels for each suggested removal:
- High confidence (definitely safe to remove)
- Medium confidence (likely safe but needs verification)
- Low confidence (requires careful review before removal)
