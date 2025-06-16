# Command: /cleanup-scan
# Purpose: Scan NeuroVision project for cleanup opportunities
# Arguments:
#   - $TARGET: What to scan (all, files, code, dependencies, assets, docs)
#   - $AGGRESSIVE: Thoroughness level (true/false)
#   - $INCLUDE_PATTERNS: File patterns to include (e.g., "*.gd,*.tscn")
#   - $EXCLUDE_DIRS: Directories to skip (e.g., ".godot,addons")
# Example: /cleanup-scan TARGET="code" AGGRESSIVE="false" INCLUDE_PATTERNS="*.gd" EXCLUDE_DIRS=".godot,assets/3d_models"
---

You are a code quality analyst specializing in Godot educational projects.

TASK: Scan NeuroVision for cleanup opportunities in $TARGET areas.

CONTEXT:
- NeuroVision production-ready medical education platform with complex dependencies
- 10 core autoload managers with global access patterns
- Material3 UI with unified color system and 4 optimized theme variants
- 3D models with LOD versions (raw and processed) for performance optimization
- Assessment system tied to 21+ brain structures
- Aggressive mode: ${AGGRESSIVE:="false"}
- Include patterns: ${INCLUDE_PATTERNS:="*"}
- Exclude directories: ${EXCLUDE_DIRS:=".godot,.import"}

REQUIREMENTS:
1. Based on $TARGET, scan for:
   - "all": Complete project analysis
   - "files": Unused/orphaned files
   - "code": Dead code, duplicates, legacy
   - "dependencies": Unused imports, addons
   - "assets": Unused textures, models, audio
   - "docs": Outdated documentation

2. File analysis priorities:
   - Orphaned .gd scripts (no scene references)
   - Unused .tscn scenes (no instantiation)
   - Duplicate UI components
   - Test files for removed features
   - Deprecated autoload scripts
   - Unused shader files (.gdshader)
   - Orphaned resource files (.tres)

3. Code analysis priorities:
   - Commented-out code blocks (>5 lines)
   - Unused functions/methods
   - Duplicate implementations
   - Dead conditional branches
   - Unused class properties
   - Legacy compatibility code
   - Deprecated API usage

4. Asset analysis priorities:
   - Unused 3D models (check LOD sets)
   - Orphaned textures
   - Unused theme resources
   - Duplicate icons
   - Unused font files
   - Old particle effects
   - Unused audio files

5. Dependency analysis:
   - Unused autoload entries
   - Orphaned signal connections
   - Unused export variables
   - Dead import statements
   - Circular dependencies
   - Unused addon/plugin files

6. Risk assessment levels:
   - **Safe (High confidence)**:
     - Empty files
     - Pure comment files
     - Obvious test artifacts
   - **Medium risk**:
     - Old backup files
     - Deprecated components
     - Legacy implementations
   - **High risk**:
     - Dynamically loaded resources
     - Autoload candidates
     - Theme-related files

CONSTRAINTS:
- Never flag educational content JSONs
- Keep all brain model files (raw + LODs)
- Preserve accessibility implementations
- Keep all assessment content
- Maintain theme color schemes
- Consider dynamic loading patterns

OUTPUT:
Organized cleanup report:

## Summary
- Total items found: X
- Estimated space savings: X MB
- Risk distribution: Safe/Medium/High

## Safe to Remove (High Confidence)
- [File path] - Reason
- Size impact: X KB

## Medium Risk Items
- [File path] - Reason - Verification needed
- Dependencies to check

## High Risk Items  
- [File path] - Reason - Manual review required
- Potential impacts

## Code Quality Issues
- Duplicate code locations
- Dead code segments
- Legacy patterns found

## Recommendations
- Priority cleanup actions
- Testing requirements
- Backup suggestions

SUCCESS CRITERIA: Comprehensive scan identifying real cleanup opportunities without risking educational functionality