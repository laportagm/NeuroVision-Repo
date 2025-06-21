class_name BasePanel
extends Control

## Base class for all NeuroVision panels with built-in theme support and animations

# Signals
signal panel_opened()
signal panel_closed()
signal visibility_changed(is_visible: bool)

# Configuration
@export_group("Panel Settings")
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 30.0
@export var animation_duration: float = 0.3
@export var panel_width: int = 400

@export_group("Theme")
@export var theme_variant: String = "enhanced"
@export var use_glass_effect: bool = true

# State
var _is_visible: bool = false
var _tween: Tween
var _auto_hide_timer: Timer

# Virtual methods to override
func _setup_content() -> void:
	pass

func _apply_theme_variant() -> void:
	if UnifiedColorManager:
		var colors = UnifiedColorManager.get_current_theme_colors()
		_apply_panel_style(colors)

func _apply_panel_style(colors: Dictionary) -> void:
	# Apply base panel styling
	var style = StyleBoxFlat.new()
	style.bg_color = colors.get("surface_container", Color.WHITE)
	style.set_corner_radius_all(12)
	add_theme_stylebox_override("panel", style)
	
	# Apply glass effect if enabled
	if use_glass_effect and material:
		material.set_shader_parameter("tint_color", colors.get("surface_tint", Color.WHITE))

# Public API
func show_panel(content: Dictionary = {}) -> void:
	if _is_visible:
		return
	
	_is_visible = true
	visible = true
	
	# Load content if provided
	if not content.is_empty():
		_load_content(content)
	
	# Animate in
	_animate_in()
	
	# Setup auto-hide
	if auto_hide:
		_reset_auto_hide_timer()
	
	panel_opened.emit()
	visibility_changed.emit(true)

func hide_panel() -> void:
	if not _is_visible:
		return
	
	_is_visible = false
	_animate_out()
	
	panel_closed.emit()
	visibility_changed.emit(false)

func toggle_panel() -> void:
	if _is_visible:
		hide_panel()
	else:
		show_panel()

# Protected methods
func _ready() -> void:
	_setup_base()
	_setup_content()
	_apply_theme_variant()
	
	# Connect to theme changes
	if UnifiedColorManager:
		UnifiedColorManager.theme_changed.connect(_on_theme_changed)

func _setup_base() -> void:
	# Base setup for all panels
	custom_minimum_size.x = panel_width
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Setup auto-hide timer
	if auto_hide:
		_auto_hide_timer = Timer.new()
		_auto_hide_timer.wait_time = auto_hide_delay
		_auto_hide_timer.one_shot = true
		_auto_hide_timer.timeout.connect(hide_panel)
		add_child(_auto_hide_timer)

func _animate_in() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Start state
	modulate.a = 0.0
	scale = Vector2(0.95, 0.95)
	
	# Animate
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, animation_duration)
	_tween.tween_property(self, "scale", Vector2.ONE, animation_duration)

func _animate_out() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, animation_duration * 0.8)
	_tween.tween_property(self, "scale", Vector2(0.95, 0.95), animation_duration)
	_tween.set_parallel(false)
	_tween.tween_callback(func(): visible = false)

func _load_content(content: Dictionary) -> void:
	# Override in derived classes
	pass

func _reset_auto_hide_timer() -> void:
	if _auto_hide_timer and auto_hide:
		_auto_hide_timer.stop()
		_auto_hide_timer.start()

func _on_theme_changed(new_theme: String) -> void:
	theme_variant = new_theme
	_apply_theme_variant()

# Input handling
func _gui_input(event: InputEvent) -> void:
	# Reset auto-hide on interaction
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if auto_hide and _is_visible:
			_reset_auto_hide_timer()