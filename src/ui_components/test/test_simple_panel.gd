extends Control

## Test script to verify SimpleInfoPanel works without issues

var info_panel: SimpleInfoPanel

func _ready() -> void:
	# Create the panel
	info_panel = SimpleInfoPanel.new()
	info_panel.name = "TestInfoPanel"
	add_child(info_panel)
	
	# Connect signals
	info_panel.panel_opened.connect(_on_panel_opened)
	info_panel.panel_closed.connect(_on_panel_closed)
	info_panel.quiz_requested.connect(_on_quiz_requested)
	
	# Create test button
	var test_button = Button.new()
	test_button.text = "Test Info Panel"
	test_button.position = Vector2(100, 100)
	test_button.pressed.connect(_test_panel)
	add_child(test_button)
	
	print("Test ready - click button to test panel")

func _test_panel() -> void:
	var test_data = {
		"id": "hippocampus",
		"name": "Hippocampus",
		"displayName": "Hippocampus",
		"description": "The hippocampus is a complex brain structure embedded deep into temporal lobe. It has a major role in learning and memory.",
		"functions": [
			"Memory consolidation",
			"Spatial navigation",
			"Learning new information"
		]
	}
	
	info_panel.display_structure_info(test_data)

func _on_panel_opened() -> void:
	print("Panel opened successfully")

func _on_panel_closed() -> void:
	print("Panel closed successfully")

func _on_quiz_requested(structure_id: String) -> void:
	print("Quiz requested for: ", structure_id)