extends Node

## UIPoolManager - Efficient object pooling for educational UI components
## Manages frequently created/destroyed UI elements to improve performance

signal pool_created(pool_name: String)
signal pool_exhausted(pool_name: String, current_size: int)
signal metrics_updated(pool_name: String, metrics: Dictionary)

# === CONSTANTS ===
const MAX_POOL_SIZE_DEFAULT: int = 50
const CLEANUP_INTERVAL: float = 30.0  # seconds
const METRICS_INTERVAL: float = 5.0   # seconds
const MEMORY_PRESSURE_THRESHOLD: int = 100  # MB

# === POOL CONFIGURATION ===
var POOL_CONFIGS = {
	"quiz_answer_button": {
		"scene_path": "",  # Will be set to Button class
		"pre_warm_count": 8,
		"max_size": 20,
		"growth_factor": 4,
		"component_class": Button
	},
	"structure_list_item": {
		"scene_path": "",  # Will be set to Button class
		"pre_warm_count": 60,
		"max_size": 100,
		"growth_factor": 20,
		"component_class": Button
	},
	"notification_popup": {
		"scene_path": "res://src/ui/components/NotificationPopup.tscn",
		"pre_warm_count": 3,
		"max_size": 10,
		"growth_factor": 2,
		"component_class": null  # Will load from scene
	},
	"progress_indicator": {
		"scene_path": "",  # Will be set to ProgressBar class
		"pre_warm_count": 2,
		"max_size": 5,
		"growth_factor": 1,
		"component_class": ProgressBar
	}
}

# === PRIVATE VARIABLES ===
var _pools: Dictionary = {}
var _cleanup_timer: Timer
var _metrics_timer: Timer
var _is_initialized: bool = false

