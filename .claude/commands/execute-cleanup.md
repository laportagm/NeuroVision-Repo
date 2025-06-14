# Command: /execute-cleanup
# Purpose: Execute cleanup operations for NeuroVision based on scan results
# Arguments:
#   - $CATEGORY: Cleanup category (safe, medium-risk, high-risk, all)
#   - $BACKUP: Create backup before changes (true/false)
#   - $TARGET_AREA: Specific area to clean (ui, 3d_models, tests, autoloads, all)
#   - $DRY_RUN: Show what would be cleaned without doing it (true/false)
# Example: /execute-cleanup CATEGORY="safe" BACKUP="true" TARGET_AREA="ui" DRY_RUN="false"
---

You are a Godot project maintenance specialist with expertise in educational software cleanup.

TASK: Execute cleanup operations for NeuroVision brain anatomy app in category $CATEGORY.

CONTEXT:
- NeuroVision has complex dependencies between educational components
- 14 autoload managers that may reference files dynamically
- Material3 theme system with multiple variants
- 3D models with LOD versions must be preserved
- Assessment content linked to brain structures
- Create backup: ${BACKUP:="true"}
- Target area: ${TARGET_AREA:="all"}
- Dry run mode: ${DRY_RUN:="false"}

REQUIREMENTS:
1. Based on $CATEGORY, perform cleanup:
   - "safe": Only definitely unused files (empty, orphaned imports)
   - "medium-risk": Deprecated components, old test files
   - "high-risk": Potentially unused scenes, duplicate code
   - "all": Complete cleanup across all categories

2. For $TARGET_AREA specifics:
   - "ui": Clean src/ui/ components, themes, effects
   - "3d_models": Optimize assets/3d_models/ (keep LODs)
   - "tests": Remove outdated tests/
   - "autoloads": Clean unused autoload references
   - "all": Clean entire project

3. Cleanup operations:
   - Remove unused .gd and .tscn files
   - Delete orphaned .import files
   - Clean dead code within scripts
   - Remove commented-out blocks
   - Consolidate duplicate functions
   - Update stale documentation
   - Remove unused theme resources
   - Clean shader files without references

4. Preservation rules:
   - Keep all brain structure data JSONs
   - Preserve assessment content
   - Maintain all LOD model versions
   - Keep accessibility-related code
   - Preserve theme color schemes

5. Safety verification:
   - Check scene dependencies (.tscn references)
   - Verify autoload usage patterns
   - Scan for dynamic loading (load(), preload())
   - Check signal connections
   - Verify export variables usage

CONSTRAINTS:
- Never remove educational content files
- Preserve all accessibility features
- Keep performance monitoring code
- Maintain error recovery systems
- Don't break theme variants
- Preserve all brain model files

OUTPUT:
- Detailed cleanup report:
  - Files removed (count and paths)
  - Code cleaned (lines removed)
  - Space saved (MB)
  - Potential risks identified
- If DRY_RUN=true: Show what would be done
- Backup location if created
- Testing recommendations post-cleanup

SUCCESS CRITERIA: Project remains fully functional, space reclaimed, no educational features broken