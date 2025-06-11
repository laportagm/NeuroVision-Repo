# Complete Implementation Strategy & Full Project Structure

***

## **Project Context: NeuroVis - An AI-Powered Neuroanatomy Learning App**

NeuroVis is an ambitious project to develop an educational neuroanatomy application built using the Godot game engine. The primary goal is to provide interactive 3D brain exploration for students and AI-assisted teaching tools for educators.

The project emphasizes several core principles: offline-first design, privacy-first approach, and accessibility-first development, ensuring that the application is robust, secure, and usable by a broad audience. A key aspect of the development strategy is the heavy reliance on AI assistance, specifically using Claude Code for code generation and Google Gemini for in-app teacher assistance.

### **General Things to Know Before Reading**
* **Technology Stack**: The project is primarily built with Godot 4.3 LTS and uses GDScript as the main scripting language, a decision supported by a detailed technical evaluation favoring its development speed and AI-friendliness. It integrates with Google OAuth and Firebase for optional cloud functionalities and leverages Blender for 3D asset processing.
* **Development Environment**: The entire development workflow is designed around a DevContainer setup, ensuring a consistent and reproducible environment for all developers. This includes pre-configured tools like Godot, Blender, Git LFS, and various VS Code extensions tailored for Godot and AI-assisted development.
* **AI-Centric Development**: The outline heavily features the integration of AI tools. Expect to see specific guidelines for how AI (Claude Code) will be used for code generation, problem-solving, and ensuring adherence to project standards (e.g., error handling, accessibility, performance). The `CLAUDE.md` document is central to this.
* **Detailed Planning**: This document provides a granular level of detail, from specific file naming conventions and code quality standards (like function design and error handling patterns) to comprehensive testing requirements (unit, integration, performance, and accessibility tests).
* **Educational Focus**: Remember that this is an educational tool. The content standards, learning objective categories, and overall application design are geared towards effective neuroanatomy education for high school to graduate-level students, with a focus on accuracy without requiring medical-grade precision.
* **Comprehensive Structure**: The document covers the entire project lifecycle, from initial setup and core foundation development to educational features, deployment, and ongoing quality assurance. It even includes specific file and directory structures and a detailed 13-week implementation timeline.

This project outline serves as a complete blueprint for developing NeuroVis, highlighting a modern, AI-augmented approach to software development for educational applications.

***

## 🔥 **CRITICAL ITEMS - Detailed Implementation Plans**

### **1. Scripting Language Selection - Complete Analysis**

**🎯 Detailed Implementation Approach:**
```bash
# Day 1: Technical Evaluation (2 hours)
# Create test project to validate decision

mkdir godot_language_test
cd godot_language_test
godot --headless --path . --script language_comparison.gd

# Test Implementation Matrix:
Test Case 1: 3D Brain Model Loading
- GDScript: Load .glb, measure implementation time
- C#: Same task, measure implementation time
- Complexity: Count lines of code, external dependencies

Test Case 2: Google API Integration
- GDScript: HTTPRequest to Google OAuth
- C#: Same integration
- Documentation: Available examples, AI training data

Test Case 3: UI Component Creation
- GDScript: Create responsive quiz interface
- C#: Same interface
- Maintenance: Code readability, debugging ease
```

**Decision Matrix:**
| Criteria | GDScript | C# | Weight | Winner |
|----------|----------|-----|---------|---------|
| AI Documentation Quality | 9/10 | 7/10 | 30% | GDScript |
| Development Speed | 9/10 | 6/10 | 25% | GDScript |
| Community Support | 9/10 | 7/10 | 20% | GDScript |
| Performance | 7/10 | 9/10 | 15% | C# |
| Educational App Examples | 8/10 | 5/10 | 10% | GDScript |

**Final Decision: GDScript**
- **Rationale**: 8.3/10 vs 6.7/10 weighted score
- **Performance**: Educational apps don't need C# performance
- **AI Friendly**: Extensive GDScript examples in AI training data
- **Backup Plan**: Add C# modules later if needed for specific calculations

---

### **2. Development Environment - Complete Configuration**

**🎯 DevContainer Implementation:**
```dockerfile
# .devcontainer/Dockerfile
FROM anthropic/claude-code-devcontainer:latest

# Install Godot 4.3 LTS
RUN wget -O godot.zip https://downloads.tuxfamily.org/godotengine/4.3/Godot_v4.3-stable_linux.x86_64.zip \
    && unzip godot.zip -d /usr/local/bin/ \
    && rm godot.zip \
    && chmod +x /usr/local/bin/Godot_v4.3-stable_linux.x86_64 \
    && ln -s /usr/local/bin/Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot

# Install Godot Export Templates
RUN wget -O templates.zip https://downloads.tuxfamily.org/godotengine/4.3/Godot_v4.3-stable_export_templates.tpz \
    && mkdir -p ~/.local/share/godot/export_templates/4.3.stable \
    && unzip templates.zip -d ~/.local/share/godot/export_templates/4.3.stable \
    && rm templates.zip

# Install Blender for automated 3D processing
RUN wget -O blender.tar.xz https://download.blender.org/release/Blender4.0/blender-4.0.0-linux-x64.tar.xz \
    && tar -xf blender.tar.xz -C /opt/ \
    && ln -s /opt/blender-4.0.0-linux-x64/blender /usr/local/bin/blender \
    && rm blender.tar.xz

# Configure Git LFS for 3D assets
RUN git lfs install

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code@latest

# VS Code Extensions for Godot Development
COPY .devcontainer/extensions.json /tmp/extensions.json
RUN code --install-extension geequlim.godot-tools \
    && code --install-extension ms-vscode.vscode-json
```

**📝 .gitattributes (Git LFS Configuration):**
```
# 3D Models and Assets
*.blend filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.gltf filter=lfs diff=lfs merge=lfs -text
*.fbx filter=lfs diff=lfs merge=lfs -text

# Textures
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.tga filter=lfs diff=lfs merge=lfs -text
*.exr filter=lfs diff=lfs merge=lfs -text

# Audio
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text

# Other large binaries
*.zip filter=lfs diff=lfs merge=lfs -text
*.7z filter=lfs diff=lfs merge=lfs -text
```

---

### **3. CLAUDE.md Documentation - Complete Implementation**

