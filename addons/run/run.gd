@tool
extends EditorPlugin

var button: Button
var scene_created = false

func read_file_as_string(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		print("File not found: ", file_path)
		return ""
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Cant open: ", file_path)
		return ""
	
	var content = file.get_as_text()
	file.close()
	
	return content

func get_extends_class(text: String) -> String:
	var lines = text.split("\n")
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed.begins_with("extends"):
			var parts = trimmed.split(" ")
			if parts.size() > 1:
				return parts[1].strip_edges()
	return ""

func create_new_scene(type, path):
	# Ensure the 'tmp' directory exists
	var dir = DirAccess.open("res://tmp")
	if dir == null:
		print("Creating tmp directory...")
		dir = DirAccess.open("res://")
		dir.make_dir("tmp")

	var root = type
	root.name = "TmpScene"
	
	var script = load(path)
	if script == null:
		push_error("Failed to load script: " + path)
		return
	
	root.set_script(script)
	
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(root)
	if result != OK:
		push_error("Failed to pack scene")
		return
	
	var save_path = "res://tmp/tmp_scene.tscn"
	result = ResourceSaver.save(packed_scene, save_path)
	if result != OK:
		push_error("Failed to save scene to disk: " + save_path)
	else:
		print("Scene saved successfully: ", save_path)
		var editor_interface = get_editor_interface()
		var file_system_dock = editor_interface.get_file_system_dock()
		
		editor_interface.open_scene_from_path(save_path)
		editor_interface.play_current_scene()
		
		scene_created = true

func _enter_tree():
	button = Button.new()
	button.text = "Run Script ▶"
	
	add_control_to_container(CONTAINER_TOOLBAR, button)
	
	button.pressed.connect(_on_button_pressed)

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.queue_free()

func _on_button_pressed(): 
	var script_editor = get_editor_interface().get_script_editor()
	var current_script = script_editor.get_current_script()
	var path = current_script.resource_path
	print("Running script: ", path)
	var inher : String = get_extends_class(read_file_as_string(path))
	
	if ClassDB.class_exists(inher):
		var node = ClassDB.instantiate(inher)
		if node is Node:
			print(inher)
			create_new_scene(node, path)

func _process(delta: float) -> void:
	var editor_interface = get_editor_interface()
	
	if not editor_interface.is_playing_scene() and scene_created:
		scene_created = false
		print("RUNNING STOPED. TODO: Create logic for deleting tmp")
		#TODO: Create logic for deleting tmp
