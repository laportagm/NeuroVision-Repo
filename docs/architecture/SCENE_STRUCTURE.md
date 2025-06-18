# NeuroVision Scene Structure Documentation

This document visualizes the scene hierarchy and relationships in the NeuroVision educational neuroanatomy platform using Mermaid.js diagrams.

## Scene Hierarchy Overview

```mermaid
graph TD
    A[project.godot] -->|main_scene| B[MainMenu.tscn]
    B -->|Start Exploration| C[EnhancedExplorationScene.tscn]
    
    C -->|Contains| D[StructureInfoPanel.tscn]
    C -->|Dynamic Load| E[QuizPanel.tscn]
    C -->|May Load| F[ProgressiveDisclosurePanel.tscn]
    
    G[OnboardingManager] -.->|References| H[TutorialOverlay.tscn]
    
    I[Test System] --> J[test_runner.tscn]
    K[Theme Tools] --> L[generate_theme_resources.tscn]
    
    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bbf,stroke:#333,stroke-width:2px
    style H fill:#fbb,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5
```

## Detailed Scene Component Structure

### MainMenu Scene Structure

```mermaid
graph TD
    MM[MainMenu.tscn<br/>Control Node] --> CL[CanvasLayer]
    
    CL --> CR[ColorRect<br/>Background]
    CL --> TB[TopBar<br/>PanelContainer]
    CL --> CC[CenterContainer]
    
    TB --> HB[HBoxContainer]
    HB --> AN[AppName Label]
    HB --> VS[VSeparator]
    HB --> VL[Version Label]
    
    CC --> VB[VBoxContainer]
    VB --> TL[TitleLabel<br/>'NeuroVision']
    VB --> SL[SubtitleLabel<br/>'Educational Neuroanatomy Explorer']
    VB --> SP[Spacer]
    VB --> SB[StartButton]
    VB --> PB[ProfessionalButton]
    VB --> STB[SettingsButton]
    VB --> QB[QuitButton]
    
    style MM fill:#bbf,stroke:#333,stroke-width:2px
    style SB fill:#bfb,stroke:#333,stroke-width:2px
```

### EnhancedExplorationScene Structure

```mermaid
graph TD
    EES[EnhancedExplorationScene.tscn<br/>Node3D] --> ENV[Environment]
    EES --> CS[CameraSystem]
    EES --> BMC[BrainModelContainer]
    EES --> VH[VisualizationHelpers]
    EES --> UI[UI CanvasLayer]
    EES --> SYS[Systems]
    
    ENV --> WE[WorldEnvironment]
    ENV --> LI[Lighting]
    LI --> DL1[DirectionalLight3D<br/>Main]
    LI --> DL2[FillLight]
    LI --> DL3[RimLight]
    
    CS --> CP[CameraPivot]
    CP --> C3D[Camera3D]
    C3D --> CE[CameraEffects]
    
    BMC --> MH[ModelHolder]
    MH --> PB[PlaceholderBrain<br/>MeshInstance3D]
    BMC --> SS[SelectionSphere<br/>MeshInstance3D]
    
    VH --> GF[GridFloor]
    VH --> AI[AxisIndicator]
    
    UI --> MUI[MainUI Control]
    MUI --> TOPB[TopBar]
    MUI --> LP[LeftPanel]
    MUI --> BP[BottomPanel]
    UI --> IP[InfoPanel<br/>StructureInfoPanel.tscn]
    UI --> OV[Overlays]
    UI --> AL[AnnotationLayer]
    
    OV --> LO[LoadingOverlay]
    OV --> HO[HelpOverlay]
    
    SYS --> IS[InteractionSystem]
    SYS --> AS[AnimationSystem]
    SYS --> AUS[AudioSystem]
    SYS --> ANS[AnalyticsSystem]
    
    style EES fill:#bbf,stroke:#333,stroke-width:2px
    style UI fill:#fbf,stroke:#333,stroke-width:2px
    style IP fill:#bfb,stroke:#333,stroke-width:2px
```

## UI Component Scene Relationships

```mermaid
graph LR
    subgraph "Atomic UI Components"
        subgraph "Organisms"
            SIP[StructureInfoPanel.tscn]
            QP[QuizPanel.tscn]
        end
        
        subgraph "Molecules"
            PDP[ProgressiveDisclosurePanel.tscn]
            TO[TutorialOverlay.tscn]
        end
    end
    
    subgraph "Full Page Scenes"
        MM[MainMenu.tscn]
        EES[EnhancedExplorationScene.tscn]
    end
    
    EES -->|Embeds| SIP
    EES -->|Loads| QP
    EES -.->|May Use| PDP
    OM[OnboardingManager] -.->|References| TO
    
    style SIP fill:#bfb,stroke:#333,stroke-width:2px
    style QP fill:#bfb,stroke:#333,stroke-width:2px
    style TO fill:#fbb,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5
```

