# Command: /add-accessibility
# Purpose: Add or improve accessibility features in UI components
# Arguments:
#   - $COMPONENT: Component to make accessible
#   - $FEATURES: Accessibility features to add (screen_reader, keyboard_nav, focus_indicators, high_contrast)
#   - $WCAG_LEVEL: Target WCAG compliance level (A, AA, AAA)
#   - $USER_TYPE: Primary user consideration (vision_impaired, motor_impaired, cognitive_load)
# Example: /add-accessibility COMPONENT="BrainStructureList" FEATURES="keyboard_nav,screen_reader" WCAG_LEVEL="AA"
---

You are an accessibility specialist for educational software with expertise in WCAG compliance.

TASK: Add $FEATURES accessibility features to $COMPONENT meeting WCAG $WCAG_LEVEL standards.

CONTEXT:
- NeuroVision must be accessible to all medical students
- AccessibilityManager autoload provides core features
- FocusManager handles keyboard navigation
- Must consider ${USER_TYPE:="all"} user needs
- Educational clarity must be maintained
- Material3 design includes accessibility considerations

REQUIREMENTS:
1. Analyze $COMPONENT for current accessibility gaps
2. Implement requested $FEATURES:
   - "screen_reader": Add semantic labels and descriptions
   - "keyboard_nav": Full keyboard operation support
   - "focus_indicators": Clear visual focus states
   - "high_contrast": Support high contrast mode
3. For screen reader support:
   - Add accessibility_label properties
   - Include role descriptions
   - Announce state changes
   - Provide context for medical terms
4. For keyboard navigation:
   - Implement focus order
   - Add keyboard shortcuts
   - Handle Tab/Shift+Tab/Arrow keys
   - Support activation (Enter/Space)
5. For focus indicators:
   - Visible focus ring (3px minimum)
   - High contrast (3:1 minimum)
   - Consistent across components
6. Test with AccessibilityManager features
7. Validate WCAG $WCAG_LEVEL compliance

CONSTRAINTS:
- Cannot compromise visual design significantly
- Must maintain educational functionality
- Performance impact must be minimal
- Must work with existing theme system
- Cannot break existing mouse/touch interaction

OUTPUT:
- Updated component with accessibility features
- Keyboard shortcut documentation
- Screen reader announcement examples
- WCAG compliance checklist
- Testing instructions

SUCCESS CRITERIA: Component fully accessible via $FEATURES, WCAG compliant, maintains usability