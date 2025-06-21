# Debugging Workflow

<!-- CLAUDE CODE INSTRUCTIONS:
UPDATE THIS FILE WHEN:
- You solve new types of bugs and develop better debugging approaches
- New debugging tools or techniques are discovered
- Educational platform specific debugging methods are found
- Performance debugging techniques are improved

HOW TO UPDATE:
1. Add new debugging techniques to appropriate sections
2. Update Recent Solutions with date and problem descriptions
3. Document new debugging tools discovered
4. Keep troubleshooting steps current
-->

## Debugging Workflow for NeuroVision

### Debug Console Access

**Launch Debug Console:**
- **In-Game**: Press `F1` to open debug console
- **Commands**: Type commands and press Enter
- **Auto-complete**: Press Tab for command suggestions

**Essential Debug Commands:**
```bash
# System validation
test autoloads              # Validate all educational autoload systems
test ui_safety             # Validate UI safety and theme system
test infrastructure        # Comprehensive system validation

# Educational system debugging
kb status                  # Check knowledge base status
knowledge [structure]      # Test educational content retrieval
performance               # Check educational platform performance

# Scene and interaction debugging
tree                      # Show scene tree structure
nodes                     # List all nodes in current scene
signals                   # Show active signal connections
```

### Step 1: Problem Identification and Classification

**Bug Categories:**
1. **Educational System Issues**: Autoloads, knowledge base, learning analytics
2. **3D Interaction Problems**: Brain selection, highlighting, camera controls
3. **UI/Theme Issues**: Visual problems, accessibility failures
4. **Performance Problems**: Frame rate drops, memory leaks
5. **Accessibility Violations**: WCAG compliance failures

**Problem Classification Workflow:**
```gdscript
# Debug information collection
func collect_debug_info() -> Dictionary:
    var debug_info = {
        "autoload_status": _check_autoload_systems(),
        "scene_state": _analyze_scene_state(),
        "ui_theme_status": _check_ui_theme_system(),
        "performance_metrics": _collect_performance_data(),
        "educational_platform_status": _check_educational_systems()
    }
    return debug_info

func _check_autoload_systems() -> Dictionary:
    var autoload_status = {}
    var required_autoloads = [
        "UnifiedColorManager", "CoreSystemManager", "UISystemManager",
        "EducationalPlatformManager", "HighlightMaterialManager"
    ]
    
    for autoload_name in required_autoloads:
        var autoload_node = get_node_or_null("/root/" + autoload_name)
        autoload_status[autoload_name] = {
            "exists": autoload_node != null,
            "ready": autoload_node.is_ready() if autoload_node else false
        }
    
    return autoload_status
```

### Step 2: Educational System Debugging

**Autoload System Validation:**
```gdscript
# Debug autoload initialization issues
func debug_autoload_initialization() -> void:
    print("=== AUTOLOAD DEBUG REPORT ===")
    
    var autoloads = [
        "UnifiedColorManager", "CoreSystemManager", "UISystemManager",
        "EducationalPlatformManager", "ResourceManager", "AuthenticationManager",
        "NetworkManager", "AssessmentService", "HighlightMaterialManager", 
        "ProgressTracker"
    ]
    
    for autoload_name in autoloads:
        var autoload_node = get_node_or_null("/root/" + autoload_name)
        if autoload_node:
            print("[✓] " + autoload_name + " - LOADED")
            if autoload_node.has_method("get_service_health"):
                var health = autoload_node.get_service_health()
                print("    Health: " + str(health))
        else:
            print("[✗] " + autoload_name + " - MISSING")
```

**Educational Content Debugging:**
```gdscript
# Debug knowledge base and educational content
func debug_educational_content() -> void:
    if not KnowledgeService:
        push_error("KnowledgeService not available")
        return
    
    # Test content retrieval
    var test_structures = ["hippocampus", "cortex", "cerebellum"]
    for structure in test_structures:
        var content = KnowledgeService.get_structure(structure)
        if content.is_empty():
            push_error("No content found for: " + structure)
        else:
            print("Content available for: " + structure)
```

### Step 3: 3D Interaction Debugging