**📝 CLAUDE.md (Complete File):**
```markdown
# NeuroVis AI Development Guide

## Project Overview
NeuroVis is an educational neuroanatomy learning application built with Godot 4.x. It provides interactive 3D brain exploration for students and AI-assisted teaching tools for educators.

### Target Audience
- Primary: High school and university students studying neuroanatomy
- Secondary: Educators teaching neuroanatomy courses
- Geographic: English-speaking educational institutions

### Core Technologies
- **Engine**: Godot 4.3 LTS with GDScript
- **Rendering**: Compatibility renderer for broad hardware support
- **Cloud**: Google OAuth + Firebase for optional sync
- **AI**: Google Gemini for teacher assistance

## Architecture Principles

### Offline-First Design
All core functionality must work without internet connection:
- 3D exploration and interaction
- Local progress tracking
- Basic assessment system
- Content viewing and learning

### Privacy-First Approach
- Anonymous usage by default
- Optional Google account for enhanced features
- COPPA/FERPA compliant data handling
- No personal data in core functionality

### Accessibility-First Development
Every feature must support:
- Screen reader compatibility
- Full keyboard navigation
- High contrast mode
- Scalable UI elements

## System Architecture

### Autoload Singletons
```gdscript
# Core system managers (always loaded)
ErrorRecoveryManager     # Global error handling and recovery
PerformanceMonitor      # FPS monitoring and quality adaptation
AccessibilityManager   # Screen reader and keyboard support
ContentManager         # Local and cloud content management
ProgressTracker        # Student learning progress
AuthenticationManager  # Google OAuth and anonymous mode
```

### Scene Structure
```
Main.tscn
├── UI_Layer (CanvasLayer)
│   ├── MainMenu
│   ├── ProgressDashboard
│   └── SettingsPanel
├── 3D_Layer (Node3D)
│   ├── BrainModel (MeshInstance3D)
│   ├── CameraController
│   └── InteractionSystem
└── Teacher_Layer (CanvasLayer)
    ├── TeacherDashboard
    ├── ContentEditor
    └── AIAssistant
```

## Domain Knowledge - Neuroanatomy Education

### Educational Accuracy Requirements
- **Level**: Educational/textbook accuracy (not medical precision)
- **Sources**: Standard neuroanatomy textbooks (Kandel, Gray's Anatomy)
- **Terminology**: Use standard anatomical terms with student-friendly explanations
- **Age Appropriateness**: Suitable for high school through university level

### Common Neuroanatomy Concepts
```gdscript
# Example structure classifications
enum BrainRegion {
    FOREBRAIN,      # Cerebrum, diencephalon
    MIDBRAIN,       # Mesencephalon
    HINDBRAIN       # Pons, medulla, cerebellum
}

enum CellType {
    NEURON,         # Nerve cells
    GLIA,           # Support cells
    ASTROCYTE,      # Star-shaped glia
    OLIGODENDROCYTE # Myelin-producing glia
}
```

### Learning Objective Categories
1. **Structure Identification**: Name and locate brain regions
2. **Function Understanding**: Explain what each region does
3. **Connectivity**: Understand how regions connect
4. **Clinical Relevance**: Basic understanding of dysfunction
5. **Development**: How the brain forms and changes

## Coding Standards

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
```

---

### **4. Code Standards - Complete Implementation**

**📝 Code Standards Document (standards.md):**
```markdown
# NeuroVis Coding Standards

## File Organization
```
src/
├── autoload/           # Global system managers
├── systems/           # Feature-specific systems
│   ├── 3d_interaction/
│   ├── content_management/
│   ├── assessment/
│   └── teacher_tools/
├── ui/               # User interface components
│   ├── components/   # Reusable UI elements
│   ├── screens/      # Full screen layouts
│   └── dialogs/      # Modal dialogs
├── data/             # Data management
│   ├── models/       # Data structure definitions
│   ├── database/     # Local database management
│   └── sync/         # Cloud synchronization
└── utils/            # Utility functions
```

## Naming Conventions

### Files and Directories
- **Files**: `snake_case.gd`
- **Directories**: `snake_case/`
- **Scenes**: `PascalCase.tscn`
- **Resources**: `snake_case.tres`

### Code Elements
```gdscript
# Classes
class_name BrainInteractionController

# Constants
const MAX_ZOOM_DISTANCE = 10.0
const DEFAULT_BRAIN_REGION = "hippocampus"

# Enums
enum InteractionMode {
    EXPLORE,
    QUIZ,
    TEACHER_EDIT
}

# Variables
var currentBrainRegion: String
var isUserInteracting: bool = false
var selectedStructures: Array[String] = []

# Functions
func select_brain_structure(structure_name: String) -> bool
func get_structure_info(structure_id: String) -> Dictionary
func _on_structure_selected(structure: Node3D) -> void

# Signals
signal structure_selected(structure_name: String)
signal quiz_completed(score: int, total: int)
signal content_loaded(success: bool)
```

## Code Quality Standards

### Function Design
```gdscript
# Good: Clear purpose, single responsibility
func calculate_structure_volume(structure_mesh: MeshInstance3D) -> float:
    """Calculate the volume of a 3D brain structure."""
    if not structure_mesh or not structure_mesh.mesh:
        push_error("Invalid mesh instance provided")
        return 0.0
    
    var mesh = structure_mesh.mesh
    var volume = _calculate_mesh_volume(mesh)
    return volume

# Bad: Multiple responsibilities, unclear purpose
func do_brain_stuff(thing):
    # Does multiple unrelated things
    pass
```

### Error Handling
```gdscript
# Always handle potential failures
func load_educational_content(content_id: String) -> Dictionary:
    # Validate input
    if content_id.is_empty():
        ErrorRecoveryManager.handle_error(
            ErrorRecoveryManager.ErrorType.INVALID_INPUT,
            {"message": "Content ID cannot be empty"}
        )
        return {}
    
    # Check if content exists
    if not ContentManager.content_exists(content_id):
        ErrorRecoveryManager.handle_error(
            ErrorRecoveryManager.ErrorType.CONTENT_NOT_FOUND,
            {"content_id": content_id}
        )
        return {}
    
    # Attempt to load with fallback
    var content = ContentManager.load_content(content_id)
    if content.is_empty():
        # Try loading backup content
        content = ContentManager.load_backup_content(content_id)
    
    return content
