class_name EnhancedExplorationScene
extends Node3D

## Enhanced main 3D exploration scene with comprehensive UI

# === SIGNALS ===
signal structure_selected(structure_name: String)
signal return_to_menu_requested()
signal view_changed(view_name: String)
signal help_toggled(visible: bool)

# === CONSTANTS ===
const CAMERA_SPEED: float = 5.0
const ZOOM_SPEED: float = 0.8  # Adjusted for better zooming
const MIN_ZOOM: float = 8.0    # Better minimum distance
const MAX_ZOOM: float = 30.0   # Allow zooming out more
const ROTATION_SPEED: float = 0.3  # Reduced for better control
const VERTICAL_ANGLE_LIMIT: float = 85.0

# === NODES ===
@onready var camera: Camera3D = $CameraSystem/CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraSystem/CameraPivot
@onready var brain_container: Node3D = $BrainModelContainer
@onready var model_holder: Node3D = $BrainModelContainer/ModelHolder
@onready var selection_sphere: MeshInstance3D = $BrainModelContainer/SelectionSphere
@onready var info_panel = $UI/InfoPanel

# UI Elements
@onready var top_bar: PanelContainer = $UI/MainUI/TopBar
@onready var left_panel: PanelContainer = $UI/MainUI/LeftPanel
@onready var bottom_panel: PanelContainer = $UI/MainUI/BottomPanel
@onready var view_presets: OptionButton = $UI/MainUI/TopBar/TopBarContent/ViewControls/ViewPresets
@onready var label_toggle: Button = $UI/MainUI/TopBar/TopBarContent/ToolButtons/LabelToggle
@onready var quiz_button: Button = $UI/MainUI/TopBar/TopBarContent/ToolButtons/QuizButton
@onready var help_button: Button = $UI/MainUI/TopBar/TopBarContent/ToolButtons/HelpButton
@onready var structure_items: VBoxContainer = $UI/MainUI/LeftPanel/StructureList/ScrollContainer/StructureItems
@onready var status_label: Label = $UI/MainUI/BottomPanel/StatusBar/StatusLabel
@onready var performance_label: Label = $UI/MainUI/BottomPanel/StatusBar/PerformanceInfo
@onready var loading_overlay: ColorRect = $UI/Overlays/LoadingOverlay
@onready var loading_label: Label = $UI/Overlays/LoadingOverlay/LoadingLabel
@onready var loading_progress: ProgressBar = $UI/Overlays/LoadingOverlay/LoadingContent/ProgressBar
@onready var help_overlay: PanelContainer = $UI/Overlays/HelpOverlay
@onready var help_close: Button = $UI/Overlays/HelpOverlay/HelpContent/CloseButton
@onready var annotation_layer: Control = $UI/AnnotationLayer

# Lighting
@onready var main_light: DirectionalLight3D = $Environment/Lighting/DirectionalLight3D
@onready var fill_light: DirectionalLight3D = $Environment/Lighting/FillLight
@onready var rim_light: DirectionalLight3D = $Environment/Lighting/RimLight

# Visualization helpers
@onready var grid_floor: MeshInstance3D = $VisualizationHelpers/GridFloor
@onready var axis_indicator: Node3D = $VisualizationHelpers/AxisIndicator

# === PRIVATE VARIABLES ===
var _camera_distance: float = 15.0  # Better initial distance for brain model
var _rotation_speed: float = ROTATION_SPEED
var _is_rotating: bool = false
var _is_panning: bool = false
var _camera_rotation: Vector2 = Vector2(deg_to_rad(-45), deg_to_rad(-20))  # Better initial angle for brain viewing
var _brain_interaction: Node3D = null
var _model_loader: Node = null
var _camera_presets: Node = null
var _annotation_system: Node = null
var _brain_structures: Dictionary = {}  # structure_id -> MeshInstance3D
var _mesh_to_structure_id: Dictionary = {}  # mesh_name -> structure_id
var _quiz_panel: QuizPanel = null
var _current_structure_id: String = ""
var _structure_buttons: Dictionary = {}  # structure_id -> Button
var _is_loading: bool = false

# Trackpad support variables
var _zoom_velocity: float = 0.0

# Export trackpad settings for easy adjustment
@export_group("Trackpad Settings")
@export_range(0.1, 2.0, 0.1) var trackpad_zoom_sensitivity: float = 0.5
@export_range(0.1, 2.0, 0.1) var trackpad_rotate_sensitivity: float = 0.7
@export_range(0.5, 0.95, 0.05) var trackpad_zoom_damping: float = 0.85

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[EnhancedExplorationScene] Initializing enhanced interface")
	_setup_ui()
	_setup_scene()
	_create_axis_indicator()
	_connect_signals()
	_setup_help_text()
	show_loading("Initializing NeuroVision...")

func _physics_process(delta: float) -> void:
	# Apply smooth zoom for trackpad
	if abs(_zoom_velocity) > 0.001:
		_camera_distance += _zoom_velocity * delta
		_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)
		_zoom_velocity *= trackpad_zoom_damping
		_update_camera_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_keyboard(event)
	elif event is InputEventPanGesture:
		_handle_pan_gesture(event)
	elif event is InputEventMagnifyGesture:
		_handle_magnify_gesture(event)

func show_loading(message: String, progress: float = -1.0) -> void:
	"""Show loading overlay with optional progress"""
	loading_overlay.visible = true
	loading_label.text = message
	if progress >= 0:
		loading_progress.visible = true
		loading_progress.value = progress * 100
	else:
		loading_progress.visible = false
	_is_loading = true

