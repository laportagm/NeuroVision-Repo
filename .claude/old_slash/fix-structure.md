# Command: /fix-structure
# Purpose: Fix structural issues in brain anatomy data, 3D models, or code architecture
# Arguments:
#   - $TARGET_TYPE: What to fix (brain_data, model_mapping, scene_hierarchy, code_architecture)
#   - $SPECIFIC_ISSUE: The specific structural problem to fix
#   - $SCOPE: Scope of fix (single_file, component, system_wide)
#   - $VALIDATION: Validate fix (true/false, default: true)
# Example: /fix-structure TARGET_TYPE="brain_data" SPECIFIC_ISSUE="hippocampus missing connections" SCOPE="single_file"
---

You are an expert in neuroanatomy data structures and Godot project architecture.

TASK: Fix structural issue in $TARGET_TYPE: "$SPECIFIC_ISSUE" with $SCOPE scope.

CONTEXT:
- NeuroVision requires precise structural relationships
- Brain anatomy data must match 3D model hierarchy
- Code architecture must support educational workflows
- Validation needed: ${VALIDATION:="true"}

REQUIREMENTS:
Based on $TARGET_TYPE:

$IF{TARGET_TYPE=="brain_data"}
1. Analyze brain structure data in content/brain_structures.json
2. Identify structural inconsistencies:
   - Missing anatomical connections
   - Incorrect hierarchical relationships
   - Mismatched IDs with 3D models
   - Invalid region assignments
3. Cross-reference with:
   - Regional files in content/brain_regions/
   - 3D model structure names
   - Medical accuracy sources
4. Fix structural relationships
5. Validate anatomical accuracy
$ELSEIF{TARGET_TYPE=="model_mapping"}
1. Analyze 3D model node structure
2. Check model-to-data mapping:
   - Node names vs structure IDs
   - Hierarchy matches anatomy
   - Material assignments
   - LOD consistency
3. Fix naming inconsistencies
4. Update model import settings
5. Verify selection system compatibility
$ELSEIF{TARGET_TYPE=="scene_hierarchy"}
1. Analyze scene structure (.tscn files)
2. Identify hierarchy issues:
   - Incorrect parent-child relationships
   - Missing required nodes
   - Broken node references
   - Signal connection problems
3. Fix scene structure
4. Update node paths in scripts
5. Validate scene functionality
$ELSEIF{TARGET_TYPE=="code_architecture"}
1. Analyze code structure issues
2. Fix architectural problems:
   - Circular dependencies
   - Incorrect inheritance
   - Autoload dependencies
   - Module boundaries
3. Refactor to clean architecture
4. Update dependent systems
5. Verify system integrity
$ENDIF

CONSTRAINTS:
- Must preserve medical accuracy
- Cannot break existing functionality
- Must maintain backward compatibility
- Must follow project conventions
- Changes must be traceable

OUTPUT:
- Fixed files with structural corrections
- Validation report showing changes
- Impact analysis on dependent systems
- Migration guide if breaking changes

SUCCESS CRITERIA: Structural issue resolved, validation passes, system remains stable