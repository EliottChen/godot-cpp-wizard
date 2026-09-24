@tool
extends EditorPlugin

var moduleManager: ModuleManager
var classManagerDialog : ClassManagerDialog
var classRemoverDialog : ClassRemoverDialog

func _enter_tree() -> void:
	Debug.check_log()
	moduleManager = ModuleManager.new()
	var menu : PopupMenu = PopupMenu.new();
	
	add_tool_menu_item("C++: Create New Module...", _on_open_create_dialog)
	add_tool_menu_item("C++: Recompile Current Module", _on_recompile_current_module)
	add_tool_menu_item("C++: Recompile All modules", _on_recompile_all)
	add_tool_menu_item("C++: Add New Class...", _on_open_and_class_dialog)
	add_tool_menu_item("C++: Remove Class...", _on_open_remove_class_dialog)

func _exit_tree() -> void:
	remove_tool_menu_item("C++: Create New Module...")
	remove_tool_menu_item("C++: Recompile Current Module")
	remove_tool_menu_item("C++: Recompile All modules")
	remove_tool_menu_item("C++: Add New Class...")
	remove_tool_menu_item("C++: Remove Class...")
	
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
	if(_recompile_current_module()):
		Debug.restart_and_log("Editor was restarted because compile success")

func _recompile_current_module() -> bool:
	var current := ModuleRegistry.get_current_module()
	if current.is_empty():
		push_error(Debug.plugin_log_prefix + ": no current module set.")
		return false
	return moduleManager.recompile_module(current) == OK

func _on_recompile_all() -> void:
	if(_recompile_all()):
		Debug.restart_and_log("Editor was restarted because compile success")

func _recompile_all() -> bool:
	var list := ModuleRegistry.list_modules()
	var all_ok := true
	for module_name in list:
		ModuleRegistry.set_current_module(module_name)
		if not _recompile_current_module():
			push_error(Debug.plugin_log_prefix + ": recompile failed for '%s', continuing with remaining modules." % module_name)
			all_ok = false
		else:
			Debug.log("Module named " + module_name + " succesfully recompiled")
	return all_ok

func _on_open_create_dialog() -> void:
	if moduleManager == null:
		moduleManager = ModuleManager.new()
	
	moduleManager.open_dialog()

func _on_open_remove_class_dialog() -> void:
	if classRemoverDialog == null:
		classRemoverDialog = ClassRemoverDialog.new()
	classRemoverDialog.open_dialog()