func hide_loading() -> void:
	"""Hide loading overlay"""
	loading_overlay.visible = false
	_is_loading = false

func update_status(message: String) -> void:
	"""Update status bar message"""
	status_label.text = message

func toggle_grid(should_show: bool) -> void:
	"""Toggle grid floor visibility"""
	grid_floor.visible = should_show

func toggle_axis_indicator(should_show: bool) -> void:
	"""Toggle axis indicator visibility"""
	axis_indicator.visible = should_show

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup all UI elements with Material 3 styling"""
	# Apply M3 theme to all UI components
	_apply_m3_theme_to_ui()
	
	# Configure view presets
	view_presets.selected = 0
	view_presets.item_selected.connect(_on_view_preset_selected)
	
	# Apply M3 button styling to all buttons
	_apply_m3_button_styling(label_toggle, "Labels", M3ComponentApplicator.ButtonVariant.SECONDARY)
	_apply_m3_button_styling(quiz_button, "Quiz", M3ComponentApplicator.ButtonVariant.SECONDARY)
	_apply_m3_button_styling(help_button, "?", M3ComponentApplicator.ButtonVariant.ICON)
	_apply_m3_button_styling(help_close, "✕", M3ComponentApplicator.ButtonVariant.ICON)
	
	# Configure buttons
	label_toggle.toggled.connect(_on_labels_toggled)
	quiz_button.pressed.connect(_on_quiz_pressed)
	help_button.pressed.connect(_on_help_pressed)
	help_close.pressed.connect(func(): help_overlay.visible = false)
	
	# Hide overlays initially
	help_overlay.visible = false
	loading_overlay.visible = false
	
	# Set initial performance display with M3 typography
	if performance_label:
		M3ComponentApplicator.apply_m3_text_styling(performance_label, M3ComponentApplicator.TypographyScale.LABEL_SMALL)
		performance_label.text = "FPS: -- | Quality: --"
		performance_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

func _apply_m3_theme_to_ui() -> void:
	"""Apply comprehensive Material 3 theme to all UI components"""
	print("[EnhancedExplorationScene] Applying M3 theme to all UI components")
	
	# Apply M3 to top bar with proper header styling
	if top_bar:
		M3ComponentApplicator.apply_m3_panel_styling(top_bar, M3ComponentApplicator.PanelVariant.SURFACE_CONTAINER)
		_apply_m3_to_top_bar_components()
	
	# Apply M3 to left panel (Brain Structures) with navigation styling
	if left_panel:
		M3ComponentApplicator.apply_m3_panel_styling(left_panel, M3ComponentApplicator.PanelVariant.SURFACE)
		_apply_m3_to_left_panel_components()
	
	# Apply M3 to bottom panel with status bar styling
	if bottom_panel:
		M3ComponentApplicator.apply_m3_panel_styling(bottom_panel, M3ComponentApplicator.PanelVariant.SURFACE_VARIANT)
		_apply_m3_to_bottom_panel_components()
	
	# Apply M3 to modal overlays
	_apply_m3_to_overlays()
	
	# Apply M3 to view controls dropdown
	_apply_m3_to_view_controls()

func _apply_m3_to_top_bar_components() -> void:
	"""Apply M3 styling to top bar components"""
	# Style the app title/logo
	var logo_label = top_bar.get_node_or_null("TopBarContent/Logo")
	if logo_label and logo_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(logo_label, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
		logo_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	
	# Style view controls label
	var view_label = top_bar.get_node_or_null("TopBarContent/ViewControls/ViewLabel")
	if view_label and view_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(view_label, M3ComponentApplicator.TypographyScale.LABEL_MEDIUM)
		view_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

func _apply_m3_to_left_panel_components() -> void:
	"""Apply M3 styling to left panel components"""
	# Style the structures list title
	var title_label = left_panel.get_node_or_null("StructureList/Title")
	if title_label and title_label is Label:
		M3ComponentApplicator.apply_m3_text_styling(title_label, M3ComponentApplicator.TypographyScale.TITLE_MEDIUM)
		title_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
	
	# Style the HSeparator
	var separator = left_panel.get_node_or_null("StructureList/HSeparator")
	if separator and separator is HSeparator:
		separator.add_theme_color_override("separator", M3DesignTokens.M3_COLORS["outline_variant"])
		separator.add_theme_constant_override("separation", 1)

func _apply_m3_to_bottom_panel_components() -> void:
	"""Apply M3 styling to bottom panel components"""
	# Style status label with M3 typography
	if status_label:
		M3ComponentApplicator.apply_m3_text_styling(status_label, M3ComponentApplicator.TypographyScale.BODY_MEDIUM)
		status_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	
	# Style performance label with M3 typography  
	if performance_label:
		M3ComponentApplicator.apply_m3_text_styling(performance_label, M3ComponentApplicator.TypographyScale.LABEL_SMALL)
		performance_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

func _apply_m3_to_overlays() -> void:
	"""Apply M3 styling to modal overlays"""
	# Style help overlay as M3 modal dialog
	if help_overlay:
		M3ComponentApplicator.apply_m3_panel_styling(help_overlay, M3ComponentApplicator.PanelVariant.MODAL)
		
		# Style help title
		var help_title = help_overlay.get_node_or_null("HelpContent/HelpTitle")
		if help_title and help_title is Label:
			M3ComponentApplicator.apply_m3_text_styling(help_title, M3ComponentApplicator.TypographyScale.HEADLINE_SMALL)
			help_title.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
		
		# Style help text
		var help_text = help_overlay.get_node_or_null("HelpContent/HelpText")
		if help_text and help_text is RichTextLabel:
			help_text.add_theme_color_override("default_color", M3DesignTokens.M3_COLORS["on_surface"])
			help_text.add_theme_font_size_override("normal_font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
	
	# Style loading overlay with M3 scrim
	if loading_overlay:
		loading_overlay.color = M3DesignTokens.M3_COLORS["scrim"]
		
		# Style loading label
		if loading_label:
			M3ComponentApplicator.apply_m3_text_styling(loading_label, M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM)
			loading_label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
		
		# Style loading progress bar
		if loading_progress:
			_apply_m3_to_progress_bar(loading_progress)

func _apply_m3_to_view_controls() -> void:
	"""Apply M3 styling to view controls dropdown"""
	if view_presets:
		# Apply M3 filled variant button styling to dropdown
		M3ComponentApplicator.apply_m3_to_component(view_presets)
		view_presets.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
		view_presets.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
		
		# Style dropdown background
		var dropdown_style = StyleBoxFlat.new()
		dropdown_style.bg_color = M3DesignTokens.M3_COLORS["surface_container"]
		dropdown_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
		dropdown_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		dropdown_style.border_color = M3DesignTokens.M3_COLORS["outline"]
		dropdown_style.set_border_width_all(1)
		view_presets.add_theme_stylebox_override("normal", dropdown_style)
		
		# Style dropdown hover state
		var dropdown_hover = dropdown_style.duplicate()
		dropdown_hover.bg_color = M3DesignTokens.M3_COLORS["surface_container_high"]
		view_presets.add_theme_stylebox_override("hover", dropdown_hover)

func _apply_m3_to_progress_bar(progress_bar: ProgressBar) -> void:
	"""Apply M3 styling to progress bar"""
	if not progress_bar:
		return
	
	# M3 progress bar background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.M3_COLORS["surface_variant"]
	bg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	bg_style.content_margin_top = 4
	bg_style.content_margin_bottom = 4
	
	# M3 progress bar fill
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = M3DesignTokens.M3_COLORS["primary"]
	fill_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	fill_style.content_margin_top = 4
	fill_style.content_margin_bottom = 4
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func _apply_m3_button_styling(button: Button, text: String, variant: M3ComponentApplicator.ButtonVariant) -> void:
	"""Apply M3 styling to a button with motion"""
	if not button:
		return
	
	button.text = text
	M3ComponentApplicator.apply_m3_button_styling(button, variant)
	
	# Add motion effects
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandler.setup_button_hover_animation(button)

func _setup_scene() -> void:
	"""Initialize scene components"""
	_setup_camera_orbit()
	_update_camera_position()
	_setup_brain_interaction()
	_setup_model_loader()
	_setup_camera_presets()
	_setup_annotation_system()
	_setup_quiz_panel()
	
	# Start loading brain models
	_load_brain_models()

func _setup_camera_orbit() -> void:
	"""Setup camera orbit system"""
	camera_pivot.position = brain_container.global_position
	_update_camera_orbit()

func _update_camera_orbit() -> void:
	"""Update camera orbit based on rotation angles"""
	camera_pivot.rotation = Vector3.ZERO
	camera_pivot.rotate_y(_camera_rotation.x)
	camera_pivot.rotate_x(_camera_rotation.y)
	_update_camera_position()

func _update_camera_position() -> void:
	"""Update camera position based on distance"""
	var offset = Vector3(0, 0, _camera_distance)
	camera.position = offset
	camera.look_at(camera_pivot.global_position, Vector3.UP)

func _create_axis_indicator() -> void:
	"""Create 3D axis indicator"""
	var materials = {
		"x": preload("res://src/materials/axis_red.tres") if ResourceLoader.exists("res://src/materials/axis_red.tres") else null,
		"y": preload("res://src/materials/axis_green.tres") if ResourceLoader.exists("res://src/materials/axis_green.tres") else null,
		"z": preload("res://src/materials/axis_blue.tres") if ResourceLoader.exists("res://src/materials/axis_blue.tres") else null
	}
	
	# Create X axis (red)
	var x_axis = BoxMesh.new()
	x_axis.size = Vector3(2, 0.1, 0.1)
	var x_instance = MeshInstance3D.new()
	x_instance.mesh = x_axis
	x_instance.position = Vector3(1, 0, 0)
	if materials.x:
		x_instance.material_override = materials.x
	else:
		x_instance.material_override = _create_axis_material(Color.RED)
	axis_indicator.add_child(x_instance)
	
	# Create Y axis (green)
	var y_axis = BoxMesh.new()
	y_axis.size = Vector3(0.1, 2, 0.1)
	var y_instance = MeshInstance3D.new()
	y_instance.mesh = y_axis
	y_instance.position = Vector3(0, 1, 0)
	if materials.y:
		y_instance.material_override = materials.y
	else:
		y_instance.material_override = _create_axis_material(Color.GREEN)
	axis_indicator.add_child(y_instance)
	
	# Create Z axis (blue)
	var z_axis = BoxMesh.new()
	z_axis.size = Vector3(0.1, 0.1, 2)
	var z_instance = MeshInstance3D.new()
	z_instance.mesh = z_axis
	z_instance.position = Vector3(0, 0, 1)
	if materials.z:
		z_instance.material_override = materials.z
	else:
		z_instance.material_override = _create_axis_material(Color.BLUE)
	axis_indicator.add_child(z_instance)

func _create_axis_material(color: Color) -> StandardMaterial3D:
	"""Create material for axis indicator"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy = 0.5
	return mat

