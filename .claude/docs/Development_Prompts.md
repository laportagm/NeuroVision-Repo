# NeuroVision Cursor System Development Prompts

> **Generated from comprehensive project analysis of NeuroVision-Repo**  
> **Focus**: Enhancing and extending cursor functionality for educational neuroanatomy application  
> **Target**: Godot 4.x best practices with accessibility and performance considerations

---

## Project Context Summary

### Current Cursor Implementation
- **3D Interaction**: `BrainInteractionController.gd` handles raycasting, selection, and highlighting
- **Camera Control**: `SmoothCameraController.gd` manages camera movement with mouse input
- **Input System**: Well-defined input actions for 3D interaction, camera rotation, and zoom
- **Visual Feedback**: Material-based highlighting for selected/hovered brain structures
- **Educational Focus**: Designed for neuroanatomy learning with structure information display

### Key Findings
- Right-click selection of 3D brain structures with visual feedback
- Left-click camera rotation with smooth interpolation and inertia
- Middle-click panning and scroll wheel zooming
- Multi-selection support with Shift+Right-click
- Integration with educational UI components (StructureInfoPanel)

---

## Core System Enhancement Prompts

### 1. Custom Cursor Visual System

**Prompt: Implement Dynamic Cursor Visual States**

```
Create a comprehensive cursor visual system for the NeuroVision educational neuroanatomy application. The system should provide contextual visual feedback to enhance user experience during 3D brain exploration.

Requirements:
1. Create a `CursorManager.gd` autoload script that manages cursor states globally
2. Design cursor states for different interaction modes:
   - Default: Standard pointer
   - Hovering: Highlight cursor when over selectable brain structures
   - Selecting: Crosshair or selection cursor during structure selection
   - Rotating: Rotation arrows during camera rotation mode
   - Panning: Hand/move cursor during camera panning
   - Zooming: Magnifying glass during zoom operations
   - Loading: Spinner when loading content or processing

3. Implement smooth cursor transitions between states
4. Support for high-DPI displays and custom cursor sprites
5. Integration with existing BrainInteractionController and SmoothCameraController
6. Accessibility considerations: Ensure cursor visibility for users with visual impairments

Technical specifications:
- Use Godot 4.x Input.set_custom_mouse_cursor() for custom cursor sprites
- Create cursor sprite assets in multiple resolutions (16x16, 32x32, 64x64)
- Implement cursor state stacking for complex interactions
- Add cursor animation support for educational feedback
- Include cursor hotspot positioning for accurate interaction

Follow NeuroVision coding standards and ensure offline functionality.
```

### 2. Context-Aware Cursor Intelligence

**Prompt: Develop Smart Cursor Context System**

```
Enhance the NeuroVision cursor system with intelligent context awareness that adapts to the educational content and user interaction state.

Implementation goals:
1. Create `CursorContextAnalyzer.gd` that evaluates:
   - Current 3D object under cursor (brain structure, UI element, empty space)
   - User's current task/mode (exploration, assessment, guided tour)
   - Available interactions for hovered elements
   - User preferences and accessibility settings

2. Dynamic cursor behavior changes:
   - Show information cursor when hovering over educational content
   - Display interaction hints for available actions
   - Adapt cursor size based on user accessibility needs
   - Change cursor based on brain structure type (cortex, subcortical, etc.)

3. Educational context integration:
   - Different cursors for different brain systems (motor, sensory, limbic)
   - Assessment mode cursors that hint at quiz interactions
   - Progress tracking cursors that show learning advancement

4. Performance optimization:
   - Efficient raycast caching to avoid redundant calculations
   - Debounced cursor state changes to prevent flicker
   - Memory-efficient cursor sprite management

Technical requirements:
- Integrate with existing BrainInteractionController raycast system
- Use signals for decoupled cursor state communication
- Implement cursor state prediction for smooth transitions
- Add cursor context history for undo/redo functionality
- Support for custom cursor themes (student vs. instructor modes)

Ensure compliance with educational accessibility standards (WCAG AAA).
```

### 3. Advanced Interaction Feedback System

**Prompt: Create Comprehensive Cursor Feedback Mechanisms**

