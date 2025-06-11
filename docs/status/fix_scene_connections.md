# Fix NeuroVision Scene Connections and Integration

## Context
I have a Godot 4.x educational neuroanatomy application called NeuroVision. The scenes are not properly connected and integrated. The project uses an autoload architecture with multiple managers, but the scenes have broken references, missing nodes, and improper signal connections.

## Current Issues
1. Scene files reference nodes that don't exist in the actual scene tree
2. EnhancedExplorationScene.gd expects nodes like `$CameraSystem/CameraPivot/Camera3D` but the scene file doesn't have this structure
3. UI components (InfoPanel, QuizPanel) are referenced but not properly instantiated
4. Model loading works but camera/lighting setup is inconsistent
5. Signal connections between components are not properly established
6. The scene transition from MainMenu to ExplorationScene doesn't properly initialize all systems

## Project Structure
- Main scene: `src/ui/screens/MainMenu.tscn`
- Exploration scenes: `src/scenes/ExplorationScene.tscn` and `src/scenes/EnhancedExplorationScene.tscn`
- UI components: `src/ui/components/StructureInfoPanel.tscn` and `src/ui/components/QuizPanel.tscn`
- Autoloads defined in project.godot
- Brain model: `assets/3d_models/raw/Internal-Structures.glb`

## Requirements
Fix all scene files and scripts to ensure:

1. **Scene Structure Consistency**
   - EnhancedExplorationScene.tscn must have all nodes referenced in EnhancedExplorationScene.gd
   - Proper node hierarchy: CameraSystem/CameraPivot/Camera3D
   - All UI nodes properly structured
   - Environment and lighting nodes present

2. **UI Integration**
   - InfoPanel and QuizPanel properly instantiated and connected
   - All @onready variables must reference existing nodes
   - Proper theme and styling applied

3. **Signal Connections**
   - All signals properly connected between components
   - Info panel signals connected to exploration scene
   - Brain interaction signals properly routed
   - Performance monitor signals connected

4. **Model Loading Pipeline**
   - Ensure ModelLoader properly integrates with scene
   - Brain model container properly set up
   - Collision detection working for structure selection
   - Proper material and lighting setup

5. **Camera System**
   - Working orbit controls with proper pivot
   - Correct initial positioning
   - Camera presets functional
   - Smooth rotation and zoom

6. **Scene Transitions**
   - MainMenu properly loads ExplorationScene
   - All systems initialize in correct order
   - No null reference errors
   - Proper cleanup on scene change

## Tasks

1. **Fix EnhancedExplorationScene.tscn**
   - Create proper node structure matching the .gd file
   - Add all missing nodes (CameraSystem, CameraPivot, etc.)
   - Properly instance UI components
   - Set up environment and lighting

2. **Update EnhancedExplorationScene.gd**
   - Ensure all @onready paths match actual scene structure
   - Add null checks for optional components
   - Fix signal connections
   - Ensure proper initialization order

3. **Fix UI Component Integration**
   - Ensure StructureInfoPanel.tscn exists and works
   - Ensure QuizPanel.tscn exists and works
   - Connect all UI signals properly

4. **Verify Autoload Integration**
   - Ensure all autoloads are properly accessed
   - Fix any circular dependencies
   - Proper error handling

5. **Create Test Scene**
   - Create a simple test scene that verifies all connections work
   - Include debug output for all major systems

## Expected Outcome
- Application starts from MainMenu without errors
- Clicking "Start Exploration" loads the exploration scene
- Brain model loads and displays properly
- Camera controls work (left-drag rotate, right-click select)
- UI panels show when structures are selected
- All signals fire properly
- No null reference errors in console

## File Priority
1. `src/scenes/EnhancedExplorationScene.tscn` - Fix scene structure
2. `src/scenes/EnhancedExplorationScene.gd` - Update node references
3. `src/ui/components/StructureInfoPanel.tscn` - Ensure exists and works
4. `src/ui/components/QuizPanel.tscn` - Ensure exists and works
5. `src/ui/screens/MainMenu.gd` - Verify scene loading

Please fix these files to create a properly integrated, working application where all scenes connect correctly and all features function as intended.