func _connect_signals() -> void:
	"""Connect all signals"""
	# Connect info panel signals
	info_panel.close_requested.connect(_on_info_panel_closed)
	info_panel.quiz_requested.connect(_on_info_panel_quiz_requested)
	
	# Connect to PerformanceMonitor
	PerformanceMonitor.performance_report_ready.connect(_on_performance_report)
	PerformanceMonitor.quality_level_changed.connect(_on_quality_changed)

func _setup_help_text() -> void:
	"""Setup help overlay content"""
	var help_text = $UI/Overlays/HelpOverlay/HelpContent/HelpText
	if help_text:
		help_text.text = "[b]Mouse Controls:[/b]\n" + \
			"• Left Click + Drag - Rotate camera\n" + \
			"• Middle Click + Drag - Pan camera\n" + \
			"• Right Click - Select structure\n" + \
			"• Scroll Wheel - Zoom in/out\n\n" + \
			"[b]Trackpad Controls:[/b]\n" + \
			"• Two-finger swipe - Rotate camera\n" + \
			"• Pinch - Zoom in/out\n" + \
			"• Two-finger scroll - Smooth zoom\n" + \
			"• Click + drag - Rotate camera\n\n" + \
			"[b]Keyboard Shortcuts:[/b]\n" + \
			"• R - Reset camera view\n" + \
			"• F - Focus on selected structure\n" + \
			"• G - Toggle grid\n" + \
			"• L - Toggle labels\n" + \
			"• Q - Open quiz\n" + \
			"• H - Toggle this help\n" + \
			"• ESC - Return to menu\n\n" + \
			"[b]Tips:[/b]\n" + \
			"• Click structure buttons on the left to select\n" + \
			"• Right-click directly on 3D structures\n" + \
			"• Use camera presets dropdown for quick views"

