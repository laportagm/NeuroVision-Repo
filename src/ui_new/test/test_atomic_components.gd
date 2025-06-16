## test_atomic_components.gd
## Test script for atomic UI components

extends Control

@onready var responsive_label: ResponsiveLabel = $VBoxContainer/ResponsiveLabel
@onready var text_button: TextButton = $VBoxContainer/TextButton
@onready var text_input: TextInput = $VBoxContainer/TextInput
@onready var email_input: TextInput = $VBoxContainer/EmailInput
@onready var password_input: TextInput = $VBoxContainer/PasswordInput

func _ready() -> void:
	print("[TestAtomicComponents] Initializing component tests...")
	
	# Connect button signals
	if text_button:
		text_button.pressed.connect(_on_button_pressed)
		print("[TestAtomicComponents] Button connected")
	
	# Connect input signals
	if text_input:
		text_input.text_changed.connect(_on_text_changed)
		text_input.value_submitted.connect(_on_text_submitted)
		print("[TestAtomicComponents] Text input connected")
	
	if email_input:
		email_input.validation_changed.connect(_on_email_validation_changed)
		print("[TestAtomicComponents] Email input connected")
	
	if password_input:
		password_input.validation_changed.connect(_on_password_validation_changed)
		print("[TestAtomicComponents] Password input connected")
	
	# Test responsive label
	if responsive_label:
		responsive_label.breakpoint_changed.connect(_on_breakpoint_changed)
		print("[TestAtomicComponents] Responsive label connected")
	
	print("[TestAtomicComponents] All components initialized")

func _on_button_pressed() -> void:
	print("[TestAtomicComponents] Button clicked!")
	
	# Test button state changes
	text_button.set_loading(true)
	await get_tree().create_timer(1.0).timeout
	text_button.set_loading(false)
	text_button.text = "Clicked!"

func _on_text_changed(new_text: String) -> void:
	print("[TestAtomicComponents] Text changed: ", new_text)

func _on_text_submitted(text: String) -> void:
	print("[TestAtomicComponents] Text submitted: ", text)

func _on_email_validation_changed(is_valid: bool) -> void:
	print("[TestAtomicComponents] Email validation: ", is_valid)

func _on_password_validation_changed(is_valid: bool) -> void:
	print("[TestAtomicComponents] Password validation: ", is_valid)

func _on_breakpoint_changed(breakpoint: String) -> void:
	print("[TestAtomicComponents] Breakpoint changed: ", breakpoint)