```
Develop an advanced cursor feedback system that enhances educational interaction through visual, audio, and haptic feedback during neuroanatomy exploration.

Core components:
1. `CursorFeedbackManager.gd` autoload for centralized feedback control
2. Visual feedback systems:
   - Cursor trail effects during camera rotation/panning
   - Glow effects when approaching selectable structures
   - Distance-based cursor scaling for depth perception
   - Color-coded cursors for different brain structure categories

3. Educational feedback integration:
   - Cursor badges showing structure classifications
   - Interactive cursor tooltips with quick facts
   - Progress indicators integrated into cursor design
   - Accuracy feedback during assessment activities

4. Accessibility enhancements:
   - High-contrast cursor modes for visual impairments
   - Cursor magnification for motor skill assistance
   - Keyboard-only cursor navigation for non-mouse users
   - Screen reader compatible cursor state announcements

5. Performance considerations:
   - GPU-accelerated cursor effects using shaders
   - LOD system for cursor complexity based on performance
   - Configurable feedback intensity for different hardware

Technical implementation:
- Custom shader materials for cursor effects
- Integration with AccessibilityManager autoload
- Use CanvasLayer for cursor overlay management
- Implement cursor effect pooling for performance
- Add cursor analytics for educational effectiveness tracking

Focus on educational value and user experience enhancement while maintaining 30+ FPS performance.
```

### 4. Multi-Input Cursor Support

**Prompt: Implement Comprehensive Multi-Input Cursor System**

```
Extend the NeuroVision cursor system to support multiple input methods for enhanced accessibility and cross-platform compatibility in educational environments.

Multi-input support requirements:
1. Touch interface adaptation:
   - Touch cursor simulation for tablet/mobile devices
   - Gesture-based cursor movement (pinch, swipe, tap)
   - Touch pressure sensitivity for depth interaction
   - Multi-touch support for complex 3D manipulations

2. Stylus/pen input integration:
   - Pressure-sensitive cursor sizing
   - Tilt-aware cursor orientation for natural drawing
   - Eraser-end detection for different interaction modes
   - Palm rejection during educational annotation

3. Gamepad/controller support:
   - Virtual cursor controlled by analog sticks
   - Button-mapped cursor modes (select, rotate, zoom)
   - Haptic feedback for structure selection
   - Customizable control schemes for different abilities

4. Keyboard navigation enhancement:
   - Tab-based cursor movement between structures
   - Arrow key precise cursor positioning
   - Keyboard shortcuts for cursor mode switching
   - Voice control integration for hands-free operation

5. Assistive technology compatibility:
   - Eye-tracking cursor control integration
   - Switch-based cursor navigation
   - Dwell-time selection for limited mobility users
   - Voice command cursor positioning

Technical architecture:
- Abstract input layer that normalizes different input types
- Configurable input mapping system
- Per-input type cursor visualization
- Input method auto-detection and switching
- Integration with Godot's InputMap system for custom controls

Ensure all input methods provide equivalent educational functionality and maintain responsive performance across devices.
```

---

## Optimization & Performance Prompts

### 5. Cursor Performance Optimization

**Prompt: Optimize Cursor System for Educational Performance Requirements**

```
Optimize the NeuroVision cursor system to maintain 30+ FPS performance on minimum hardware (Intel UHD 620) while providing rich educational interaction feedback.

Performance optimization targets:
1. Efficient raycast optimization:
   - Implement spatial partitioning for 3D structure detection
   - Use distance-based LOD for cursor interaction complexity
   - Cache raycast results with intelligent invalidation
   - Optimize raycast frequency based on cursor movement speed

2. Cursor rendering optimization:
   - GPU-based cursor sprite batching
   - Texture atlas usage for multiple cursor states
   - Shader-based cursor effects to reduce CPU load
   - Dynamic resolution scaling based on performance

3. Memory management:
   - Cursor sprite pooling and reuse
   - Automatic cleanup of unused cursor resources
   - Streaming of cursor assets based on current context
   - Memory-efficient cursor animation systems

4. Educational content integration optimization:
   - Asynchronous loading of structure information for cursor tooltips
   - Predictive preloading of likely interaction targets
   - Efficient cursor state serialization for progress saving
   - Optimized integration with ContentManager autoload

5. Platform-specific optimizations:
   - Hardware-accelerated cursor effects where available
   - Fallback systems for limited graphics capabilities
   - Battery optimization for mobile educational devices
   - Network optimization for cloud-based educational content

Implementation approach:
- Profile existing cursor system bottlenecks using Godot's profiler
- Implement performance monitoring integration with PerformanceMonitor autoload
- Create configurable quality settings for different hardware tiers
- Add performance regression testing for cursor functionality
- Document performance best practices for educational feature development

Maintain all educational functionality while meeting strict performance requirements.
```

### 6. Cursor System Architecture Refactoring

**Prompt: Refactor Cursor System for Maintainable Educational Platform**

