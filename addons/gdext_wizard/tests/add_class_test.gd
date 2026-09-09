@tool
extends EditorScript

func _run():
	var service := ClassService.new()
	var err := service.add_class("Core", "Enemy", "Node2D")
	print("add_class result: ", err)