## Scene Loading Flow

```mermaid
sequenceDiagram
    participant G as Godot Engine
    participant P as project.godot
    participant MM as MainMenu
    participant EES as EnhancedExplorationScene
    participant SIP as StructureInfoPanel
    participant QP as QuizPanel
    
    G->>P: Load project settings
    P->>G: main_scene = MainMenu.tscn
    G->>MM: Load and instantiate
    MM->>MM: _ready() setup UI
    
    Note over MM: User clicks "Start Exploration"
    
    MM->>G: change_scene_to_file()
    G->>EES: Load EnhancedExplorationScene
    EES->>SIP: Instance embedded panel
    EES->>EES: Setup 3D environment
    
    Note over EES: User triggers quiz
    
    EES->>QP: preload() and instantiate
    QP->>EES: Display quiz overlay
```

## Scene Component Types

```mermaid
graph TD
    subgraph "Scene Types"
        FS[Full Screen Scenes]
        RC[Reusable Components]
        UT[Utility Scenes]
    end
    
    FS --> MM[MainMenu.tscn<br/>Entry point UI]
    FS --> EES[EnhancedExplorationScene.tscn<br/>Main application]
    
    RC --> SIP[StructureInfoPanel.tscn<br/>Info display widget]
    RC --> QP[QuizPanel.tscn<br/>Quiz modal]
    RC --> PDP[ProgressiveDisclosurePanel.tscn<br/>Advanced info panel]
    RC --> TO[TutorialOverlay.tscn<br/>Onboarding overlay]
    
    UT --> TR[test_runner.tscn<br/>Test execution]
    UT --> GTR[generate_theme_resources.tscn<br/>Theme generator]
    
    style FS fill:#bbf,stroke:#333,stroke-width:2px
    style RC fill:#bfb,stroke:#333,stroke-width:2px
    style UT fill:#ffb,stroke:#333,stroke-width:2px
```

## Scene File Organization

```mermaid
graph TD
    R[NeuroVision-Repo/]
    
    R --> S[scenes/]
    R --> SRC[src/]
    R --> T[test_runner.tscn]
    
    S --> SUI[ui/]
    S --> S3D[3d/]
    
    SUI --> MM[MainMenu.tscn]
    S3D --> EES[EnhancedExplorationScene.tscn]
    
    SRC --> UA[ui_atomic/]
    UA --> O[organisms/]
    UA --> M[molecules/]
    UA --> TH[themes/]
    
    O --> SIP[StructureInfoPanel.tscn]
    O --> QP[QuizPanel.tscn]
    
    M --> PDP[ProgressiveDisclosurePanel.tscn]
    M --> TO[TutorialOverlay.tscn]
    
    TH --> RES[resources/]
    RES --> GTR[generate_theme_resources.tscn]
    
    style R fill:#f9f,stroke:#333,stroke-width:4px
    style S fill:#bbf,stroke:#333,stroke-width:2px
    style UA fill:#bfb,stroke:#333,stroke-width:2px
```

## Scene Dependencies and Issues

```mermaid
graph TD
    subgraph "Working Dependencies"
        W1[MainMenu → EnhancedExplorationScene]
        W2[EnhancedExplorationScene → StructureInfoPanel]
        W3[EnhancedExplorationScene → QuizPanel]
    end
    
    subgraph "Potential Issues"
        I1[TutorialOverlay.tscn<br/>Referenced but missing?]
        I2[Some scripts missing<br/>for UI components]
        I3[UI system transition<br/>ui vs ui_atomic]
    end
    
    style I1 fill:#fbb,stroke:#333,stroke-width:2px
    style I2 fill:#fbb,stroke:#333,stroke-width:2px
    style I3 fill:#fbf,stroke:#333,stroke-width:2px
```

## Key Observations

1. **Atomic Design Pattern**: The project uses atomic design with organisms and molecules for UI components
2. **Scene Reusability**: UI components are designed as reusable scenes that can be instantiated in multiple places
3. **Clear Separation**: Full application scenes vs. reusable components vs. utility scenes
4. **Simple Flow**: Main application flow is straightforward: MainMenu → EnhancedExplorationScene
5. **Dynamic Loading**: Some components (like QuizPanel) are loaded on-demand rather than embedded
6. **Migration Evidence**: The ui_atomic directory structure suggests an ongoing or completed UI system migration

## Scene Best Practices Used

- ✅ Modular scene design
- ✅ Reusable UI components
- ✅ Clear naming conventions
- ✅ Organized directory structure
- ✅ Separation of concerns (UI vs 3D vs systems)
- ✅ Dynamic loading for performance
- ✅ Atomic design pattern implementation

---

*Last Updated: 2025-06-18*