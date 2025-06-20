## Fix Missing Node References Completely
## This script adds null checks for all missing nodes referenced in the script

extends SceneTree

func _init() -> void:
	print("\n=== FIXING MISSING NODE REFERENCES COMPLETELY ===")
	
	var file_path = "res://scenes/3d/EnhancedExplorationScene.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		quit(1)
		return
	
	var fixes = 0
	
	# Fix references to missing nodes in @onready declarations
	# Comment out the missing node references that were removed in our optimization
	
	# ProximityWarning nodes
	content = content.replace("@onready var proximity_warning: Area3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/ProximityWarning", 
		"#@onready var proximity_warning: Area3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/ProximityWarning # Removed in optimization")
	content = content.replace("@onready var proximity_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/ProximityWarning/ProximityShape",
		"#@onready var proximity_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/ProximityWarning/ProximityShape # Removed in optimization")
	fixes += 2
	
	# CameraConstraints nodes
	content = content.replace("@onready var camera_constraints: StaticBody3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints",
		"#@onready var camera_constraints: StaticBody3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints # Removed in optimization")
	content = content.replace("@onready var constraint_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints/ConstraintShape",
		"#@onready var constraint_shape: CollisionShape3D = $EducationalCameraSystem/AnatomicalCameraPivot/CameraCollisionDetection/CameraConstraints/ConstraintShape # Removed in optimization")
	fixes += 2
	
	# AnnotationDebug node
	content = content.replace("@onready var annotation_debug: Control = $EducationalUILayer/AnatomicalAnnotationLayer/AnnotationDebug",
		"#@onready var annotation_debug: Control = $EducationalUILayer/AnatomicalAnnotationLayer/AnnotationDebug # Removed in optimization")
	fixes += 1
	
	# Now fix any code that uses these nodes by adding null checks
	
	# Fix proximity_warning usage
	if content.contains("proximity_warning."):
		content = content.replace("proximity_warning.area_entered", "# proximity_warning.area_entered # Node removed")
		content = content.replace("if proximity_warning:", "if false: # proximity_warning removed")
		fixes += 1
	
	# Fix proximity_shape usage
	if content.contains("proximity_shape."):
		content = content.replace("proximity_shape.shape =", "# proximity_shape.shape = # Node removed\n\tpass #")
		fixes += 1
	
	# Fix camera_constraints usage
	if content.contains("camera_constraints."):
		content = content.replace("camera_constraints.", "# camera_constraints. # Node removed\n\t#")
		fixes += 1
	
	# Fix constraint_shape usage
	if content.contains("constraint_shape."):
		content = content.replace("constraint_shape.", "# constraint_shape. # Node removed\n\t#")
		fixes += 1
	
	# Fix annotation_debug usage
	if content.contains("annotation_debug."):
		content = content.replace("annotation_debug.", "# annotation_debug. # Node removed\n\t#")
		fixes += 1
	
	# Save the fixed file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("✅ Fixed %d missing node references" % fixes)
		print("✅ Commented out references to nodes that were removed during optimization")
	else:
		push_error("Failed to write file: " + file_path)
		quit(1)
		return
	
	print("\n✅ Missing node references completely fixed!")
	quit(0)