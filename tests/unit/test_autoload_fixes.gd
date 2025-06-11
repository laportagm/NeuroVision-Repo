extends GutTest

## Tests for Level 1: Autoload Script Fixes

# === ERROR RECOVERY MANAGER TESTS ===

func test_error_recovery_handles_context_parameter():
	var error_manager = preload("res://src/autoload/ErrorRecoveryManager.gd").new()
	
	# Should not cause parameter warning
	error_manager.handle_error("TEST_ERROR", "Test message", {"key": "value"})
	
	# Check error was recorded
	var history = error_manager.get_error_history()
	assert_gt(history.size(), 0)
	assert_eq(history[0].code, "TEST_ERROR")
	
	error_manager.queue_free()

# === ACCESSIBILITY MANAGER TESTS ===

func test_accessibility_uses_high_contrast_variable():
	var accessibility = preload("res://src/autoload/AccessibilityManager.gd").new()
	
	# Initially should be false
	assert_false(accessibility.is_high_contrast_enabled())
	
	# Enable accessibility
	accessibility.enable_accessibility()
	assert_true(accessibility.is_high_contrast_enabled())
	
	# Disable accessibility
	accessibility.disable_accessibility()
	assert_false(accessibility.is_high_contrast_enabled())
	
	accessibility.queue_free()

func test_accessibility_uses_reduce_motion_variable():
	var accessibility = preload("res://src/autoload/AccessibilityManager.gd").new()
	
	# Initially should be false
	assert_false(accessibility.is_reduce_motion_enabled())
	
	# Enable accessibility
	accessibility.enable_accessibility()
	assert_true(accessibility.is_reduce_motion_enabled())
	
	# Disable accessibility
	accessibility.disable_accessibility()
	assert_false(accessibility.is_reduce_motion_enabled())
	
	accessibility.queue_free()

# === CONTENT MANAGER TESTS ===

func test_content_manager_emits_load_failed_signal():
	var content_manager = preload("res://src/autoload/ContentManager.gd").new()
	var signal_emitted = false
	var error_message = ""
	
	content_manager.content_load_failed.connect(func(id, error):
		signal_emitted = true
		error_message = error
	)
	
	# Try to load non-existent content
	content_manager.load_content("non_existent_content")
	
	# Signal should have been emitted
	assert_true(signal_emitted)
	assert_true(error_message.contains("not found"))
	
	content_manager.queue_free()

func test_content_manager_caches_loaded_content():
	var content_manager = preload("res://src/autoload/ContentManager.gd").new()
	
	# Test cache functionality
	content_manager._content_cache["test_id"] = {"data": "test"}
	
	var content = content_manager.get_content("test_id")
	assert_eq(content.data, "test")
	
	# Non-existent content should return empty dict
	var missing = content_manager.get_content("missing_id")
	assert_eq(missing, {})
	
	content_manager.queue_free()

# === AUTHENTICATION MANAGER TESTS ===

func test_auth_manager_uses_password_parameter():
	var auth_manager = preload("res://src/autoload/AuthenticationManager.gd").new()
	add_child(auth_manager)  # Need to add to tree for timer
	
	var login_success = false
	var login_error = ""
	
	auth_manager.login_successful.connect(func(user_id):
		login_success = true
	)
	
	auth_manager.login_failed.connect(func(error):
		login_error = error
	)
	
	# Test empty username
	auth_manager.login("", "password123")
	assert_false(login_success)
	assert_eq(login_error, "Username cannot be empty")
	
	# Test valid login
	auth_manager.login("testuser", "password123")
	assert_true(auth_manager.is_authenticated())
	
	auth_manager.queue_free()

func test_auth_manager_session_timer():
	var auth_manager = preload("res://src/autoload/AuthenticationManager.gd").new()
	add_child(auth_manager)
	
	# Login should start session timer
	auth_manager.login("testuser", "password")
	assert_true(auth_manager.is_authenticated())
	
	# Logout should work
	auth_manager.logout()
	assert_false(auth_manager.is_authenticated())
	
	auth_manager.queue_free()

# === COMPREHENSIVE AUTOLOAD STARTUP TEST ===

func test_all_autoloads_initialize_without_warnings():
	# This test verifies that all autoloads can be instantiated without errors
	var managers = []
	
	# Create all managers
	managers.append(preload("res://src/autoload/ErrorRecoveryManager.gd").new())
	managers.append(preload("res://src/autoload/AccessibilityManager.gd").new())
	managers.append(preload("res://src/autoload/ContentManager.gd").new())
	managers.append(preload("res://src/autoload/AuthenticationManager.gd").new())
	managers.append(preload("res://src/autoload/NetworkManager.gd").new())
	managers.append(preload("res://src/autoload/SettingsManager.gd").new())
	managers.append(preload("res://src/autoload/ProgressTracker.gd").new())
	
	# All should be valid
	for manager in managers:
		assert_not_null(manager)
	
	# Cleanup
	for manager in managers:
		if manager.has_method("queue_free"):
			manager.queue_free()