func _populate_structure_list(structures: Array) -> void:
	"""Populate the structure list in left panel"""
	# Clear existing items
	for child in structure_items.get_children():
		child.queue_free()
	_structure_buttons.clear()
	
	# Add structure buttons with M3 styling
	for structure in structures:
		var button = Button.new()
		button.text = structure.get("displayName", structure.get("name", "Unknown"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 48)  # M3 standard button height
		
		# Apply M3 tertiary button styling for list items
		M3ComponentApplicator.apply_m3_button_styling(button, M3ComponentApplicator.ButtonVariant.TERTIARY)
		
		# Override some styling for list appearance
		button.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
		
		# Create custom style for list items
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color.TRANSPARENT
		style_normal.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
		style_normal.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = M3DesignTokens.M3_COLORS["primary_container"]
		style_hover.bg_color.a = 0.08
		style_hover.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
		style_hover.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		
		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = M3DesignTokens.M3_COLORS["primary_container"]
		style_pressed.bg_color.a = 0.12
		style_pressed.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
		style_pressed.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		
		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_pressed)
		button.add_theme_stylebox_override("focus", style_hover)
		
		# Add M3 motion effects
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandler.setup_button_hover_animation(button)
		
		button.pressed.connect(_on_structure_button_pressed.bind(structure.get("id", "")))
		structure_items.add_child(button)
		_structure_buttons[structure.get("id", "")] = button

func _on_structure_button_pressed(structure_id: String) -> void:
	"""Handle structure button press"""
	print("[EnhancedExplorationScene] Structure button pressed: ", structure_id)
	print("[EnhancedExplorationScene] _brain_structures keys: ", _brain_structures.keys())
	print("[EnhancedExplorationScene] _brain_interaction exists: ", _brain_interaction != null)
	
	if not _brain_interaction:
		push_error("[EnhancedExplorationScene] BrainInteractionController not initialized")
		return
		
	if not _brain_structures.has(structure_id):
		push_warning("[EnhancedExplorationScene] Structure ID not found in _brain_structures: ", structure_id)
		# Try to find the mesh by searching through the brain container
		var found = false
		for child in brain_container.get_children():
			if child is Node3D:
				for subchild in child.get_children():
					if subchild is MeshInstance3D:
						# Check if this mesh matches the structure ID
						if _mesh_to_structure_id.has(subchild.name) and _mesh_to_structure_id[subchild.name] == structure_id:
							print("[EnhancedExplorationScene] Found mesh instance: ", subchild.name, " for structure: ", structure_id)
							_brain_structures[structure_id] = subchild
							_brain_interaction.select_structure_by_mesh(subchild)
							found = true
							break
			if found:
				break
		if not found:
			push_error("[EnhancedExplorationScene] Could not find mesh for structure: ", structure_id)
		return
		
	var mesh_instance = _brain_structures[structure_id]
	_brain_interaction.select_structure_by_mesh(mesh_instance)

func _on_view_preset_selected(index: int) -> void:
	"""Handle view preset selection"""
	if _camera_presets:
		_camera_presets.apply_preset(index)
		view_changed.emit(view_presets.get_item_text(index))

func _on_labels_toggled(toggled: bool) -> void:
	"""Handle label toggle"""
	if _annotation_system:
		# Only toggle if the current state differs from the desired state
		var current_visible = _annotation_system.is_visible() if _annotation_system.has_method("is_visible") else false
		if current_visible != toggled:
			_annotation_system.toggle_visibility()
	update_status("Labels " + ("enabled" if toggled else "disabled"))

