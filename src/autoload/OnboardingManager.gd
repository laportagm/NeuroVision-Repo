class_name OnboardingManagerClass
extends Node

## Manages the onboarding and tutorial system for new users
##
## This singleton provides a guided first-time experience for medical students,
## teaching them how to navigate and use the NeuroVision educational platform.

signal onboarding_started()
signal onboarding_step_completed(step_name: String)
signal onboarding_completed()
signal onboarding_skipped()

# === CONSTANTS ===
const SAVE_PATH = "user://onboarding_state.save"
const ONBOARDING_VERSION = "1.0"  # Increment to force re-onboarding

# Onboarding steps definition
const STEPS = [
	{
		"name": "welcome",
		"title": "Welcome to NeuroVision",
		"description": "An interactive 3D brain anatomy learning platform",
		"target": null,
		"position": "center",
		"allow_skip": true
	},
	{
		"name": "navigation_basics",
		"title": "Navigation Controls",
		"description": "Left-click and drag to rotate\nScroll to zoom\nMiddle-click to pan",
		"target": null,
		"position": "center",
		"highlight_area": Rect2(0, 0, 0, 0),  # Full screen
		"allow_skip": false
	},
	{
		"name": "structure_selection",
		"title": "Selecting Structures",
		"description": "Right-click on any brain structure to select it\nOr use the structure list on the left",
		"target": "UI/MainUI/LeftPanel",
		"position": "right",
		"highlight_area": Rect2(0, 100, 300, 600),
		"allow_skip": false
	},
	{
		"name": "info_panel",
		"title": "Educational Information",
		"description": "Selected structures display detailed information here",
		"target": "UI/InfoPanel",
		"position": "left",
		"trigger": "structure_selected",
		"allow_skip": false
	},
	{
		"name": "quiz_system",
		"title": "Test Your Knowledge",
		"description": "Click the Quiz button to test your understanding",
		"target": "UI/MainUI/TopBar/TopBarContent/ToolButtons/QuizButton",
		"position": "bottom",
		"allow_skip": true
	},
	{
		"name": "camera_presets",
		"title": "Quick Views",
		"description": "Use view presets for standard anatomical perspectives",
		"target": "UI/MainUI/TopBar/TopBarContent/ViewControls/ViewPresets",
		"position": "bottom",
		"allow_skip": true
	},
	{
		"name": "keyboard_shortcuts",
		"title": "Keyboard Shortcuts",
		"description": "Press H for help\nR to reset view\nF to focus on selection",
		"target": null,
		"position": "center",
		"allow_skip": true
	},
	{
		"name": "completion",
		"title": "Ready to Learn!",
		"description": "You're all set to explore brain anatomy\nPress H anytime for help",
		"target": null,
		"position": "center",
		"allow_skip": false
	}
]

# === EXPORTS ===
@export var auto_start_onboarding: bool = true
@export var force_onboarding: bool = false  # Debug option
@export var step_delay: float = 0.5  # Delay between automatic steps
@export_group("Visual Settings")
@export var overlay_color: Color = Color(0, 0, 0, 0.7)
@export var highlight_color: Color = Color(1, 1, 0, 0.3)
@export var tooltip_max_width: int = 400

