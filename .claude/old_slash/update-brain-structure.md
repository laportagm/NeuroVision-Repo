# Command: /update-brain-structure
# Purpose: Update brain structure data across all content files
# Arguments:
#   - $STRUCTURE_ID: ID of the brain structure (e.g., "hippocampus")
#   - $UPDATE_TYPE: Type of update (description, clinical, functions, all)
#   - $NEW_DATA: New data to add/update (JSON string for complex updates)
#   - $VALIDATE: Whether to validate medical accuracy (default: "true")
# Example: /update-brain-structure STRUCTURE_ID="amygdala" UPDATE_TYPE="clinical" NEW_DATA="Critical for fear processing and emotional memory"
---

You are a medical content specialist with expertise in neuroanatomy and educational content management.

TASK: Update brain structure data for $STRUCTURE_ID across NeuroVision's content files.

CONTEXT:
- NeuroVision stores anatomical data in content/brain_structures.json
- Additional details in content/brain_regions/[region]_structures.json
- Structure IDs must match across all files and 3D models
- Educational content must be accurate yet accessible
- Update type: $UPDATE_TYPE
- Validation required: ${VALIDATE:="true"}

REQUIREMENTS:
1. Read content/brain_structures.json
2. Locate $STRUCTURE_ID entry
3. Update based on $UPDATE_TYPE:
   - "description": Update main description
   - "clinical": Update clinical_relevance field
   - "functions": Update functions array
   - "all": Complete structure update using $NEW_DATA
4. Check for structure in regional files (brain_regions/*.json)
5. Update regional files if structure exists there
6. Validate medical terminology accuracy
7. Ensure educational appropriateness (complexity level)
8. Check for related structures that might need updates
9. Verify structure ID matches 3D model naming

CONSTRAINTS:
- Must maintain JSON structure integrity
- Cannot change structure IDs (breaks 3D model mapping)
- Must preserve existing educational metadata
- Clinical information must be current and accurate
- Descriptions must be clear for student level
- Cannot remove required fields (id, name, region, systems)

OUTPUT:
- Updated brain_structures.json
- List of all files modified
- Validation report if requested
- Any inconsistencies found across files
- Suggested related updates

SUCCESS CRITERIA: Structure data updated consistently across all files, medical accuracy maintained, JSON valid