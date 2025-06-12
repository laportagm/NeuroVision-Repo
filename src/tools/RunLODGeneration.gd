@tool
extends EditorScript

## Quick LOD Generation Runner
##
## This script runs the Brain Model Optimizer to generate LOD variants.
## Run this from the Script Editor: Script > Run

func _run() -> void:
	print("\n🚀 Starting LOD Generation Process...")
	print("==================================================")
	
	# Load and run the optimizer
	var optimizer_script = load("res://src/tools/BrainModelOptimizer.gd")
	if optimizer_script:
		var optimizer = optimizer_script.new()
		optimizer._run()
	else:
		print("❌ ERROR: Could not load BrainModelOptimizer.gd")
		print("Please ensure the file exists at:")
		print("  res://src/tools/BrainModelOptimizer.gd")