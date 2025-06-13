extends Node

## Test just the EducationalColorSystem without other dependencies

func _ready():
	print("=== EducationalColorSystem Standalone Test ===")
	
	# Test basic color retrieval
	var light_critical = EducationalColorSystem.get_educational_color("light", "critical_concept")
	var dark_critical = EducationalColorSystem.get_educational_color("dark", "critical_concept")
	
	print("Light critical concept color: ", light_critical)
	print("Dark critical concept color: ", dark_critical)
	
	if light_critical == Color.MAGENTA:
		print("ERROR: Light theme returned default color")
		get_tree().quit(1)
		return
	
	if dark_critical == Color.MAGENTA:
		print("ERROR: Dark theme returned default color")
		get_tree().quit(1)
		return
		
	if light_critical == dark_critical:
		print("ERROR: Light and dark colors are the same")
		get_tree().quit(1)
		return
		
	print("✓ Basic color retrieval works")
	
	# Test content type mapping
	var structure_color = EducationalColorSystem.get_content_type_color("light", "structure_name")
	var function_color = EducationalColorSystem.get_content_type_color("light", "function")
	
	print("Structure name color: ", structure_color)
	print("Function color: ", function_color)
	
	if structure_color == Color.MAGENTA or function_color == Color.MAGENTA:
		print("ERROR: Content type colors returned default")
		get_tree().quit(1)
		return
		
	print("✓ Content type color mapping works")
	
	# Test contrast calculations
	var contrast = EducationalColorSystem.calculate_contrast_ratio(Color.BLACK, Color.WHITE)
	print("Black on white contrast ratio: ", contrast)
	
	if contrast < 20.0:
		print("ERROR: Contrast ratio calculation incorrect")
		get_tree().quit(1)
		return
		
	print("✓ Contrast ratio calculations work")
	
	# Test accessibility functions
	var meets_aaa = EducationalColorSystem.meets_wcag_aaa(Color.BLACK, Color.WHITE)
	var meets_aa = EducationalColorSystem.meets_wcag_aa(Color.BLACK, Color.WHITE)
	
	if not meets_aaa or not meets_aa:
		print("ERROR: WCAG compliance check failed")
		get_tree().quit(1)
		return
		
	print("✓ WCAG compliance checks work")
	
	# Test color scheme info
	var color_info = EducationalColorSystem.get_color_scheme_info()
	print("Color scheme info: ", color_info)
	
	if not color_info.has("wcag_compliance"):
		print("ERROR: Color scheme info missing WCAG compliance")
		get_tree().quit(1)
		return
		
	print("✓ Color scheme information works")
	
	print("=== All EducationalColorSystem tests passed! ===")
	get_tree().quit()