# Source Code Cleanup Plan

## Priority 1: Autoload Consolidation (HIGH IMPACT)

### Performance Systems (Consolidate 3 → 1)
**Action**: Merge into single `PerformanceMonitor.gd`
- [x] Current: PerformanceMonitor.gd, IntelOptimizer.gd, GraphicsOptimizationManager.gd
- [ ] Target: Enhanced PerformanceMonitor.gd with Intel module
- [ ] Archive: Move old files to `archived_code/autoload/`

### Debug Systems (Consolidate 2 → 1)
**Action**: Remove redundant debug autoload
- [x] Keep: DebugSystem.gd (comprehensive)
- [ ] Remove: DebugConsoleAutoload.gd (redundant wrapper)

## Priority 2: Systems Cleanup (MEDIUM IMPACT)

### 3D Interaction
**Duplicates Found**:
- BrainInteractionController.gd vs ImprovedBrainInteractionController.gd
- ModelLoader.gd vs SafeModelLoader.gd

**Action**: Keep improved versions
- [ ] Keep: ImprovedBrainInteractionController.gd, SafeModelLoader.gd
- [ ] Archive: BrainInteractionController.gd, ModelLoader.gd

### Empty Directories
- [ ] Remove: `systems/lighting/` (has .gdkeep but no implementation)

## Priority 3: UI System Consolidation (HIGH CONFUSION)

### Current State: THREE UI Systems!
1. `ui/` - Legacy UI (2 shaders, 2 themes)
2. `ui_atomic/` - Current atomic design (comprehensive)
3. `ui_components/` - New reusable system (just started)

### Recommended Action:
```
Phase 1: Archive legacy ui/
Phase 2: Merge ui_components best practices into ui_atomic
Phase 3: Single unified UI system
```

### Duplicate Shaders
- glass_morphism_ui.gdshader (in both ui/ and ui_atomic/)
- glass_morphism_ui_lite.gdshader (in both)

## Priority 4: Core & Utils (LOW IMPACT)

### Core
- Well organized, no changes needed
- Clear separation: config/, interaction/, managers/

### Utils
- Keep all 3 files (MemoryManager, SafeResourceLoader, SafeSignalConnector)
- Well-focused utilities

## File-by-File Actions

### To Archive Immediately:
```bash
archived_code/
├── autoload/
│   ├── IntelOptimizer.gd
│   ├── GraphicsOptimizationManager.gd
│   └── DebugConsoleAutoload.gd
├── systems/
│   ├── BrainInteractionController.gd
│   └── ModelLoader.gd
└── ui/  # Entire legacy UI folder
```

### To Delete:
- All .uid files (136 total)
- Duplicate shaders in ui/
- Empty directories without clear purpose

### To Consolidate:
1. Merge performance autoloads → PerformanceMonitor.gd
2. Update references in project.godot
3. Test thoroughly

## Impact on Claude Code

This cleanup will:
- Reduce confusion from 3 UI systems to 1
- Clear autoload redundancy (9 → 6 autoloads)
- Remove "which file to use?" decisions
- Make codebase more navigable

## Execution Order

1. **Backup first**: `git add -A && git commit -m "backup: before major src cleanup"`
2. **Run cleanup script**: Execute automated cleanup
3. **Manual consolidation**: Merge performance autoloads
4. **Test**: Ensure everything still works
5. **Commit**: Document changes clearly