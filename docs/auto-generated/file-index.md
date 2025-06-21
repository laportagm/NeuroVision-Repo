# File Location Index

<!-- AUTO-GENERATED: Last updated by Claude Code on 2025-06-21 -->
<!-- UPDATE TRIGGER: When new files are created or moved -->
<!-- CLAUDE CODE: Update this file when you create, move, or delete important files -->

## Quick File Location Reference for Claude Code

### Core Autoload Services
```
# Educational Platform Core
UnifiedColorManager         → src/autoload/UnifiedColorManager.gd
CoreSystemManager          → src/core/managers/CoreSystemManager.gd
UISystemManager           → src/core/managers/UISystemManager.gd
EducationalPlatformManager → src/core/managers/EducationalPlatformManager.gd

# Resource and Content Management
ResourceManager           → src/core/managers/ResourceManager.gd
AssessmentService        → src/systems/assessment/AssessmentService.gd
ProgressTracker          → src/autoload/ProgressTracker.gd

# Interaction and Visualization
HighlightMaterialManager → src/systems/3d_interaction/HighlightMaterialManager.gd
PerformanceMonitor       → src/autoload/PerformanceMonitor.gd

# Supporting Services
UIThemeManager           → src/autoload/UIThemeManager.gd
AuthenticationManager    → src/autoload/AuthenticationManager.gd
NetworkManager           → src/autoload/NetworkManager.gd
DebugSystem             → src/debug/DebugSystem.gd
```

### Main Scenes
```
# Primary Entry Points
MainMenu                 → scenes/ui/MainMenu.tscn
EnhancedExplorationScene → scenes/3d/EnhancedExplorationScene.tscn

# Supporting Scenes
StructureInfoPanel       → src/ui_atomic/organisms/StructureInfoPanel.tscn
```

### UI Components (src/ui_atomic/)
```
# Atoms (Basic Elements)
atoms/                   → Basic UI elements (buttons, labels, inputs)

# Molecules (Combined Elements)  
molecules/               → Combined UI components (panels, forms)

# Organisms (Complex Systems)
organisms/               → Complex UI systems (dialogs, layouts)
├── StructureInfoPanel.tscn  → Brain structure information display
└── QuizPanel.tscn          → Educational assessment interface
```

### Systems and Controllers
```
# 3D Interaction Systems
3d_interaction/BrainInteractionController.gd    → Brain structure selection
3d_interaction/HighlightMaterialManager.gd      → 3D highlighting system

# 3D Rendering Systems  
3d_rendering/ComprehensiveBrainRenderingSystem.gd → Advanced brain rendering

# Assessment Systems
assessment/AssessmentService.gd                  → Educational testing framework
```

### Project Configuration
```
# Core Configuration
project.godot           → Main project configuration (13 autoloads)
.mcp.json              → MCP server configuration for Claude Code

# Documentation Structure
docs/CLAUDE.md         → Main development guide
docs/templates/        → Code templates for Claude Code
docs/workflows/        → Development workflows
docs/auto-generated/   → Self-updating documentation
```

## File Patterns for Claude Code

### When User Says "autoload" → Check These Locations:
```
src/autoload/           # Service autoloads (7 files)
src/core/managers/      # Manager autoloads (4 files)  
src/systems/assessment/ # Assessment autoload (1 file)
src/debug/             # Debug autoload (1 file)
project.godot          # Autoload registration
```

### When User Says "UI component" → Check These Locations:
```
src/ui_atomic/atoms/     # Basic UI elements
src/ui_atomic/molecules/ # Combined UI elements  
src/ui_atomic/organisms/ # Complex UI systems
scenes/ui/              # UI scenes
```

### When User Says "brain interaction" → Check These Locations:
```
src/systems/3d_interaction/           # 3D interaction controllers
scenes/3d/EnhancedExplorationScene.*  # Main brain interaction scene
src/systems/3d_rendering/             # 3D rendering systems
```

### When User Says "educational content" → Check These Locations:
```
src/systems/assessment/     # Educational assessment systems
src/core/managers/         # Educational platform management
assets/data/              # Educational content databases
```

### When User Says "theme" or "color" → Check These Locations:
```
src/autoload/UnifiedColorManager.gd   # Color system authority
src/autoload/UIThemeManager.gd        # Theme application
src/core/managers/UISystemManager.gd  # UI coordination
```

### When User Says "performance" → Check These Locations:
```
src/autoload/PerformanceMonitor.gd    # Performance monitoring
src/autoload/IntelOptimizer.gd        # Intel UHD 620 optimizations
src/core/managers/CoreSystemManager.gd # System health monitoring
```

## Project Statistics

**Total GDScript Files**: 71 files in src/  
**Autoload Services**: 13 active systems  
**UI Components**: 3-tier atomic design structure  
**Main Scenes**: 2 primary scenes (Menu + 3D Exploration)  
**Educational Systems**: 5 core educational services  
**Documentation Files**: Self-updating structure with templates  

## Common File Operations for Claude Code

### Creating New UI Component:
1. **Location**: `src/ui_atomic/[atoms|molecules|organisms]/ComponentName.gd`
2. **Template**: `docs/templates/ui-component-template.md`
3. **Registration**: Add to `UISystemManager` if needed

### Creating New Autoload:
1. **Location**: `src/autoload/ServiceName.gd` (services) or `src/core/managers/ManagerName.gd` (managers)
2. **Template**: `docs/templates/autoload-template.md`
3. **Registration**: Add to `project.godot` [autoload] section

### Creating New Scene:
1. **Location**: `scenes/[ui|3d]/SceneName.tscn`
2. **Script**: `scenes/[ui|3d]/SceneName.gd`
3. **Template**: `docs/templates/scene-template.md`

### Creating New Educational System:
1. **Location**: `src/systems/[category]/SystemName.gd`
2. **Integration**: Register with `EducationalPlatformManager`
3. **Validation**: Add to debug console test commands

## Recent File Changes (Claude Code Updates)

<!-- CLAUDE CODE: Add new files, moves, or significant changes here with date -->
- 2025-06-21: Created initial file index from project scan (71 GDScript files)
- [CLAUDE CODE: Document file creation, moves, and structural changes]

## Directory Change Tracking

**Directories to Monitor for Changes:**
- `src/autoload/` - Service additions/removals
- `src/core/managers/` - Manager system changes
- `src/ui_atomic/` - UI component additions
- `scenes/` - New scene creation
- `src/systems/` - Educational system additions

**Files to Monitor for Configuration Changes:**
- `project.godot` - Autoload registration changes
- `CLAUDE.md` - Development guide updates
- `.mcp.json` - MCP server configuration changes

---
**Last Scanned**: 2025-06-21 by Claude Code  
**File Count**: 71 GDScript files  
**Structure Version**: 2.1.0  
**Scan Depth**: Complete project structure analysis