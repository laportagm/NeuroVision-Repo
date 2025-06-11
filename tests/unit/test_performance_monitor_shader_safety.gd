extends GutTest

## Test shader parameter safety in PerformanceMonitor

func test_safe_shader_param_setting():
	# Test that shader param setting doesn't crash
	var pm = preload("res://src/autoload/PerformanceMonitor.gd").new()
	
	# These should not crash even without defined shader params
	pm._safe_set_shader_param("texture_lod_bias", 1.0)
	pm._safe_set_shader_param("glow_enabled", true)
	pm._safe_set_shader_param("ssr_enabled", false)
	
	# Test passed if we get here without crashes
	assert_true(true)

func test_quality_settings_without_shaders():
	# Test that quality changes work without shader params
	var pm = preload("res://src/autoload/PerformanceMonitor.gd").new()
	
	# These should all work without errors
	pm._apply_low_quality()
	pm._apply_medium_quality() 
	pm._apply_high_quality()
	pm._apply_ultra_quality()
	
	assert_true(true)

func test_performance_targets():
	# Verify performance monitoring works
	var pm = preload("res://src/autoload/PerformanceMonitor.gd").new()
	
	# Check that monitoring can start
	pm.start_monitoring()
	assert_true(pm._is_monitoring)
	
	# Check metrics are available
	var metrics = pm.get_current_metrics()
	assert_has(metrics, "fps")
	assert_has(metrics, "memory")
	assert_has(metrics, "quality_level")
	
	pm.stop_monitoring()

func test_auto_quality_adjustment_logic():
	# Test quality adjustment thresholds
	var pm = preload("res://src/autoload/PerformanceMonitor.gd").new()
	
	# Simulate low FPS
	pm._average_fps = 25.0
	pm._current_quality = PerformanceMonitor.QualityLevel.HIGH
	pm._check_and_adjust_quality()
	
	# Should downgrade quality
	assert_eq(pm._current_quality, PerformanceMonitor.QualityLevel.MEDIUM)
	
	# Simulate high FPS
	pm._average_fps = 65.0
	pm._fps_variance = 2.0
	pm._current_quality = PerformanceMonitor.QualityLevel.MEDIUM
	pm._check_and_adjust_quality()
	
	# Should upgrade quality
	assert_eq(pm._current_quality, PerformanceMonitor.QualityLevel.HIGH)