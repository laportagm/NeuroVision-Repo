# Command: /optimize-3d-model
# Purpose: Optimize 3D brain models for better performance
# Arguments:
#   - $MODEL_NAME: Name of the model file (without extension)
#   - $OPTIMIZATION_LEVEL: Level of optimization (light, moderate, aggressive)
#   - $TARGET_PLATFORM: Target platform (desktop, mobile, web)
#   - $PRESERVE_FEATURES: Features to preserve (e.g., "vertex_colors,uv_mapping")
# Example: /optimize-3d-model MODEL_NAME="brain_stem_detailed" OPTIMIZATION_LEVEL="moderate" TARGET_PLATFORM="mobile"
---

You are a 3D optimization specialist for educational medical visualization.

TASK: Optimize 3D model $MODEL_NAME.glb for $TARGET_PLATFORM with $OPTIMIZATION_LEVEL optimization.

CONTEXT:
- NeuroVision uses GLTF 2.0 format for brain models
- Models in assets/3d_models/raw/ need optimization
- Optimized versions go to assets/3d_models/processed/
- Must preserve educational detail and accuracy
- Features to preserve: ${PRESERVE_FEATURES:="materials,vertex_colors"}
- LOD system uses _lod0, _lod1, _lod2 suffixes

REQUIREMENTS:
1. Analyze raw model: assets/3d_models/raw/$MODEL_NAME.glb
2. Check current statistics:
   - Vertex count
   - Triangle count
   - Material count
   - Texture sizes
   - Bone count (if animated)
3. Apply optimization based on $OPTIMIZATION_LEVEL:
   - "light": 20% reduction, preserve all detail
   - "moderate": 40% reduction, maintain educational features
   - "aggressive": 60% reduction, essential features only
4. Create LOD versions:
   - LOD0: Full quality (minimal optimization)
   - LOD1: Medium quality (balanced)
   - LOD2: Low quality (maximum optimization)
5. Optimize for $TARGET_PLATFORM:
   - "desktop": Focus on visual quality
   - "mobile": Aggressive optimization, smaller textures
   - "web": File size priority, progressive loading
6. Preserve educational requirements:
   - Anatomical accuracy
   - Structure boundaries
   - Important surface details
7. Generate optimization report

CONSTRAINTS:
- Must maintain anatomical accuracy
- Cannot merge distinct brain structures
- Must preserve structure identification
- Color accuracy for educational coding
- File size limits: Desktop <50MB, Mobile <20MB, Web <10MB

OUTPUT:
- Optimized model files (*_lod0/1/2.glb)
- Optimization report with statistics
- Visual comparison description
- Integration code for LOD switching
- Performance improvement estimates

SUCCESS CRITERIA: Models optimized without losing educational value, significant performance gain