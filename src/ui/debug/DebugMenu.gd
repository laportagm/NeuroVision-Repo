class_name DebugMenu
extends Control

## In-game debug menu for NeuroVision development
## Press F12 to toggle

# === SIGNALS ===
signal scene_change_requested(scene_path: String)

# === CONSTANTS ===
const SCENES = {
	"Main Menu": "res://src/ui/screens/MainMenu.tscn",
	"Enhanced Explorer": "res://src/scenes/EnhancedExplorationScene.tscn",
	"Standard Explorer": "res://src/scenes/ExplorationScene.tscn",
	"Info Panel Test": "res://src/ui/components/StructureInfoPanel.tscn",
	"Quiz Panel Test": "res://src/ui/components/QuizPanel.tscn",
}

# === NODES ===
@onready var panel: Panel = $Panel
@onready var scene_buttons: VBoxContainer = $Panel/VBox/SceneButtons
@onready var fps_label: Label = $Panel/VBox/Stats/FPSLabel
@onready var memory_label: Label = $Panel/VBox/Stats/MemoryLabel
@onready var quality_option: OptionButton = $Panel/VBox/Settings/QualityOption
@onready var debug_draw: CheckBox = $Panel/VBox/Settings/DebugDraw
@onready var show_fps: CheckBox = $Panel/VBox/Settings/ShowFPS

# === PRIVATE VARIABLES ===
var _update_timer: float = 0.0

# === PUBLIC METHODS ===

func _ready() -> void:
	visible = false
	_setup_ui()
	
	# Make sure we're on top
	z_index = 1000
	
	# Connect to performance monitor
	if PerformanceMonitor:
		PerformanceMonitor.performance_report_ready.connect(_on_performance_report)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			visible = not visible
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not visible:
		return
		
	_update_timer += delta
	if _update_timer > 0.5:  # Update every 0.5 seconds
		_update_timer = 0.0
		_update_stats()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	# Create scene buttons
	for scene_name in SCENES:
		var btn = Button.new()
		btn.text = scene_name
		btn.pressed.connect(_on_scene_button_pressed.bind(SCENES[scene_name]))
		scene_buttons.add_child(btn)
	
	# Setup quality options
	quality_option.add_item("Low")
	quality_option.add_item("Medium")
	quality_option.add_item("High")
	quality_option.add_item("Ultra")
	quality_option.selected = 1  # Default to Medium
	quality_option.item_selected.connect(_on_quality_changed)
	
	# Connect settings
	debug_draw.toggled.connect(_on_debug_draw_toggled)
	show_fps.toggled.connect(_on_show_fps_toggled)
	
	# Add close button
	var close_btn = Button.new()
	close_btn.text = "Close (F12)"
	close_btn.pressed.connect(func(): visible = false)
	$Panel/VBox.add_child(close_btn)

func _update_stats() -> void:
	# Update FPS
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: %.1f" % fps
	fps_label.modulate = Color.GREEN if fps >= 30 else Color.YELLOW if fps >= 20 else Color.RED
	
	# Update Memory
	var memory_mb = OS.get_static_memory_usage() / 1048576.0
	memory_label.text = "Memory: %.1f MB" % memory_mb

func _on_scene_button_pressed(scene_path: String) -> void:
	print("[DebugMenu] Loading scene: ", scene_path)
	get_tree().change_scene_to_file(scene_path)

func _on_quality_changed(index: int) -> void:
	if PerformanceMonitor:
		PerformanceMonitor.set_quality_level(index)

func _on_debug_draw_toggled(enabled: bool) -> void:
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME if enabled else Viewport.DEBUG_DRAW_DISABLED

func _on_show_fps_toggled(enabled: bool) -> void:
	# This would typically show/hide an FPS counter
	# For now, just print
	print("[DebugMenu] Show FPS: ", enabled)

func _on_performance_report(metrics: Dictionary) -> void:
	# Update with detailed metrics if available
	if fps_label:
		fps_label.text = "FPS: %.1f (Avg: %.1f)" % [metrics.get("fps", 0), metrics.get("average_fps", 0)]