extends Node

## System for displaying 3D labels and annotations on brain structures

# signal annotation_clicked(annotation_id: String)
signal annotation_visibility_changed(visible: bool)

# === CONSTANTS ===
const LABEL_OFFSET: float = 1.0
const LABEL_SCALE: float = 0.01
const LINE_COLOR: Color = Color(0.8, 0.8, 0.8, 0.5)
const LABEL_COLOR: Color = Color.WHITE
const HIGHLIGHT_COLOR: Color = Color.CYAN

# === ANNOTATION CLASS ===
class Annotation extends RefCounted:
	var id: String = ""
	var text: String = ""
	var target_node: Node3D = null
	var position_offset: Vector3 = Vector3.ZERO
	var always_visible: bool = false
	var category: String = ""
	var importance: int = 0  # 0-2 (low, medium, high)
	
	# UI elements
	var label_3d: Label3D = null
	var line_mesh: MeshInstance3D = null
	var connector_line: ImmediateMesh = null

# === PRIVATE VARIABLES ===
var _annotations: Dictionary = {}  # id -> Annotation
var _annotation_container: Node3D = null
var _camera: Camera3D = null
var _visibility_enabled: bool = true
var _detail_level: int = 2  # 0=minimal, 1=important, 2=all
var _label_template: Label3D = null

# === PUBLIC METHODS ===

func initialize(parent: Node3D, camera: Camera3D) -> void:
	"""Initialize the annotation system"""
	_annotation_container = Node3D.new()
	_annotation_container.name = "Annotations"
	parent.add_child(_annotation_container)
	
	_camera = camera
	_create_label_template()
	
	print("[Annotations] System initialized")

func add_annotation(id: String, text: String, target: Node3D, offset: Vector3 = Vector3.ZERO) -> void:
	"""Add a new annotation to a structure"""
	if _annotations.has(id):
		push_warning("[Annotations] Annotation already exists: " + id)
		return
	
	var annotation = Annotation.new()
	annotation.id = id
	annotation.text = text
	annotation.target_node = target
	annotation.position_offset = offset
	
	# Create 3D label
	_create_annotation_label(annotation)
	
	_annotations[id] = annotation
	
	# Update visibility
	_update_annotation_visibility(annotation)

func remove_annotation(id: String) -> void:
	"""Remove an annotation"""
	if not _annotations.has(id):
		return
	
	var annotation = _annotations[id]
	
	if annotation.label_3d:
		annotation.label_3d.queue_free()
	if annotation.line_mesh:
		annotation.line_mesh.queue_free()
	
	_annotations.erase(id)

func set_annotation_importance(id: String, importance: int) -> void:
	"""Set the importance level of an annotation (0-2)"""
	if _annotations.has(id):
		_annotations[id].importance = clamp(importance, 0, 2)
		_update_annotation_visibility(_annotations[id])

func set_detail_level(level: int) -> void:
	"""Set the detail level for annotation visibility (0-2)"""
	_detail_level = clamp(level, 0, 2)
	_update_all_annotations()

func toggle_visibility() -> void:
	"""Toggle all annotations on/off"""
	_visibility_enabled = not _visibility_enabled
	_update_all_annotations()
	annotation_visibility_changed.emit(_visibility_enabled)

func is_visible() -> bool:
	"""Returns the current visibility state of the annotation system"""
	return _visibility_enabled

func highlight_annotation(id: String, highlight: bool = true) -> void:
	"""Highlight or unhighlight an annotation"""
	if not _annotations.has(id):
		return
	
	var annotation = _annotations[id]
	if annotation.label_3d:
		if highlight:
			annotation.label_3d.modulate = HIGHLIGHT_COLOR
			annotation.label_3d.outline_modulate = HIGHLIGHT_COLOR
		else:
			annotation.label_3d.modulate = LABEL_COLOR
			annotation.label_3d.outline_modulate = Color.BLACK

func get_annotations_for_structure(structure_node: Node3D) -> Array:
	"""Get all annotations for a specific structure"""
	var results = []
	
	for id in _annotations:
		var annotation = _annotations[id]
		if annotation.target_node == structure_node:
			results.append({
				"id": annotation.id,
				"text": annotation.text,
				"importance": annotation.importance
			})
	
	return results

