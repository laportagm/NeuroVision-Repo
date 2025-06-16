extends Button

## Simple test button for NeuroVision atomic UI system
## This is a minimal implementation to test the UI architecture

signal nv_clicked()

func _ready() -> void:
	# Connect button signals
	pressed.connect(_on_pressed)
	
	# Apply basic styling
	custom_minimum_size = Vector2(120, 48)
	
	print("[NVButtonTest] Button component ready")

func _on_pressed() -> void:
	print("[NVButtonTest] Button pressed")
	nv_clicked.emit()

func set_button_text(text: String) -> void:
	self.text = text

func set_button_variant(variant: String) -> void:
	print("[NVButtonTest] Setting variant: %s" % variant)
	# Variant styling would be applied here