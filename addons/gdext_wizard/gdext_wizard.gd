@tool
extends EditorPlugin

var moduleManager: ModuleManager
var classManagerDialog : ClassManagerDialog

func _enter_tree() -> void:
	moduleManager = ModuleManager.new()
	add_tool_menu_item("C++: Create New Module...", _on_open_create_dialog)
	add_tool_menu_item("C++: Recompile Current Module", _on_recompile_current_module)
	add_tool_menu_item("C++: Add New Class...", _on_open_and_class_dialog)

func _exit_tree() -> void:
	remove_tool_menu_item("C++: Create New Module...")
	remove_tool_menu_item("C++: Recompile Current Module")
	remove_tool_menu_item("C++: Add New Class...")
	if moduleManager:
		moduleManager.cleanup()
		moduleManager = null
	if classManagerDialog:
		classManagerDialog.cleanup()
		classManagerDialog = null

func _on_open_and_class_dialog() -> void:
	if classManagerDialog == null:
		classManagerDialog = ClassManagerDialog.new()

	classManagerDialog.open_dialog()

func _on_recompile_current_module() -> void:
	var current := ModuleRegistry.get_current_module()
	if current.is_empty():
		push_error(Debug.plugin_log_prefix + ": no current module set.")
		return
	moduleManager.recompile_module(current)

func _on_open_create_dialog() -> void:
	if moduleManager == null:
		moduleManager = ModuleManager.new()
	
	moduleManager.open_dialog()