func create_default_annotations(brain_structures: Dictionary) -> void:
	"""Create default educational annotations for brain structures"""
	# Thalamus
	if brain_structures.has("Thalami (good)"):
		add_annotation(
			"thalamus_relay",
			"Sensory Relay Center",
			brain_structures["Thalami (good)"],
			Vector3(0, 1.5, 0)
		)
		set_annotation_importance("thalamus_relay", 2)
	
	# Hippocampus
	if brain_structures.has("Hipp and Others (good)"):
		add_annotation(
			"hippocampus_memory",
			"Memory Formation",
			brain_structures["Hipp and Others (good)"],
			Vector3(-1, 0.5, 0)
		)
		set_annotation_importance("hippocampus_memory", 2)
	
	# Striatum
	if brain_structures.has("Striatum (good)"):
		add_annotation(
			"striatum_motor",
			"Motor Control",
			brain_structures["Striatum (good)"],
			Vector3(1, 0.5, 0)
		)
		set_annotation_importance("striatum_motor", 1)
	
	# Ventricles
	if brain_structures.has("Ventricles (good)"):
		add_annotation(
			"ventricles_csf",
			"CSF Circulation",
			brain_structures["Ventricles (good)"],
			Vector3(0, -1, 0)
		)
		set_annotation_importance("ventricles_csf", 1)
	
	# Corpus Callosum
	if brain_structures.has("Corpus Callosum (good)"):
		add_annotation(
			"corpus_callosum_connect",
			"Hemispheric Connection",
			brain_structures["Corpus Callosum (good)"],
			Vector3(0, 2, 0)
		)
		set_annotation_importance("corpus_callosum_connect", 2)

# === PRIVATE METHODS ===

func _create_label_template() -> void:
	"""Create a template for 3D labels"""
	_label_template = Label3D.new()
	_label_template.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label_template.no_depth_test = true
	_label_template.fixed_size = true
	_label_template.pixel_size = LABEL_SCALE
	_label_template.modulate = LABEL_COLOR
	_label_template.outline_modulate = Color.BLACK
	_label_template.outline_size = 20
	_label_template.font_size = 32

func _create_annotation_label(annotation: Annotation) -> void:
	"""Create the visual elements for an annotation"""
	# Create 3D label
	annotation.label_3d = _label_template.duplicate()
	annotation.label_3d.text = annotation.text
	_annotation_container.add_child(annotation.label_3d)
	
	# Create connector line
	_create_connector_line(annotation)
	
	# Update position
	_update_annotation_position(annotation)

func _create_connector_line(annotation: Annotation) -> void:
	"""Create a line connecting label to structure"""
	var line_mesh = MeshInstance3D.new()
	line_mesh.name = "ConnectorLine_" + annotation.id
	
	# Create immediate mesh for the line
	var immediate_mesh = ImmediateMesh.new()
	line_mesh.mesh = immediate_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line_mesh.material_override = material
	
	_annotation_container.add_child(line_mesh)
	annotation.line_mesh = line_mesh
	annotation.connector_line = immediate_mesh

func _update_annotation_position(annotation: Annotation) -> void:
	"""Update the position of an annotation"""
	if not annotation.target_node or not annotation.label_3d:
		return
	
	# Calculate label position
	var target_pos = annotation.target_node.global_position
	var label_pos = target_pos + annotation.position_offset
	
	# Offset towards camera for better visibility
	if _camera:
		var to_camera = (_camera.global_position - target_pos).normalized()
		label_pos += to_camera * LABEL_OFFSET
	
	annotation.label_3d.global_position = label_pos
	
	# Update connector line
	_update_connector_line(annotation, target_pos, label_pos)

func _update_connector_line(annotation: Annotation, start_pos: Vector3, end_pos: Vector3) -> void:
	"""Update the connector line between label and structure"""
	if not annotation.connector_line:
		return
	
	annotation.connector_line.clear_surfaces()
	annotation.connector_line.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Add line vertices
	annotation.connector_line.surface_set_color(LINE_COLOR)
	annotation.connector_line.surface_add_vertex(start_pos)
	annotation.connector_line.surface_add_vertex(end_pos)
	
	annotation.connector_line.surface_end()

func _update_annotation_visibility(annotation: Annotation) -> void:
	"""Update visibility of a single annotation based on settings"""
	if not annotation.label_3d:
		return
	
	var should_show = _visibility_enabled
	
	# Check detail level
	if should_show and not annotation.always_visible:
		match _detail_level:
			0:  # Minimal - only high importance
				should_show = annotation.importance >= 2
			1:  # Important - medium and high
				should_show = annotation.importance >= 1
			2:  # All
				should_show = true
	
	annotation.label_3d.visible = should_show
	if annotation.line_mesh:
		annotation.line_mesh.visible = should_show

func _update_all_annotations() -> void:
	"""Update visibility of all annotations"""
	for id in _annotations:
		_update_annotation_visibility(_annotations[id])

func _process(_delta: float) -> void:
	"""Update annotation positions to face camera"""
	if not _visibility_enabled:
		return
	
	for id in _annotations:
		var annotation = _annotations[id]
		if annotation.label_3d and annotation.label_3d.visible:
			_update_annotation_position(annotation)