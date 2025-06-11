extends Node3D

## Quick test scene for brain model loading

func _ready():
	print("[TestScene] Starting model load test...")
	
	# Create model loader
	var ModelLoader = preload("res://src/systems/3d_interaction/ModelLoader.gd")
	var loader = ModelLoader.new()
	add_child(loader)
	
	# Set up callbacks
	loader.model_loaded.connect(_on_model_loaded)
	loader.model_load_failed.connect(_on_model_failed)
	
	# Try to load the model
	print("[TestScene] Attempting to load Internal-Structures.glb...")
	loader.use_threading = false
	
	var model = loader.load_model("Internal-Structures")
	if model:
		print("[TestScene] Model loaded synchronously!")
		add_child(model)
		_inspect_model(model)
	else:
		print("[TestScene] Trying async load...")
		loader.load_model_async("Internal-Structures", func(m): 
			if m:
				print("[TestScene] Model loaded asynchronously!")
				add_child(m)
				_inspect_model(m)
			else:
				print("[TestScene] Async load failed!")
		)

func _on_model_loaded(model_name: String, instance: Node3D):
	print("[TestScene] Model loaded signal: ", model_name)

func _on_model_failed(model_name: String, error: String):
	print("[TestScene] Model load failed: ", model_name, " - ", error)

func _inspect_model(model: Node3D):
	print("[TestScene] Inspecting loaded model...")
	print("  - Type: ", model.get_class())
	print("  - Children: ", model.get_child_count())
	
	var mesh_count = 0
	var queue = [model]
	
	while queue.size() > 0:
		var node = queue.pop_front()
		if node is MeshInstance3D:
			mesh_count += 1
			print("  - Found mesh: ", node.name)
		
		for child in node.get_children():
			queue.append(child)
	
	print("  - Total meshes found: ", mesh_count)