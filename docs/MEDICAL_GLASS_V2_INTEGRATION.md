# Medical Glass V2 Shader Integration Guide

## Overview

The Medical Glass V2 shader provides enhanced glass morphism effects specifically designed for NeuroVision's medical education platform. This shader offers professional medical-grade visual feedback while maintaining excellent performance (120+ FPS) and WCAG AAA accessibility compliance.

## Quick Start

### 1. Basic Integration

```gdscript
# Apply to any PanelContainer for instant medical glass effect
var glass_material = MedicalGlassV2Material.create_for_component("info_panel")
info_panel.material = glass_material
```

### 2. Educational Component Integration

```gdscript
# For educational information panels
var info_material = MedicalGlassV2Material.new()
info_material.configure_for_medical_panel("info_panel")
structure_info_panel.material = info_material

# For interactive assessments  
var assessment_material = MedicalGlassV2Material.new()
assessment_material.configure_for_medical_panel("assessment_panel")
quiz_panel.material = assessment_material

# For teacher dashboard
var teacher_material = MedicalGlassV2Material.new()
teacher_material.configure_for_medical_panel("teacher_dashboard")
dashboard_panel.material = teacher_material
```

## Theme System Integration

### Automatic Theme Updates

The shader automatically integrates with NeuroVision's unified color system:

```gdscript
# Materials automatically update when themes change
UIThemeManager.set_theme_mode("minimal_clinical")
# Glass effects automatically adapt to new theme colors
```

### Manual Theme Configuration

```gdscript
# Override theme colors if needed
var material = MedicalGlassV2Material.new()
material.set_shader_parameter("glass_tint", M3DesignTokens.get_color("primary"))
material.set_shader_parameter("border_color", M3DesignTokens.get_color("surface_variant"))
```

## Performance Optimization

### Hardware-Adaptive Configuration

```gdscript
# Automatically optimize based on hardware
var material = MedicalGlassV2Material.create_for_component("info_panel")

if PerformanceMonitor.is_low_end_gpu():
    material.set_performance_profile(MedicalGlassV2Material.PerformanceProfile.PERFORMANCE)
elif PerformanceMonitor.is_high_end_gpu():
    material.set_performance_profile(MedicalGlassV2Material.PerformanceProfile.QUALITY)
else:
    material.set_performance_profile(MedicalGlassV2Material.PerformanceProfile.BALANCED)
```

### Performance Profiles

| Profile | Target Hardware | Frame Cost | Visual Quality |
|---------|----------------|------------|----------------|
| Performance | Intel UHD 620 | ~0.6ms | Good |
| Balanced | Mid-range GPU | ~1.2ms | Excellent |
| Quality | High-end GPU | ~1.8ms | Maximum |

## Accessibility Compliance

### WCAG AAA Integration

```gdscript
# Configure for accessibility requirements
var material = MedicalGlassV2Material.new()

# High contrast mode
if AccessibilityManager.is_high_contrast_enabled():
    material.configure_for_accessibility(true, false)

# Reduced motion
if AccessibilityManager.is_reduced_motion_enabled():
    material.configure_for_accessibility(false, true)

# Combined accessibility needs
material.configure_for_accessibility(
    AccessibilityManager.is_high_contrast_enabled(),
    AccessibilityManager.is_reduced_motion_enabled()
)
```

### Accessibility Features

- **High Contrast Support**: Automatically reduces glass effects for better text visibility
- **Reduced Motion**: Disables animations for motion-sensitive users
- **Screen Reader Compatible**: Purely visual enhancement, doesn't interfere with accessibility tools
- **Keyboard Navigation**: No impact on keyboard focus or navigation

## Educational Use Cases

### Information Panels

```gdscript
# Brain structure information display
var hippocampus_panel = preload("res://src/ui/components/StructureInfoPanel.tscn").instantiate()
var glass_material = MedicalGlassV2Material.create_for_component("info_panel")
hippocampus_panel.material = glass_material
```

### Assessment Interfaces

```gdscript
# Interactive quiz panels with enhanced glass
var quiz_material = MedicalGlassV2Material.new()
quiz_material.set_glass_intensity(MedicalGlassV2Material.GlassIntensity.PROMINENT)
quiz_material.set_interactive_mode(true)  # Enable shimmer on hover
quiz_panel.material = quiz_material
```