func _on_quiz_pressed() -> void:
	"""Handle quiz button press"""
	_toggle_quiz()

func _on_help_pressed() -> void:
	"""Handle help button press"""
	help_overlay.visible = not help_overlay.visible
	help_toggled.emit(help_overlay.visible)

func _on_performance_report(metrics: Dictionary) -> void:
	"""Update performance display"""
	var quality_text = ["LOW", "MEDIUM", "HIGH", "ULTRA"][metrics.quality_level]
	performance_label.text = "FPS: %.0f | Quality: %s" % [metrics.fps, quality_text]

func _on_quality_changed(new_level: int) -> void:
	"""Handle quality level changes"""
	var quality_names = ["LOW", "MEDIUM", "HIGH", "ULTRA"]
	update_status("Quality changed to " + quality_names[new_level])

# ... (Include all the existing methods from ExplorationScene.gd)
# ... (handle_mouse_button, handle_mouse_motion, handle_keyboard, etc.)

func _setup_brain_interaction() -> void:
	"""Setup brain interaction controller"""
	var BrainInteractionController = preload("res://src/systems/3d_interaction/BrainInteractionController.gd")
	_brain_interaction = BrainInteractionController.new()
	add_child(_brain_interaction)
	_brain_interaction.initialize(camera)
	
	# Connect signals
	_brain_interaction.structure_selected.connect(_on_structure_selected)
	_brain_interaction.structure_highlighted.connect(_on_structure_highlighted)
	_brain_interaction.selection_cleared.connect(_on_selection_cleared)

func _on_structure_selected(structure_name: String, mesh_instance: MeshInstance3D) -> void:
	"""Handle structure selection"""
	print("[EnhancedExplorationScene] Selected mesh name: ", structure_name)
	
	# Convert mesh name to structure ID
	var structure_id = ""
	if _mesh_to_structure_id.has(structure_name):
		structure_id = _mesh_to_structure_id[structure_name]
		print("[EnhancedExplorationScene] Converted to structure ID: ", structure_id)
	else:
		# Try normalized version
		var normalized_name = structure_name.to_lower().strip_edges()
		normalized_name = normalized_name.replace(" (good)", "").replace("(good)", "").strip_edges()
		
		# Check if normalized version exists
		var found = false
		for mesh_name in _mesh_to_structure_id:
			var normalized_mesh = mesh_name.to_lower().strip_edges()
			normalized_mesh = normalized_mesh.replace(" (good)", "").replace("(good)", "").strip_edges()
			
			if normalized_mesh == normalized_name:
				structure_id = _mesh_to_structure_id[mesh_name]
				print("[EnhancedExplorationScene] Found mapping via normalization: ", structure_id)
				found = true
				break
		
		if not found:
			# Special case for known problematic names
			if normalized_name == "hipp and others":
				structure_id = "hippocampus"
				print("[EnhancedExplorationScene] Applied special case mapping to hippocampus")
			else:
				# Fallback: use the mesh name as structure ID
				structure_id = structure_name
				push_warning("[EnhancedExplorationScene] No structure ID mapping for mesh: ", structure_name)
	
	# Show selection sphere
	if mesh_instance:
		selection_sphere.visible = true
		selection_sphere.global_position = mesh_instance.global_position
	
	# Get educational content
	var content = StructureContentService.get_structure_content(structure_id)
	
	if content.is_empty():
		info_panel.display_structure_info({
			"name": structure_id,
			"description": "Educational content for this structure is being prepared."
		})
	else:
		info_panel.display_structure_info(content)
		_current_structure_id = structure_id
	
	# Update status
	update_status("Selected: " + structure_id)
	
	# Highlight button with M3 colors
	for id in _structure_buttons:
		_structure_buttons[id].modulate = Color.WHITE
	if _structure_buttons.has(_current_structure_id):
		_structure_buttons[_current_structure_id].modulate = M3DesignTokens.M3_COLORS["primary"]
	
	structure_selected.emit(structure_id)

func _on_structure_highlighted(structure_name: String, _mesh_instance: MeshInstance3D) -> void:
	"""Handle structure highlighting"""
	# Convert mesh name to structure ID for display
	var display_name = structure_name
	if _mesh_to_structure_id.has(structure_name):
		display_name = _mesh_to_structure_id[structure_name]
	update_status("Hovering: " + display_name)

func _on_selection_cleared() -> void:
	"""Handle selection cleared"""
	selection_sphere.visible = false
	info_panel.hide_panel()
	update_status("Ready")
	
	# Clear button highlights
	for id in _structure_buttons:
		_structure_buttons[id].modulate = Color.WHITE

func _load_brain_models() -> void:
	"""Load the brain models"""
	print("[EnhancedExplorationScene] Loading brain models...")
	show_loading("Loading brain anatomy model...", 0.0)
	
	# Remove placeholder after a delay
	await get_tree().create_timer(0.5).timeout
	var placeholder = $BrainModelContainer/ModelHolder/PlaceholderBrain
	if placeholder:
		placeholder.queue_free()
	
	show_loading("Initializing brain structures...", 0.3)
	
	# Load Internal-Structures model
	if _model_loader:
		_model_loader.load_model_async("Internal-Structures", _on_internal_structures_loaded)

