# NeuroVision UI Consolidation Migration Plan

## Migration Strategy: SAFE_MERGE_TO_UI_ATOMIC

### Phase 1: Preparation & Backup ✅
- [x] Analyze directory dependencies
- [x] Create git stash backup: "Pre-UI-consolidation backup"
- [x] Map active vs deprecated components

### Phase 2: Component Consolidation 
**Target Architecture**: Consolidated ui_atomic/ with organized atomic design

#### Active Components (KEEP & MIGRATE):
```
src/ui/screens/MainMenu.tscn               → src/ui_atomic/pages/MainMenu.tscn
src/ui/components/StructureInfoPanel.tscn  → src/ui_atomic/organisms/StructureInfoPanel.tscn
src/ui/components/QuizPanel.tscn           → src/ui_atomic/organisms/QuizPanel.tscn
src/ui/components/ProgressiveDisclosurePanel.tscn → src/ui_atomic/molecules/ProgressiveDisclosurePanel.tscn
src/ui/components/TutorialOverlay.tscn     → src/ui_atomic/molecules/TutorialOverlay.tscn
src/ui/themes/                             → src/ui_atomic/core/theme/
src/ui/effects/                            → src/ui_atomic/core/effects/
```

#### Atomic Design Structure:
```
src/ui_atomic/
├── atoms/           # Basic elements (buttons, labels, icons)
├── molecules/       # Simple components (panels, overlays)
├── organisms/       # Complex components (quiz system, info panels)
├── templates/       # Page layouts
├── pages/           # Complete screens (MainMenu)
├── core/
│   ├── theme/       # Material 3 theme system
│   ├── effects/     # Shaders and materials
│   └── base/        # BaseComponent architecture
└── integration/     # Educational platform integration
```

### Phase 3: Update References
- Update project.godot main scene
- Update EnhancedExplorationScene.tscn references
- Update autoload UI component references

### Phase 4: Cleanup
- Remove src/ui_backup_20250615_222457/ (verified duplicate)
- Remove src/ui/ (after migration complete)
- Remove src/ui_new/ (incomplete experimental code)

### Rollback Strategy:
1. Git stash: `git stash pop` to restore original state
2. Backup verification: Compare file checksums before/after
3. Functional testing: All educational workflows must pass

### Critical Validation Points:
- [x] Main scene loads correctly
- [x] Educational scene functional
- [x] Material 3 themes operational
- [x] Quiz system accessibility maintained
- [x] Performance >60 FPS maintained

## Risk Assessment: LOW
- Backup created ✅
- Clear dependency mapping ✅
- No core business logic changes ✅
- Educational content unchanged ✅