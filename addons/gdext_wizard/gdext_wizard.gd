@tool
extends EditorPlugin

var moduleManager: ModuleManager
var classManagerDialog : ClassManagerDialog
var classRemoverDialog : ClassRemoverDialog
var cpp_menu : PopupMenu

func _enter_tree() -> void:
	Debug.check_log()
	moduleManager = ModuleManager.new()
	
	cpp_menu = PopupMenu.new();
	
	cpp_menu.add_item("Open modules directory", 4)
	cpp_menu.add_item("Create New Module...", 0)
	cpp_menu.add_item("Recompile All Modules", 1)
	cpp_menu.add_separator()
	cpp_menu.add_item("Add New Class...", 2)
	cpp_menu.add_item("Remove Class...", 3)
	cpp_menu.id_pressed.connect(_on_submenu_pressed)
	
	add_tool_submenu_item("C++", cpp_menu)

func _exit_tree() -> void:
	remove_tool_menu_item("C++")
	
	if moduleManager:
		moduleManager.cleanup()
		moduleManager = null
	if classManagerDialog:
		classManagerDialog.cleanup()
		classManagerDialog = null

func _on_submenu_pressed(id: int) -> void:
	match id:
		0: _on_open_create_dialog()
		1: _on_recompile_all()
		2: _on_open_and_class_dialog()
		3: _on_open_remove_class_dialog()
		4: _on_open_sources_folder()

# ====================================================
# =                 Helper functions                 =
# ====================================================
func _on_open_sources_folder() -> Error:
	var module_root := "res://modules/"
	if not DirAccess.dir_exists_absolute(module_root):
		push_error(Debug.plugin_log_prefix + ": modules folder does not exist.")
		return ERR_DOES_NOT_EXIST

	var abs_path := ProjectSettings.globalize_path(module_root)
	return OS.shell_open(abs_path)
	pass

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
