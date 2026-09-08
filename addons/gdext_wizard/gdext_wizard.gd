@tool
extends EditorPlugin

var moduleManager: ModuleManager

func _enter_tree() -> void:
	moduleManager = ModuleManager.new()
	add_tool_menu_item("C++: Create New Module...", _on_open_create_dialog)

func _exit_tree() -> void:
	remove_tool_menu_item("C++: Create New Module...")
	if moduleManager:
		moduleManager.cleanup() # Supprime proprement le nœud Window de l'éditeur
		moduleManager = null

func _on_open_create_dialog() -> void:
	if moduleManager == null:
		moduleManager = ModuleManager.new()
	
	moduleManager.open_dialog()