**Brain Model and Interaction Debugging:**
```gdscript
# Debug 3D brain interaction system
func debug_brain_interactions() -> void:
    print("=== 3D INTERACTION DEBUG ===")
    
    # Check brain model loading
    var brain_model = get_node_or_null("Educational3DContent/BrainModel")
    if brain_model:
        print("[✓] Brain model loaded: " + str(brain_model.mesh != null))
    else:
        print("[✗] Brain model not found")
    
    # Check interaction controller
    var interaction_controller = get_node_or_null("EducationalSystems/InteractionController")
    if interaction_controller:
        print("[✓] Interaction controller ready")
        if interaction_controller.has_method("get_interaction_status"):
            var status = interaction_controller.get_interaction_status()
            print("    Status: " + str(status))
    else:
        print("[✗] Interaction controller missing")
    
    # Check highlight system
    if HighlightMaterialManager:
        print("[✓] Highlight system available")
        var active_highlights = HighlightMaterialManager.get_active_highlights()
        print("    Active highlights: " + str(active_highlights.size()))
    else:
        print("[✗] Highlight system unavailable")
```

**Camera System Debugging:**
```gdscript
# Debug camera controls and presets
func debug_camera_system() -> void:
    var camera_controller = get_node_or_null("CameraSystem/CameraController3D")
    if not camera_controller:
        push_error("Camera controller not found")
        return
    
    print("Camera Position: " + str(camera_controller.global_position))
    print("Camera Rotation: " + str(camera_controller.global_rotation))
    
    # Test camera presets
    if camera_controller.has_method("test_all_presets"):
        camera_controller.test_all_presets()
```

### Step 4: UI and Theme Debugging

**Theme System Debugging:**
```gdscript
# Debug theme application and color system
func debug_theme_system() -> void:
    print("=== THEME SYSTEM DEBUG ===")
    
    # Check UnifiedColorManager
    if UnifiedColorManager:
        print("[✓] UnifiedColorManager available")
        var current_theme = UnifiedColorManager.get_current_theme_variant()
        print("    Current theme: " + current_theme)
        
        # Test color retrieval
        var test_colors = ["primary", "surface", "on_surface"]
        for color_name in test_colors:
            var color = UnifiedColorSystem.get_color(color_name)
            print("    " + color_name + ": " + str(color))
    else:
        print("[✗] UnifiedColorManager missing")
    
    # Check UI theme application
    if UISystemManager:
        print("[✓] UISystemManager available")
        var theme_status = UISystemManager.get_theme_application_status()
        print("    Theme status: " + str(theme_status))
    else:
        print("[✗] UISystemManager missing")
```

**UI Component Debugging:**
```gdscript
# Debug UI component hierarchy and states
func debug_ui_components() -> void:
    var ui_layer = get_node_or_null("EducationalUILayer")
    if not ui_layer:
        push_error("UI layer not found")
        return
    
    # Recursively check UI components
    _debug_ui_node_recursive(ui_layer, 0)

func _debug_ui_node_recursive(node: Node, depth: int) -> void:
    var indent = "  ".repeat(depth)
    var node_info = indent + node.get_class() + " (" + node.name + ")"
    
    if node is Control:
        var control = node as Control
        node_info += " - Visible: " + str(control.visible)
        node_info += ", Size: " + str(control.size)
    
    print(node_info)
    
    for child in node.get_children():
        _debug_ui_node_recursive(child, depth + 1)
```

### Step 5: Performance Debugging

**Frame Rate Analysis:**
```gdscript
# Debug performance bottlenecks
func debug_performance_issues() -> void:
    print("=== PERFORMANCE DEBUG ===")
    
    var fps = Engine.get_frames_per_second()
    print("Current FPS: " + str(fps))
    
    if fps < 30:
        print("⚠️  FPS below Intel UHD 620 minimum target")
        _analyze_performance_bottlenecks()
    elif fps < 60:
        print("⚠️  FPS below optimal target")
    else:
        print("✓ Performance within targets")

func _analyze_performance_bottlenecks() -> void:
    # Check common bottleneck sources
    print("Analyzing performance bottlenecks...")
    
    # Memory usage
    var memory_usage = OS.get_static_memory_usage_by_type()
    print("Memory usage: " + str(memory_usage / (1024 * 1024)) + " MB")
    
    # Node count
    var node_count = get_tree().get_node_count()
    print("Total nodes: " + str(node_count))
    
    # Draw calls (if available)
    if PerformanceMonitor:
        var metrics = PerformanceMonitor.get_detailed_metrics()
        print("Performance metrics: " + str(metrics))
```

### Step 6: Accessibility Debugging

