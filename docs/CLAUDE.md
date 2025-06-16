# NeuroVision Professional Medical Education Platform - Claude Development Guide

## Project Overview
**NeuroVision** is a mature, professional neuroanatomy education platform built with Godot 4.4.1, designed for medical students, researchers, and healthcare professionals. The platform combines interactive 3D brain exploration with AI-powered learning assistance and comprehensive accessibility support.

### Current Status: Phase 2 - Educational Features (In Progress)
- **Phase 1**: ✅ **COMPLETE** - Core Foundation (120+ FPS achieved, all systems operational)
- **Phase 2**: 🔄 **IN PROGRESS** - Advanced Educational Features
- **Technical Maturity**: Professional medical-grade platform operational

## Quick Reference
- **Engine**: Godot 4.4.1 with GDScript
- **Performance**: 120+ FPS achieved (target: 30+ FPS Intel UHD 620)
- **Design System**: Material 3 with unified color management
- **Accessibility**: WCAG AAA compliance framework
- **Architecture**: 10 core autoload systems, modular educational platform

## Current System Architecture

### Core Autoload Managers (10 Systems)
```gdscript
# Primary System Managers
UnifiedColorManager          # Central color system & theme coordination
CoreSystemManager           # Error recovery, performance, accessibility
UISystemManager            # Theme management & UI coordination  
EducationalPlatformManager  # Learning progress & educational features
ResourceManager            # 3D model loading & optimization

# Specialized Services
NetworkManager             # Connectivity & cloud features
AssessmentService          # Quiz & educational assessment system
HighlightMaterialManager   # 3D visual feedback & selection
ProgressTracker           # Learning analytics & progress tracking
```

### Key Systems Operational
- ✅ **3D Brain Interaction**: Advanced structure selection and highlighting
- ✅ **Professional UI**: Material 3 with glass morphism effects
- ✅ **Unified Color System**: Theme-aware color management (recent migration complete)
- ✅ **Performance Optimization**: Intel UHD 620 specific optimizations
- ✅ **Educational Content**: Brain structure database with assessment integration
- ✅ **Accessibility Framework**: WCAG AAA compliance infrastructure

## Development Standards

### Material 3 Design System
```gdscript
# Access colors through unified system
var primary_color = UnifiedColorSystem.get_color("primary")
var brain_color = UnifiedColorSystem.get_brain_structure_color("hippocampus")

# Theme switching
UnifiedColorManager.set_theme_variant("enhanced")  # Student-friendly
UnifiedColorManager.set_theme_variant("minimal")   # Clinical/professional
```

### Performance Requirements (Intel UHD 620 Optimized)
- **Target**: 30+ FPS minimum, 60+ FPS optimal
- **Achieved**: 120+ FPS stable operation
- **Memory**: <500MB stable usage
- **UI Response**: <100ms interaction feedback
- **Load Time**: <3 seconds from launch to interaction

### Accessibility Standards (WCAG AAA)
```gdscript
# All interactive elements must have accessibility support
button.accessible_name = "Structure Selection"
button.accessible_description = "Select hippocampus for detailed information"
# Touch targets: ≥44px (medical education standard)
# Contrast ratios: 7:1+ for all text and interactive elements
```

### Educational Content Standards
- **Accuracy**: Medical textbook level (not medical-grade precision)
- **Content Source**: `content/brain_structures.json` - 21+ brain structures
- **Assessment Integration**: Quiz system operational with progress tracking
- **Learning Objectives**: Structure identification, function understanding, clinical relevance

## Current Development Priorities

### Phase 2 Focus Areas
1. **Enhanced Assessment Tools** - Advanced quiz generation and analytics
2. **Teacher Dashboard** - Classroom management and progress monitoring  
3. **AI Assistant Integration** - Contextual learning support
4. **Content Creation Tools** - Teacher content authoring system
5. **Analytics Dashboard** - Learning effectiveness metrics

### Code Quality Requirements
- **Color System**: Use `UnifiedColorSystem.get_color()` - no hardcoded colors
- **Theme Awareness**: All UI components must support theme switching
- **Performance**: Maintain 60+ FPS target, Intel UHD 620 compatibility
- **Accessibility**: WCAG AAA compliance for all new features
- **Educational Context**: Include learning objectives in all educational features