# === PRIVATE VARIABLES ===
var _current_step: int = -1
var _onboarding_active: bool = false
var _tutorial_overlay: Control = null
var _current_scene: Node = null
var _save_data: Dictionary = {}
var _step_triggers: Dictionary = {}  # event_name -> step_index
var _completed_steps: Array = []

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize onboarding system"""
	_load_save_data()
	
	# Setup step triggers
	_setup_step_triggers()
	
	# Wait for scene to be ready
	await get_tree().process_frame
	
	if auto_start_onboarding and should_show_onboarding():
		start_onboarding()

func should_show_onboarding() -> bool:
	"""Check if onboarding should be shown"""
	if force_onboarding:
		return true
	
	# Check if user has completed onboarding for current version
	if _save_data.has("completed_version"):
		return _save_data["completed_version"] != ONBOARDING_VERSION
	
	# First time user
	return true

func start_onboarding(scene: Node = null) -> void:
	"""Start the onboarding process"""
	if _onboarding_active:
		return
	
	print("[OnboardingManager] Starting onboarding")
	_onboarding_active = true
	_current_scene = scene if scene else get_tree().current_scene
	_current_step = -1
	_completed_steps.clear()
	
	# Create tutorial overlay
	_create_tutorial_overlay()
	
	onboarding_started.emit()
	
	# Start first step
	next_step()

func stop_onboarding() -> void:
	"""Stop the onboarding process"""
	if not _onboarding_active:
		return
	
	_onboarding_active = false
	_cleanup_overlay()
	
	print("[OnboardingManager] Onboarding stopped")

func skip_onboarding() -> void:
	"""Skip the rest of the onboarding"""
	if not _onboarding_active:
		return
	
	print("[OnboardingManager] Onboarding skipped")
	_save_completion()
	stop_onboarding()
	onboarding_skipped.emit()

func next_step() -> void:
	"""Move to the next onboarding step"""
	if not _onboarding_active:
		return
	
	_current_step += 1
	
	if _current_step >= STEPS.size():
		complete_onboarding()
		return
	
	var step = STEPS[_current_step]
	_show_step(step)

func previous_step() -> void:
	"""Go back to previous step"""
	if not _onboarding_active or _current_step <= 0:
		return
	
	_current_step -= 1
	var step = STEPS[_current_step]
	_show_step(step)

func complete_onboarding() -> void:
	"""Complete the onboarding process"""
	if not _onboarding_active:
		return
	
	print("[OnboardingManager] Onboarding completed")
	_save_completion()
	stop_onboarding()
	onboarding_completed.emit()

func restart_onboarding() -> void:
	"""Restart onboarding from beginning"""
	stop_onboarding()
	_save_data.clear()
	_save_state()
	start_onboarding()

func trigger_event(event_name: String) -> void:
	"""Trigger an onboarding event (for conditional steps)"""
	if not _onboarding_active:
		return
	
	if _step_triggers.has(event_name):
		var step_index = _step_triggers[event_name]
		if step_index == _current_step + 1:
			# This is the expected next step
			next_step()

# === PRIVATE METHODS ===

func _create_tutorial_overlay() -> void:
	"""Create the tutorial overlay UI"""
	var tutorial_scene = load("res://src/ui/components/TutorialOverlay.tscn")
	if tutorial_scene:
		_tutorial_overlay = tutorial_scene.instantiate()
	else:
		push_error("[OnboardingManager] Failed to load TutorialOverlay.tscn")
		return
	
	# Add to current scene's UI layer
	var ui_layer = _find_ui_layer()
	if ui_layer:
		ui_layer.add_child(_tutorial_overlay)
		_tutorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		push_error("[OnboardingManager] Could not find UI layer for tutorial overlay")
		return
	
	# Connect signals
	_tutorial_overlay.next_pressed.connect(next_step)
	_tutorial_overlay.skip_pressed.connect(skip_onboarding)
	_tutorial_overlay.previous_pressed.connect(previous_step)

func _find_ui_layer() -> CanvasLayer:
	"""Find the UI canvas layer in the scene"""
	if not _current_scene:
		return null
	
	# Look for UI node
	var ui = _current_scene.get_node_or_null("UI")
	if ui and ui is CanvasLayer:
		return ui
	
	# Search for any CanvasLayer
	for child in _current_scene.get_children():
		if child is CanvasLayer:
			return child
	
	# Create one if needed
	var canvas = CanvasLayer.new()
	canvas.name = "OnboardingLayer"
	canvas.layer = 10  # Above other UI
	_current_scene.add_child(canvas)
	return canvas

func _show_step(step: Dictionary) -> void:
	"""Display a specific onboarding step"""
	if not _tutorial_overlay:
		return
	
	print("[OnboardingManager] Showing step: ", step.name)
	
	# Update overlay content
	_tutorial_overlay.set_step_content(
		step.title,
		step.description,
		_current_step,
		STEPS.size()
	)
	
	# Handle target highlighting
	if step.has("target") and step.target:
		var target_node = _current_scene.get_node_or_null(step.target)
		if target_node:
			_highlight_target(target_node, step.get("position", "auto"))
		else:
			push_warning("[OnboardingManager] Target node not found: ", step.target)
	else:
		_tutorial_overlay.clear_highlight()
	
	# Handle skip button
	_tutorial_overlay.set_skip_enabled(step.get("allow_skip", true))
	
	# Mark step as completed
	if not step.name in _completed_steps:
		_completed_steps.append(step.name)
		onboarding_step_completed.emit(step.name)

func _highlight_target(target: Node, position: String) -> void:
	"""Highlight a target node in the UI"""
	if not target is Control:
		return
	
	var target_rect = target.get_global_rect()
	_tutorial_overlay.highlight_area(target_rect, position)

func _setup_step_triggers() -> void:
	"""Setup event triggers for conditional steps"""
	for i in range(STEPS.size()):
		var step = STEPS[i]
		if step.has("trigger"):
			_step_triggers[step.trigger] = i

func _cleanup_overlay() -> void:
	"""Remove tutorial overlay"""
	if _tutorial_overlay:
		_tutorial_overlay.queue_free()
		_tutorial_overlay = null

func _load_save_data() -> void:
	"""Load saved onboarding state"""
	if not FileAccess.file_exists(SAVE_PATH):
		_save_data = {}
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			_save_data = json.data
		else:
			push_error("[OnboardingManager] Failed to parse save data")
			_save_data = {}
	else:
		push_error("[OnboardingManager] Failed to open save file")
		_save_data = {}

func _save_state() -> void:
	"""Save current onboarding state"""
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(_save_data)
		file.store_string(json_string)
		file.close()
	else:
		push_error("[OnboardingManager] Failed to save onboarding state")

func _save_completion() -> void:
	"""Save that onboarding was completed"""
	_save_data["completed_version"] = ONBOARDING_VERSION
	_save_data["completed_date"] = Time.get_datetime_string_from_system()
	_save_data["completed_steps"] = _completed_steps
	_save_state()

# === STATIC HELPER METHODS ===

static func reset_onboarding() -> void:
	"""Reset onboarding state (for testing)"""
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("[OnboardingManager] Onboarding state reset")