**WCAG Compliance Validation:**
```gdscript
# Debug accessibility compliance
func debug_accessibility_compliance() -> void:
    print("=== ACCESSIBILITY DEBUG ===")
    
    # Check focus chain
    _debug_focus_chain()
    
    # Check color contrast
    _debug_color_contrast()
    
    # Check touch targets
    _debug_touch_targets()

func _debug_focus_chain() -> void:
    var focusable_nodes = _find_focusable_nodes(get_tree().current_scene)
    print("Focusable nodes found: " + str(focusable_nodes.size()))
    
    for node in focusable_nodes:
        if node is Control:
            var control = node as Control
            var min_size = control.custom_minimum_size
            if min_size.x < 44 or min_size.y < 44:
                print("⚠️  Small touch target: " + control.get_path() + " (" + str(min_size) + ")")

func _debug_color_contrast() -> void:
    # Check color contrast ratios for WCAG AAA compliance
    if UnifiedColorManager:
        var contrast_report = UnifiedColorManager.validate_color_contrast_ratios()
        print("Color contrast validation: " + str(contrast_report))
```

### Step 7: Automated Debug Reports

**Comprehensive System Report:**
```gdscript
# Generate comprehensive debug report
func generate_debug_report() -> String:
    var report = "=== NEUROVISION DEBUG REPORT ===\n"
    report += "Generated: " + Time.get_datetime_string_from_system() + "\n\n"
    
    # System information
    report += "SYSTEM INFO:\n"
    report += "- Godot Version: " + Engine.get_version_info().string + "\n"
    report += "- Platform: " + OS.get_name() + "\n"
    report += "- FPS: " + str(Engine.get_frames_per_second()) + "\n\n"
    
    # Autoload status
    report += "AUTOLOAD STATUS:\n"
    var autoload_status = _check_autoload_systems()
    for autoload in autoload_status:
        var status = "✓" if autoload_status[autoload].exists else "✗"
        report += "- " + status + " " + autoload + "\n"
    
    # Educational systems
    report += "\nEDUCATIONAL SYSTEMS:\n"
    report += "- Knowledge Base: " + ("✓" if KnowledgeService else "✗") + "\n"
    report += "- Theme System: " + ("✓" if UnifiedColorManager else "✗") + "\n"
    report += "- UI System: " + ("✓" if UISystemManager else "✗") + "\n"
    
    return report
```

## Common Issues and Solutions

### Issue: "Autoload not found" Errors
**Symptoms**: Missing autoload error messages, educational features not working
**Debug Steps**:
1. Run `test autoloads` command
2. Check project.godot [autoload] section
3. Verify autoload file paths exist
**Solution**: Update project.godot with correct autoload paths

### Issue: Brain Structure Selection Not Working
**Symptoms**: Clicking on brain structures has no effect
**Debug Steps**:
1. Check interaction controller initialization
2. Verify brain model collision shapes
3. Test highlight system functionality
**Solution**: Ensure InteractionController and HighlightMaterialManager are properly initialized

### Issue: Theme Not Applying
**Symptoms**: UI components not following current theme
**Debug Steps**:
1. Run `test ui_safety` command
2. Check UnifiedColorManager status
3. Verify theme signal connections
**Solution**: Reconnect theme change signals, reload theme system

### Issue: Performance Drops
**Symptoms**: FPS below 30, stuttering interactions
**Debug Steps**:
1. Run `performance` command
2. Check memory usage with `memory` command
3. Profile with PerformanceMonitor
**Solution**: Apply Intel UHD 620 optimizations, reduce quality settings

### Issue: Educational Content Missing
**Symptoms**: Info panels show no content, knowledge base errors
**Debug Steps**:
1. Run `kb status` command
2. Test with `knowledge hippocampus` command
3. Check educational content file paths
**Solution**: Reload knowledge base, verify content file integrity

## Recent Solutions (Claude Code Updates)

<!-- CLAUDE CODE: Add your debugging solutions here with date -->
- 2025-06-21: Created comprehensive debugging workflow for educational platform
- [CLAUDE CODE: Document new debugging techniques and solutions discovered]

## Debug Console Command Reference

```bash
# System validation
test autoloads          # Check all autoload systems
test ui_safety         # Validate UI and theme systems
test infrastructure    # Comprehensive system check

# Educational debugging
kb status              # Knowledge base status
knowledge [structure]  # Test content retrieval
performance           # Performance metrics
memory                # Memory usage

# Scene debugging
tree                  # Scene tree structure
nodes                 # List all nodes
signals              # Active signal connections
focus                # Current focus chain

# UI debugging
theme status         # Theme system status
colors              # Color system validation
contrast            # Color contrast check

# Performance debugging
fps                 # Current frame rate
gpu                 # GPU usage
cpu                 # CPU usage
lod                 # Level of detail status
```

---
**Last Updated**: 2025-06-21 by Claude Code
**Workflow Version**: 1.0
**Educational Platform**: NeuroVision 2.1.0