```
Refactor the NeuroVision cursor system architecture to improve maintainability, extensibility, and integration with the broader educational platform while following Godot 4.x best practices.

Architectural improvements:
1. Modular cursor system design:
   - Separate cursor visualization from interaction logic
   - Create pluggable cursor behavior modules
   - Implement cursor state machine for complex interactions
   - Design reusable cursor components for different educational contexts

2. Clean integration patterns:
   - Standardize cursor-to-UI communication using signals
   - Create cursor service layer for cross-system coordination
   - Implement cursor context providers for different educational modes
   - Design cursor middleware for feature extension

3. Educational platform integration:
   - Seamless integration with ProgressTracker for learning analytics
   - Cursor behavior customization through SettingsManager
   - Educational theme support via UIThemeManager
   - Accessibility compliance through AccessibilityManager

4. Testable architecture:
   - Unit testable cursor logic separation
   - Mock-friendly interfaces for cursor dependencies
   - Automated cursor behavior testing framework
   - Educational interaction scenario testing

5. Future-proof design patterns:
   - Plugin architecture for custom cursor behaviors
   - Event-driven cursor system for loose coupling
   - Configurable cursor pipelines for different educational needs
   - Extensible cursor metadata system for learning analytics

Technical specifications:
- Follow SOLID principles for cursor component design
- Implement Observer pattern for cursor state notifications
- Use Dependency Injection for cursor service management
- Create comprehensive cursor system documentation
- Establish cursor development guidelines for team consistency

Refactoring approach:
- Incremental refactoring with backward compatibility
- Comprehensive testing during transition
- Performance benchmarking before/after changes
- Documentation updates throughout refactoring process

Ensure zero disruption to existing educational functionality during refactoring.
```

---

## Advanced Feature Enhancement Prompts

### 7. Educational Cursor Analytics System

**Prompt: Implement Cursor-Based Learning Analytics**

```
Develop a comprehensive cursor analytics system for NeuroVision that captures educational interaction patterns to improve learning outcomes and platform effectiveness.

Analytics implementation:
1. Cursor behavior tracking:
   - Track cursor movement patterns during brain exploration
   - Measure time spent hovering over different structures
   - Record selection accuracy and interaction efficiency
   - Monitor cursor path analysis for learning pattern recognition

2. Educational metrics collection:
   - Structure discovery order and learning progression
   - Difficulty assessment based on cursor hesitation patterns
   - Engagement measurement through cursor activity analysis
   - Accessibility usage patterns for platform improvement

3. Privacy-first analytics design:
   - Anonymous data collection by default
   - Local analytics processing without external transmission
   - User consent management for optional data sharing
   - GDPR/FERPA compliant educational data handling

4. Adaptive learning integration:
   - Cursor pattern-based learning style detection
   - Personalized cursor assistance based on usage patterns
   - Difficulty adjustment recommendations from cursor analytics
   - Educational content recommendation based on interaction data

5. Instructor dashboard integration:
   - Aggregated cursor analytics for class assessment
   - Individual student progress visualization
   - Common difficulty identification through cursor patterns
   - Educational effectiveness measurement tools

Technical implementation:
- Lightweight analytics data structure for minimal performance impact
- Real-time analytics processing with configurable sampling rates
- Integration with existing ProgressTracker autoload
- Export capabilities for educational research purposes
- Analytics data visualization components for instructor tools

Analytics should enhance educational outcomes while respecting user privacy and maintaining system performance.
```

### 8. Accessibility-First Cursor Enhancements

**Prompt: Develop Comprehensive Cursor Accessibility Features**

```
Create advanced accessibility features for the NeuroVision cursor system to ensure inclusive educational experiences for users with diverse abilities and learning needs.

Accessibility enhancement areas:
1. Visual accessibility improvements:
   - High contrast cursor modes with customizable colors
   - Cursor size scaling for visual impairment accommodation
   - Motion-reduced cursor options for vestibular disorders
   - Customizable cursor opacity and outline thickness

2. Motor accessibility features:
   - Dwell-time cursor selection for limited mobility
   - Cursor magnetism to snap to selectable educational elements
   - Adjustable cursor movement sensitivity and acceleration
   - Tremor compensation through cursor path smoothing

3. Cognitive accessibility support:
   - Simplified cursor states for cognitive load reduction
   - Clear cursor intent indicators for complex interactions
   - Consistent cursor behavior patterns throughout application
   - Optional cursor assistance for guided educational exploration

4. Screen reader integration:
   - Cursor position announcements for spatial understanding
   - Selected structure information through screen reader APIs
   - Cursor state changes communicated to assistive technology
   - Alternative cursor navigation descriptions

5. Multi-sensory feedback:
   - Audio cues for cursor state changes and selections
   - Haptic feedback patterns for different educational interactions
   - Visual cursor trails for movement tracking assistance
   - Configurable sensory feedback combinations

Implementation requirements:
- Full WCAG AAA compliance for educational accessibility
- Integration with AccessibilityManager autoload
- Extensive user testing with accessibility consultants
- Configurable accessibility profiles for different needs
- Real-time accessibility feature toggling

Technical considerations:
- Platform-specific accessibility API integration
- Performance optimization for assistive technology compatibility
- Accessibility settings persistence across sessions
- Comprehensive accessibility documentation and training materials

Design for universal accessibility while maintaining educational effectiveness and system performance.
```

