extends Control

@onready var status_label: RichTextLabel = $VBoxContainer/Status
@onready var container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	status_label.text = "[center][b]Testing UI Components[/b][/center]\n\n"
	
	# Test loading components
	var results = []
	
	# Test BaseComponent
	var base_comp = load("res://src/ui_new/core/base/BaseComponent.gd")
	if base_comp:
		results.append("[color=green]✓[/color] BaseComponent loaded")
	else:
		results.append("[color=red]✗[/color] BaseComponent failed")
	
	# Test NVBaseButton
	var base_button = load("res://src/ui_new/components/atoms/buttons/BaseButton.gd")
	if base_button:
		results.append("[color=green]✓[/color] NVBaseButton loaded")
		
		# Try to create instance
		var btn_instance = Control.new()
		btn_instance.set_script(base_button)
		btn_instance.name = "TestButton"
		container.add_child(btn_instance)
		results.append("  → Button instance created")
	else:
		results.append("[color=red]✗[/color] NVBaseButton failed")
	
	# Test TextButton
	var text_button = load("res://src/ui_new/components/atoms/buttons/TextButton.gd")
	if text_button:
		results.append("[color=green]✓[/color] TextButton loaded")
	else:
		results.append("[color=red]✗[/color] TextButton failed")
	
	# Test BaseLabel
	var base_label = load("res://src/ui_new/components/atoms/labels/BaseLabel.gd")
	if base_label:
		results.append("[color=green]✓[/color] BaseLabel loaded")
	else:
		results.append("[color=red]✗[/color] BaseLabel failed")
	
	# Test ResponsiveLabel
	var resp_label = load("res://src/ui_new/components/atoms/labels/ResponsiveLabel.gd")
	if resp_label:
		results.append("[color=green]✓[/color] ResponsiveLabel loaded")
	else:
		results.append("[color=red]✗[/color] ResponsiveLabel failed")
	
	# Test BaseInput
	var base_input = load("res://src/ui_new/components/atoms/inputs/BaseInput.gd")
	if base_input:
		results.append("[color=green]✓[/color] BaseInput loaded")
	else:
		results.append("[color=red]✗[/color] BaseInput failed")
	
	# Test TextInput
	var text_input = load("res://src/ui_new/components/atoms/inputs/TextInput.gd")
	if text_input:
		results.append("[color=green]✓[/color] TextInput loaded")
	else:
		results.append("[color=red]✗[/color] TextInput failed")
	
	# Show results
	status_label.text += "\n".join(results)
	status_label.text += "\n\n[center][b]Component loading complete![/b][/center]"