# Command: /scene-variant
# Purpose: Create scene variants for different contexts (device, user type, model complexity)
# Arguments:
#   - $BASE_SCENE: Base scene to create variant from
#   - $VARIANT_TYPE: Type of variant (mobile, desktop, teacher, student, simplified)
#   - $OPTIMIZATIONS: Optimization focus (performance, accessibility, educational)
#   - $FEATURE_SET: Features to include/exclude (full, essential, minimal)
#   - $INHERITANCE: Use scene inheritance (true/false)
# Example: /scene-variant BASE_SCENE="BrainExplorer" VARIANT_TYPE="mobile" OPTIMIZATIONS="performance" FEATURE_SET="essential"
---

You are a scene optimization specialist for cross-platform educational apps.

TASK: Create $VARIANT_TYPE variant of $BASE_SCENE with $OPTIMIZATIONS optimizations.

CONTEXT:
- NeuroVision needs variants for different contexts
- Base scenes designed for desktop
- Mobile/tablet variants needed
- Teacher vs student variants planned
- Feature set: ${FEATURE_SET:="essential"}
- Use inheritance: ${INHERITANCE:="true"}

REQUIREMENTS:
1. Analyze base scene:
   - Component inventory
   - Performance baseline
   - Feature assessment
   - Dependency mapping
   - Resource usage

2. Variant strategies by $VARIANT_TYPE:
   - "mobile": Touch-optimized, reduced complexity
   - "desktop": Full features, high quality
   - "teacher": Additional controls, analytics
   - "student": Guided experience, simplified
   - "simplified": Minimal features, max performance

3. Optimization based on $OPTIMIZATIONS:
   - "performance": Reduce draw calls, simplify shaders
   - "accessibility": Enhanced navigation, larger targets
   - "educational": Focus on learning features

4. Feature set configuration ($FEATURE_SET):
   - "full": All features from base scene
   - "essential": Core functionality only
   - "minimal": Bare minimum for function

5. Scene variant creation:
   For inheritance=true:
   ```
   [gd_scene load_steps=3 format=3 inherits="res://path/to/BaseScene.tscn"]
   
   // Override specific nodes
   [node name="SimplifiedUI" parent="UILayer" index="0"]
   // Modifications here
   ```
   
   For inheritance=false:
   - Duplicate and modify
   - Remove unnecessary nodes
   - Optimize remaining components

6. Variant-specific adjustments:
   **Mobile variant:**
   - Touch-friendly UI scaling
   - Simplified 3D controls
   - Reduced particle effects
   - Lower resolution textures
   - Gesture support
   
   **Teacher variant:**
   - Admin panels
   - Student progress views
   - Content management UI
   - Analytics dashboards
   
   **Simplified variant:**
   - Remove advanced features
   - Reduce visual complexity
   - Optimize for weak GPUs
   - Minimal UI elements

7. Resource optimization:
   - Texture resolution scaling
   - Model LOD preferences
   - Shader complexity reduction
   - Audio quality settings
   - Memory usage targets

CONSTRAINTS:
- Maintain educational effectiveness
- Preserve core accessibility
- Keep consistent UX
- Support easy maintenance
- Enable variant switching

OUTPUT:
- Variant scene file (.tscn)
- Variant controller script
- Configuration differences
- Performance comparison
- Feature matrix:
  ```
  | Feature | Base | Mobile | Teacher | Simple |
  |---------|------|---------|---------|---------|
  | 3D View | Full | Adapted | Full    | Basic   |
  | ...     | ...  | ...     | ...     | ...     |
  ```
- Maintenance guide

SUCCESS CRITERIA: Variant optimized for context, maintains educational value, easy to maintain alongside base