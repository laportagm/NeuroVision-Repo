# Command: /fix-theme-issue
# Purpose: Fix theme-related issues in UI components or color inconsistencies
# Arguments:
#   - $COMPONENT: Component or file with theme issue
#   - $ISSUE_TYPE: Type of issue (color, responsive, dark_mode, contrast)
#   - $THEME_VARIANT: Which theme variant (neural_purple, ocean_depths, warm_cognition, all)
#   - $DESCRIPTION: Description of the visual issue
# Example: /fix-theme-issue COMPONENT="QuizQuestionCard.gd" ISSUE_TYPE="contrast" THEME_VARIANT="ocean_depths" DESCRIPTION="Text hard to read on surface_variant background"
---

You are a Material3 UI specialist with expertise in accessible educational interfaces.

TASK: Fix theme $ISSUE_TYPE issue in $COMPONENT affecting $THEME_VARIANT variant.

CONTEXT:
- NeuroVision uses Material3 design with educational adaptations
- UIThemeManager handles theme switching and color tokens
- Themes defined in assets/themes/color_schemes/
- Issue description: $DESCRIPTION
- Must maintain WCAG AA contrast ratios for education
- Components must work across all theme variants

REQUIREMENTS:
1. Analyze $COMPONENT for theme color usage
2. Identify incorrect theme token usage causing $ISSUE_TYPE
3. Check Material3 color roles:
   - Primary/Secondary/Tertiary (actions, emphasis)
   - Surface/Surface_variant (backgrounds)
   - On_* colors (text on colored backgrounds)
   - Error/Success states
4. Fix based on $ISSUE_TYPE:
   - "color": Correct color token usage
   - "responsive": Fix color adaptation to theme changes
   - "dark_mode": Ensure proper dark theme support
   - "contrast": Fix accessibility contrast issues
5. Verify fix across theme variants:
   - neural_purple (primary)
   - ocean_depths
   - warm_cognition
   - soft_sage
   - midnight_focus
6. Update any hardcoded colors to theme tokens
7. Test theme change signal handling

CONSTRAINTS:
- Must use UIThemeManager color tokens only
- Cannot hardcode hex colors
- Must maintain minimum 4.5:1 contrast for text
- Must preserve educational clarity
- Cannot break existing theme functionality
- Must handle theme_changed signal

OUTPUT:
- Fixed component with proper theme integration
- List of color tokens changed and why
- Contrast validation results
- Screenshots/description of fix across themes

SUCCESS CRITERIA: Issue resolved, works across all themes, maintains accessibility standards