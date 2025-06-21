# Performance Optimization Workflow

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You complete performance optimization tasks
- New optimization techniques are discovered
- Performance targets are adjusted
- Intel UHD 620 specific optimizations are found

HOW TO UPDATE:
1. Add new optimization techniques to appropriate sections
2. Update Recent Improvements with date and performance gains
3. Document new profiling methods discovered
4. Keep performance targets current
-->

## Performance Optimization Workflow

### Current Performance Targets

**Primary Targets (Intel UHD 620 Compatibility):**
- **Minimum FPS**: 30 FPS (33.33ms frame time)
- **Target FPS**: 60 FPS (16.67ms frame time)
- **Achieved**: 120+ FPS (current stable performance)
- **Memory Budget**: <500MB total usage
- **UI Response**: <100ms for all interactions
- **Scene Load**: <3 seconds from launch to interaction

### Step 1: Performance Monitoring and Analysis

**Enable Performance Monitoring:**
```gdscript
# In scene or autoload initialization
if PerformanceMonitor:
    PerformanceMonitor.enable_detailed_monitoring()
    PerformanceMonitor.set_performance_targets({
        "min_fps": 30.0,
        "target_fps": 60.0,
        "max_memory_mb": 500.0,
        "max_ui_response_ms": 100.0
    })
```

**Performance Profiling Commands:**
```bash
# In-game debug console (F1)
performance           # Show current performance metrics
memory                # Show memory usage breakdown
frame_time            # Show detailed frame timing
gpu_usage             # Show GPU utilization (Intel UHD 620)
```

**Performance Data Collection:**
```gdscript
func _process(_delta: float) -> void:
    if PerformanceMonitor and PerformanceMonitor.is_monitoring_enabled():
        var current_fps = Engine.get_frames_per_second()
        var memory_usage = OS.get_static_memory_usage_by_type()
        
        PerformanceMonitor.report_frame_metrics({
            "fps": current_fps,
            "frame_time_ms": 1000.0 / current_fps,
            "memory_mb": memory_usage / (1024 * 1024)
        })
```

### Step 2: Identify Performance Bottlenecks

**Common Bottleneck Areas:**
1. **3D Rendering**: Brain models, shaders, lighting
2. **UI Overdraw**: Multiple transparent panels
3. **Memory Allocation**: Large textures, frequent allocations
4. **CPU Usage**: Complex calculations, inefficient algorithms
5. **GPU Usage**: Shader complexity, texture bandwidth

**Profiling Techniques:**
```gdscript
# Profile specific functions
func _profile_expensive_function() -> void:
    var start_time = Time.get_time_dict_from_system()
    
    # Your expensive code here
    _expensive_operation()
    
    var end_time = Time.get_time_dict_from_system()
    var duration_ms = (end_time["unix"] - start_time["unix"]) * 1000
    
    if PerformanceMonitor:
        PerformanceMonitor.report_function_timing("expensive_operation", duration_ms)
```

### Step 3: Intel UHD 620 Specific Optimizations

**Graphics Quality Adaptation:**
```gdscript
# Intel UHD 620 optimization autoload
func optimize_for_intel_uhd_620() -> void:
    # Reduce rendering quality
    get_viewport().render_scale = 0.8
    get_viewport().msaa_3d = Viewport.MSAA_DISABLED
    
    # Optimize shader quality
    var rendering_device = RenderingServer.create_local_rendering_device()
    if rendering_device:
        # Use simplified shaders for integrated graphics
        _apply_low_end_shader_variants()
    
    # Reduce texture quality
    _reduce_texture_quality_for_integrated_gpu()
```

**Memory Optimization for Integrated Graphics:**
```gdscript
func optimize_memory_for_integrated_gpu() -> void:
    # Reduce texture sizes
    ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
    
    # Use texture compression
    ProjectSettings.set_setting("rendering/textures/vram_compression/import_etc2_astc", true)
    
    # Optimize 3D model LOD
    _setup_aggressive_lod_for_brain_models()
```