## Architecture Patterns

### 3D Interaction Pattern
```gdscript
# Brain structure selection workflow
func select_brain_structure(structure_name: String) -> void:
    # 1. Validate structure exists
    if not StructureContentService.has_structure(structure_name):
        push_error("Unknown structure: " + structure_name)
        return
    
    # 2. Update highlight system
    HighlightMaterialManager.highlight_structure(structure_name)
    
    # 3. Load educational content
    var content = StructureContentService.get_structure_content(structure_name)
    
    # 4. Update UI panels
    StructureInfoPanel.display_content(content)
    
    # 5. Track learning progress
    ProgressTracker.record_structure_interaction(structure_name)
```

### Theme-Aware Development
```gdscript
# Always use unified color system
var surface_color = UnifiedColorSystem.get_color("surface")
var accent_color = UnifiedColorSystem.get_educational_color("primary")

# Apply theme-aware shader parameters
ShaderColorAdapter.set_glass_morphism_parameters(material, current_theme)
```

### Performance Monitoring
```gdscript
# Monitor performance and adapt quality
func _check_performance():
    var fps = CoreSystemManager.get_average_fps()
    if fps < 45:
        # Reduce quality for Intel UHD 620 compatibility
        ResourceManager.set_quality_level("medium")
        UISystemManager.disable_expensive_effects()
```

## Technical Achievements

### Performance Metrics
- **Frame Rate**: 120+ FPS stable (exceeds 30+ FPS target by 4x)
- **Memory Usage**: <500MB peak during typical operations  
- **UI Response**: <100ms for all interactions
- **Load Performance**: <3 seconds from launch to first interaction

### Accessibility Compliance
- **WCAG AAA**: 7:1+ contrast ratios throughout
- **Touch Targets**: 50x44px minimum (exceeds 44px requirement)
- **Keyboard Navigation**: Full interface accessibility
- **Screen Reader**: Semantic markup and ARIA support
- **Theme Support**: High contrast and colorblind-safe variants

### Educational Standards
- **Content Accuracy**: Medical textbook level neuroanatomy
- **Structure Coverage**: 21+ brain regions with detailed information
- **Assessment System**: Quiz framework with progress tracking
- **Learning Analytics**: Progress monitoring and effectiveness metrics

## Development Workflow

### Quality Gates
1. **Performance**: Maintain 60+ FPS on all features
2. **Accessibility**: WCAG AAA validation required
3. **Color System**: Use UnifiedColorSystem - no hardcoded colors
4. **Theme Compatibility**: Test all 4 theme variants
5. **Educational Value**: Include learning objectives

### Testing Requirements
- **Manual Testing**: All educational workflows verified
- **Performance Testing**: Intel UHD 620 compatibility confirmed
- **Accessibility Testing**: Screen reader and keyboard navigation
- **Theme Testing**: All variants functional and compliant

## Key Principles

1. **Professional Medical Standards**: Medical-grade reliability and accuracy
2. **Universal Accessibility**: WCAG AAA compliance mandatory
3. **Performance Excellence**: 60+ FPS target, Intel UHD 620 compatible
4. **Educational Effectiveness**: Learning objectives drive all feature development
5. **Material 3 Consistency**: Unified design system throughout
6. **Theme Awareness**: All components support dynamic theme switching

## Emergency Contacts & Documentation

- **Architecture**: See `NEUROVISION_ARCHITECTURE_DIAGRAM.md`
- **Performance**: See `PROFESSIONAL_UI_IMPLEMENTATION_REPORT.md`  
- **Color System**: See `COLOR_SYSTEM_MIGRATION_COMPLETE.md`
- **Progress**: See `docs/status/PROJECT_PROGRESS.md`

---

**Platform Status**: Professional medical education platform operational with 120+ FPS performance, WCAG AAA accessibility compliance, and comprehensive Material 3 design system. All Phase 1 objectives exceeded, Phase 2 educational enhancements in progress.
