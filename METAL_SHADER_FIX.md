# Metal Shader Warning Fix

## Issue
```
W 0:00:00:841 Metal does not support LOD bias for samplers.
```

This warning occurred when loading the glass morphism shader on macOS due to Metal API limitations.

## Root Cause
The glass morphism shader was using `filter_linear_mipmap` for the screen texture sampler, which creates a sampler with LOD (Level of Detail) bias that Metal doesn't support.

## Fixes Applied

### 1. Updated Shader Sampler Settings
- Changed `filter_linear_mipmap` to `filter_linear` in glass_morphism_ui.gdshader
- This removes the mipmap LOD bias requirement while maintaining linear filtering

### 2. Removed Noise Texture Dependency
- Replaced texture-based noise with procedural noise generation
- This eliminates potential texture sampling issues on Metal
- Uses a simple hash function for noise: `fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453)`

### 3. Simplified ThemeEffectsManager Loading
- Removed dynamic creation of ThemeEffectsManager to avoid shader compilation at runtime
- Glass effects now require ThemeEffectsManager to be added as an autoload in project.godot

## Result
- ✅ Metal warning eliminated
- ✅ Shader remains fully functional
- ✅ Glass morphism effects work correctly when enabled
- ✅ No visual quality loss from the changes

## To Enable Glass Effects (Optional)
Add to project.godot:
```ini
[autoload]
ThemeEffectsManager="*res://src/ui/effects/ThemeEffectsManager.gd"
```

The enhanced theme styling will work without glass effects, providing shadows, rounded corners, and modern styling even without the ThemeEffectsManager.