# Debug and monitoring
var _debug_mode: bool = false
var _total_objects_created: int = 0
var _total_objects_reused: int = 0

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the pool manager and create essential pools"""
	print("[UIPoolManager] Initializing object pooling system")
	_setup_timers()
	_initialize_essential_pools()
	_is_initialized = true
	print("[UIPoolManager] Pool system ready - %d pools initialized" % _pools.size())

func create_pool(pool_name: String, config: Dictionary = {}) -> bool:
	"""Create a new object pool with configuration"""
	if _pools.has(pool_name):
		push_warning("[UIPoolManager] Pool '%s' already exists" % pool_name)
		return false
	
	# Merge with default config
	var default_config = POOL_CONFIGS.get(pool_name, {})
	var final_config = default_config.duplicate()
	
	for key in config:
		final_config[key] = config[key]
	
	# Validate required fields
	if not final_config.has("component_class") and not final_config.has("scene_path"):
		push_error("[UIPoolManager] Pool '%s' needs either component_class or scene_path" % pool_name)
		return false
	
	# Create pool structure
	_pools[pool_name] = {
		"config": final_config,
		"available": [],
		"in_use": [],
		"created_count": 0,
		"reuse_count": 0,
		"last_used": Time.get_time_dict_from_system(),
		"allocation_times": [],
		"return_times": []
	}
	
	# Pre-warm the pool
	var pre_warm_count = final_config.get("pre_warm_count", 0)
	_pre_warm_pool(pool_name, pre_warm_count)
	
	pool_created.emit(pool_name)
	print("[UIPoolManager] Created pool '%s' with %d pre-warmed objects" % [pool_name, pre_warm_count])
	return true

func get_object(pool_name: String) -> Control:
	"""Get an object from the pool (create if necessary)"""
	if not _pools.has(pool_name):
		push_error("[UIPoolManager] Pool '%s' does not exist" % pool_name)
		return null
	
	var pool = _pools[pool_name]
	var start_time = Time.get_time_dict_from_system()
	
	var obj: Control = null
	
	# Try to get from available objects
	if pool.available.size() > 0:
		obj = pool.available.pop_back()
		pool.reuse_count += 1
		_total_objects_reused += 1
		
		if _debug_mode:
			print("[UIPoolManager] Reused object from pool '%s' (available: %d)" % [pool_name, pool.available.size()])
	else:
		# Create new object
		obj = _create_new_object(pool_name)
		if obj:
			pool.created_count += 1
			_total_objects_created += 1
			
			# Check if pool is approaching limit
			var total_objects = pool.available.size() + pool.in_use.size()
			var max_size = pool.config.get("max_size", MAX_POOL_SIZE_DEFAULT)
			
			if total_objects >= max_size * 0.8:
				pool_exhausted.emit(pool_name, total_objects)
				if _debug_mode:
					print("[UIPoolManager] Pool '%s' approaching limit (%d/%d)" % [pool_name, total_objects, max_size])
	
	if obj:
		# Add to in-use tracking
		pool.in_use.append(obj)
		pool.last_used = Time.get_time_dict_from_system()
		
		# Track allocation time
		var end_time = Time.get_time_dict_from_system()
		var allocation_time = _calculate_time_diff(start_time, end_time)
		pool.allocation_times.append(allocation_time)
		
		# Keep only recent timing data
		if pool.allocation_times.size() > 100:
			pool.allocation_times = pool.allocation_times.slice(-50)
		
		# Reset object state
		if obj.has_method("reset"):
			obj.reset()
		else:
			_default_reset(obj)
	
	return obj

func return_object(pool_name: String, obj: Control) -> bool:
	"""Return an object to the pool"""
	if not obj or not is_instance_valid(obj):
		push_warning("[UIPoolManager] Cannot return null or invalid object to pool '%s'" % pool_name)
		return false
	
	if not _pools.has(pool_name):
		push_error("[UIPoolManager] Pool '%s' does not exist" % pool_name)
		return false
	
	var pool = _pools[pool_name]
	var start_time = Time.get_time_dict_from_system()
	
	# Remove from in-use tracking
	var in_use_index = pool.in_use.find(obj)
	if in_use_index == -1:
		push_warning("[UIPoolManager] Object not found in in_use list for pool '%s'" % pool_name)
		return false
	
	pool.in_use.remove_at(in_use_index)
	
	# Reset object state
	if obj.has_method("reset"):
		obj.reset()
	else:
		_default_reset(obj)
	
	# Remove from scene tree if needed
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	
	# Check pool size limits
	var max_size = pool.config.get("max_size", MAX_POOL_SIZE_DEFAULT)
	if pool.available.size() >= max_size:
		# Pool is full, destroy the object
		obj.queue_free()
		if _debug_mode:
			print("[UIPoolManager] Pool '%s' full, destroying returned object" % pool_name)
	else:
		# Add back to available pool
		pool.available.append(obj)
		if _debug_mode:
			print("[UIPoolManager] Returned object to pool '%s' (available: %d)" % [pool_name, pool.available.size()])
	
	# Track return time
	var end_time = Time.get_time_dict_from_system()
	var return_time = _calculate_time_diff(start_time, end_time)
	pool.return_times.append(return_time)
	
	# Keep only recent timing data
	if pool.return_times.size() > 100:
		pool.return_times = pool.return_times.slice(-50)
	
	return true

func get_pool_stats(pool_name: String) -> Dictionary:
	"""Get detailed statistics for a pool"""
	if not _pools.has(pool_name):
		return {}
	
	var pool = _pools[pool_name]
	var stats = {
		"pool_name": pool_name,
		"available_count": pool.available.size(),
		"in_use_count": pool.in_use.size(),
		"total_created": pool.created_count,
		"total_reused": pool.reuse_count,
		"reuse_ratio": 0.0,
		"avg_allocation_time": 0.0,
		"avg_return_time": 0.0,
		"memory_saved_mb": 0.0,
		"efficiency_score": 0.0
	}
	
	# Calculate reuse ratio
	var total_requests = pool.created_count + pool.reuse_count
	if total_requests > 0:
		stats.reuse_ratio = float(pool.reuse_count) / float(total_requests)
	
	# Calculate average times
	if pool.allocation_times.size() > 0:
		var total_alloc_time = 0.0
		for time in pool.allocation_times:
			total_alloc_time += time
		stats.avg_allocation_time = total_alloc_time / pool.allocation_times.size()
	
	if pool.return_times.size() > 0:
		var total_return_time = 0.0
		for time in pool.return_times:
			total_return_time += time
		stats.avg_return_time = total_return_time / pool.return_times.size()
	
	# Estimate memory saved (rough calculation)
	var estimated_object_size = 0.05  # 50KB per UI object estimate
	stats.memory_saved_mb = pool.reuse_count * estimated_object_size
	
	# Calculate efficiency score (0-100)
	stats.efficiency_score = stats.reuse_ratio * 100.0
	
	return stats

func get_global_stats() -> Dictionary:
	"""Get global pooling statistics"""
	var total_available = 0
	var total_in_use = 0
	var total_created = 0
	var total_reused = 0
	
	for pool_name in _pools:
		var pool = _pools[pool_name]
		total_available += pool.available.size()
		total_in_use += pool.in_use.size()
		total_created += pool.created_count
		total_reused += pool.reuse_count
	
	var total_requests = total_created + total_reused
	var global_reuse_ratio = 0.0
	if total_requests > 0:
		global_reuse_ratio = float(total_reused) / float(total_requests)
	
	return {
		"total_pools": _pools.size(),
		"total_available": total_available,
		"total_in_use": total_in_use,
		"total_created": total_created,
		"total_reused": total_reused,
		"global_reuse_ratio": global_reuse_ratio,
		"memory_saved_mb": total_reused * 0.05,  # Estimate
		"performance_improvement": global_reuse_ratio * 100.0
	}

func cleanup_pools() -> void:
	"""Clean up oversized pools and unused objects"""
	print("[UIPoolManager] Running pool cleanup...")
	var cleaned_count = 0
	
	for pool_name in _pools:
		var pool = _pools[pool_name]
		var target_size = pool.config.get("pre_warm_count", 5)
		
		# Remove excess objects beyond target size
		while pool.available.size() > target_size:
			var obj = pool.available.pop_back()
			if is_instance_valid(obj):
				obj.queue_free()
				cleaned_count += 1
	
	print("[UIPoolManager] Cleanup completed - removed %d excess objects" % cleaned_count)

func clear_pool(pool_name: String) -> bool:
	"""Clear all objects from a specific pool"""
	if not _pools.has(pool_name):
		return false
	
	var pool = _pools[pool_name]
	
	# Free all available objects
	for obj in pool.available:
		if is_instance_valid(obj):
			obj.queue_free()
	
	# Clear arrays
	pool.available.clear()
	# Note: Don't clear in_use as those objects are still being used
	
	print("[UIPoolManager] Cleared pool '%s'" % pool_name)
	return true

func set_debug_mode(enabled: bool) -> void:
	"""Enable/disable debug logging"""
	_debug_mode = enabled
	print("[UIPoolManager] Debug mode: %s" % ("enabled" if enabled else "disabled"))

func shutdown() -> void:
	"""Shutdown the pool manager and clean up all resources"""
	print("[UIPoolManager] Shutting down pool system")
	
	for pool_name in _pools:
		clear_pool(pool_name)
	
	_pools.clear()
	
	if _cleanup_timer:
		_cleanup_timer.queue_free()
	if _metrics_timer:
		_metrics_timer.queue_free()

# === PRIVATE METHODS ===

func _setup_timers() -> void:
	"""Setup cleanup and metrics timers"""
	# Cleanup timer
	_cleanup_timer = Timer.new()
	_cleanup_timer.wait_time = CLEANUP_INTERVAL
	_cleanup_timer.timeout.connect(_on_cleanup_timer)
	_cleanup_timer.autostart = true
	add_child(_cleanup_timer)
	
	# Metrics timer
	_metrics_timer = Timer.new()
	_metrics_timer.wait_time = METRICS_INTERVAL
	_metrics_timer.timeout.connect(_on_metrics_timer)
	_metrics_timer.autostart = true
	add_child(_metrics_timer)

func _initialize_essential_pools() -> void:
	"""Initialize the most important pools for immediate use"""
	var essential_pools = ["quiz_answer_button", "structure_list_item"]
	
	for pool_name in essential_pools:
		if POOL_CONFIGS.has(pool_name):
			create_pool(pool_name)

func _pre_warm_pool(pool_name: String, count: int) -> void:
	"""Pre-create objects for a pool"""
	if count <= 0:
		return
	
	var pool = _pools[pool_name]
	
	for i in range(count):
		var obj = _create_new_object(pool_name)
		if obj:
			pool.available.append(obj)
			pool.created_count += 1

func _create_new_object(pool_name: String) -> Control:
	"""Create a new object for the pool"""
	var pool = _pools[pool_name]
	var config = pool.config
	
	var obj: Control = null
	
	# Create from component class
	if config.has("component_class") and config.component_class:
		obj = config.component_class.new()
		
		# Apply common UI setup
		_setup_pooled_object(obj, pool_name)
		
	# Create from scene file
	elif config.has("scene_path") and config.scene_path != "":
		if ResourceLoader.exists(config.scene_path):
			var scene = load(config.scene_path)
			obj = scene.instantiate()
		else:
			push_error("[UIPoolManager] Scene not found: %s" % config.scene_path)
			return null
	
	if obj:
		# Mark object as pooled
		obj.set_meta("pooled_object", true)
		obj.set_meta("pool_name", pool_name)
		
		if _debug_mode:
			print("[UIPoolManager] Created new object for pool '%s'" % pool_name)
	
	return obj

func _setup_pooled_object(obj: Control, pool_name: String) -> void:
	"""Apply common setup to pooled objects"""
	match pool_name:
		"quiz_answer_button":
			_setup_quiz_button(obj)
		"structure_list_item":
			_setup_structure_item(obj)
		"progress_indicator":
			_setup_progress_indicator(obj)

func _setup_quiz_button(button: Button) -> void:
	"""Setup a quiz answer button with standard properties"""
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0, 48)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Apply Material 3 styling if available
	if ClassDB.class_exists("M3ComponentApplicator"):
		M3ComponentApplicator.apply_m3_button_styling(button, M3ComponentApplicator.ButtonVariant.TERTIARY)

func _setup_structure_item(button: Button) -> void:
	"""Setup a structure list item button"""
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 48)
	
	# Apply Material 3 styling if available
	if ClassDB.class_exists("M3ComponentApplicator"):
		M3ComponentApplicator.apply_m3_button_styling(button, M3ComponentApplicator.ButtonVariant.TERTIARY)

func _setup_progress_indicator(progress_bar: ProgressBar) -> void:
	"""Setup a progress indicator"""
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.value = 0
	progress_bar.step = 1
	progress_bar.min_value = 0
	progress_bar.max_value = 100

func _default_reset(obj: Control) -> void:
	"""Default reset for objects without custom reset method"""
	if obj is Button:
		var button = obj as Button
		button.text = ""
		button.pressed = false
		button.disabled = false
		button.modulate = Color.WHITE
		
		# Disconnect all signals to prevent memory leaks
		var connections = button.get_signal_connection_list("pressed")
		for connection in connections:
			button.pressed.disconnect(connection.callable)
			
	elif obj is ProgressBar:
		var progress = obj as ProgressBar
		progress.value = 0
		
	elif obj is Label:
		var label = obj as Label
		label.text = ""
		label.modulate = Color.WHITE

func _calculate_time_diff(start_time: Dictionary, end_time: Dictionary) -> float:
	"""Calculate time difference in milliseconds"""
	var start_ms = start_time.hour * 3600000 + start_time.minute * 60000 + start_time.second * 1000
	var end_ms = end_time.hour * 3600000 + end_time.minute * 60000 + end_time.second * 1000
	return abs(end_ms - start_ms)

func _on_cleanup_timer() -> void:
	"""Periodic cleanup of pools"""
	cleanup_pools()

func _on_metrics_timer() -> void:
	"""Periodic metrics collection and reporting"""
	for pool_name in _pools:
		var stats = get_pool_stats(pool_name)
		metrics_updated.emit(pool_name, stats)
		
		# Integration with PerformanceMonitor if available
		if PerformanceMonitor:
			PerformanceMonitor.report_custom_metric("pool_efficiency_" + pool_name, stats.efficiency_score)