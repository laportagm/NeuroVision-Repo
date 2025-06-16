# Command: /fix-theme-issue
# Purpose: Fix theme-related issues in UI components using unified color system
# Arguments:
#   - $COMPONENT: Component or file with theme issue
#   - $ISSUE_TYPE: Type of issue (color, responsive, accessibility, contrast, unified_colors)
#   - $THEME_VARIANT: Which theme variant (enhanced_student, minimal_clinical, high_contrast_accessibility, colorblind_safe, all)
#   - $DESCRIPTION: Description of the visual issue
# Example: /fix-theme-issue COMPONENT="QuizQuestionCard.gd" ISSUE_TYPE="contrast" THEME_VARIANT="high_contrast_accessibility" DESCRIPTION="Text contrast below WCAG AAA 7:1 requirement"
---

You are a Material3 UI specialist with expertise in accessible educational interfaces.

TASK: Fix theme $ISSUE_TYPE issue in $COMPONENT affecting $THEME_VARIANT variant.

CONTEXT:
- NeuroVision uses Material3 design with Unified Color Management System
- UnifiedColorManager and UIThemeManager handle theme switching and color tokens
- Themes defined through M3DesignTokens with unified color system
- Issue description: $DESCRIPTION
- Must maintain WCAG AAA contrast ratios (7:1+ achieved) for medical education
- Components must work across all 4 theme variants
- Unified color system ensures no hardcoded colors in codebase

REQUIREMENTS:
1. Analyze $COMPONENT for theme color usage
2. Identify incorrect theme token usage causing $ISSUE_TYPE
3. Check Material3 color roles:
   - Primary/Secondary/Tertiary (actions, emphasis)
   - Surface/Surface_variant (backgrounds)
   - On_* colors (text on colored backgrounds)
   - Error/Success states
4. Fix based on $ISSUE_TYPE:
   - "color": Correct unified color token usage
   - "responsive": Fix color adaptation to theme changes
   - "accessibility": Ensure WCAG AAA compliance
   - "contrast": Fix contrast to meet 7:1+ standard
   - "unified_colors": Migrate hardcoded colors to unified system
5. Verify fix across theme variants:
   - enhanced_student (engaging for students)
   - minimal_clinical (professional medical)
   - high_contrast_accessibility (WCAG AAA)
   - colorblind_safe (universal accessibility)
6. Ensure unified color system compliance
7. Test theme change signal handling through UnifiedColorManager

CONSTRAINTS:
- Must use UnifiedColorManager and M3DesignTokens only
- Cannot hardcode hex colors (unified system enforced)
- Must maintain 7:1+ contrast for WCAG AAA compliance
- Must preserve medical education clarity
- Cannot break existing unified color functionality
- Must handle theme_changed signal through unified system

OUTPUT:
- Fixed component with proper theme integration
- List of color tokens changed and why
- Contrast validation results
- Screenshots/description of fix across themes

SUCCESS CRITERIA: Issue resolved, works across all themes, maintains accessibility standards