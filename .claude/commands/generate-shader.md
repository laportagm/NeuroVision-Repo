# Command: /generate-shader
# Purpose: Create custom shaders for visual effects in NeuroVision
# Arguments:
#   - $SHADER_NAME: Name for the shader file
#   - $SHADER_TYPE: Type of shader (material, canvas_item, particle)
#   - $EFFECT: Visual effect to create (glass, highlight, pulse, outline, xray)
#   - $PERFORMANCE_TARGET: Performance profile (high_quality, balanced, performance)
# Example: /generate-shader SHADER_NAME="brain_highlight" SHADER_TYPE="material" EFFECT="pulse" PERFORMANCE_TARGET="balanced"
---

You are a Godot shader specialist focusing on educational visualization effects.

TASK: Create $SHADER_TYPE shader named $SHADER_NAME implementing $EFFECT effect.

CONTEXT:
- NeuroVision needs clear visual feedback for medical education
- UI shaders go in src/ui/effects/shaders/, 3D shaders in assets/shaders/
- Must work with unified color system and Material3 design tokens
- Performance target: $PERFORMANCE_TARGET (must maintain 120+ FPS)
- Used for brain structure visualization and educational UI effects
- Must be compatible with Godot 4.4.1's optimized renderer

REQUIREMENTS:
1. Create shader implementing $EFFECT:
   - "glass": Glassmorphism with blur and transparency
   - "highlight": Structure selection highlighting
   - "pulse": Rhythmic pulsing for attention
   - "outline": Clean outline around 3D objects
   - "xray": See-through effect for layers
2. Optimize for $PERFORMANCE_TARGET:
   - "high_quality": Maximum visual quality (maintains 120+ FPS)
   - "balanced": Good quality, excellent performance (default)
   - "performance": Minimal GPU impact for Intel UHD 620
3. Include shader parameters:
   - Color inputs using Material3 tokens
   - Intensity/strength controls
   - Animation speed (if applicable)
   - Blend modes
4. Add educational enhancements:
   - Clear visual hierarchy
   - Accessibility considerations
   - No seizure-inducing effects
5. Include usage documentation
6. Consider mobile GPU limitations
7. Provide fallback for older GPUs

CONSTRAINTS:
- Must work on integrated GPUs
- Cannot cause visual discomfort
- Must integrate with theme colors
- Performance budget: <2ms per frame
- Must handle transparency sorting

OUTPUT:
- Complete shader file (.gdshader)
- Parameter documentation
- Usage example in a material
- Performance characteristics
- Visual description of effect

SUCCESS CRITERIA: Shader creates clear educational effect, performs well, integrates with theme