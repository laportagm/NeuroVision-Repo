# Command: /model-integrate
# Purpose: Integrate new 3D brain models into NeuroVision scenes
# Arguments:
#   - $MODEL_NAME: Name of the model to integrate (e.g., "detailed_hippocampus")
#   - $TARGET_SCENES: Scenes to update (all, viewer, quiz, or specific scene names)
#   - $INTEGRATION_TYPE: How to integrate (replace, add_option, add_layer, add_variant)
#   - $LOD_CONFIG: LOD configuration (auto, manual, performance_based)
#   - $EDUCATIONAL_METADATA: Associated educational data file
# Example: /model-integrate MODEL_NAME="hippocampus_detailed" TARGET_SCENES="viewer,quiz" INTEGRATION_TYPE="add_option" LOD_CONFIG="auto"
---

You are a 3D model integration specialist for educational applications.

TASK: Integrate $MODEL_NAME model into $TARGET_SCENES with $INTEGRATION_TYPE integration.

CONTEXT:
- NeuroVision currently has base brain models
- Planning for specialized structure models
- Each model needs LOD variants (0,1,2)
- Models must link to educational content
- Performance critical on Intel UHD 620
- LOD configuration: ${LOD_CONFIG:="auto"}
- Educational metadata: ${EDUCATIONAL_METADATA:="auto_detect"}

REQUIREMENTS:
1. Model analysis and preparation:
   - Verify model format (GLTF 2.0)
   - Check polygon count for LODs
   - Validate material setup
   - Ensure structure naming matches IDs
   - Create import configuration

2. Integration strategies ($INTEGRATION_TYPE):
   - "replace": Replace existing model
   - "add_option": Add as user-selectable option
   - "add_layer": Add as toggleable layer
   - "add_variant": Add as detail variant

3. Scene updates for $TARGET_SCENES:
   - Update model loading logic
   - Add UI controls if needed
   - Configure SubViewport settings
   - Update performance profiles
   - Maintain existing functionality

4. LOD configuration ($LOD_CONFIG):
   - "auto": Automatic distance-based
   - "manual": User-controlled quality
   - "performance_based": FPS-driven switching
   
   LOD Setup:
   ```gdscript
   var lod_configs = {
       "lod0": {"distance": 0, "max_fps_drop": 5},
       "lod1": {"distance": 10, "max_fps_drop": 10},
       "lod2": {"distance": 20, "max_fps_drop": 15}
   }
   ```

5. Educational integration:
   - Link model structures to content
   - Update selection mappings
   - Configure highlight groups
   - Set up info panel data
   - Add quiz references

6. Performance optimization:
   - Baseline performance test
   - Memory usage analysis
   - Draw call optimization
   - Texture atlas setup
   - Occlusion culling config

7. Compatibility maintenance:
   - Preserve existing model access
   - Update model switcher UI
   - Maintain selection system
   - Keep assessment links
   - Update documentation

CONSTRAINTS:
- Cannot break existing scenes
- Must maintain 30+ FPS
- Model names must be consistent
- Educational data required
- Accessibility features preserved

OUTPUT:
- Updated scene files
- Model integration scripts
- Performance impact report
- UI updates needed
- Migration guide for:
  - ContentManager updates
  - Assessment adjustments
  - Scene modifications
- Testing checklist

SUCCESS CRITERIA: Model seamlessly integrated, performance maintained, educational features enhanced