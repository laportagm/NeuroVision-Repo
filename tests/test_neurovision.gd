extends SceneTree

func _init():
    print("\n=== NeuroVision Test Suite ===\n")
    
    # Test 1: Check main scene
    print("[TEST] Loading main scene...")
    var main_scene_path = ProjectSettings.get_setting("application/run/main_scene")
    print("  Main scene: ", main_scene_path)
    
    if ResourceLoader.exists(main_scene_path):
        print("  ✅ Main scene file exists")
        var scene = load(main_scene_path)
        if scene:
            print("  ✅ Main scene loaded successfully")
            var instance = scene.instantiate()
            if instance:
                print("  ✅ Main scene instantiated")
                get_root().add_child(instance)
                print("  ✅ Main scene added to tree")
                
                # Test UI elements
                _test_main_menu_ui(instance)
            else:
                print("  ❌ Failed to instantiate main scene")
        else:
            print("  ❌ Failed to load main scene")
    else:
        print("  ❌ Main scene file not found")
    
    # Test 2: Check autoloads
    print("\n[TEST] Checking autoloads...")
    _test_autoloads()
    
    # Test 3: Check resources
    print("\n[TEST] Checking resources...")
    _test_resources()
    
    # Test 4: Check scenes
    print("\n[TEST] Checking scene files...")
    _test_scenes()
    
    print("\n=== Test Complete ===\n")
    quit()

func _test_main_menu_ui(main_menu):
    print("\n[TEST] Testing MainMenu UI...")
    
    # Find buttons
    var start_button = main_menu.get_node_or_null("CanvasLayer/CenterContainer/VBoxContainer/StartButton")
    var professional_button = main_menu.get_node_or_null("CanvasLayer/CenterContainer/VBoxContainer/ProfessionalButton")
    var settings_button = main_menu.get_node_or_null("CanvasLayer/CenterContainer/VBoxContainer/SettingsButton")
    var quit_button = main_menu.get_node_or_null("CanvasLayer/CenterContainer/VBoxContainer/QuitButton")
    
    if start_button:
        print("  ✅ Start button found")
        if start_button.pressed.is_connected(main_menu._on_start_button_pressed):
            print("  ✅ Start button connected")
        else:
            print("  ❌ Start button not connected")
    else:
        print("  ❌ Start button not found")
    
    if professional_button:
        print("  ✅ Professional button found")
    if settings_button:
        print("  ✅ Settings button found")
    if quit_button:
        print("  ✅ Quit button found")

func _test_autoloads():
    var autoloads = [
        "ButtonMotionHandler",
        "UnifiedColorManager",
        "CoreSystemManager",
        "UISystemManager",
        "EducationalPlatformManager",
        "ResourceManager",
        "NetworkManager",
        "AssessmentService",
        "HighlightMaterialManager",
        "ProgressTracker"
    ]
    
    for autoload in autoloads:
        if Engine.has_singleton(autoload):
            print("  ✅ ", autoload, " loaded")
        else:
            print("  ❌ ", autoload, " NOT loaded")

func _test_resources():
    var critical_resources = [
        "res://scenes/3d/EnhancedExplorationScene.tscn",
        "res://src/ui_atomic/organisms/StructureInfoPanel.tscn",
        "res://src/ui_atomic/organisms/QuizPanel.tscn",
        "res://src/ui_atomic/effects/shaders/glass_panel.gdshader",
        "res://src/ui_atomic/effects/shaders/medical_glass.gdshader"
    ]
    
    for resource in critical_resources:
        if ResourceLoader.exists(resource):
            print("  ✅ ", resource.get_file(), " exists")
        else:
            print("  ❌ ", resource, " NOT FOUND")

func _test_scenes():
    # Test exploration scene
    var exploration_path = "res://scenes/3d/EnhancedExplorationScene.tscn"
    if ResourceLoader.exists(exploration_path):
        print("  ✅ EnhancedExplorationScene exists")
        var scene = load(exploration_path)
        if scene:
            print("  ✅ EnhancedExplorationScene loads correctly")
            var instance = scene.instantiate()
            if instance:
                print("  ✅ EnhancedExplorationScene instantiates")
                instance.queue_free()
            else:
                print("  ❌ EnhancedExplorationScene failed to instantiate")
        else:
            print("  ❌ EnhancedExplorationScene failed to load")