### Step 4: 3D Rendering Optimization

**Brain Model Optimization:**
```gdscript
# Level of Detail (LOD) implementation
class_name BrainModelLOD
extends Node3D

@export var lod_distances: Array[float] = [10.0, 25.0, 50.0]
@export var brain_models: Array[Mesh] = []  # High, Medium, Low, Ultra-Low

func _process(_delta: float) -> void:
    var camera_distance = _get_camera_distance()
    var target_lod = _calculate_target_lod(camera_distance)
    
    if target_lod != _current_lod:
        _switch_brain_model_lod(target_lod)

func _switch_brain_model_lod(lod_level: int) -> void:
    if lod_level < brain_models.size() and brain_models[lod_level]:
        mesh_instance.mesh = brain_models[lod_level]
        _current_lod = lod_level
        
        # Report LOD change for performance monitoring
        if PerformanceMonitor:
            PerformanceMonitor.report_lod_change("brain_model", lod_level)
```

**Shader Optimization:**
```gdscript
# Adaptive shader quality
func optimize_shader_performance() -> void:
    var current_fps = Engine.get_frames_per_second()
    
    if current_fps < 45.0:
        # Switch to simplified shaders
        _apply_performance_shader_variants()
    elif current_fps > 75.0:
        # Can use higher quality shaders
        _apply_quality_shader_variants()
```

### Step 5: UI Performance Optimization

**UI Pooling Implementation:**
```gdscript
# Object pooling for frequently created/destroyed UI elements
class_name UIComponentPool
extends Node

var _panel_pool: Array[Control] = []
var _button_pool: Array[Button] = []

func get_pooled_panel() -> Control:
    if _panel_pool.size() > 0:
        return _panel_pool.pop_back()
    else:
        return _create_new_panel()

func return_panel_to_pool(panel: Control) -> void:
    panel.visible = false
    panel.get_parent().remove_child(panel)
    _panel_pool.append(panel)
```

**Reduce UI Overdraw:**
```gdscript
# Visibility-based optimization
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_VISIBILITY_CHANGED:
            if not visible:
                # Disable expensive UI effects when hidden
                _disable_glass_morphism_effects()
                _pause_ui_animations()
            else:
                # Re-enable effects when visible
                _enable_glass_morphism_effects()
                _resume_ui_animations()
```

### Step 6: Memory Optimization

**Texture Memory Management:**
```gdscript
# Texture streaming for large brain models
func optimize_texture_memory() -> void:
    # Unload distant textures
    for texture in _loaded_textures:
        var distance = _get_texture_distance(texture)
        if distance > MAX_TEXTURE_DISTANCE:
            _unload_texture(texture)
    
    # Preload nearby textures
    _preload_nearby_textures()
```

**Memory Leak Prevention:**
```gdscript
# Proper resource cleanup
func _cleanup_resources() -> void:
    # Clear mesh references
    for mesh_instance in brain_model_instances:
        if mesh_instance:
            mesh_instance.mesh = null
    
    # Clear texture references
    for material in brain_materials:
        if material and material.albedo_texture:
            material.albedo_texture = null
    
    # Force garbage collection
    if OS.get_name() != "Web":
        System.gc()  # Platform-specific garbage collection
```

### Step 7: Performance Validation