func _on_internal_structures_loaded(model_instance: Node3D) -> void:
	"""Handle Internal-Structures model loaded"""
	show_loading("Processing brain structures...", 0.7)
	
	if not model_instance:
		print("[EnhancedExplorationScene] Failed to load Internal-Structures model")
		hide_loading()
		update_status("Error: Failed to load brain model")
		return
	
	print("[EnhancedExplorationScene] Internal-Structures model loaded successfully")
	
	# Add to scene
	model_holder.add_child(model_instance)
	
	# Load structure metadata from JSON
	var file = FileAccess.open("res://content/brain_structures.json", FileAccess.READ)
	var json_data = {}
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			json_data = json.data
		else:
			push_error("[EnhancedExplorationScene] Failed to parse brain_structures.json")
	else:
		push_error("[EnhancedExplorationScene] Failed to load brain_structures.json")
	
	# Process structures and map IDs to mesh instances
	var structures_data = []
	var structure_mapping = {}  # Maps structure IDs to model names
	
	# Build mapping from JSON data
	if json_data.has("structures"):
		for structure_id in json_data.structures:
			var structure_info = json_data.structures[structure_id]
			if structure_info.has("modelNames"):
				for model_name in structure_info.modelNames:
					structure_mapping[model_name] = structure_id
			structures_data.append({
				"id": structure_id,
				"name": structure_info.get("displayName", structure_id),
				"displayName": structure_info.get("displayName", structure_id)
			})
	
	# Map mesh instances to structure IDs
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			var mesh_name = child.name.strip_edges()  # Remove any leading/trailing whitespace
			print("[EnhancedExplorationScene] Found mesh: '", mesh_name, "' (length: ", mesh_name.length(), ")")
			
			# Check if this mesh name is in our mapping
			var found_mapping = false
			
			# Debug: print available mappings for this mesh
			print("[EnhancedExplorationScene] Looking for mapping for mesh: '", mesh_name, "'")
			print("[EnhancedExplorationScene] Available mappings: ", structure_mapping.keys())
			
			# Try exact match first
			if structure_mapping.has(mesh_name):
				var structure_id = structure_mapping[mesh_name]
				_brain_structures[structure_id] = child
				_mesh_to_structure_id[mesh_name] = structure_id
				print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "'")
				found_mapping = true
			# Also check with different capitalization patterns
			elif structure_mapping.has("Hipp and Others (good)") and mesh_name == "Hipp And Others (good)":
				var structure_id = structure_mapping["Hipp and Others (good)"]
				_brain_structures[structure_id] = child
				_mesh_to_structure_id[mesh_name] = structure_id
				print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (capitalization fix)")
				found_mapping = true
			else:
				# Try case-insensitive match
				for model_name in structure_mapping:
					if model_name.to_lower() == mesh_name.to_lower():
						var structure_id = structure_mapping[model_name]
						_brain_structures[structure_id] = child
						_mesh_to_structure_id[mesh_name] = structure_id
						print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (case-insensitive match)")
						found_mapping = true
						break
				
				# If still not found, try partial match
				if not found_mapping:
					for model_name in structure_mapping:
						if mesh_name.to_lower().begins_with(model_name.to_lower()) or model_name.to_lower().begins_with(mesh_name.to_lower()):
							var structure_id = structure_mapping[model_name]
							_brain_structures[structure_id] = child
							_mesh_to_structure_id[mesh_name] = structure_id
							print("[EnhancedExplorationScene] Mapped mesh '", mesh_name, "' to structure ID '", structure_id, "' (partial match)")
							found_mapping = true
							break
			
			if not found_mapping:
				# Last resort - check if this is a known problematic case
				var normalized = mesh_name.to_lower().replace(" (good)", "").replace("_", " ").strip_edges()
				if normalized == "hipp and others":
					_brain_structures["hippocampus"] = child
					_mesh_to_structure_id[mesh_name] = "hippocampus"
					print("[EnhancedExplorationScene] Applied hardcoded mapping for hippocampus variant")
					found_mapping = true
				else:
					push_warning("[EnhancedExplorationScene] No mapping found for mesh: ", mesh_name)
	
	# Populate structure list with data from JSON
	_populate_structure_list(structures_data)
	
	# Center and scale
	_adjust_model_transform(model_instance)
	_frame_model(model_instance)
	
	# Create annotations if needed
	if _annotation_system:
		_annotation_system.create_default_annotations(_brain_structures)
	
	show_loading("Finalizing...", 0.9)
	await get_tree().create_timer(0.5).timeout
	
	hide_loading()
	update_status("Ready - " + str(_brain_structures.size()) + " structures loaded")

