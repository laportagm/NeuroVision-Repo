# NeuroVis Global Shader Parameters Setup

## Overview

The PerformanceMonitor system uses global shader parameters to control visual quality settings. These parameters need to be defined in the Godot project settings to avoid runtime warnings.

## Required Global Shader Parameters

Add these parameters in **Project Settings > Shader Globals**:

### 1. texture_lod_bias (float)
- **Type**: float
- **Default**: 0.0
- **Range**: -0.5 to 2.0
- **Purpose**: Controls texture detail level
  - Negative values = sharper textures (higher quality)
  - Positive values = blurrier textures (better performance)
- **Quality Settings**:
  - LOW: 2.0
  - MEDIUM: 1.0
  - HIGH: 0.0
  - ULTRA: -0.5

### 2. glow_enabled (bool)
- **Type**: bool
- **Default**: false
- **Purpose**: Enables/disables glow post-processing effect
- **Quality Settings**:
  - LOW/MEDIUM: false
  - HIGH/ULTRA: true

### 3. ssr_enabled (bool)
- **Type**: bool  
- **Default**: false
- **Purpose**: Enables/disables screen-space reflections
- **Quality Settings**:
  - LOW/MEDIUM: false
  - HIGH/ULTRA: true

## How to Add in Godot Editor

1. Open Project Settings (Project > Project Settings)
2. Navigate to "Shader Globals" section
3. Add each parameter:
   - Click "Add" button
   - Enter parameter name exactly as shown above
   - Select correct type (float or bool)
   - Set default value

## Alternative: project.godot Configuration

Add these lines to your `project.godot` file under `[shader_globals]`:

```ini
[shader_globals]

texture_lod_bias={
"type": "float",
"value": 0.0
}

glow_enabled={
"type": "bool", 
"value": false
}

ssr_enabled={
"type": "bool",
"value": false
}
```

## Verification

After adding the parameters:

1. Restart Godot Editor
2. Run the project
3. Check console - shader warnings should be gone
4. Performance monitor should show quality changes without errors

## Performance Impact

- **Intel UHD 620** (minimum spec): Keep at LOW/MEDIUM for 30+ FPS
- **Dedicated GPU**: HIGH/ULTRA settings maintain 60+ FPS
- Auto-quality adjustment handles this automatically

## Educational Context

These visual quality settings enhance the neuroanatomy learning experience:
- Higher texture detail helps students identify brain structures
- Glow effects highlight selected regions
- Reflections improve depth perception in 3D models

## Troubleshooting

If warnings persist after adding parameters:

1. Ensure parameter names match exactly (case-sensitive)
2. Check parameter types are correct
3. Restart Godot Editor completely
4. Clear shader cache: `.godot/shader_cache/`

## Current Status

As of the latest update, these parameters are **not yet defined** in the project. The PerformanceMonitor uses a safe wrapper function that prevents errors but disables the visual enhancements. Once defined, uncomment line 340 in `PerformanceMonitor.gd` to enable the effects.