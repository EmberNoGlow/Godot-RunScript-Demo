extends Node3D


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	position.y += delta*10.0
	print("Position.y: ", position.y)