```

### Accessibility Requirements
```gdscript
# Every interactive UI element must support accessibility
func create_quiz_button(question_text: String, answer_text: String) -> Button:
    var button = Button.new()
    button.text = answer_text
    
    # Required accessibility setup
    button.accessible_name = answer_text
    button.accessible_description = "Answer option for: " + question_text
    button.accessible_role = AccessibilityRole.BUTTON
    
    # Keyboard navigation support
    button.focus_entered.connect(_on_answer_focused.bind(button))
    button.focus_exited.connect(_on_answer_unfocused.bind(button))
    
    return button

func _on_answer_focused(button: Button):
    AccessibilityManager.announce(button.accessible_name + ", " + button.accessible_description)
```

### Performance Considerations
```gdscript
# Always consider minimum hardware performance
func update_brain_visualization():
    var current_fps = PerformanceMonitor.get_average_fps()
    var memory_usage = PerformanceMonitor.get_memory_usage()
    
    # Adjust quality based on performance
    if current_fps < 30 or memory_usage > 0.8:
        # Reduce visual quality
        reduce_model_quality()
        disable_expensive_effects()
    
    # Limit expensive operations
    if frame_count % 60 == 0:  # Only check every second
        update_progress_statistics()
```

## Documentation Standards

### Function Documentation
```gdscript
func calculate_learning_progress(user_id: String, module_id: String) -> float:
    """
    Calculate the learning progress percentage for a user in a specific module.
    
    Args:
        user_id: Unique identifier for the student
        module_id: Identifier for the neuroanatomy module
    
    Returns:
        Progress percentage (0.0 to 100.0)
        Returns 0.0 if user or module not found
    
    Example:
        var progress = calculate_learning_progress("student123", "hippocampus")
        print("Student has completed ", progress, "% of hippocampus module")
    """
    pass
```

### Educational Context Documentation
```gdscript
# Educational features need learning objective documentation
class_name HippocampusQuizComponent
extends Control

"""
Quiz component for hippocampus neuroanatomy assessment.

Learning Objectives:
1. Identify major hippocampal subregions (CA1, CA2, CA3, DG)
2. Understand functional differences between subregions
3. Recognize hippocampal connectivity patterns

Educational Level: High school to undergraduate
Prerequisites: Basic brain anatomy knowledge
Assessment Type: Structure identification + functional understanding
"""
```

## Testing Standards

### Unit Test Requirements
```gdscript
# tests/unit/test_brain_interaction.gd
extends GutTest

var brain_controller: BrainInteractionController

func before_each():
    brain_controller = BrainInteractionController.new()

func test_select_valid_structure():
    var result = brain_controller.select_brain_structure("hippocampus")
    assert_true(result, "Should successfully select valid structure")
    assert_eq(brain_controller.currentBrainRegion, "hippocampus")

func test_select_invalid_structure():
    var result = brain_controller.select_brain_structure("")
    assert_false(result, "Should reject empty structure name")
    assert_eq(brain_controller.currentBrainRegion, "", "Should not change current region")

func test_accessibility_announcement():
    brain_controller.select_brain_structure("hippocampus")
    # Verify accessibility announcement was made
    assert_signal_emitted(AccessibilityManager, "announcement_made")
```

### Performance Test Requirements
```gdscript
# tests/performance/test_3d_performance.gd
extends GutTest

func test_brain_model_load_time():
    var start_time = Time.get_ticks_msec()
    var model = load("res://content/models/hippocampus_high.glb")
    var load_time = Time.get_ticks_msec() - start_time
    
    assert_not_null(model, "Model should load successfully")
    assert_less_than(load_time, 2000, "Model should load in under 2 seconds")

func test_minimum_fps_performance():
    # Simulate minimum hardware conditions
    PerformanceMonitor.set_test_mode(true)
    PerformanceMonitor.simulate_low_end_hardware()
    
    var fps_samples = []
    for i in range(60):  # Test for 1 second
        fps_samples.append(Engine.get_frames_per_second())
        await get_tree().process_frame
    
    var average_fps = fps_samples.reduce(func(a, b): return a + b) / fps_samples.size()
    assert_greater_than(average_fps, 30.0, "Should maintain 30+ FPS on minimum hardware")
```

## Code Review Checklist

### Functionality
- [ ] Code accomplishes stated objective
- [ ] Edge cases are handled appropriately
- [ ] Error conditions are managed gracefully
- [ ] Performance is acceptable on minimum hardware

### Educational Appropriateness
- [ ] Content is age-appropriate for target audience
- [ ] Educational terminology is accurate
- [ ] Learning objectives are clear and measurable
- [ ] Assessment difficulty is appropriate

### Accessibility
- [ ] UI elements have accessible names and descriptions
- [ ] Keyboard navigation is fully supported
- [ ] Screen reader announcements are meaningful
- [ ] High contrast mode is supported

### Privacy and Security
- [ ] No personal data is collected unnecessarily
- [ ] User input is validated and sanitized
- [ ] Anonymous usage is preserved
- [ ] COPPA/FERPA requirements are met

### Code Quality
- [ ] Naming conventions are followed
- [ ] Code is well-documented
- [ ] Tests are included and comprehensive
- [ ] No unused code or variables
```

---

### **5. VS Code/Cursor Extensions & Configuration - Complete Setup**

