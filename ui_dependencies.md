# UI Dependencies Report

This document lists all files outside of `src/ui/` that import UI components from that directory.

## Summary

Total files with UI dependencies: 12

## Files and Their UI Imports

### 1. **src/scenes/EnhancedExplorationScene.gd**
- **Import**: `preload("res://src/ui/themes/utilities/apply_neurovision_theme.gd")`
- **Line**: 201
- **Purpose**: Applies comprehensive NeuroVision theme to entire UI hierarchy

### 2. **src/autoload/UIThemeManager.gd**
- **Import**: `preload("res://src/ui/themes/generators/Material3ThemeGenerator.gd")`
- **Line**: 23
- **Purpose**: Preloads Material 3 theme generator for dynamic theme generation

### 3. **src/core/managers/UISystemManager.gd**
- **Import**: `preload("res://src/ui/themes/generators/Material3ThemeGenerator.gd")`
- **Line**: 29
- **Purpose**: Preloads Material 3 theme generator for consolidated UI system management

### 4. **src/autoload/OnboardingManager.gd**
- **Import**: `load("res://src/ui/components/TutorialOverlay.tscn")`
- **Line**: 228
- **Purpose**: Loads tutorial overlay component for onboarding system

### 5. **src/core/managers/ResourceManager.gd**
- **Imports**:
  - `"res://src/ui/resources/materials/GlassPanelMaterial.tres"`
  - `"res://src/ui/resources/styles/GlassPanelStyle.tres"`
  - `"res://src/ui/resources/styles/SidebarPanelStyle.tres"`
  - `"res://src/ui/resources/styles/BottomPanelStyle.tres"`
- **Lines**: 49-52
- **Purpose**: Defines essential UI resources for preloading

### 6. **src/autoload/UIPoolManager.gd**
- **Import**: `"res://src/ui/components/NotificationPopup.tscn"`
- **Line**: 33
- **Purpose**: Scene path for notification popup pooling configuration

### 7. **src/autoload/UIAdaptationManager.gd**
- **Import**: `load("res://src/ui/themes/EducationalThemeGenerator.gd")`
- **Line**: 428
- **Purpose**: Loads educational theme generator for adaptive theme generation

### 8. **src/utils/launch_app.gd**
- **Import**: `load("res://src/ui/screens/MainMenu.tscn")`
- **Line**: 11
- **Purpose**: Loads main menu scene for app launch

### 9. **tools/scripts/setup_unified_colors.gd**
- **Imports**:
  - `"res://src/ui/themes/M3DesignTokens.gd"`
  - `"res://src/ui/themes/ColorSystemMigration.gd"`
  - `"res://src/ui/themes/ShaderColorAdapter.gd"`
  - `"res://src/ui/themes/ThemePresetManager.gd"`
  - `"res://src/ui/themes/ColorSystemValidator.gd"`
- **Lines**: Various
- **Purpose**: Setup script for unified color system integration

### 10. **project.godot**
- **Imports**:
  - `"*res://src/ui/resources/materials/GlassPanelMaterial.tres"`
  - `"*res://src/ui/resources/styles/GlassPanelStyle.tres"` 
  - `"*res://src/ui/resources/styles/SidebarPanelStyle.tres"`
  - `"*res://src/ui/resources/styles/BottomPanelStyle.tres"`
- **Lines**: Not applicable (configuration file)
- **Purpose**: Preload paths defined in project configuration

### 11. **docs/MEDICAL_GLASS_V2_INTEGRATION.md**
- **Import References**: Documentation references to various UI paths
- **Purpose**: Documentation only, not actual code imports

### 12. **UNIFIED_COLOR_SYSTEM_SETUP.md**
- **Import References**: Documentation references to various UI paths
- **Purpose**: Documentation only, not actual code imports

## Categorized by Import Type

### Scene Files (.tscn)
- `TutorialOverlay.tscn` - Used by OnboardingManager
- `MainMenu.tscn` - Used by launch_app utility
- `NotificationPopup.tscn` - Referenced in UIPoolManager config

### Script Files (.gd)
- `apply_neurovision_theme.gd` - Used by EnhancedExplorationScene
- `Material3ThemeGenerator.gd` - Used by UIThemeManager and UISystemManager
- `EducationalThemeGenerator.gd` - Used by UIAdaptationManager
- Various theme-related scripts used by setup_unified_colors tool

### Resource Files (.tres)
- `GlassPanelMaterial.tres` - Referenced in ResourceManager
- `GlassPanelStyle.tres` - Referenced in ResourceManager
- `SidebarPanelStyle.tres` - Referenced in ResourceManager
- `BottomPanelStyle.tres` - Referenced in ResourceManager

## Analysis

1. **Most Common Dependencies**:
   - Theme generators (Material3ThemeGenerator, EducationalThemeGenerator)
   - UI resources (materials and styles)
   - Scene files for specific UI components

2. **Key External Systems Depending on UI**:
   - Autoload managers (UIThemeManager, UIAdaptationManager, OnboardingManager)
   - Core managers (UISystemManager, ResourceManager)
   - Main scenes (EnhancedExplorationScene)
   - Development tools (setup scripts)

3. **Potential Refactoring Considerations**:
   - Theme generators could potentially be moved to autoload or core systems
   - UI resources might be better managed through a centralized resource system
   - Some dependencies are for configuration/setup only and not runtime

## Recommendations

1. Consider moving frequently-used theme generators to a more central location
2. Evaluate if UI resources should be part of a resource management system rather than direct imports
3. Document the purpose of each UI dependency to ensure they're necessary
4. Consider creating interfaces or abstract base classes to reduce direct UI dependencies