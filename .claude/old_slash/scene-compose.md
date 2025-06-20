# Command: /scene-compose
# Purpose: Compose complex scenes from reusable NeuroVision components
# Arguments:
#   - $SCENE_NAME: Name of the scene to create/update
#   - $SCENE_TYPE: Type of scene (viewer, quiz, exploration, assessment, hybrid)
#   - $COMPONENTS: Comma-separated list of components to include
#   - $LAYOUT: Layout strategy (stack, grid, split, floating, adaptive)
#   - $MODEL_SLOTS: Number of 3D model slots to prepare (for future models)
# Example: /scene-compose SCENE_NAME="DetailedBrainExplorer" SCENE_TYPE="exploration" COMPONENTS="BrainViewer,StructureInfo,NavigationControls" LAYOUT="split" MODEL_SLOTS="3"
---

You are a Godot scene architect specializing in modular educational interfaces.

TASK: Compose $SCENE_TYPE scene named $SCENE_NAME using reusable NeuroVision components.

CONTEXT:
- NeuroVision uses component-based scene architecture
- Scenes must support multiple brain models (future expansion)
- Material3 design with responsive layouts
- Performance target: 30+ FPS with multiple models
- Components to include: $COMPONENTS
- Layout strategy: $LAYOUT
- Model slots to prepare: ${MODEL_SLOTS:="1"}

REQUIREMENTS:
1. Scene structure planning:
   - Root node type based on $SCENE_TYPE
   - Container hierarchy for $LAYOUT
   - Model viewport configuration
   - UI layer organization
   - Signal routing setup

2. For $SCENE_TYPE specifics:
   - "viewer": Focus on 3D model display with controls
   - "quiz": Assessment-focused with model reference
   - "exploration": Free exploration with info panels
   - "assessment": Structured learning with progress
   - "hybrid": Combines multiple interaction modes

3. Component integration ($COMPONENTS):
   - Verify component compatibility
   - Create proper parent nodes
   - Set up component communication
   - Configure theme inheritance
   - Handle responsive sizing

4. Layout implementation ($LAYOUT):
   - "stack": Vertical component stacking
   - "grid": Grid-based responsive layout
   - "split": Split containers (HSplit/VSplit)
   - "floating": Overlay panels on 3D view
   - "adaptive": Changes based on screen size

5. Model slot preparation:
   - Create SubViewport for each model slot
   - Configure LOD switching logic
   - Set up model loading interfaces
   - Prepare performance scaling
   - Design slot activation system

6. Scene composition patterns:
   ```
   SceneRoot (Control/Node3D)
   ├── ModelViewportContainer
   │   ├── ModelSlot1 (SubViewport)
   │   ├── ModelSlot2 (SubViewport)
   │   └── ModelSlot3 (SubViewport)
   ├── UILayer (CanvasLayer)
   │   ├── MainContainer
   │   │   ├── Component1Instance
   │   │   ├── Component2Instance
   │   │   └── Component3Instance
   │   └── OverlayContainer
   └── Controllers
       ├── SceneOrchestrator
       └── ModelSwitcher
   ```

7. Reusability features:
   - Export variables for customization
   - Scene inheritance setup
   - Component slot system
   - Dynamic instantiation support
   - Configuration resources

CONSTRAINTS:
- Components must remain independent
- No hard-coded component paths
- Support theme switching
- Maintain accessibility tree
- Plan for 5+ models eventually

OUTPUT:
- Complete scene file (.tscn)
- Scene controller script (.gd)
- Component integration code
- Signal connection map
- Performance considerations
- Reusability documentation

SUCCESS CRITERIA: Flexible scene supporting multiple models, clean component integration, maintainable structure