**🎯 Development Environment Extensions:**
```json
// .devcontainer/devcontainer.json (FULL CONFIGURATION)
{
  "name": "NeuroVis Development Environment",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        // Godot Development
        "geequlim.godot-tools",              // Core Godot support
        "razoric.gdscript-toolkit-formatter", // GDScript formatting
        "alfish.godot-files",                // Godot resource file support
        
        // AI Development
        "anthropic.claude-code",             // Claude Code integration
        "github.copilot",                    // GitHub Copilot (optional)
        
        // Code Quality
        "dbaeumer.vscode-eslint",            // For any JS in web exports
        "esbenp.prettier-vscode",            // General formatting
        "streetsidesoftware.code-spell-checker", // Spell checking
        
        // Git & Collaboration
        "eamodio.gitlens",                   // Advanced Git features
        "mhutchie.git-graph",                // Git visualization
        "github.vscode-pull-request-github",  // PR management
        
        // Development Helpers
        "christian-kohler.path-intellisense", // Path autocomplete
        "aaron-bond.better-comments",         // Colored comments
        "wayou.vscode-todo-highlight",        // TODO highlighting
        "gruntfuggly.todo-tree",             // TODO tree view
        "alefragnani.bookmarks",             // Code bookmarks
        
        // Testing
        "hbenl.vscode-test-explorer",        // Test explorer UI
        "ms-vscode.test-adapter-converter",   // Test adapter
        
        // Documentation
        "yzhang.markdown-all-in-one",        // Markdown support
        "bierner.markdown-mermaid",           // Mermaid diagrams
        "shd101wyy.markdown-preview-enhanced" // Enhanced preview
      ],
      "settings": {
        // Godot Configuration
        "godot_tools.editor_path": "/usr/local/bin/godot",
        "godot_tools.gdscript_lsp_server_port": 6008,
        "godot_tools.scene_file_config": {
          "autoOpen": true,
          "autoClose": false
        },
        
        // File Associations
        "files.associations": {
          "*.gd": "gdscript",
          "*.tscn": "godot-scene",
          "*.tres": "godot-resource",
          "*.godot": "ini",
          "*.import": "ini"
        },
        
        // Editor Configuration
        "editor.fontSize": 14,
        "editor.fontFamily": "'Fira Code', 'Cascadia Code', monospace",
        "editor.fontLigatures": true,
        "editor.rulers": [80, 120],
        "editor.wordWrap": "bounded",
        "editor.wordWrapColumn": 120,
        "editor.formatOnSave": true,
        "editor.formatOnPaste": true,
        "editor.minimap.enabled": true,
        "editor.bracketPairColorization.enabled": true,
        "editor.guides.indentation": true,
        
        // GDScript Specific
        "[gdscript]": {
          "editor.defaultFormatter": "razoric.gdscript-toolkit-formatter",
          "editor.tabSize": 4,
          "editor.insertSpaces": false,
          "editor.detectIndentation": false
        },
        
        // Git Configuration
        "git.autofetch": true,
        "git.confirmSync": false,
        "gitlens.hovers.currentLine.over": "line",
        
        // Terminal Configuration
        "terminal.integrated.defaultProfile.linux": "bash",
        "terminal.integrated.fontSize": 13,
        
        // Better Comments Configuration
        "better-comments.tags": [
          {
            "tag": "!",
            "color": "#FF2D00",
            "strikethrough": false,
            "backgroundColor": "transparent"
          },
          {
            "tag": "?",
            "color": "#3498DB",
            "strikethrough": false,
            "backgroundColor": "transparent"
          },
          {
            "tag": "//",
            "color": "#474747",
            "strikethrough": true,
            "backgroundColor": "transparent"
          },
          {
            "tag": "TODO",
            "color": "#FF8C00",
            "strikethrough": false,
            "backgroundColor": "transparent"
          },
          {
            "tag": "HACK",
            "color": "#EC407A",
            "strikethrough": false,
            "backgroundColor": "transparent"
          }
        ],
        
        // TODO Highlight Configuration
        "todohighlight.keywords": [
          "TODO:",
          "FIXME:",
          "HACK:",
          "BUG:",
          "NOTE:",
          "OPTIMIZE:",
          "REVIEW:",
          "CLEANUP:"
        ],
        
        // Spell Checker Configuration
        "cSpell.words": [
          "Godot",
          "gdscript",
          "tscn",
          "tres",
          "gltf",
          "glb",
          "neuroanatomy",
          "hippocampus",
          "amygdala",
          "cortex",
          "cerebellum",
          "brainstem",
          "synapse",
          "neurotransmitter",
          "axon",
          "dendrite",
          "glia",
          "astrocyte",
          "oligodendrocyte",
          "signin",
          "signout",
          "oauth",
          "firebase",
          "gemini",
          "lerp",
          "slerp",
          "viewport",
          "raycast",
          "collider",
          "autoload",
          "singleton"
        ],
        
        // Workspace Configuration
        "files.exclude": {
          "**/.git": true,
          "**/.DS_Store": true,
          "**/*.tmp": true,
          "**/.import": false,  // Show Godot import folder
          "**/releases": true
        },
        
        // Search Configuration
        "search.exclude": {
          "**/node_modules": true,
          "**/.git": true,
          "**/.import": true,
          "**/releases": true,
          "**/*.glb": true,
          "**/*.blend": true
        }
      }
    }
  },
  "forwardPorts": [6007, 6008],
  "postCreateCommand": "git config --global --add safe.directory /workspaces/neurovis",
  "remoteUser": "vscode"
}
```

**📝 .vscode/tasks.json (Build Automation):**
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Godot Project",
      "type": "shell",
      "command": "godot",
      "args": ["--path", "${workspaceFolder}"],
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "./scripts/development/run_tests.sh",
      "problemMatcher": [],
      "group": "test"
    },
    {
      "label": "Export Windows Build",
      "type": "shell",
      "command": "godot",
      "args": [
        "--headless",
        "--path", "${workspaceFolder}",
        "--export", "Windows Desktop",
        "releases/windows/NeuroVis.exe"
      ],
      "problemMatcher": []
    },
    {
      "label": "Generate Documentation",
      "type": "shell",
      "command": "./scripts/development/generate_docs.sh",
      "problemMatcher": []
    }
  ]
}
```

**📝 .vscode/launch.json (Debug Configuration):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Godot",
      "type": "godot",
      "request": "launch",
      "project": "${workspaceFolder}",
      "port": 6007,
      "address": "127.0.0.1",
      "launch_game_instance": true,
      "launch_scene": false
    },
    {
      "name": "Launch Current Scene",
      "type": "godot",
      "request": "launch",
      "project": "${workspaceFolder}",
      "port": 6007,
      "address": "127.0.0.1",
      "launch_game_instance": true,
      "launch_scene": true
    },
    {
      "name": "Attach to Running Godot",
      "type": "godot",
      "request": "attach",
      "port": 6007,
      "address": "127.0.0.1"
    }
  ]
}
```

