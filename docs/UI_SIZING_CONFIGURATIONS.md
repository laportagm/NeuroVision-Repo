# NeuroVision UI Sizing Configurations

This document contains all UI button sizes, bars, panels, and theme configurations found in the NeuroVision codebase.

## Button Configurations

### Material 3 Design Tokens (`src/ui/themes/M3DesignTokens.gd`)
- **Button Padding**: 24px (`M3_SPACING["button_padding"]`)
- **Touch Target Size**: 48px minimum (`M3_ACCESSIBILITY["touch_target_size"]`)
- **Button Corner Radius**: 12px (`M3_CORNER_RADIUS["button"]`)
- **Button Elevation**: 2 (`M3_ELEVATION["button"]`)

### Typography for Buttons
- **Button Font Size**: 14px (`M3_TYPE_SCALE["label_large"]["size"]`)
- **Button Font Weight**: 500 (`M3_TYPE_SCALE["label_large"]["weight"]`)
- **Letter Spacing**: 0.1 (`M3_TYPE_SCALE["label_large"]["tracking"]`)

### DarkTheme.tres Button Margins
- **Content Margins**: 
  - Left/Right: 24px
  - Top/Bottom: 8px
- **Corner Radius**: 12px

## Panel Configurations

### Structure Info Panel (`src/ui/components/StructureInfoPanel.gd`)
- **Panel Width**: 450px (`PANEL_WIDTH`)
- **Panel Margin**: 30px (`PANEL_MARGIN`)
- **Animation Duration**: 0.3s

### Quiz Panel (`src/ui/components/QuizPanel.gd`)
- **Panel Width**: 500px (`PANEL_WIDTH`)
- **Panel Height**: 600px (`PANEL_HEIGHT`)

### Professional Sidebar (`src/ui/components/ProfessionalSidebar.gd`)
- **Sidebar Width**: 320px (`SIDEBAR_WIDTH`)
- **Icon Size**: 24px

### Progressive Disclosure Panel
- Uses default panel sizing from theme

## Layout Configurations (UIAdaptationManager)

### Layout Mode Dimensions
```gdscript
LAYOUT_CONFIGURATIONS = {
    LayoutMode.COMPACT: {
        "sidebar_width": 280,
        "info_panel_width": 350,
    },
    LayoutMode.STANDARD: {
        "sidebar_width": 320,
        "info_panel_width": 450,
    },
    LayoutMode.PRESENTATION: {
        "sidebar_width": 0,
        "info_panel_width": 600,
    },
    LayoutMode.MULTI_MONITOR: {
        "sidebar_width": 400,
        "info_panel_width": 500,
    }
}
```

## Spacing System (`src/ui/themes/DesignTokens.gd`)
- **xs**: 4px (Tight spacing)
- **sm**: 8px (Small elements)
- **md**: 16px (Default spacing)
- **lg**: 24px (Section spacing)
- **xl**: 32px (Large gaps)
- **xxl**: 48px (Major sections)
- **xxxl**: 64px (Page margins)

## Material 3 Spacing (`src/ui/themes/M3DesignTokens.gd`)
- **none**: 0px
- **extra_small**: 4px
- **small**: 8px
- **medium**: 16px
- **large**: 24px
- **extra_large**: 32px
- **huge**: 48px
- **button_padding**: 24px
- **card_padding**: 16px
- **list_item_padding**: 16px
- **dialog_padding**: 24px
- **section_gap**: 32px

## Typography Sizes

### Material 3 Type Scale
- **Display Large**: 57px
- **Display Medium**: 45px
- **Display Small**: 36px
- **Headline Large**: 32px
- **Headline Medium**: 28px
- **Headline Small**: 24px
- **Title Large**: 22px
- **Title Medium**: 16px
- **Title Small**: 14px
- **Body Large**: 16px
- **Body Medium**: 14px
- **Body Small**: 12px
- **Label Large**: 14px
- **Label Medium**: 12px
- **Label Small**: 11px

### Design Tokens Typography
- **h1**: 32px
- **h2**: 24px
- **h3**: 20px
- **body**: 14px
- **body_large**: 16px
- **caption**: 12px
- **button**: 14px

## Border Configurations

### Border Radius (`src/ui/themes/DesignTokens.gd`)
- **sm**: 4px
- **md**: 8px
- **lg**: 12px
- **xl**: 16px
- **pill**: 999px

### Material 3 Corner Radius
- **none**: 0px
- **extra_small**: 4px
- **small**: 8px
- **medium**: 12px
- **large**: 16px
- **extra_large**: 28px
- **full**: 9999px
- **button**: 12px
- **card**: 12px
- **dialog**: 28px
- **chip**: 8px
- **navigation**: 16px
- **text_field**: 8px

### Border Width
- **thin**: 1px
- **medium**: 2px
- **thick**: 3px
- **focus_indicator_width**: 3px (Material 3 Accessibility)

## Theme Resource Files

### Panel Content Margins (from DarkTheme.tres)
- **Panel margins**: 16px all sides
- **Dialog/Modal margins**: 24px all sides

## Accessibility Requirements
- **Minimum touch target size**: 48px
- **Focus indicator width**: 3px
- **Large text size**: 18px minimum
- **Minimum contrast ratio**: 7.0 (WCAG AAA)

## Screen Breakpoints
- **mobile**: 768px
- **tablet**: 1024px
- **desktop**: 1440px
- **ultrawide**: 1920px

## Animation Durations
- **instant**: 0.0s
- **fast**: 0.15s
- **normal**: 0.3s
- **slow**: 0.6s
- **very_slow**: 1.0s

## Z-Index Layers
- **background**: -1
- **content**: 0
- **elevated**: 10
- **overlay**: 100
- **modal**: 200
- **tooltip**: 300
- **notification**: 400
- **debug**: 999

## Notes
- All UI components support Material 3 design system
- Sizes are responsive and adapt based on layout mode
- Touch targets meet accessibility requirements (48px minimum)
- Panel widths can be adjusted through UIAdaptationManager
- Theme configurations are generated dynamically through Material3ThemeGenerator