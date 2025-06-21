extends Node

## Runtime test script that runs after autoloads are initialized
##
## This script tests the NeuroVision project at runtime, checking all
## major systems and reporting any issues.

var test_results = []
var error_count = 0

func _ready():
    print("\n=== NeuroVision Runtime Test ===\n")
    
    # Give autoloads time to initialize
    await get_tree().create_timer(0.5).timeout
    
    # Run all tests
    _test_autoloads()
    _test_main_menu()
    _test_resources()
    _test_scene_loading()
    _test_ui_components()
    
    # Report results
    _report_results()
    
    # Quit after tests
    await get_tree().create_timer(2.0).timeout
    get_tree().quit()

func _test_autoloads():
    print("[TEST] Checking Autoloads...")
    var autoloads = {
        "UnifiedColorManager": "Color system manager",
        "CoreSystemManager": "Core systems",
        "UISystemManager": "UI systems",
        "EducationalPlatformManager": "Educational platform",
        "ResourceManager": "Resource management",
        "AuthenticationManager": "Authentication",
        "NetworkManager": "Network management",
        "AssessmentService": "Assessment system",
        "HighlightMaterialManager": "3D highlight materials",
        "ProgressTracker": "Progress tracking"
    }
    
    for autoload_name in autoloads:
        var singleton = get_node("/root/" + autoload_name)
        if singleton:
            test_results.append("✅ %s loaded (%s)" % [autoload_name, autoloads[autoload_name]])
        else:
            test_results.append("❌ %s NOT FOUND" % autoload_name)
            error_count += 1

func _test_main_menu():
    print("\n[TEST] Testing Main Menu...")
    
    # Check if we're in the main menu scene
    var current_scene = get_tree().current_scene
    if current_scene and current_scene.has_method("_on_start_button_pressed"):
        test_results.append("✅ Main menu scene loaded correctly")
        
        # Test buttons
        var buttons = {
            "CanvasLayer/CenterContainer/VBoxContainer/StartButton": "Start button",
            "CanvasLayer/CenterContainer/VBoxContainer/ProfessionalButton": "Professional button",
            "CanvasLayer/CenterContainer/VBoxContainer/SettingsButton": "Settings button",
            "CanvasLayer/CenterContainer/VBoxContainer/QuitButton": "Quit button"
        }
        
        for button_path in buttons:
            var button = current_scene.get_node_or_null(button_path)
            if button and button is Button:
                test_results.append("✅ %s found and valid" % buttons[button_path])
            else:
                test_results.append("❌ %s not found" % buttons[button_path])
                error_count += 1
    else:
        test_results.append("⚠️  Not in main menu scene")

func _test_resources():
    print("\n[TEST] Checking Critical Resources...")
    var resources = [
        "res://scenes/3d/EnhancedExplorationScene.tscn",
        "res://src/ui_atomic/organisms/StructureInfoPanel.tscn",
        "res://src/ui_atomic/organisms/QuizPanel.tscn",
        # "res://src/ui_atomic/effects/shaders/glass_panel.gdshader", # Deprecated - replaced with StyleBoxFlat
        "res://src/ui_atomic/effects/shaders/medical_glass.gdshader",
        "res://assets/3d_models/processed/Internal_Structures_LOD/Internal-Structures_low.glb"
    ]
    
    for resource_path in resources:
        if ResourceLoader.exists(resource_path):
            test_results.append("✅ %s exists" % resource_path.get_file())
        else:
            test_results.append("❌ %s NOT FOUND" % resource_path)
            error_count += 1

func _test_scene_loading():
    print("\n[TEST] Testing Scene Loading...")
    
    # Test if exploration scene can be loaded
    var exploration_scene = load("res://scenes/3d/EnhancedExplorationScene.tscn")
    if exploration_scene:
        test_results.append("✅ EnhancedExplorationScene loads successfully")
        
        # Try to instantiate it
        var instance = exploration_scene.instantiate()
        if instance:
            test_results.append("✅ EnhancedExplorationScene instantiates correctly")
            instance.queue_free()
        else:
            test_results.append("❌ EnhancedExplorationScene failed to instantiate")
            error_count += 1
    else:
        test_results.append("❌ EnhancedExplorationScene failed to load")
        error_count += 1

func _test_ui_components():
    print("\n[TEST] Testing UI Components...")
    
    # Test theme system
    var color_manager = get_node_or_null("/root/UnifiedColorManager")
    if color_manager:
        # Try to get a color
        if color_manager.has_method("get_color"):
            var test_color = color_manager.get_color("primary")
            if test_color is Color:
                test_results.append("✅ Color system working (primary: %s)" % test_color)
            else:
                test_results.append("❌ Color system not returning valid colors")
                error_count += 1
        else:
            test_results.append("❌ UnifiedColorManager missing get_color method")
            error_count += 1
    
    # Test button animation handler
    var button_handler = get_node_or_null("/root/ButtonMotionHandler")
    if button_handler:
        if button_handler.has_method("setup_button_hover_animation"):
            test_results.append("✅ ButtonMotionHandler has animation methods")
        else:
            test_results.append("❌ ButtonMotionHandler missing animation methods")
            error_count += 1

func _report_results():
    print("\n=== Test Results ===\n")
    
    for result in test_results:
        print(result)
    
    print("\n=== Summary ===")
    print("Total tests: %d" % test_results.size())
    print("Errors found: %d" % error_count)
    
    if error_count == 0:
        print("\n✅ All tests passed! NeuroVision is ready.")
    else:
        print("\n❌ %d errors found. Please fix these issues." % error_count)