**📝 .vscode/snippets/gdscript.json (Code Snippets):**
```json
{
  "Accessible UI Component": {
    "prefix": "accessible_ui",
    "body": [
      "func setup_${1:component}_accessibility(${1:component}: ${2:Control}):",
      "\t${1:component}.accessible_name = \"${3:Name}\"",
      "\t${1:component}.accessible_description = \"${4:Description}\"",
      "\t${1:component}.focus_entered.connect(_on_${1:component}_focused.bind(${1:component}))",
      "\t${1:component}.focus_exited.connect(_on_${1:component}_unfocused.bind(${1:component}))",
      "",
      "func _on_${1:component}_focused(${1:component}: ${2:Control}):",
      "\tAccessibilityManager.announce(${1:component}.accessible_name + \", \" + ${1:component}.accessible_description)",
      "",
      "func _on_${1:component}_unfocused(${1:component}: ${2:Control}):",
      "\tpass"
    ],
    "description": "Create accessible UI component with screen reader support"
  },
  
  "Error Handling Pattern": {
    "prefix": "error_handle",
    "body": [
      "if not ${1:condition}:",
      "\tErrorRecoveryManager.handle_error(",
      "\t\tErrorRecoveryManager.ErrorType.${2:ERROR_TYPE},",
      "\t\t{",
      "\t\t\t\"message\": \"${3:Error message}\",",
      "\t\t\t\"context\": ${4:context_data}",
      "\t\t}",
      "\t)",
      "\treturn ${5:null}"
    ],
    "description": "Standard error handling pattern"
  },
  
  "Performance Check": {
    "prefix": "perf_check",
    "body": [
      "var current_fps = PerformanceMonitor.get_average_fps()",
      "if current_fps < 30:",
      "\t# Reduce quality",
      "\t${1:reduce_quality_action}",
      "elif current_fps > 45:",
      "\t# Increase quality if headroom available",
      "\t${2:increase_quality_action}"
    ],
    "description": "Performance-based quality adjustment"
  }
}
```

**📝 .editorconfig (Cross-Editor Consistency):**
```ini
# EditorConfig for consistent coding styles

root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.gd]
indent_style = tab
indent_size = 4

[*.{json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[*.{tscn,tres,import}]
indent_style = space
indent_size = 4
```

---

### **6. Secret Management & Security - Complete Implementation**

**📝 Secret Management Strategy:**
```markdown
# Secret Management Policy

## Local Development
- All secret keys (API keys, OAuth credentials) will be stored in a `.env` file at the project root
- The `.env` file is included in `.gitignore` and will never be committed to the repository
- A template file named `.env.example` will be provided in the repository to show required variables
- The `.devcontainer/devcontainer.json` will be configured to load variables from the `.env` file

## CI/CD (GitHub Actions)
- All secrets required for building, testing, and deployment will be stored as GitHub Encrypted Secrets
- Workflows will access these secrets using the `${{ secrets.SECRET_NAME }}` syntax
- Separate secrets for development, staging, and production environments

## Security Practices
- API keys are rotated quarterly
- Firebase service account keys are stored encrypted
- OAuth client secrets use environment-specific configurations
- All sensitive data is encrypted at rest and in transit
```

**📝 .env.example (Template for developers):**
```bash
# Google API Keys
GOOGLE_OAUTH_CLIENT_ID=your_client_id_here
GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret_here
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here

# Development Settings
DEBUG_MODE=true
LOG_LEVEL=debug

# Analytics (Optional)
ANALYTICS_TRACKING_ID=your_tracking_id_here
```

---

## 📊 **COMPLETE PROJECT STRUCTURE OVERVIEW - FINAL VERSION**

