class_name InfoPanel
extends BasePanel

## Simplified info panel that extends BasePanel for reusability

signal structure_selected(structure_id: String)
signal quiz_requested(structure_id: String)

# Components
@onready var header := $VBox/Header as InfoPanelHeader
@onready var content := $VBox/Content as InfoPanelContent
@onready var tabs := $VBox/Tabs as InfoPanelTabs

var current_structure_id: String = ""

func _setup_content() -> void:
	# Configure panel specifics
	panel_width = 500
	
	# Create child components if they don't exist
	_create_components()
	
	# Connect signals
	if header:
		header.close_requested.connect(hide_panel)
		header.bookmark_toggled.connect(_on_bookmark_toggled)
	
	if tabs:
		tabs.quiz_requested.connect(func(): quiz_requested.emit(current_structure_id))

func _create_components() -> void:
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	add_child(vbox)
	
	# Create header
	var header_scene = preload("res://src/ui_components/composite/InfoPanel/InfoPanelHeader.tscn")
	if header_scene:
		header = header_scene.instantiate()
		vbox.add_child(header)
	
	# Create content
	var content_scene = preload("res://src/ui_components/composite/InfoPanel/InfoPanelContent.tscn")
	if content_scene:
		content = content_scene.instantiate()
		vbox.add_child(content)
	
	# Create tabs
	var tabs_scene = preload("res://src/ui_components/composite/InfoPanel/InfoPanelTabs.tscn")
	if tabs_scene:
		tabs = tabs_scene.instantiate()
		vbox.add_child(tabs)

func _load_content(data: Dictionary) -> void:
	current_structure_id = data.get("id", "")
	
	# Update header
	if header:
		header.set_title(data.get("displayName", "Unknown"))
		header.set_subtitle(data.get("latinName", ""))
	
	# Update content tabs
	if tabs:
		tabs.load_structure_data(data)

func display_structure(structure_data: Dictionary) -> void:
	show_panel(structure_data)

func _on_bookmark_toggled(is_bookmarked: bool) -> void:
	# Save bookmark state
	if current_structure_id and ProgressTracker:
		ProgressTracker.set_bookmark(current_structure_id, is_bookmarked)