**Automated Performance Testing:**
```gdscript
# Performance regression testing
func run_performance_benchmark() -> Dictionary:
    var benchmark_results = {}
    
    # Test 3D rendering performance
    benchmark_results.brain_rendering_fps = _benchmark_brain_rendering()
    
    # Test UI performance
    benchmark_results.ui_response_time = _benchmark_ui_interactions()
    
    # Test memory usage
    benchmark_results.memory_usage_mb = _benchmark_memory_usage()
    
    # Test scene loading
    benchmark_results.scene_load_time = _benchmark_scene_loading()
    
    return benchmark_results

func _validate_performance_targets(results: Dictionary) -> bool:
    var targets_met = true
    
    if results.brain_rendering_fps < 30.0:
        push_warning("Brain rendering FPS below target: " + str(results.brain_rendering_fps))
        targets_met = false
    
    if results.ui_response_time > 100.0:
        push_warning("UI response time above target: " + str(results.ui_response_time) + "ms")
        targets_met = false
    
    return targets_met
```

## Performance Optimization Patterns

### Adaptive Quality System
```gdscript
class_name AdaptiveQualityManager
extends Node

enum QualityLevel {
    ULTRA_LOW,    # Intel UHD 620 minimum
    LOW,          # Intel UHD 620 recommended
    MEDIUM,       # Dedicated GPU minimum
    HIGH,         # Dedicated GPU recommended
    ULTRA         # High-end GPU
}

func adapt_quality_to_performance() -> void:
    var current_fps = Engine.get_frames_per_second()
    var target_quality: QualityLevel
    
    if current_fps >= 60.0:
        target_quality = QualityLevel.HIGH
    elif current_fps >= 45.0:
        target_quality = QualityLevel.MEDIUM
    elif current_fps >= 30.0:
        target_quality = QualityLevel.LOW
    else:
        target_quality = QualityLevel.ULTRA_LOW
    
    _apply_quality_settings(target_quality)
```

### Frame Rate Stabilization
```gdscript
# Frame rate stabilization for consistent educational experience
func maintain_stable_framerate() -> void:
    var frame_time_history: Array[float] = []
    var target_frame_time = 1.0 / 60.0  # 60 FPS target
    
    var current_frame_time = get_process_delta_time()
    frame_time_history.append(current_frame_time)
    
    if frame_time_history.size() > 60:  # Keep 1 second of history
        frame_time_history.pop_front()
    
    var average_frame_time = _calculate_average(frame_time_history)
    
    if average_frame_time > target_frame_time * 1.2:  # 20% above target
        _reduce_quality_temporarily()
```

## Recent Improvements (Claude Code Updates)

<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: Created initial workflow with Intel UHD 620 optimization focus
- [CLAUDE CODE: Document new optimization techniques and performance gains]

## Performance Debugging Commands

```bash
# Debug console commands for performance analysis
performance_detailed    # Show detailed performance breakdown
memory_detailed        # Show memory usage by category
gpu_profile           # Profile GPU usage patterns
cpu_profile           # Profile CPU usage patterns
lod_debug             # Show current LOD levels
shader_debug          # Show active shader variants
texture_debug         # Show texture memory usage
frame_debug           # Show frame timing breakdown
```

## Common Performance Issues and Solutions

### Issue: Frame Rate Drops During Brain Interaction
**Cause**: Complex highlight shaders, multiple selection areas
**Solution**: Use simplified shaders, implement selection culling

### Issue: High Memory Usage
**Cause**: Large brain textures, memory leaks
**Solution**: Implement texture streaming, proper resource cleanup

### Issue: Slow Scene Loading
**Cause**: Synchronous asset loading, large model files
**Solution**: Implement asynchronous loading, model compression

### Issue: UI Lag During Theme Switching
**Cause**: Synchronous theme application, shader compilation
**Solution**: Pre-compile shaders, asynchronous theme updates

## Performance Targets by Hardware

| Hardware | Min FPS | Target FPS | Memory Budget | UI Response |
|----------|---------|------------|---------------|-------------|
| Intel UHD 620 | 30 FPS | 45 FPS | 400MB | <100ms |
| Dedicated GPU | 60 FPS | 90 FPS | 500MB | <50ms |
| High-end GPU | 90 FPS | 120+ FPS | 750MB | <25ms |

---
**Last Updated**: 2025-06-21 by Claude Code
**Workflow Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0