---

## Integration & Workflow Prompts

### 9. Cursor-UI Integration Enhancement

**Prompt: Enhance Cursor Integration with Educational UI Components**

```
Improve the integration between the NeuroVision cursor system and educational UI components to create seamless, intuitive learning experiences.

Integration enhancement goals:
1. Unified cursor-UI communication:
   - Bidirectional cursor state synchronization with UI panels
   - Cursor-driven UI element highlighting and selection
   - Dynamic UI layout adaptation based on cursor context
   - Consistent cursor behavior across 3D and 2D interface areas

2. Educational workflow integration:
   - Cursor integration with StructureInfoPanel for enhanced content display
   - Quiz interaction cursor states for assessment activities
   - Progress visualization cursor integration for learning tracking
   - Annotation cursor support for educational note-taking

3. Context-aware UI responses:
   - UI panel auto-positioning based on cursor activity areas
   - Cursor-proximity-based UI element visibility
   - Educational content preloading based on cursor movement patterns
   - Dynamic UI element sizing based on cursor accessibility settings

4. Cross-component coordination:
   - Cursor state management across multiple educational screens
   - Consistent cursor behavior in different learning modes
   - UI theme integration with cursor visual design
   - Performance coordination between cursor and UI rendering

5. Educational interaction patterns:
   - Cursor-driven tutorial and onboarding flows
   - Interactive cursor guides for complex 3D navigation
   - Educational hotspot detection and highlighting
   - Cursor-based progressive disclosure of advanced features

Technical implementation:
- Create CursorUIBridge for centralized cursor-UI communication
- Implement cursor event bubbling system for UI components
- Design cursor-aware UI component base classes
- Establish cursor-UI integration testing framework
- Document cursor-UI interaction patterns for developers

Integration should feel natural and enhance educational effectiveness without adding complexity for users.
```

### 10. Advanced 3D Cursor Interactions

**Prompt: Implement Advanced 3D Cursor Interaction Features**

```
Develop sophisticated 3D cursor interaction capabilities for NeuroVision that leverage modern Godot 4.x features to enhance neuroanatomy education.

Advanced 3D interaction features:
1. Depth-aware cursor behavior:
   - 3D cursor projection for accurate spatial interaction
   - Distance-based cursor scaling for depth perception
   - Layer-aware cursor interactions for complex brain models
   - 3D cursor snapping to anatomical planes and axes

2. Advanced selection mechanisms:
   - Lasso selection for multiple brain structure selection
   - Box selection for region-based educational content
   - Brush selection with size adjustment for detailed exploration
   - Smart selection that understands anatomical relationships

3. 3D manipulation cursor modes:
   - Structure isolation cursor for focused study
   - Cross-section cursor for anatomical plane exploration
   - Measurement cursor for educational distance/volume calculations
   - Annotation cursor for 3D spatial note placement

4. Educational 3D navigation enhancements:
   - Cursor-guided camera paths for structured learning tours
   - Landmark-based cursor navigation between brain regions
   - Educational viewpoint suggestions based on cursor position
   - Cursor-controlled model transparency and layer visibility

5. Advanced visual feedback:
   - 3D cursor shadows and depth cues
   - Cursor interaction preview for complex operations
   - Educational information overlay positioning in 3D space
   - Real-time cursor collision feedback with 3D models

Technical implementation:
- Utilize Godot 4.x improved 3D raycasting and physics
- Implement custom 3D cursor visualization using MeshInstance3D
- Create 3D cursor shader effects for enhanced visual feedback
- Design efficient 3D cursor culling and LOD systems
- Integrate with Godot's XR support for future VR educational features

Implementation considerations:
- Maintain performance on minimum hardware specifications
- Ensure accessibility compliance for 3D interactions
- Provide fallback 2D cursor modes for users who need them
- Integrate with existing educational content and assessment systems

Advanced 3D cursor features should enhance spatial understanding and educational effectiveness while remaining intuitive for students and educators.
```