# Include remaining methods from original ExplorationScene.gd...
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if _is_loading:
		return
	
	# Use LEFT mouse button for rotation (more intuitive)
	if event.button_index == MOUSE_BUTTON_LEFT and not event.shift_pressed:
		_is_rotating = event.pressed
		# Update cursor
		if event.pressed:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	# RIGHT click for selection
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if _brain_interaction:
			_brain_interaction.handle_mouse_click(event)
	
	# Handle zoom with trackpad-friendly smooth scrolling
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if event.pressed:
			# Check if this is a trackpad (high precision) or mouse wheel
			var is_trackpad = event.factor != 1.0
			if is_trackpad:
				# Smooth trackpad scrolling
				_zoom_velocity -= event.factor * ZOOM_SPEED * trackpad_zoom_sensitivity * 20.0
			else:
				# Discrete mouse wheel
				_camera_distance = max(MIN_ZOOM, _camera_distance - ZOOM_SPEED)
				_update_camera_position()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if event.pressed:
			var is_trackpad = event.factor != 1.0
			if is_trackpad:
				# Smooth trackpad scrolling
				_zoom_velocity += event.factor * ZOOM_SPEED * trackpad_zoom_sensitivity * 20.0
			else:
				# Discrete mouse wheel
				_camera_distance = min(MAX_ZOOM, _camera_distance + ZOOM_SPEED)
				_update_camera_position()
	
	# Middle mouse button for panning
	elif event.button_index == MOUSE_BUTTON_MIDDLE:
		_is_panning = event.pressed
		if event.pressed:
			Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _is_loading:
		return
		
	if _brain_interaction:
		_brain_interaction.handle_mouse_motion(event)
	
	# Check for trackpad vs mouse (trackpad typically has pressure)
	var sensitivity_multiplier = 1.0
	if event.pressure > 0.0:
		# Trackpad detected, use custom sensitivity
		sensitivity_multiplier = trackpad_rotate_sensitivity
	
	if _is_rotating:
		_camera_rotation.x -= event.relative.x * _rotation_speed * 0.01 * sensitivity_multiplier
		_camera_rotation.y -= event.relative.y * _rotation_speed * 0.01 * sensitivity_multiplier
		_camera_rotation.y = clamp(_camera_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
		_update_camera_orbit()
	elif _is_panning:
		# Pan the camera pivot
		var pan_speed = _camera_distance * 0.001 * sensitivity_multiplier
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y
		
		if camera_pivot:
			camera_pivot.global_position -= right * event.relative.x * pan_speed
			camera_pivot.global_position += up * event.relative.y * pan_speed

func _handle_keyboard(event: InputEventKey) -> void:
	if not event.pressed or _is_loading:
		return
		
	match event.keycode:
		KEY_ESCAPE:
			return_to_menu_requested.emit()
		KEY_R:
			reset_camera_view()
		KEY_G:
			toggle_grid(not grid_floor.visible)
		KEY_H:
			_on_help_pressed()
		KEY_L:
			label_toggle.button_pressed = not label_toggle.button_pressed
		KEY_Q:
			_on_quiz_pressed()
		KEY_F:
			_focus_on_selection()

func _handle_pan_gesture(event: InputEventPanGesture) -> void:
	"""Handle trackpad pan gestures (two-finger swipe)"""
	if _is_loading:
		return
	
	# Use pan gesture for rotation (more natural on trackpad)
	_camera_rotation.x -= event.delta.x * _rotation_speed * 0.5 * trackpad_rotate_sensitivity
	_camera_rotation.y += event.delta.y * _rotation_speed * 0.5 * trackpad_rotate_sensitivity
	_camera_rotation.y = clamp(_camera_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
	_update_camera_orbit()

func _handle_magnify_gesture(event: InputEventMagnifyGesture) -> void:
	"""Handle trackpad pinch zoom gestures"""
	if _is_loading:
		return
	
	# Magnify gesture for zoom (pinch)
	var zoom_factor = 1.0 - (event.factor - 1.0) * trackpad_zoom_sensitivity
	_camera_distance *= zoom_factor
	_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)
	_update_camera_position()

func reset_camera_view() -> void:
	"""Reset camera to default view"""
	_camera_rotation = Vector2(deg_to_rad(-45), deg_to_rad(-20))
	_camera_distance = 15.0
	# Reset camera pivot to origin
	if camera_pivot:
		camera_pivot.global_position = Vector3.ZERO
	_update_camera_orbit()
	update_status("Camera view reset")

func _focus_on_selection() -> void:
	"""Focus camera on currently selected structure"""
	if _current_structure_id.is_empty() or not _brain_structures.has(_current_structure_id):
		update_status("No structure selected to focus on")
		return
	
	var mesh_instance = _brain_structures[_current_structure_id]
	if not mesh_instance:
		return
		
	# Get bounds of the selected mesh
	if mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		var global_aabb = mesh_instance.global_transform * aabb
		var size = global_aabb.size
		var max_dimension = max(size.x, max(size.y, size.z))
		
		# Calculate optimal distance
		var fov_rad = deg_to_rad(camera.fov)
		_camera_distance = (max_dimension * 0.8) / tan(fov_rad * 0.5) * 2.0
		_camera_distance = clamp(_camera_distance, MIN_ZOOM * 0.5, MAX_ZOOM)
		
		# Move camera pivot to structure center
		if camera_pivot:
			camera_pivot.global_position = mesh_instance.global_position
		
		_update_camera_position()
		update_status("Focused on: " + _current_structure_id)

# Model adjustment methods
func _adjust_model_transform(model: Node3D) -> void:
	"""Adjust model transform for proper display"""
	var aabb = AABB()
	var first = true
	
	for child in model.get_children():
		if child is MeshInstance3D and child.mesh:
			var mesh_aabb = child.mesh.get_aabb()
			mesh_aabb = child.transform * mesh_aabb
			
			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)
	
	var center = aabb.get_center()
	# Center the model at origin
	model.position = Vector3.ZERO
	
	# Adjust all child meshes to center them
	for child in model.get_children():
		if child is MeshInstance3D:
			child.position -= center
	
	var size = aabb.size
	var max_dimension = max(size.x, max(size.y, size.z))
	if max_dimension > 0:
		# Increased target size for better visibility
		var target_size = 6.0
		var scale_factor = target_size / max_dimension
		model.scale = Vector3.ONE * scale_factor
		print("[EnhancedExplorationScene] Model scaled by factor: ", scale_factor)
		print("[EnhancedExplorationScene] Model positioned at origin")