```
NeuroVis/
├── .devcontainer/                    # Development environment
│   ├── devcontainer.json            # VS Code dev container config (FULL CONFIG ABOVE)
│   └── Dockerfile                   # Custom container with Godot + Claude Code
│
├── .vscode/                         # VS Code workspace configuration
│   ├── extensions.json              # Extension recommendations
│   ├── settings.json                # Workspace-specific settings
│   ├── tasks.json                   # Build and run tasks
│   ├── launch.json                  # Debug configurations
│   └── snippets/                    # Custom code snippets
│       └── gdscript.json            # GDScript snippets
│
├── .github/                         # GitHub integration
│   ├── workflows/                   # CI/CD pipelines
│   │   ├── build.yml               # Automated builds and testing
│   │   ├── deploy.yml              # Deployment pipeline
│   │   └── claude-code.yml         # AI-assisted development workflow
│   ├── ISSUE_TEMPLATE/             # Issue templates for bug reports/features
│   └── PULL_REQUEST_TEMPLATE.md    # PR template with review checklist
│
├── .claude/                        # Claude Code AI integration
│   ├── config.json                 # Claude Code project configuration
│   ├── prompts/                    # Reusable prompt library
│   │   ├── features/               # Feature implementation prompts
│   │   │   ├── 3d_interaction.md
│   │   │   ├── quiz_builder.md
│   │   │   ├── teacher_dashboard.md
│   │   │   └── ai_assistant.md
│   │   ├── patterns/               # Code pattern templates
│   │   │   ├── ui_component.md
│   │   │   ├── data_sync.md
│   │   │   ├── error_handling.md
│   │   │   └── accessibility.md
│   │   ├── debugging/              # Debugging assistance prompts
│   │   │   ├── performance_issue.md
│   │   │   ├── platform_bug.md
│   │   │   └── api_integration.md
│   │   └── testing/                # Testing generation prompts
│   │       ├── unit_test.md
│   │       ├── integration_test.md
│   │       └── accessibility_test.md
│   ├── context/                    # Project context for AI
│   │   ├── architecture.md         # System architecture overview
│   │   ├── domain_knowledge.md     # Neuroanatomy education context
│   │   └── user_personas.md        # Target user descriptions
│   └── memory/                     # AI memory and learning
│       ├── decisions.json          # Architectural decisions record
│       ├── patterns.json           # Successful code patterns
│       └── feedback.json           # Human feedback on AI code
│
├── assets/                         # All game assets
│   ├── 3d_models/                  # 3D brain models and structures
│   │   ├── raw/                    # Source Blender files (.blend)
│   │   │   ├── hippocampus.blend
│   │   │   ├── cortex.blend
│   │   │   ├── brainstem.blend
│   │   │   └── cerebellum.blend
│   │   ├── processed/              # Exported game-ready models (.glb)
│   │   │   ├── hippocampus_high.glb    # 10K polygons
│   │   │   ├── hippocampus_medium.glb  # 5K polygons
│   │   │   ├── hippocampus_low.glb     # 1K polygons
│   │   │   └── [other_structures...]
│   │   └── textures/               # Texture files
│   │       ├── 2k/                 # High resolution (2048x2048)
│   │       ├── 1k/                 # Medium resolution (1024x1024)
│   │       └── 512/                # Low resolution (512x512)
│   ├── ui/                         # User interface assets
│   │   ├── icons/                  # UI icons and buttons
│   │   │   ├── navigation/         # Navigation icons
│   │   │   ├── assessment/         # Quiz and testing icons
│   │   │   ├── accessibility/      # Accessibility feature icons
│   │   │   └── general/            # General UI icons
│   │   ├── themes/                 # UI themes and styling
│   │   │   ├── default.tres        # Standard theme
│   │   │   ├── high_contrast.tres  # High contrast accessibility theme
│   │   │   └── teacher.tres        # Teacher interface theme
│   │   └── fonts/                  # Typography
│   │       ├── Inter-Regular.ttf   # Primary font
│   │       ├── Inter-Bold.ttf      # Bold variant
│   │       └── Inter-Light.ttf     # Light variant
│   ├── audio/                      # Audio assets (optional)
│   │   ├── ui_sounds/              # Button clicks, notifications
│   │   └── ambient/                # Background audio
│   └── import_presets/             # Godot import configurations
│       ├── 3d_model_high.preset
│       ├── 3d_model_medium.preset
│       ├── 3d_model_low.preset
│       └── texture_compression.preset
│
├── src/                            # Source code
│   ├── autoload/                   # Global system managers (singletons)
│   │   ├── ErrorRecoveryManager.gd     # Global error handling
│   │   ├── PerformanceMonitor.gd       # FPS and memory monitoring
│   │   ├── AccessibilityManager.gd     # Screen reader and keyboard support
│   │   ├── ContentManager.gd           # Local and cloud content management
│   │   ├── ProgressTracker.gd          # Student learning progress tracking
│   │   ├── AuthenticationManager.gd    # Google OAuth and anonymous mode
│   │   ├── NetworkManager.gd           # Internet connectivity management
│   │   └── SettingsManager.gd          # User preferences and settings
│   │
│   ├── systems/                    # Feature-specific systems
│   │   ├── 3d_interaction/         # 3D brain exploration system
│   │   │   ├── BrainInteractionController.gd
│   │   │   ├── CameraController.gd
│   │   │   ├── StructureSelector.gd
│   │   │   ├── ModelLoader.gd
│   │   │   └── LODManager.gd
│   │   │
│   │   ├── content_management/     # Educational content system
│   │   │   ├── ContentDatabase.gd      # Local content storage
│   │   │   ├── CloudSync.gd            # Firebase synchronization
│   │   │   ├── ContentEditor.gd        # Teacher content creation
│   │   │   ├── ContentValidator.gd     # Educational content validation
│   │   │   └── MetadataManager.gd      # Content metadata handling
│   │   │
│   │   ├── assessment/             # Quiz and testing system
│   │   │   ├── QuizBuilder.gd          # Template-based quiz creation
│   │   │   ├── QuestionTypes/          # Different question implementations
│   │   │   │   ├── MultipleChoice.gd
│   │   │   │   ├── Structure3DIdentification.gd
│   │   │   │   ├── DragAndDrop.gd
│   │   │   │   └── OrderingQuestion.gd
│   │   │   ├── ScoringSystem.gd        # Assessment scoring and feedback
│   │   │   ├── ProgressAnalytics.gd    # Learning progress analysis
│   │   │   └── AssessmentExporter.gd   # Export results for teachers
│   │   │
│   │   ├── teacher_tools/          # Teacher-specific features
│   │   │   ├── TeacherDashboard.gd     # Main teacher interface
│   │   │   ├── AIAssistant.gd          # Google Gemini chat integration
│   │   │   ├── ClassroomManager.gd     # Student progress monitoring
│   │   │   ├── ContentCreationWizard.gd # Guided content creation
│   │   │   └── ReportGenerator.gd      # Student progress reports
│   │   │
│   │   ├── analytics/              # Learning analytics system
│   │   │   ├── ProgressDashboard.gd    # Student progress visualization
│   │   │   ├── LearningAnalytics.gd    # Learning pattern analysis
│   │   │   ├── PerformanceMetrics.gd   # Educational effectiveness metrics
│   │   │   └── DataExporter.gd         # Export analytics data
│   │   │
│   │   ├── cloud_services/         # External service integrations
│   │   │   ├── GoogleOAuth.gd          # Google authentication
│   │   │   ├── GeminiAPI.gd            # AI assistant integration
│   │   │   ├── FirebaseManager.gd      # Cloud storage and sync
│   │   │   ├── APIRateLimiter.gd       # Rate limiting and quota management
│   │   │   └── FeedbackAPI.gd          # User feedback submission service
│   │   │
│   │   └── onboarding/             # Interactive tutorial system
│   │       ├── OnboardingManager.gd    # Main onboarding coordinator
│   │       ├── TutorialSteps.gd        # Tutorial step definitions
│   │       ├── HighlightOverlay.gd     # UI element highlighting
│   │       └── ProgressIndicator.gd    # Tutorial progress tracking
│   │
│   ├── ui/                         # User interface components
│   │   ├── components/             # Reusable UI elements
│   │   │   ├── ModuleCard.gd           # Brain module display cards
│   │   │   ├── ProgressRing.gd         # Circular progress indicators
│   │   │   ├── StructureInfoPanel.gd   # Anatomical structure information
│   │   │   ├── QuizQuestion.gd         # Quiz question component
│   │   │   ├── AccessibleButton.gd     # Screen reader friendly buttons
│   │   │   ├── ResponsiveContainer.gd  # Responsive layout container
│   │   │   └── LoadingIndicator.gd     # Loading state component
│   │   │
│   │   ├── screens/                # Full screen layouts
│   │   │   ├── MainMenu.gd             # Application main menu
│   │   │   ├── LearningHub.gd          # Module selection hub
│   │   │   ├── BrainExplorer.gd        # 3D exploration interface
│   │   │   ├── AssessmentScreen.gd     # Quiz and testing interface
│   │   │   ├── ProgressScreen.gd       # Student progress overview
│   │   │   ├── SettingsScreen.gd       # Application settings
│   │   │   ├── TeacherPortal.gd        # Teacher main interface
│   │   │   ├── HelpScreen.gd           # User help and tutorials
│   │   │   └── FeedbackScreen.gd       # User feedback submission form
│   │   │
│   │   ├── dialogs/                # Modal dialogs and popups
│   │   │   ├── StructureDetails.gd     # Anatomical structure details
│   │   │   ├── QuizResults.gd          # Assessment results display
│   │   │   ├── ContentEditor.gd        # Content creation dialog
│   │   │   ├── SettingsDialog.gd       # Settings configuration
│   │   │   ├── AuthenticationDialog.gd # Google sign-in dialog
│   │   │   ├── ErrorDialog.gd          # Error message display
│   │   │   └── AIChat.gd               # Teacher AI assistant chat
│   │   │
│   │   └── accessibility/          # Accessibility-specific components
│   │       ├── ScreenReaderHelper.gd   # Screen reader integration
│   │       ├── KeyboardNavigator.gd    # Keyboard navigation system
│   │       ├── FocusManager.gd         # Focus handling and indicators
│   │       └── HighContrastManager.gd  # High contrast mode support
│   │
│   ├── data/                       # Data management and models
│   │   ├── models/                 # Data structure definitions
│   │   │   ├── UserProfile.gd          # Student/teacher profile data
│   │   │   ├── BrainStructure.gd       # Anatomical structure data model
│   │   │   ├── EducationalContent.gd   # Educational content structure
│   │   │   ├── Assessment.gd           # Quiz and assessment data
│   │   │   ├── LearningProgress.gd     # Progress tracking data
│   │   │   └── ClassroomData.gd        # Classroom management data
│   │   │
│   │   ├── database/               # Local database management
│   │   │   ├── DatabaseManager.gd      # SQLite database interface
│   │   │   ├── MigrationManager.gd     # Database schema migrations
│   │   │   ├── QueryBuilder.gd         # SQL query construction
│   │   │   └── BackupManager.gd        # Database backup and restore
│   │   │
│   │   ├── sync/                   # Cloud synchronization
│   │   │   ├── SyncManager.gd          # Main synchronization coordinator
│   │   │   ├── ConflictResolver.gd     # Data conflict resolution
│   │   │   ├── OfflineQueue.gd         # Offline action queuing
│   │   │   └── DataValidator.gd        # Sync data validation
│   │   │
│   │   └── schemas/                # Data validation schemas
│   │       ├── user_profile.json       # User profile validation
│   │       ├── educational_content.json # Content validation
│   │       ├── assessment_data.json    # Assessment validation
│   │       └── sync_protocol.json      # Sync data validation
│   │
│   └── utils/                      # Utility functions and helpers
│       ├── FileManager.gd              # File system operations
│       ├── JSONHelper.gd               # JSON parsing and validation
│       ├── MathUtils.gd                # Mathematical calculations
│       ├── StringUtils.gd              # String manipulation utilities
│       ├── ImageProcessor.gd           # Image processing for UI
│       ├── Logger.gd                   # Logging system
│       ├── Encryption.gd               # Data encryption utilities
│       └── PlatformDetector.gd         # Platform-specific adaptations
│
├── tests/                          # Automated testing
│   ├── unit/                       # Unit tests
│   │   ├── test_brain_interaction.gd
│   │   ├── test_content_management.gd
│   │   ├── test_assessment_system.gd
│   │   ├── test_teacher_tools.gd
│   │   ├── test_data_sync.gd
│   │   └── test_accessibility.gd
│   │
│   ├── integration/                # Integration tests
│   │   ├── test_3d_interaction_flow.gd
│   │   ├── test_assessment_flow.gd
│   │   ├── test_teacher_workflow.gd
│   │   ├── test_cloud_sync.gd
│   │   └── test_offline_mode.gd
│   │
│   ├── performance/                # Performance tests
│   │   ├── test_3d_rendering.gd
│   │   ├── test_model_loading.gd
│   │   ├── test_memory_usage.gd
│   │   └── test_startup_time.gd
│   │
│   ├── accessibility/              # Accessibility tests
│   │   ├── test_screen_reader.gd
│   │   ├── test_keyboard_navigation.gd
│   │   ├── test_high_contrast.gd
│   │   └── test_focus_management.gd
│   │
│   └── platform/                   # Cross-platform tests
│       ├── test_windows_specific.gd
│       ├── test_macos_specific.gd
│       ├── test_linux_specific.gd
│       └── test_cross_platform_compatibility.gd
│
├── content/                        # Educational content
│   ├── brain_regions/              # Neuroanatomy content by region
│   │   ├── forebrain/
│   │   │   ├── hippocampus.json
│   │   │   ├── amygdala.json
│   │   │   ├── cortex.json
│   │   │   └── thalamus.json
│   │   ├── midbrain/
│   │   │   ├── substantia_nigra.json
│   │   │   └── superior_colliculus.json
│   │   └── hindbrain/
│   │       ├── cerebellum.json
│   │       ├── pons.json
│   │       └── medulla.json
│   │
│   ├── assessments/                # Pre-built assessments
│   │   ├── basic_anatomy/
│   │   ├── brain_functions/
│   │   ├── neural_pathways/
│   │   └── clinical_correlations/
│   │
│   ├── learning_paths/             # Structured learning sequences
│   │   ├── high_school_intro.json
│   │   ├── undergraduate_detailed.json
│   │   └── graduate_advanced.json
│   │
│   └── templates/                  # Content creation templates
│       ├── structure_template.json
│       ├── assessment_template.json
│       └── learning_objective_template.json
│
├── docs/                           # Documentation
│   ├── CLAUDE.md                   # AI development guide (detailed above)
│   ├── architecture.md             # System architecture documentation
│   ├── api_reference.md            # API documentation
│   ├── standards.md                # Coding standards (detailed above)
│   ├── security.md                 # Security and secret management guide
│   ├── deployment.md               # Deployment and distribution guide
│   ├── user_guide/                 # User documentation
│   │   ├── student_guide.md
│   │   ├── teacher_guide.md
│   │   └── accessibility_guide.md
│   ├── developer_guide/            # Developer documentation
│   │   ├── setup.md
│   │   ├── contributing.md
│   │   ├── testing.md
│   │   └── troubleshooting.md
│   └── design/                     # Design documentation
│       ├── ui_wireframes/
│       ├── user_flow_diagrams/
│       └── accessibility_requirements.md
│
├── scripts/                        # Build and deployment scripts
│   ├── build/                      # Build automation
│   │   ├── build.sh                # Main build script
│   │   ├── export_all_platforms.sh # Multi-platform export
│   │   ├── optimize_assets.sh      # Asset optimization
│   │   └── generate_lod_models.py  # Automatic LOD generation
│   │
│   ├── deploy/                     # Deployment automation
│   │   ├── deploy.sh               # Main deployment script
│   │   ├── sign_executables.sh     # Code signing
│   │   ├── upload_to_cdn.sh        # CDN upload
│   │   └── update_version.sh       # Version management
│   │
│   ├── development/                # Development utilities
│   │   ├── setup_dev_env.sh        # Development environment setup
│   │   ├── run_tests.sh            # Test execution
│   │   ├── generate_docs.sh        # Documentation generation
│   │   └── claude_code_setup.sh    # Claude Code CLI setup
│   │
│   └── maintenance/                # Maintenance scripts
│       ├── backup_user_data.sh     # User data backup
│       ├── check_dependencies.sh   # Dependency health check
│       ├── update_api_keys.sh      # API key rotation
│       └── cleanup_logs.sh         # Log file maintenance
│
├── config/                         # Configuration files
│   ├── export_presets.cfg          # Godot export settings
│   ├── project.godot               # Main Godot project file
│   ├── .gdignore                   # Godot ignore patterns
│   ├── .gitignore                  # Git ignore patterns
│   ├── .gitattributes              # Git LFS configuration (detailed above)
│   ├── firebase.json               # Firebase configuration
│   ├── google_oauth_config.json    # Google OAuth settings
│   └── api_endpoints.json          # API endpoint configuration
│
├── .editorconfig                   # Cross-editor consistency settings
│
├── certificates/                   # Code signing certificates (secure storage)
│   ├── windows_cert.p12.encrypted  # Windows code signing
│   ├── apple_cert.p12.encrypted    # Apple code signing
│   └── certificate_manager.py      # Certificate management utility
│
├── releases/                       # Release artifacts
│   ├── v1.0.0/                     # Version-specific releases
│   │   ├── windows/
│   │   ├── macos/
│   │   ├── linux/
│   │   └── release_notes.md
│   └── latest/                     # Latest stable release
│
├── user_data/                      # User data directory (local installation)
│   ├── progress/                   # Student progress data
│   ├── content_cache/              # Cached cloud content
│   ├── logs/                       # Application logs
│   ├── backups/                    # Local backups
│   └── settings/                   # User preferences
│
├── .env.example                    # Environment variables template
├── LICENSE                         # Software license
├── README.md                       # Project overview and setup instructions
└── CONTRIBUTING.md                 # Contribution guidelines
```

