# NeuroVision Theme System Architecture

This directory contains the comprehensive Material 3-based theme system for the NeuroVision educational neuroscience platform. The theme system has been organized into logical subdirectories for better maintainability and development workflow.

## Directory Structure

```
src/ui/themes/
├── archive/                    # Deprecated/legacy theme files
├── core/                      # Core theme foundation systems
├── generators/                # Theme generation and creation tools
├── presets/                   # Educational context-aware theme presets
├── resources/                 # Generated theme files and assets
├── utilities/                 # Theme application and integration utilities
└── validation/               # Theme validation and accessibility checking
```

## Core Systems (`core/`)

### **M3DesignTokens.gd** - Material 3 Design Foundation
- **Purpose**: Central Material 3 design token system defining colors, typography, and spacing
- **Usage**: Single source of truth for all theme colors and design decisions
- **Features**: 
  - WCAG AAA compliant color palette
  - Professional medical education color scheme
  - Educational brain structure color integration
  - Accessibility-first design tokens

### **UnifiedColorSystem.gd** - Color Management System  
- **Purpose**: Enforces unified color access across the entire application
- **Usage**: Prevents hardcoded colors and ensures theme consistency
- **Features**:
  - Color access validation and logging
  - Theme switching integrity enforcement
  - Fallback color handling
  - Educational context-aware color resolution

## Theme Generators (`generators/`)

### **Material3ThemeGenerator.gd** - Primary Theme Engine
- **Purpose**: Main theme generation system implementing Material 3 design principles
- **Usage**: Runtime theme generation and switching
- **Features**:
  - Complete M3-compliant theme generation
  - Educational brain structure color integration
  - Multiple theme variants (enhanced, minimal, high_contrast, colorblind_safe)
  - Glass morphism effects for modern educational UI

### **ThemeResourceGenerator.gd** - Static Theme File Generator
- **Purpose**: Creates `.tres` theme resource files for static theme loading
- **Usage**: Pre-generates theme files for optimal performance
- **Features**:
  - Exports themes to `resources/themes/` directory
  - Creates DarkTheme.tres, HighContrastTheme.tres, ColorblindTheme.tres
  - Backup system for existing theme files
  - Educational component styling integration

### **GenerateNeuroVisionThemes.gd** - Editor Theme Generation Tool
- **Purpose**: EditorScript for generating all NeuroVision theme variations
- **Usage**: Run from Godot Editor (Tools > Execute Script)
- **Features**:
  - Batch generation of all theme variants
  - Educational context-specific customizations
  - Accessibility validation integration
  - Medical education styling optimizations

### **GenerateThemeResources.gd** - Resource Generation Helper
- **Purpose**: Helper script for theme resource file generation and management
- **Usage**: Utility for creating and managing theme resource files
- **Features**:
  - Theme resource file creation and validation
  - Educational component resource generation
  - Asset management for theme-related resources

## Educational Presets (`presets/`)

### **ThemePresetManager.gd** - Advanced Educational Preset System
- **Purpose**: Context-aware theme preset management for educational environments
- **Usage**: Provides theme presets optimized for different educational contexts
- **Features**:
  - 6 educational presets (medical_student_study, clinical_training, research_presentation, etc.)
  - Institutional branding support (hospitals, medical schools)
  - Dynamic theme recommendations based on user context
  - Compliance validation (HIPAA, WCAG AAA, Section 508)
  - Learning environment optimization

## Generated Resources (`resources/`)

### **themes/** - Generated Theme Files
Contains the generated `.tres` theme resource files:
- **DarkTheme.tres** - Primary dark theme with cyan educational accents
- **HighContrastTheme.tres** - Accessibility-focused high contrast theme
- **ColorblindTheme.tres** - Blue-orange colorblind-safe educational palette

### **generate_theme_resources.tscn** - Theme Generation Scene
- **Purpose**: Godot scene for interactive theme generation and testing
- **Usage**: Load in editor for theme development and testing
- **Features**: Visual theme generation interface

## Theme Utilities (`utilities/`)

### **apply_neurovision_theme.gd** - Runtime Theme Application
- **Purpose**: Applies NeuroVision theme colors and styling to UI at runtime
- **Usage**: Dynamic theme application to scene hierarchies
- **Features**:
  - Recursive theme application to UI nodes
  - Component-specific styling (panels, buttons, labels, etc.)
  - Material 3 surface hierarchy implementation
  - Educational component styling

