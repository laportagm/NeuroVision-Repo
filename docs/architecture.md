# NeuroVis System Architecture

[## 📊 **COMPLETE PROJECT STRUCTURE OVERVIEW - FINAL VERSION**

```
NeuroVis/
├── .devcontainer/                    # Development environment
│   ├── devcontainer.json            # VS Code dev container config (FULL CONFIG ABOVE)
│   └── Dockerfile                   # Custom container with Godot + Claude Code
│
├── .vscode/                         # VS Code workspace configuration
│   ├── extensions.json              # Extension recommendations
│   ├── settings.json                # Workspace-specific settings
│   ├── tasks.json                   # Build and run tasks
│   ├── launch.json                  # Debug configurations
│   └── snippets/                    # Custom code snippets
│       └── gdscript.json            # GDScript snippets
│
├── .github/                         # GitHub integration
│   ├── workflows/                   # CI/CD pipelines
│   │   ├── build.yml               # Automated builds and testing
│   │   ├── deploy.yml              # Deployment pipeline
│   │   └── claude-code.yml         # AI-assisted development workflow
│   ├── ISSUE_TEMPLATE/             # Issue templates for bug reports/features
│   └── PULL_REQUEST_TEMPLATE.md    # PR template with review checklist
│
├── .claude/                        # Claude Code AI integration
│   ├── config.json                 # Claude Code project configuration
│   ├── prompts/                    # Reusable prompt library
│   │   ├── features/               # Feature implementation prompts
│   │   │   ├── 3d_interaction.md
│   │   │   ├── quiz_builder.md
│   │   │   ├── teacher_dashboard.md
│   │   │   └── ai_assistant.md
│   │   ├── patterns/               # Code pattern templates
│   │   │   ├── ui_component.md
│   │   │   ├── data_sync.md
│   │   │   ├── error_handling.md
│   │   │   └── accessibility.md
│   │   ├── debugging/              # Debugging assistance prompts
│   │   │   ├── performance_issue.md
│   │   │   ├── platform_bug.md
│   │   │   └── api_integration.md
│   │   └── testing/                # Testing generation prompts
│   │       ├── unit_test.md
│   │       ├── integration_test.md
│   │       └── accessibility_test.md
│   ├── context/                    # Project context for AI
│   │   ├── architecture.md         # System architecture overview
│   │   ├── domain_knowledge.md     # Neuroanatomy education context
│   │   └── user_personas.md        # Target user descriptions
│   └── memory/                     # AI memory and learning
│       ├── decisions.json          # Architectural decisions record
│       ├── patterns.json           # Successful code patterns
│       └── feedback.json           # Human feedback on AI code
│
├── assets/                         # All game assets
│   ├── 3d_models/                  # 3D brain models and structures
│   │   ├── raw/                    # Source Blender files (.blend)
│   │   │   ├── hippocampus.blend
│   │   │   ├── cortex.blend
│   │   │   ├── brainstem.blend
│   │   │   └── cerebellum.blend
│   │   ├── processed/              # Exported game-ready models (.glb)
│   │   │   ├── hippocampus_high.glb    # 10K polygons
│   │   │   ├── hippocampus_medium.glb  # 5K polygons
│   │   │   ├── hippocampus_low.glb     # 1K polygons
│   │   │   └── [other_structures...]
│   │   └── textures/               # Texture files
│   │       ├── 2k/                 # High resolution (2048x2048)
│   │       ├── 1k/                 # Medium resolution (1024x1024)
│   │       └── 512/                # Low resolution (512x512)
│   ├── ui/                         # User interface assets
│   │   ├── icons/                  # UI icons and buttons
│   │   │   ├── navigation/         # Navigation icons
│   │   │   ├── assessment/         # Quiz and testing icons
│   │   │   ├── accessibility/      # Accessibility feature icons
│   │   │   └── general/            # General UI icons
│   │   ├── themes/                 # UI themes and styling
│   │   │   ├── default.tres        # Standard theme
│   │   │   ├── high_contrast.tres  # High contrast accessibility theme
│   │   │   └── teacher.tres        # Teacher interface theme
│   │   └── fonts/                  # Typography
│   │       ├── Inter-Regular.ttf   # Primary font
│   │       ├── Inter-Bold.ttf      # Bold variant
│   │       └── Inter-Light.ttf     # Light variant
│   ├── audio/                      # Audio assets (optional)
│   │   ├── ui_sounds/              # Button clicks, notifications
│   │   └── ambient/                # Background audio
│   └── import_presets/             # Godot import configurations
│       ├── 3d_model_high.preset
│       ├── 3d_model_medium.preset
│       ├── 3d_model_low.preset
│       └── texture_compression.preset
│
├── src/                            # Source code
│   ├── autoload/                   # Global system managers (singletons)
│   │   ├── ErrorRecoveryManager.gd     # Global error handling
│   │   ├── PerformanceMonitor.gd       # FPS and memory monitoring
│   │   ├── AccessibilityManager.gd     # Screen reader and keyboard support
│   │   ├── ContentManager.gd           # Local and cloud content management
│   │   ├── ProgressTracker.gd          # Student learning progress tracking
│   │   ├── AuthenticationManager.gd    # Google OAuth and anonymous mode
│   │   ├── NetworkManager.gd           # Internet connectivity management
│   │   └── SettingsManager.gd          # User preferences and settings
│   │
│   ├── systems/                    # Feature-specific systems
│   │   ├── 3d_interaction/         # 3D brain exploration system
│   │   │   ├── BrainInteractionController.gd
│   │   │   ├── CameraController.gd
│   │   │   ├── StructureSelector.gd
│   │   │   ├── ModelLoader.gd
│   │   │   └── LODManager.gd
│   │   │
│   │   ├── content_management/     # Educational content system
│   │   │   ├── ContentDatabase.gd      # Local content storage
│   │   │   ├── CloudSync.gd            # Firebase synchronization
│   │   │   ├── ContentEditor.gd        # Teacher content creation
│   │   │   ├── ContentValidator.gd     # Educational content validation
│   │   │   └── MetadataManager.gd      # Content metadata handling
│   │   │
│   │   ├── assessment/             # Quiz and testing system
│   │   │   ├── QuizBuilder.gd          # Template-based quiz creation
│   │   │   ├── QuestionTypes/          # Different question implementations
│   │   │   │   ├── MultipleChoice.gd
│   │   │   │   ├── Structure3DIdentification.gd
│   │   │   │   ├── DragAndDrop.gd
│   │   │   │   └── OrderingQuestion.gd
│   │   │   ├── ScoringSystem.gd        # Assessment scoring and feedback
│   │   │   ├── ProgressAnalytics.gd    # Learning progress analysis
│   │   │   └── AssessmentExporter.gd   # Export results for teachers
│   │   │
│   │   ├── teacher_tools/          # Teacher-specific features
│   │   │   ├── TeacherDashboard.gd     # Main teacher interface
│   │   │   ├── AIAssistant.gd          # Google Gemini chat integration
│   │   │   ├── ClassroomManager.gd     # Student progress monitoring
│   │   │   ├── ContentCreationWizard.gd # Guided content creation
│   │   │   └── ReportGenerator.gd      # Student progress reports
│   │   │
│   │   ├── analytics/              # Learning analytics system
│   │   │   ├── ProgressDashboard.gd    # Student progress visualization
│   │   │   ├── LearningAnalytics.gd    # Learning pattern analysis
│   │   │   ├── PerformanceMetrics.gd   # Educational effectiveness metrics
│   │   │   └── DataExporter.gd         # Export analytics data
│   │   │
│   │   ├── cloud_services/         # External service integrations
│   │   │   ├── GoogleOAuth.gd          # Google authentication
│   │   │   ├── GeminiAPI.gd            # AI assistant integration
│   │   │   ├── FirebaseManager.gd      # Cloud storage and sync
│   │   │   ├── APIRateLimiter.gd       # Rate limiting and quota management
│   │   │   └── FeedbackAPI.gd          # User feedback submission service
│   │   │
│   │   └── onboarding/             # Interactive tutorial system
│   │       ├── OnboardingManager.gd    # Main onboarding coordinator
│   │       ├── TutorialSteps.gd        # Tutorial step definitions
│   │       ├── HighlightOverlay.gd     # UI element highlighting
│   │       └── ProgressIndicator.gd    # Tutorial progress tracking
│   │
│   ├── ui/                         # User interface components
│   │   ├── components/             # Reusable UI elements
│   │   │   ├── ModuleCard.gd           # Brain module display cards
│   │   │   ├── ProgressRing.gd         # Circular progress indicators
│   │   │   ├── StructureInfoPanel.gd   # Anatomical structure information
│   │   │   ├── QuizQuestion.gd         # Quiz question component
│   │   │   ├── AccessibleButton.gd     # Screen reader friendly buttons
│   │   │   ├── ResponsiveContainer.gd  # Responsive layout container
│   │   │   └── LoadingIndicator.gd     # Loading state component
│   │   │
│   │   ├── screens/                # Full screen layouts
│   │   │   ├── MainMenu.gd             # Application main menu
│   │   │   ├── LearningHub.gd          # Module selection hub
│   │   │   ├── BrainExplorer.gd        # 3D exploration interface
│   │   │   ├── AssessmentScreen.gd     # Quiz and testing interface
│   │   │   ├── ProgressScreen.gd       # Student progress overview
│   │   │   ├── SettingsScreen.gd       # Application settings
│   │   │   ├── TeacherPortal.gd        # Teacher main interface
│   │   │   ├── HelpScreen.gd           # User help and tutorials
│   │   │   └── FeedbackScreen.gd       # User feedback submission form
│   │   │
│   │   ├── dialogs/                # Modal dialogs and popups
│   │   │   ├── StructureDetails.gd     # Anatomical structure details
│   │   │   ├── QuizResults.gd          # Assessment results display
│   │   │   ├── ContentEditor.gd        # Content creation dialog
│   │   │   ├── SettingsDialog.gd       # Settings configuration
│   │   │   ├── AuthenticationDialog.gd # Google sign-in dialog
│   │   │   ├── ErrorDialog.gd          # Error message display
│   │   │   └── AIChat.gd               # Teacher AI assistant chat
│   │   │
│   │   └── accessibility/          # Accessibility-specific components
│   │       ├── ScreenReaderHelper.gd   # Screen reader integration
│   │       ├── KeyboardNavigator.gd    # Keyboard navigation system
│   │       ├── FocusManager.gd         # Focus handling and indicators
│   │       └── HighContrastManager.gd  # High contrast mode support
│   │
│   ├── data/                       # Data management and models
│   │   ├── models/                 # Data structure definitions
│   │   │   ├── UserProfile.gd          # Student/teacher profile data
│   │   │   ├── BrainStructure.gd       # Anatomical structure data model
│   │   │   ├── EducationalContent.gd   # Educational content structure
│   │   │   ├── Assessment.gd           # Quiz and assessment data
│   │   │   ├── LearningProgress.gd     # Progress tracking data
│   │   │   └── ClassroomData.gd        # Classroom management data
│   │   │
│   │   ├── database/               # Local database management
│   │   │   ├── DatabaseManager.gd      # SQLite database interface
│   │   │   ├── MigrationManager.gd     # Database schema migrations
│   │   │   ├── QueryBuilder.gd         # SQL query construction
│   │   │   └── BackupManager.gd        # Database backup and restore
│   │   │
│   │   ├── sync/                   # Cloud synchronization
│   │   │   ├── SyncManager.gd          # Main synchronization coordinator
│   │   │   ├── ConflictResolver.gd     # Data conflict resolution
│   │   │   ├── OfflineQueue.gd         # Offline action queuing
│   │   │   └── DataValidator.gd        # Sync data validation
│   │   │
│   │   └── schemas/                # Data validation schemas
│   │       ├── user_profile.json       # User profile validation
│   │       ├── educational_content.json # Content validation
│   │       ├── assessment_data.json    # Assessment validation
│   │       └── sync_protocol.json      # Sync data validation
│   │
│   └── utils/                      # Utility functions and helpers
│       ├── FileManager.gd              # File system operations
│       ├── JSONHelper.gd               # JSON parsing and validation
│       ├── MathUtils.gd                # Mathematical calculations
│       ├── StringUtils.gd              # String manipulation utilities
│       ├── ImageProcessor.gd           # Image processing for UI
│       ├── Logger.gd                   # Logging system
│       ├── Encryption.gd               # Data encryption utilities
│       └── PlatformDetector.gd         # Platform-specific adaptations
│
├── tests/                          # Automated testing
│   ├── unit/                       # Unit tests
│   │   ├── test_brain_interaction.gd
│   │   ├── test_content_management.gd
│   │   ├── test_assessment_system.gd
│   │   ├── test_teacher_tools.gd
│   │   ├── test_data_sync.gd
│   │   └── test_accessibility.gd
│   │
│   ├── integration/                # Integration tests
│   │   ├── test_3d_interaction_flow.gd
│   │   ├── test_assessment_flow.gd
│   │   ├── test_teacher_workflow.gd
│   │   ├── test_cloud_sync.gd
│   │   └── test_offline_mode.gd
│   │
│   ├── performance/                # Performance tests
│   │   ├── test_3d_rendering.gd
│   │   ├── test_model_loading.gd
│   │   ├── test_memory_usage.gd
│   │   └── test_startup_time.gd
│   │
│   ├── accessibility/              # Accessibility tests
│   │   ├── test_screen_reader.gd
│   │   ├── test_keyboard_navigation.gd
│   │   ├── test_high_contrast.gd
│   │   └── test_focus_management.gd
│   │
│   └── platform/                   # Cross-platform tests
│       ├── test_windows_specific.gd
│       ├── test_macos_specific.gd
│       ├── test_linux_specific.gd
│       └── test_cross_platform_compatibility.gd
│
├── content/                        # Educational content
│   ├── brain_regions/              # Neuroanatomy content by region
│   │   ├── forebrain/
│   │   │   ├── hippocampus.json
│   │   │   ├── amygdala.json
│   │   │   ├── cortex.json
│   │   │   └── thalamus.json
│   │   ├── midbrain/
│   │   │   ├── substantia_nigra.json
│   │   │   └── superior_colliculus.json
│   │   └── hindbrain/
│   │       ├── cerebellum.json
│   │       ├── pons.json
│   │       └── medulla.json
│   │
│   ├── assessments/                # Pre-built assessments
│   │   ├── basic_anatomy/
│   │   ├── brain_functions/
│   │   ├── neural_pathways/
│   │   └── clinical_correlations/
│   │
│   ├── learning_paths/             # Structured learning sequences
│   │   ├── high_school_intro.json
│   │   ├── undergraduate_detailed.json
│   │   └── graduate_advanced.json
│   │
│   └── templates/                  # Content creation templates
│       ├── structure_template.json
│       ├── assessment_template.json
│       └── learning_objective_template.json
│
├── docs/                           # Documentation
│   ├── CLAUDE.md                   # AI development guide (detailed above)
│   ├── architecture.md             # System architecture documentation
│   ├── api_reference.md            # API documentation
│   ├── standards.md                # Coding standards (detailed above)
│   ├── security.md                 # Security and secret management guide
│   ├── deployment.md               # Deployment and distribution guide
│   ├── user_guide/                 # User documentation
│   │   ├── student_guide.md
│   │   ├── teacher_guide.md
│   │   └── accessibility_guide.md
│   ├── developer_guide/            # Developer documentation
│   │   ├── setup.md
│   │   ├── contributing.md
│   │   ├── testing.md
│   │   └── troubleshooting.md
│   └── design/                     # Design documentation
│       ├── ui_wireframes/
│       ├── user_flow_diagrams/
│       └── accessibility_requirements.md
│
├── scripts/                        # Build and deployment scripts
│   ├── build/                      # Build automation
│   │   ├── build.sh                # Main build script
│   │   ├── export_all_platforms.sh # Multi-platform export
│   │   ├── optimize_assets.sh      # Asset optimization
│   │   └── generate_lod_models.py  # Automatic LOD generation
│   │
│   ├── deploy/                     # Deployment automation
│   │   ├── deploy.sh               # Main deployment script
│   │   ├── sign_executables.sh     # Code signing
│   │   ├── upload_to_cdn.sh        # CDN upload
│   │   └── update_version.sh       # Version management
│   │
│   ├── development/                # Development utilities
│   │   ├── setup_dev_env.sh        # Development environment setup
│   │   ├── run_tests.sh            # Test execution
│   │   ├── generate_docs.sh        # Documentation generation
│   │   └── claude_code_setup.sh    # Claude Code CLI setup
│   │
│   └── maintenance/                # Maintenance scripts
│       ├── backup_user_data.sh     # User data backup
│       ├── check_dependencies.sh   # Dependency health check
│       ├── update_api_keys.sh      # API key rotation
│       └── cleanup_logs.sh         # Log file maintenance
│
├── config/                         # Configuration files
│   ├── export_presets.cfg          # Godot export settings
│   ├── project.godot               # Main Godot project file
│   ├── .gdignore                   # Godot ignore patterns
│   ├── .gitignore                  # Git ignore patterns
│   ├── .gitattributes              # Git LFS configuration (detailed above)
│   ├── firebase.json               # Firebase configuration
│   ├── google_oauth_config.json    # Google OAuth settings
│   └── api_endpoints.json          # API endpoint configuration
│
├── .editorconfig                   # Cross-editor consistency settings
│
├── certificates/                   # Code signing certificates (secure storage)
│   ├── windows_cert.p12.encrypted  # Windows code signing
│   ├── apple_cert.p12.encrypted    # Apple code signing
│   └── certificate_manager.py      # Certificate management utility
│
├── releases/                       # Release artifacts
│   ├── v1.0.0/                     # Version-specific releases
│   │   ├── windows/
│   │   ├── macos/
│   │   ├── linux/
│   │   └── release_notes.md
│   └── latest/                     # Latest stable release
│
├── user_data/                      # User data directory (local installation)
│   ├── progress/                   # Student progress data
│   ├── content_cache/              # Cached cloud content
│   ├── logs/                       # Application logs
│   ├── backups/                    # Local backups
│   └── settings/                   # User preferences
│
├── .env.example                    # Environment variables template
├── LICENSE                         # Software license
├── README.md                       # Project overview and setup instructions
└── CONTRIBUTING.md                 # Contribution guidelines
]