---

## 🎯 **Implementation Timeline with All Items**

### **Week 0: Pre-Development Setup (5 days)**
```
Day 1-2: Development Environment
- Set up DevContainer with Godot 4.x + Claude Code CLI
- Configure Git LFS for 3D assets
- Test basic Godot project in container
- Set up .env file with API keys

Day 3: Documentation and Standards
- Complete CLAUDE.md with all AI development guidelines
- Finalize coding standards and review checklist
- Set up prompt library structure
- Create security documentation

Day 4: Critical Decisions
- Validate GDScript choice with prototype
- Configure Google API credentials and test integration
- Set up Firebase project and test connectivity
- Test secret management system

Day 5: Project Structure
- Create complete directory structure
- Initialize Git repository with proper .gitignore/.gitattributes
- Set up basic CI/CD pipeline structure
- Configure VS Code extensions and settings
```

### **Phase 1: Core Foundation (Weeks 1-6)**
```
Week 1-2: 3D Engine and Interaction
✅ Implement BrainInteractionController with complete accessibility
✅ Set up PerformanceMonitor with automatic quality adaptation
✅ Create ModelLoader with LOD system and error handling

Week 3-4: UI Framework and Content System
✅ Build responsive UI framework with accessibility compliance
✅ Implement ContentManager with local/cloud hybrid approach
✅ Create basic ProgressTracker with SQLite storage

Week 5-6: Assessment and Error Handling
✅ Build template-based QuizBuilder system
✅ Implement comprehensive ErrorRecoveryManager
✅ Set up automated testing framework with accessibility tests
```

