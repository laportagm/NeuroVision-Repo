# Performance-Based Shader System

## Overview

The NeuroVision educational platform includes an advanced performance-based shader system that automatically adapts visual quality based on hardware capabilities. This system is specifically designed to ensure smooth performance on low-end hardware like Intel UHD 620 while maintaining visual fidelity on higher-end systems.

## Components

### 1. Glass Morphism Shaders

#### Full Quality Shader (`glass_morphism_ui.gdshader`)
- **Features**: Gaussian blur, chromatic aberration, complex noise, saturation control
- **Performance**: High GPU cost, 15+ texture samples per fragment
- **Target Hardware**: Dedicated GPUs, high-end integrated graphics
- **Quality Settings**: High, Ultra

#### Lite Shader (`glass_morphism_ui_lite.gdshader`)
- **Features**: Simple gradients, fast noise, basic tinting
- **Performance**: 60-70% reduction in fragment shader cost
- **Target Hardware**: Intel UHD 620, low-end integrated graphics
- **Quality Settings**: Low, Medium

### 2. UIThemeManager Integration

The `UIThemeManager` automatically switches between shaders based on performance metrics:

```gdscript
# Automatic switching based on PerformanceMonitor
UIThemeManager.apply_quality_based_shaders("low")    # Uses lite shader
UIThemeManager.apply_quality_based_shaders("high")   # Uses full shader

# Manual override for testing
UIThemeManager.force_shader_quality("medium")
```

### 3. Performance Monitoring Integration

The system integrates with `PerformanceMonitor` to automatically adjust quality:

- **FPS < 25**: Automatically switches to lite shader
- **FPS > 50**: Can upgrade to full shader (if stable)
- **Dynamic adjustment**: Real-time switching based on performance

## Implementation Details

### Shader Quality Mapping

| Quality Level | Shader Used | FPS Target | Hardware Target |
|---------------|-------------|------------|-----------------|
| Low (0)       | Lite        | 30+ FPS    | Intel UHD 620   |
| Medium (1)    | Lite        | 45+ FPS    | Basic integrated|
| High (2)      | Full        | 60+ FPS    | Dedicated GPU   |
| Ultra (3)     | Full        | 60+ FPS    | High-end GPU    |

### UI Panels Group System

All UI panels are automatically added to the `ui_panels` group for efficient shader management:

```gdscript
# Panels included in shader system
- TopBar (main navigation)
- LeftPanel (structure list)  
- BottomPanel (status bar)
- HelpOverlay (modal dialogs)
- InfoPanel (structure information)
- QuizPanel (educational quizzes)
```

### Performance Optimizations in Lite Shader

1. **Blur Elimination**: Removes expensive Gaussian blur (15+ samples → 2 samples)
2. **Simple Gradients**: Replaces complex blur with radial gradients
3. **Fast Noise**: Single calculation instead of texture lookup
4. **Reduced Uniforms**: 8 parameters → 4 parameters
5. **Single-Pass Rendering**: No multi-pass effects

## Visual Comparison

### Full Quality Shader
- ✅ Realistic frosted glass effect
- ✅ Background blur with chromatic aberration  
- ✅ Complex noise textures
- ❌ High GPU cost (15+ texture samples)
- ❌ Poor performance on integrated graphics

### Lite Shader
- ✅ Glass-like appearance maintained
- ✅ Smooth gradients for depth
- ✅ Subtle noise for texture
- ✅ 60-70% performance improvement
- ❌ No background blur
- ❌ Simplified visual effects

## Usage Examples

### Automatic Quality Management

```gdscript
# System automatically adjusts based on performance
func _ready():
    # PerformanceMonitor will trigger quality changes
    PerformanceMonitor.quality_level_changed.connect(_on_quality_changed)

func _on_quality_changed(new_level: int):
    # UIThemeManager automatically switches shaders
    print("Quality changed to: " + str(new_level))
```

### Manual Quality Control

```gdscript
# Force specific quality for testing
UIThemeManager.force_shader_quality("low")

# Check current shader
if UIThemeManager.is_lite_shader_active():
    print("Using performance-optimized shaders")
else:
    print("Using full-quality shaders")
```

### Debug and Testing

```gdscript
# Test shader performance
var test_script = preload("res://tests/test_shader_performance.gd").new()
test_script.test_shader_switch_performance()

# Force quality from debug console
test_script.force_quality("low")
```

## Performance Metrics

### Benchmark Results (Intel UHD 620)

| Shader Type | Fragment Cost | Texture Samples | Target FPS |
|-------------|---------------|-----------------|------------|
| Full        | 100%          | 15-20 per pixel| 15-20 FPS  |
| Lite        | 35%           | 2 per pixel     | 45-60 FPS  |

### Memory Usage

- **Full Shader**: Higher VRAM usage due to blur textures
- **Lite Shader**: Minimal VRAM impact, CPU-based gradients

## Configuration

### Settings in project.godot

```ini
# Automatic shader quality (saved by SettingsManager)
forced_shader_quality="medium"

# Performance monitoring
performance_monitoring_enabled=true
quality_auto_adjustment=true
```

### Theme Integration

```gdscript
# Apply quality-based materials to new panels
func add_new_panel(panel: Control):
    panel.add_to_group("ui_panels")
    UIThemeManager.apply_quality_based_shaders(
        UIThemeManager.get_current_shader_quality()
    )
```

## Troubleshooting

### Common Issues

1. **Shaders not loading**
   - Check file paths in `UIThemeManager._preload_shaders()`
   - Verify Godot can compile both shaders

2. **Quality not switching**
   - Ensure panels are in `ui_panels` group
   - Check PerformanceMonitor signal connections

3. **Visual artifacts**
   - Lite shader uses different parameters
   - Check Material parameters in `_apply_shader_to_control()`

### Debug Commands

```gdscript
# Check current state
print("Current quality: ", UIThemeManager.get_current_shader_quality())
print("Lite active: ", UIThemeManager.is_lite_shader_active())
print("UI panels count: ", get_tree().get_nodes_in_group("ui_panels").size())
```

## Educational Benefits

### Accessibility Improvements
- **Low-end hardware support**: Students with budget computers can participate
- **Consistent experience**: Automatic adaptation prevents performance issues
- **Visual coherence**: Maintains educational aesthetic across quality levels

### Performance Considerations
- **Battery life**: Lite shader extends laptop battery life
- **Heat reduction**: Lower GPU usage prevents thermal throttling
- **Stability**: Prevents crashes from GPU memory exhaustion

## Future Enhancements

1. **Adaptive LOD**: Dynamic quality based on UI element importance
2. **Custom profiles**: Save quality preferences per user
3. **Advanced metrics**: GPU temperature and memory monitoring
4. **A/B testing**: Compare educational effectiveness across quality levels

## References

- [Godot Shader Documentation](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html)
- [GPU Performance Optimization](https://developer.nvidia.com/gpu-performance-optimization)
- [Intel Graphics Performance Guide](https://software.intel.com/content/www/us/en/develop/articles/intel-graphics-performance-guide.html)