### Teacher Dashboard

```gdscript
# Professional dashboard with subtle effects
var dashboard_material = MedicalGlassV2Material.new()
dashboard_material.configure_for_medical_panel("teacher_dashboard")
dashboard_material.set_interactive_mode(false)  # Disable distracting effects
teacher_dashboard.material = dashboard_material
```

## Advanced Configuration

### Custom Glass Effects

```gdscript
var material = MedicalGlassV2Material.new()

# Fine-tune glass appearance
material.set_shader_parameter("glass_intensity", 0.2)    # More prominent glass
material.set_shader_parameter("glass_blur", 10.0)        # Increased blur
material.set_shader_parameter("surface_roughness", 0.15) # More texture
material.set_shader_parameter("border_width", 0.003)     # Thicker borders

# Animation settings
material.set_shader_parameter("hover_intensity", 1.5)    # Stronger hover effect
material.set_shader_parameter("animation_speed", 0.5)    # Slower animations
```

### Interactive Enhancements

```gdscript
# Connect to UI events for dynamic effects
func _on_panel_mouse_entered():
    glass_material.set_shader_parameter("hover_intensity", 1.5)

func _on_panel_mouse_exited():
    glass_material.set_shader_parameter("hover_intensity", 1.0)

func _on_panel_focus_entered():
    glass_material.set_shader_parameter("border_width", 0.004)

func _on_panel_focus_exited():
    glass_material.set_shader_parameter("border_width", 0.002)
```

## Best Practices

### Educational Interface Design

1. **Information Hierarchy**: Use different glass intensities to establish visual hierarchy
   - Subtle (0.1): Background panels, secondary information
   - Normal (0.15): Primary content panels
   - Prominent (0.25): Featured content, assessments
   - Dramatic (0.35): Hero elements, important announcements

2. **Medical Context**: Configure glass effects appropriate for medical education
   - Clinical environments: Use minimal glass with professional borders
   - Student interfaces: Enable interactive shimmer for engagement
   - Assessment panels: Use prominent glass to focus attention

3. **Performance Considerations**: Always consider target hardware
   - Start with balanced profile for most users
   - Detect hardware capabilities and adjust automatically
   - Provide user controls for manual optimization

### Theme Integration

1. **Color Consistency**: Always use theme-integrated colors
2. **Automatic Updates**: Let materials handle theme changes automatically
3. **Fallback Colors**: Ensure graceful degradation if theme system unavailable

## Troubleshooting

### Common Issues

**Glass effect not visible:**
- Check that glass_intensity > 0.0
- Verify material is applied to PanelContainer
- Ensure background has content to blur

**Performance issues:**
- Reduce blur_samples for older GPUs
- Disable high_quality_mode on integrated graphics
- Set performance profile to PERFORMANCE mode

**Theme colors not updating:**
- Verify UnifiedColorManager is available
- Check theme system connections
- Manually call _update_theme_colors() if needed

**Accessibility concerns:**
- Enable high contrast mode for better readability
- Disable animations for reduced motion
- Test with screen readers for compatibility

### Debug Information

```gdscript
# Check material configuration
print("Glass intensity: ", material.get_shader_parameter("glass_intensity"))
print("Performance cost: ", material.get_performance_cost())
print("Theme integration: ", material.validate_theme_integration())

# Monitor performance impact
PerformanceMonitor.start_monitoring("glass_effects")
# ... use materials ...
var stats = PerformanceMonitor.get_performance_stats("glass_effects")
print("Average frame time: ", stats.avg_frame_time * 1000.0, "ms")
```

## Integration Checklist

- [ ] Material created and configured for component type
- [ ] Performance profile set based on target hardware
- [ ] Theme integration verified and working
- [ ] Accessibility requirements addressed
- [ ] Performance impact tested and acceptable
- [ ] Visual hierarchy established with appropriate glass intensities
- [ ] Interactive effects configured for user engagement
- [ ] Fallback behavior tested for edge cases

## Examples and Demo

See `src/ui/examples/MedicalGlassDemo.tscn` for a complete working demonstration of all shader features and integration patterns.

---

*This shader enhances NeuroVision's professional medical appearance while maintaining the platform's commitment to performance, accessibility, and educational effectiveness.*