---

## Testing & Quality Assurance Prompts

### 11. Comprehensive Cursor Testing Framework

**Prompt: Develop Complete Testing Suite for Cursor System**

```
Create a comprehensive testing framework for the NeuroVision cursor system that ensures reliability, performance, and educational effectiveness across all supported platforms and use cases.

Testing framework components:
1. Unit testing suite:
   - Cursor state management logic testing
   - Input event processing validation
   - Cursor-3D interaction accuracy testing
   - Performance benchmark testing for cursor operations

2. Integration testing:
   - Cursor-UI component interaction testing
   - Cross-platform cursor behavior consistency
   - Accessibility feature compliance testing
   - Educational workflow integration validation

3. Educational effectiveness testing:
   - User interaction pattern validation
   - Learning outcome measurement with cursor analytics
   - Accessibility testing with real users
   - Usability testing in educational environments

4. Performance testing:
   - Cursor system performance profiling
   - Memory usage monitoring during extended use
   - Frame rate impact assessment
   - Battery usage optimization on mobile devices

5. Automated testing scenarios:
   - Cursor behavior regression testing
   - Cross-platform compatibility validation
   - Educational content interaction testing
   - Accessibility compliance verification

Testing implementation:
- Create GDScript unit tests using Godot's testing framework
- Implement automated cursor behavior simulation
- Design performance benchmarking tools
- Establish continuous integration testing pipelines
- Document testing procedures for educational feature development

Testing should ensure cursor system reliability while validating educational effectiveness and accessibility compliance.
```

### 12. Cursor System Documentation & Onboarding

**Prompt: Create Comprehensive Cursor System Documentation**

```
Develop complete documentation for the NeuroVision cursor system that serves developers, educators, and users, ensuring effective knowledge transfer and system maintainability.

Documentation structure:
1. Developer documentation:
   - Cursor system architecture overview
   - API reference for cursor components
   - Integration guidelines for new educational features
   - Performance optimization best practices
   - Troubleshooting guide for common cursor issues

2. Educational user documentation:
   - Cursor interaction guide for students
   - Advanced cursor features for educators
   - Accessibility options and customization
   - Educational workflow optimization tips

3. Technical specifications:
   - Cursor input mapping documentation
   - Platform-specific cursor behavior differences
   - Accessibility compliance documentation
   - Performance requirements and limitations

4. Educational effectiveness guide:
   - Cursor analytics interpretation for educators
   - Learning outcome improvement strategies
   - Cursor customization for different learning styles
   - Educational assessment integration documentation

5. Maintenance and support documentation:
   - Cursor system update procedures
   - Educational content integration guidelines
   - User support troubleshooting workflows
   - Feature enhancement request procedures

Documentation implementation:
- Create interactive documentation with code examples
- Include video tutorials for complex cursor interactions
- Provide multilingual support for global educational use
- Implement searchable documentation with educational context
- Design mobile-friendly documentation for tablet-based learning

Documentation should enable effective cursor system use while supporting educational goals and platform maintainability.
```

---

## Implementation Priority & Roadmap

### Recommended Implementation Order:

1. **Phase 1 - Foundation** (Critical)
   - Custom Cursor Visual System (#1)
   - Cursor Performance Optimization (#5)
   - Basic Accessibility Enhancements (#8)

2. **Phase 2 - Enhancement** (High Priority)
   - Context-Aware Cursor Intelligence (#2)
   - Cursor-UI Integration Enhancement (#9)
   - Multi-Input Cursor Support (#4)

3. **Phase 3 - Advanced Features** (Medium Priority)
   - Advanced Interaction Feedback System (#3)
   - Advanced 3D Cursor Interactions (#10)
   - Educational Cursor Analytics System (#7)

4. **Phase 4 - Polish & Quality** (Ongoing)
   - Cursor System Architecture Refactoring (#6)
   - Comprehensive Testing Framework (#11)
   - Documentation & Onboarding (#12)

### Development Considerations:

- **Educational Focus**: All enhancements must improve learning outcomes
- **Performance Requirements**: Maintain 30+ FPS on minimum hardware
- **Accessibility Compliance**: WCAG AAA standards for educational institutions
- **Offline-First Design**: Core cursor functionality must work without internet
- **Cross-Platform Compatibility**: Consistent behavior across Windows, macOS, Linux

---

*Generated through comprehensive analysis of NeuroVision-Repo cursor system implementation and educational platform requirements. Each prompt is designed to enhance the educational effectiveness while maintaining technical excellence and accessibility compliance.*