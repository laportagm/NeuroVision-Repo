# NeuroVision Developer Quick Reference

## Common Tasks

### Running the Project
```bash
# Run the project
godot

# Run with specific scene
godot scenes/ui/MainMenu.tscn

# Run tests
./tools/scripts/quick_test.sh
```

### Debug Console (F1)
```bash
# Test systems
test autoloads
test ui_safety
test infrastructure

# Check performance
performance
memory
models

# Search knowledge base
kb search hippocampus
knowledge hippocampus
```

## File Locations

### Scenes
- Main Menu: `scenes/ui/MainMenu.tscn`
- Exploration: `scenes/3d/EnhancedExplorationScene.tscn`

### Models
- Brain models: `assets/3d_models/processed/`
- Default model: `Internal_Structures_LOD/Internal-Structures_low.glb`

### UI Components
- Atomic components: `src/ui_atomic/atoms/`
- Panels: `src/ui_atomic/organisms/`
- Themes: `src/ui_atomic/themes/`

### Core Systems
- Autoloads: `src/autoload/`
- Managers: `src/core/managers/`
- 3D Systems: `src/systems/3d_interaction/`

## Key Classes

### Autoloads (Global Access)
```gdscript
# Color/Theme Management
UnifiedColorManager.get_color("primary")
UnifiedColorManager.set_theme_mode(UnifiedColorManager.ThemeMode.DARK)

# Progress Tracking
ProgressTracker.update_progress("hippocampus", 0.75)
ProgressTracker.save_progress()

# Resource Loading
ResourceManager.load_resource("res://path/to/resource.tres")
ResourceManager.clear_cache_category(ResourceManager.ResourceCategory.MODELS)

# Assessment
AssessmentService.get_assessment("quiz_id")
AssessmentService.submit_answer(question_id, answer)
```

### Model Loading
```gdscript
# Safe model loading with error handling
var loader = SafeModelLoader.new()
var model = loader.load_brain_model("Internal-Structures", "low")

# Standard model loading
var model_loader = preload("res://src/systems/3d_interaction/ModelLoader.gd")
model_loader.load_model("Internal-Structures", ModelLoader.LODLevel.LOW)
```

### UI Creation
```gdscript
# Create info panel
var panel = preload("res://src/ui_atomic/organisms/StructureInfoPanel.tscn").instantiate()
panel.display_structure_info(structure_data)

# Apply theme
var theme_applier = preload("res://src/ui_atomic/themes/utilities/apply_neurovision_theme.gd")
theme_applier.apply_neurovision_theme_to_scene(node)
```

## Common Patterns

### Error Handling
```gdscript
func load_educational_content(structure_id: String) -> Dictionary:
    if structure_id.is_empty():
        push_error("[Module] Structure ID cannot be empty")
        return {}
    
    var content = KnowledgeService.get_structure(structure_id)
    if content.is_empty():
        push_warning("[Module] No content for: " + structure_id)
        return {}
    
    return content
```

### Resource Cleanup
```gdscript
func _exit_tree() -> void:
    # Clean up resources
    if _timer:
        _timer.stop()
        _timer.queue_free()
    
    # Clear collections
    _cache.clear()
    
    # Remove overrides
    remove_theme_stylebox_override("normal")
```

### Accessibility
```gdscript
# Minimum touch target size
button.custom_minimum_size = Vector2(48, 48)

# Focus indication
button.focus_mode = Control.FOCUS_ALL

# Screen reader support
button.set_meta("accessible_name", "Select " + structure_name)
button.set_meta("accessible_role", "button")
```

## Performance Tips

### Intel UHD 620 Optimization
- Use LOW LOD models
- Disable complex shaders
- Reduce particle effects
- Target 60fps

### Memory Management
- Use ResourceManager for caching
- Clear unused resources
- Implement _exit_tree() cleanup
- Monitor with `memory` command

## Troubleshooting

### Scene Won't Load
1. Check file path in error message
2. Verify scene file exists
3. Check for script errors in scene
4. Try loading in editor first

### RID Leaks
1. Implement _exit_tree() in custom nodes
2. Clear theme overrides properly
3. Free materials and textures
4. Use queue_free() not free()

### Model Not Found
1. Check ModelPaths.gd configuration
2. Verify file exists at path
3. Check file extension (.glb vs .gltf)
4. Try fallback paths

## Code Style

### Naming Conventions
- Classes: `PascalCase`
- Functions: `snake_case()`
- Variables: `snake_case`
- Constants: `ALL_CAPS`
- Signals: `snake_case`
- Private: `_underscore_prefix`

### File Organization
```
ClassName.gd
├── class_name declaration
├── extends statement
├── docstring
├── signals
├── enums
├── constants
├── exports
├── onready vars
├── private vars
├── _ready()
├── _process()
├── public methods
└── private methods
```

## Git Workflow

### Commit Messages
```
feat(scope): add new feature
fix(scope): fix bug description
docs(scope): update documentation
refactor(scope): improve code structure
test(scope): add tests
chore(scope): maintenance task
```

### Pre-commit Checks
- GDScript syntax validation
- Naming convention enforcement
- File size limits
- Secret detection
- Documentation requirements

---

**Quick Links**:
- [Full Architecture](CLEAN_ARCHITECTURE.md)
- [Setup Guide](../setup/SETUP_GUIDE.md)
- [API Reference](API_REFERENCE.md)
- [Testing Guide](TESTING_GUIDE.md)