### **M3ComponentApplicator.gd** - Material 3 Component Styling
- **Purpose**: Applies Material 3 styling to individual UI components
- **Usage**: Component-level theme application and styling
- **Features**:
  - Material 3 component styling patterns
  - Educational UI component optimizations
  - Accessibility-compliant component styling

### **M3ComponentIntegrator.gd** - Component Integration System
- **Purpose**: Integrates Material 3 components with existing NeuroVision UI
- **Usage**: Seamless integration of M3 styling with educational components
- **Features**:
  - Legacy component integration
  - Educational workflow preservation
  - Component hierarchy management

### **M3AnimationHelper.gd** - Material 3 Animation System
- **Purpose**: Provides Material 3-compliant animations and transitions
- **Usage**: Theme switching animations and UI transitions
- **Features**:
  - Material 3 motion design principles
  - Educational context-appropriate animations
  - Performance-optimized transitions

### **M3PerformanceIntegration.gd** - Performance Optimization
- **Purpose**: Optimizes theme system performance for educational use
- **Usage**: Performance monitoring and optimization
- **Features**:
  - Theme switching performance optimization
  - Memory usage monitoring
  - Educational session performance tracking

### **PerformanceThemeAdapter.gd** - Adaptive Performance Theming
- **Purpose**: Adapts theme complexity based on system performance
- **Usage**: Dynamic theme quality adjustment
- **Features**:
  - Performance-based theme adaptation
  - Educational experience preservation
  - System capability detection

### **ShaderColorAdapter.gd** - Shader Color Integration
- **Purpose**: Integrates theme colors with shader-based UI effects
- **Usage**: Theme-aware shader color management
- **Features**:
  - Glass morphism shader integration
  - Educational UI effect color management
  - Dynamic shader color updating

## Validation Systems (`validation/`)

### **ColorSystemValidator.gd** - Color System Validation
- **Purpose**: Build-time validation to prevent color system bypassing
- **Usage**: Development and CI/CD pipeline validation
- **Features**:
  - Hardcoded color detection
  - Theme consistency validation
  - WCAG accessibility compliance checking
  - Educational color scheme validation

### **M3AccessibilityValidator.gd** - Accessibility Compliance
- **Purpose**: Ensures Material 3 theme meets accessibility standards
- **Usage**: Accessibility validation for educational compliance
- **Features**:
  - WCAG AAA compliance validation
  - Educational accessibility requirements
  - Medical education accessibility standards
  - Color contrast validation

## Deprecated/Archive (`archive/`)

Contains legacy theme system files that have been superseded by the current Material 3 implementation:

- **EducationalColorSystem.gd** - Replaced by M3DesignTokens.gd
- **ColorSystemIntegration.gd** - Functionality merged into current system
- **ColorSystemMigration.gd** - Migration utilities (no longer needed)
- **M3ColorMigrator.gd** - Color migration tools (completed)

These files are preserved for reference but should not be used in new development.

## Development Workflow

### **Adding New Themes**
1. Define colors in `M3DesignTokens.gd`
2. Use `Material3ThemeGenerator.gd` for runtime generation
3. Use `ThemeResourceGenerator.gd` for static `.tres` files
4. Test with `ColorSystemValidator.gd` and `M3AccessibilityValidator.gd`

### **Educational Context Integration**
1. Use `ThemePresetManager.gd` for context-aware presets
2. Integrate educational colors through `M3DesignTokens.gd`
3. Apply with `apply_neurovision_theme.gd` utilities
4. Validate educational accessibility requirements

### **Performance Optimization**
1. Monitor with `M3PerformanceIntegration.gd`
2. Adapt with `PerformanceThemeAdapter.gd`
3. Use static `.tres` files for performance-critical scenarios

## Integration Points

The theme system integrates with:
- **UISystemManager** - Theme switching and management
- **Educational UI Components** - Context-aware styling
- **Accessibility Systems** - WCAG compliance
- **Performance Monitoring** - Educational session optimization
- **Brain Structure Visualization** - Educational color coordination

## Accessibility Compliance

All themes maintain:
- **WCAG AAA** color contrast ratios (7:1+)
- **Educational accessibility** standards
- **Medical education** compliance requirements
- **Section 508** government accessibility standards
- **HIPAA** compliant design practices (where applicable)

This organized theme system provides a robust, maintainable, and educationally-focused theming infrastructure for the NeuroVision platform.