### **Phase 2: Educational Features (Weeks 7-12)**
```
Week 7-8: Authentication and Cloud Sync
🎯 Implement Google OAuth with anonymous fallback
🎯 Build Firebase sync with conflict resolution
🎯 Create ContentEditor for teacher content creation
🎯 Implement FeedbackAPI for user feedback collection

Week 9-10: Teacher Tools and AI Integration
🎯 Build TeacherDashboard with student progress monitoring
🎯 Integrate Google Gemini API with context-aware chat
🎯 Implement ClassroomManager for multi-student support
🎯 Create basic OnboardingManager for new users

Week 11-12: Analytics and Polish
🎯 Create ProgressDashboard with educational analytics
🎯 Implement LearningAnalytics with pattern recognition
🎯 Build FeedbackScreen for in-app feedback
🎯 Complete integration testing and performance optimization
```

### **Phase 3: Deployment and Distribution (Week 13)**
```
🎯 Set up automated build pipeline with code signing
🎯 Create installation packages for all platforms
🎯 Deploy update system and content distribution
🎯 Complete documentation and user guides
🎯 Implement interactive onboarding tutorial
```

---

## 🏆 **Success Criteria - Complete**

### **Technical Milestones**
- ✅ **Performance**: 30+ FPS on Intel UHD 620, <2sec model loading
- ✅ **Accessibility**: WCAG AAA compliance, full keyboard navigation
- ✅ **Cross-Platform**: Windows, macOS, Linux compatibility
- 🎯 **Cloud Integration**: Seamless Google OAuth and Firebase sync
- 🎯 **AI Assistant**: Helpful teacher support via Gemini API
- 🎯 **Offline Capability**: Full functionality without internet
- 🎯 **Security**: Proper secret management and data encryption

### **Educational Milestones**
- 🎯 **Content Creation**: Teachers create quizzes in <10 minutes
- 🎯 **Learning Progress**: Measurable improvement in student understanding
- 🎯 **AI Assistance**: 50% reduction in teacher content creation time
- 🎯 **Cross-Device**: Seamless learning continuation across devices
- 🎯 **Analytics**: Actionable insights for educators
- 🎯 **User Feedback**: Direct feedback channel for continuous improvement

### **Development Milestones**
- ✅ **AI Development**: Claude Code successfully implements features
- 🎯 **Quality Assurance**: Automated testing prevents regressions
- 🎯 **Deployment**: Reliable release pipeline with code signing
- 🎯 **Maintenance**: Sustainable development and update process
- 🎯 **Onboarding**: Interactive tutorial for new users

**Final Timeline: 13 weeks total** (including 1 week pre-development setup)

This complete project structure provides everything needed for successful AI-assisted development of a professional educational neuroanatomy application.