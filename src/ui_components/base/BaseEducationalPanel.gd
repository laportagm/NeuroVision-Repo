class_name BaseEducationalPanel
extends Control

## Minimal base panel that integrates with existing NeuroVision systems
## Designed to work without breaking any existing functionality

signal panel_opened()
signal panel_closed()

# Configuration
@export_group("Panel Configuration")
@export var panel_name: String = "BasePanel"
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 30.0

# Internal state
var _is_visible: bool = false
var _auto_hide_timer: Timer

func _ready() -> void:
	# Ensure we work with existing systems
	set_process_unhandled_input(false)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Hide by default
	visible = false
	modulate.a = 0.0
	
	# Setup auto-hide if needed
	if auto_hide:
		_setup_auto_hide_timer()
	
	# Let derived classes set up
	_setup_panel()

## Override this in derived classes to setup your specific panel
func _setup_panel() -> void:
	pass

## Show the panel with optional data
func show_panel(data: Dictionary = {}) -> void:
	if _is_visible:
		return
		
	_is_visible = true
	visible = true
	
	# Simple fade in animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Load data if provided
	if not data.is_empty():
		_on_data_received(data)
	
	# Start auto-hide timer
	if auto_hide and _auto_hide_timer:
		_auto_hide_timer.start()
	
	panel_opened.emit()

## Hide the panel
func hide_panel() -> void:
	if not _is_visible:
		return
		
	_is_visible = false
	
	# Simple fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): visible = false)
	
	# Stop auto-hide timer
	if _auto_hide_timer:
		_auto_hide_timer.stop()
	
	panel_closed.emit()

## Override this to handle data
func _on_data_received(data: Dictionary) -> void:
	pass

func _setup_auto_hide_timer() -> void:
	_auto_hide_timer = Timer.new()
	_auto_hide_timer.wait_time = auto_hide_delay
	_auto_hide_timer.one_shot = true
	_auto_hide_timer.timeout.connect(hide_panel)
	add_child(_auto_hide_timer)

## Reset auto-hide timer on interaction
func _gui_input(event: InputEvent) -> void:
	if auto_hide and _auto_hide_timer and _is_visible:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			_auto_hide_timer.start()  # Reset timer