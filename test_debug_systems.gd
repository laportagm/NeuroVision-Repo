extends Node

## Test script to verify all debug systems are working

func _ready():
	print("\n=== Testing Debug Systems ===\n")
	
	# Test 1: Check if DebugSystem autoload is available
	print("1. Testing DebugSystem autoload...")
	if has_node("/root/DebugSystem"):
		var debug_system = get_node("/root/DebugSystem")
		print("   ✓ DebugSystem found")
		
		# Test logging functions
		debug_system.log_debug("TEST", "Debug message test")
		debug_system.log_warning("TEST", "Warning message test")
		debug_system.log_error("TEST", "Error message test (this is intentional)")
		
		# Test profiling
		debug_system.start_profiling("test_function")
		await get_tree().create_timer(0.1).timeout
		var time = debug_system.end_profiling("test_function")
		print("   ✓ Profiling test completed: %.2fms" % time)
		
		# Test resource checking
		var exists = debug_system.check_resource_exists("res://project.godot", "for testing")
		print("   ✓ Resource check: %s" % ("passed" if exists else "failed"))
	else:
		print("   ✗ DebugSystem not found!")
	
	# Test 2: Check if DebugConsole is available
	print("\n2. Testing DebugConsole autoload...")
	if has_node("/root/DebugConsoleAutoload"):
		var console_autoload = get_node("/root/DebugConsoleAutoload")
		print("   ✓ DebugConsoleAutoload found")
		
		if console_autoload.debug_console:
			print("   ✓ Debug console instance created")
			print("   Press ` (backtick) to toggle the debug console")
		else:
			print("   ✗ Debug console instance not created")
	else:
		print("   ✗ DebugConsoleAutoload not found!")
	
	# Test 3: Check autoload status
	print("\n3. Checking all autoloads...")
	var autoloads = [
		"UnifiedColorManager",
		"UIThemeManager",
		"CoreSystemManager",
		"UISystemManager",
		"EducationalPlatformManager",
		"ResourceManager",
		"AuthenticationManager",
		"NetworkManager",
		"AssessmentService",
		"HighlightMaterialManager",
		"ProgressTracker",
		"IntelOptimizer",
		"DebugSystem",
		"DebugConsoleAutoload"
	]
	
	var loaded = 0
	var missing = []
	
	for autoload in autoloads:
		if has_node("/root/" + autoload):
			loaded += 1
		else:
			missing.append(autoload)
	
	print("   Loaded: %d/%d" % [loaded, autoloads.size()])
	if missing.size() > 0:
		print("   Missing: %s" % ", ".join(missing))
	
	# Test 4: Performance check
	print("\n4. Testing performance monitoring...")
	var fps = Engine.get_frames_per_second()
	var memory_mb = (Performance.get_monitor(Performance.MEMORY_STATIC) + Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)) / 1024.0 / 1024.0
	print("   FPS: %d" % fps)
	print("   Memory: %.2f MB" % memory_mb)
	
	# Test 5: Debug commands
	print("\n5. Testing debug commands...")
	if has_node("/root/DebugSystem"):
		var debug_system = get_node("/root/DebugSystem")
		print("   Executing 'help' command...")
		debug_system.execute_debug_command("help")
		print("   ✓ Command executed")
	
	print("\n=== Debug Systems Test Complete ===")
	print("\nInstructions:")
	print("- Press ` (backtick) to open the debug console")
	print("- Type 'help' in the console for available commands")
	print("- Check the debug overlay in the top-right corner")
	print("- Run './debug_neurovision_enhanced.sh' for external debugging")
	print("- Run './tools/scripts/comprehensive_error_check.sh' for error scanning")
	
	# Wait a bit then return to main menu
	await get_tree().create_timer(5.0).timeout
	print("\nReturning to main menu...")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")