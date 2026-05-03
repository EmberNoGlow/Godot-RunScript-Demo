extends Node2D

func _ready() -> void:
	var sp = Sprite2D.new()
	sp.texture = preload("res://icon.svg")
	sp.position = Vector2(300,400)
	add_child(sp)
