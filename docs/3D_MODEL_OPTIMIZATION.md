# 3D Model Optimization Guide for NeuroVision

## Overview

This guide explains how to optimize 3D brain models for better performance on standard hardware, particularly for systems with Intel UHD 620 graphics.

## The Problem

- Original brain model: 26MB file size causing <20 FPS on Intel UHD graphics
- Single high-resolution model loads entirely into memory
- No LOD (Level of Detail) variants available
- Students on standard hardware experience poor performance

## The Solution

We've implemented a comprehensive LOD system with GPU detection:

### 1. LOD Variants
- **LOW**: ~25k vertices (for Intel UHD 620)
- **MEDIUM**: ~50k vertices (balanced quality)
- **HIGH**: Original quality (for high-end GPUs)

### 2. GPU Detection
- Automatically detects GPU capabilities
- Sets appropriate quality defaults
- Adjusts LOD level based on hardware

### 3. Dynamic Loading
- Only loads the necessary LOD variant
- Supports runtime quality switching
- Memory-efficient model management

## How to Generate LOD Variants

### Method 1: Using the Quick Runner (Recommended)

1. Open Godot Editor
2. Navigate to `FileSystem` dock
3. Find `res://src/tools/RunLODGeneration.gd`
4. Right-click and select "Change Script..."
5. In Script Editor, go to `File > Run` or press `Ctrl+Shift+X`

### Method 2: Using the Brain Model Optimizer Directly

1. Open `res://src/tools/BrainModelOptimizer.gd` in Script Editor
2. Run the script with `File > Run`
3. Check console output for progress
4. Models will be saved to `res://assets/3d_models/processed/`

### Method 3: Manual LOD Generation

If the automated tools don't work perfectly, you can manually create LODs:

1. Export the original model from Godot
2. Use external tools like:
   - Blender with Decimate modifier
   - MeshLab with Quadric Edge Collapse
   - Simplygon (commercial)
3. Target polygon counts:
   - `model_name_low.glb`: ~25k triangles
   - `model_name_medium.glb`: ~50k triangles
   - `model_name_high.glb`: original
4. Save to `res://assets/3d_models/processed/`

## File Structure

The system supports two organizational structures:

### Option 1: Subdirectory Structure (Recommended)
```
assets/
└── 3d_models/
    ├── raw/                    # Original high-res models
    │   └── Internal-Structures.glb
    └── processed/              # Optimized LOD variants
        └── Internal_Structures_LOD/    # Model-specific folder
            ├── Internal-Structures_low.glb
            ├── Internal-Structures_high.glb
            └── Internal-Structures p.glb   # Optional variants
```

### Option 2: Flat Structure (Legacy)
```
assets/
└── 3d_models/
    ├── raw/                    # Original high-res models
    │   └── Internal-Structures.glb
    └── processed/              # Optimized LOD variants
        ├── Internal-Structures_low.glb
        ├── Internal-Structures_medium.glb
        └── Internal-Structures_high.glb
```

The ModelLoader automatically searches both structures, prioritizing subdirectories.

## GPU Detection System

The `GPUDetector` class automatically identifies your GPU and sets quality:

### Low-End GPUs (Use LOW quality):
- Intel UHD Graphics
- Intel HD Graphics
- Intel Iris Graphics
- AMD Radeon Vega (integrated)
- NVIDIA GeForce MX series
- NVIDIA GeForce GTX 1050 and below

### High-End GPUs (Use HIGH/ULTRA quality):
- NVIDIA RTX 30/40 series
- AMD RX 6900/7900 series
- Intel Arc A7 series

### Quality Settings by GPU

| Quality Level | Target Hardware | LOD | Shadows | MSAA | Render Scale |
|--------------|----------------|-----|---------|------|--------------|
| LOW | Intel UHD 620 | Low | Hard | Off | 75% |
| MEDIUM | GTX 1660 | Medium | Soft Medium | 2x | 100% |
| HIGH | RTX 3070 | High | Soft High | 4x | 100% |
| ULTRA | RTX 4090 | High | Soft Ultra | 8x | 125% |

## Testing Your Optimization

1. **Check GPU Detection**:
   ```gdscript
   # In game console (F1)
   performance
   ```

2. **Monitor FPS**:
   - Should maintain 60 FPS on target hardware
   - LOW preset targets Intel UHD 620

3. **Verify LOD Loading**:
   - Check console for "[ModelLoader] Found processed LOD variant"
   - Ensure correct LOD loads for your GPU

## Troubleshooting

### Models Not Loading

1. Ensure LOD files exist in `processed/` directory
2. Check file naming: `ModelName_low.glb`, `ModelName_medium.glb`, etc.
3. Verify import settings have LOD generation enabled

### Poor Performance After Optimization

1. Check if correct LOD is loading (see console)
2. Verify GPU detection is working properly
3. Try manually setting quality lower:
   ```gdscript
   PerformanceMonitor.set_quality_level(PerformanceMonitor.QualityLevel.LOW)
   ```

### LOD Generation Fails

1. Check original model is valid GLB format
2. Ensure sufficient disk space
3. Try manual generation with external tools
4. Check Godot console for specific errors

## Performance Targets

After optimization, you should see:

- **Intel UHD 620**: 30-60 FPS (LOW quality)
- **GTX 1660**: 60+ FPS (MEDIUM quality)
- **RTX 3070**: 60+ FPS (HIGH quality)
- **Loading time**: <3 seconds on all hardware

## Advanced Optimization

For further optimization:

1. **Texture Compression**: Use basis universal for textures
2. **Occlusion Culling**: Hide non-visible brain structures
3. **Distance-based LOD**: Switch LODs based on camera distance
4. **Instanced Rendering**: For repeated structures

## Resources

- [Godot Optimization Guide](https://docs.godotengine.org/en/stable/tutorials/performance/index.html)
- [MeshLab Documentation](https://www.meshlab.net/)
- [Blender Decimate Modifier](https://docs.blender.org/manual/en/latest/modeling/modifiers/generate/decimate.html)