func _frame_model(model: Node3D) -> void:
	"""Adjust camera to frame the model"""
	var aabb = AABB()
	var first = true
	
	for child in model.get_children():
		if child is MeshInstance3D and child.mesh:
			var mesh_aabb = child.mesh.get_aabb()
			mesh_aabb = model.transform * child.transform * mesh_aabb
			
			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)
	
	var size = aabb.size
	var max_dimension = max(size.x, max(size.y, size.z))
	
	var fov_rad = deg_to_rad(camera.fov)
	_camera_distance = (max_dimension * 0.5) / tan(fov_rad * 0.5) * 2.5  # Increased multiplier for better framing
	_camera_distance = clamp(_camera_distance, MIN_ZOOM, MAX_ZOOM)
	print("[EnhancedExplorationScene] Camera distance set to: ", _camera_distance)
	
	_update_camera_position()

# Stub methods for systems - implement as needed
func _setup_model_loader() -> void:
	var ModelLoader = preload("res://src/systems/3d_interaction/ModelLoader.gd")
	_model_loader = ModelLoader.new()
	add_child(_model_loader)
	_model_loader.model_loaded.connect(func(loaded_model_name, _instance): print("[Enhanced] Model loaded: ", loaded_model_name))
	_model_loader.model_load_failed.connect(func(failed_model_name, _error): update_status("Failed to load: " + failed_model_name))

func _setup_camera_presets() -> void:
	var CameraPresetManager = preload("res://src/systems/3d_interaction/CameraPresetManager.gd")
	_camera_presets = CameraPresetManager.new()
	add_child(_camera_presets)
	_camera_presets.initialize(camera, camera_pivot)

func _setup_annotation_system() -> void:
	var AnnotationSystem = preload("res://src/systems/3d_interaction/AnnotationSystem.gd")
	_annotation_system = AnnotationSystem.new()
	add_child(_annotation_system)
	_annotation_system.initialize(brain_container, camera)

func _setup_quiz_panel() -> void:
	"""Setup the quiz panel"""
	# Create quiz panel instance
	var QuizPanelScene = preload("res://src/ui/components/QuizPanel.tscn")
	_quiz_panel = QuizPanelScene.instantiate()
	$UI.add_child(_quiz_panel)
	
	# Connect quiz signals
	_quiz_panel.answer_submitted.connect(_on_quiz_answer_submitted)
	_quiz_panel.next_question_requested.connect(_on_quiz_next_question)
	_quiz_panel.quiz_closed.connect(_on_quiz_closed)
	_quiz_panel.assessment_selected.connect(_on_assessment_selected)
	
	# Connect assessment service signals
	AssessmentService.question_answered.connect(_on_question_answered)
	AssessmentService.assessment_completed.connect(_on_assessment_completed)
	
	print("[EnhancedExplorationScene] Quiz system initialized")

func _toggle_quiz() -> void:
	"""Toggle quiz panel visibility"""
	if not _quiz_panel:
		update_status("Quiz system not available")
		return
	
	if _quiz_panel.visible:
		_quiz_panel.hide()
	else:
		# Show assessments for current structure
		if _current_structure_id.is_empty():
			# Show all assessments if no structure selected
			var all_assessments = []
			for structure_id in ["thalamus", "hippocampus", "striatum", "ventricles", "corpus_callosum"]:
				var assessments = AssessmentService.get_assessments_for_structure(structure_id)
				all_assessments.append_array(assessments)
			_quiz_panel.show_assessment_list(all_assessments)
		else:
			# Show assessments for selected structure
			var assessments = AssessmentService.get_assessments_for_structure(_current_structure_id)
			if assessments.is_empty():
				update_status("No assessments available for: " + _current_structure_id)
			else:
				_quiz_panel.show_assessment_list(assessments)

func _on_info_panel_closed() -> void:
	if _brain_interaction:
		_brain_interaction.clear_all_selections()

func _on_info_panel_quiz_requested(structure_id: String) -> void:
	_current_structure_id = structure_id
	_toggle_quiz()

func _on_assessment_selected(assessment_id: String) -> void:
	"""Handle assessment selection"""
	if AssessmentService.start_assessment(assessment_id):
		var question = AssessmentService.get_current_question()
		_quiz_panel.display_question(question)

func _on_quiz_answer_submitted(answer: Variant) -> void:
	"""Handle quiz answer submission"""
	var result = AssessmentService.submit_answer(answer)
	_quiz_panel.show_feedback(result)

func _on_quiz_next_question() -> void:
	"""Handle next question request"""
	if AssessmentService.next_question():
		var question = AssessmentService.get_current_question()
		_quiz_panel.display_question(question)

func _on_quiz_closed() -> void:
	"""Handle quiz panel closed"""
	update_status("Quiz closed")

func _on_question_answered(_question_id: String, _is_correct: bool) -> void:
	"""Handle question answered event"""
	var progress = AssessmentService.get_progress()
	print("[EnhancedExplorationScene] Quiz progress: ", progress)

func _on_assessment_completed(_assessment_id: String, score_data: Dictionary) -> void:
	"""Handle assessment completion"""
	_quiz_panel.show_results(score_data)
	update_status("Assessment completed: %.1f%%" % score_data.percentage)
