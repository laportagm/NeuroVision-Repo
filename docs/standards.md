# NeuroVis Coding Standards

[## Coding Standards

### GDScript Conventions
```gdscript
# File naming: snake_case.gd
# brain_interaction_controller.gd

# Class naming: PascalCase
class_name BrainInteractionController

# Constants: UPPER_SNAKE_CASE
const MAX_ZOOM_DISTANCE = 10.0
const MIN_ZOOM_DISTANCE = 0.5

# Variables: camelCase
var currentBrainRegion: String
var isRotating: bool = false

# Functions: snake_case
func select_brain_structure(structure_name: String) -> void:
    if not structure_name.is_valid_identifier():
        ErrorRecoveryManager.handle_error(
            ErrorRecoveryManager.ErrorType.INVALID_INPUT,
            {"message": "Invalid structure name", "input": structure_name}
        )
        return
    
    currentBrainRegion = structure_name
    structure_selected.emit(structure_name)

# Signals: snake_case (past tense)
signal structure_selected(structure_name: String)
signal camera_moved(new_transform: Transform3D)
```

### Error Handling Patterns
```gdscript
# Always handle potential failures
func load_brain_model(model_path: String) -> Node3D:
    if not ResourceLoader.exists(model_path):
        ErrorRecoveryManager.handle_error(
            ErrorRecoveryManager.ErrorType.MODEL_LOAD_FAILURE,
            {"model_path": model_path}
        )
        return null
    
    var model = load(model_path)
    if not model:
        # Try fallback model
        var fallback_path = model_path.replace("_high", "_low")
        if ResourceLoader.exists(fallback_path):
            model = load(fallback_path)
    
    return model
```

### Accessibility Patterns
```gdscript
# Every interactive element needs accessibility support
func setup_button_accessibility(button: Button, description: String):
    button.accessible_name = button.text
    button.accessible_description = description
    button.focus_entered.connect(_on_button_focused.bind(button))

func _on_button_focused(button: Button):
    var announcement = button.accessible_name + ", " + button.accessible_description
    AccessibilityManager.announce(announcement)
```

### Performance Patterns
```gdscript
# Always consider minimum hardware
func update_brain_model_quality():
    var current_fps = PerformanceMonitor.get_average_fps()
    
    if current_fps < 30:
        # Reduce quality
        brain_model.use_low_lod()
        disable_post_processing()
    elif current_fps > 45:
        # Increase quality if headroom available
        brain_model.use_high_lod()
        enable_post_processing()
```

## Content Creation Guidelines

### 3D Model Requirements
- **Format**: .glb with Draco compression
- **Polygon Limits**: High: 10K, Medium: 5K, Low: 1K triangles
- **Texture Resolution**: High: 2048x2048, Medium: 1024x1024, Low: 512x512
- **Naming**: `{region}_{subregion}_{detail}_{lod}.glb`

### Educational Content Structure
```json
{
  "structure_id": "hippocampus_ca1",
  "display_name": "CA1 Region",
  "description": "Student-friendly explanation here",
  "function": "Primary role in memory formation",
  "connections": ["ca3", "subiculum", "entorhinal_cortex"],
  "clinical_notes": "Early affected in Alzheimer's disease",
  "learning_objectives": [
    "Identify CA1 on 3D model",
    "Explain role in memory formation",
    "Describe connections to other regions"
  ]
}
```

## AI Development Guidelines

### Code Generation Principles
1. **Always include error handling** for external operations
2. **Test accessibility** with every UI component
3. **Consider offline functionality** in all features
4. **Validate user input** from any source
5. **Document learning objectives** for educational features

### Common AI Tasks
- Implement new UI components with accessibility
- Create 3D interaction behaviors
- Build assessment question types
- Add progress tracking features
- Integrate cloud sync functionality

### Testing Requirements
Every AI-generated feature must include:
- Unit tests for core functionality
- Accessibility validation
- Performance testing on minimum hardware
- Error handling verification
- Offline mode testing

## Integration Patterns

### Google API Integration
```gdscript
# Example: Gemini API integration with error handling
func query_ai_assistant(prompt: String) -> String:
    if not NetworkManager.is_online():
        return "AI assistant requires internet connection"
    
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    var headers = ["Authorization: Bearer " + GEMINI_API_KEY]
    var body = JSON.stringify({"prompt": prompt, "context": get_current_context()})
    
    http_request.request("https://api.generativeai.google/v1/models/gemini-pro:generateContent", headers, HTTPClient.METHOD_POST, body)
    
    var response = await http_request.request_completed
    http_request.queue_free()
    
    return parse_ai_response(response)
```

### Firebase Sync Pattern
```gdscript
# Example: Progress sync with conflict resolution
func sync_progress_to_cloud():
    if not AuthenticationManager.is_signed_in():
        return
    
    var local_progress = ProgressTracker.get_all_progress()
    var cloud_progress = await firebase_get_progress()
    
    var merged_progress = merge_progress_data(local_progress, cloud_progress)
    await firebase_update_progress(merged_progress)
    
    ProgressTracker.update_local_progress(merged_progress)
```

## Quality Assurance

### Code Review Checklist
- [ ] Error handling for all external calls
- [ ] Accessibility support for UI elements
- [ ] Performance consideration for minimum hardware
- [ ] Offline functionality maintained
- [ ] Educational context appropriate
- [ ] Privacy-compliant data handling
- [ ] Tests included and passing

### Performance Benchmarks
- Minimum FPS: 30 on Intel UHD 620
- Load Time: <2 seconds for brain models
- Memory Usage: <2GB on minimum hardware
- Startup Time: <5 seconds cold start

Remember: This is an educational tool for students. Prioritize learning effectiveness, accessibility, and reliability over advanced features.

---]
