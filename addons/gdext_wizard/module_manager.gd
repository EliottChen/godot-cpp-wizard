@tool
class_name ModuleManager
extends RefCounted

var dialog: ConfirmationDialog
var module_name_input: LineEdit


func _init() -> void:
	Debug.log("Module Manager Initialized")
	_setup_dialog()

func _setup_dialog() -> void:
	dialog = ConfirmationDialog.new()
	dialog.title = "Create a new C++ GDExtension module"
	dialog.min_size = Vector2i(400, 100)
	
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Module name:"
	vbox.add_child(label)
	
	module_name_input = LineEdit.new()
	module_name_input.placeholder_text = "ex: DialogueSystem"
	vbox.add_child(module_name_input)
	
	dialog.add_child(vbox)
	dialog.confirmed.connect(_on_create_module_confirmed)
	
	EditorInterface.get_base_control().add_child(dialog)

func open_dialog() -> void:
	module_name_input.text = ""
	dialog.popup_centered()

func cleanup() -> void:
	if is_instance_valid(dialog):
		dialog.queue_free()

func _on_create_module_confirmed() -> void:
	var module_name = module_name_input.text.strip_edges()
	if module_name.is_empty():
		push_error(Debug.plugin_log_prefix, ": module name can't be empty.")
		return
	
	Debug.log("Starting creation of C++ module of name: " + module_name)
	var err := create_module(module_name)
	if err != OK:
		push_error(Debug.plugin_log_prefix + ": module creation failed with error %d." % err)

func _write_sconstruct(module_root: String, snake_name: String, godot_cpp_ref: String) -> bool:
	var ctx := {
		"snake": snake_name,
		"branch": godot_cpp_ref,
	}
	var content := TemplateUtils.apply_template(TemplateUtils.load_template("sconstruct.txt"), ctx)
	return TemplateUtils.write_file(module_root + "/SConstruct", content)

func _get_godot_cpp_branch() -> String:
	var info := Engine.get_version_info()
	return "%d.%d" % [info.major, info.minor]

func _ensure_godot_cpp_available(ref: String) -> bool:
	var target_dir := "res://addons/gdext_wizard/godot-cpp-%s" % ref
	if DirAccess.dir_exists_absolute(target_dir):
		return true

	Debug.log("Downloading godot-cpp (%s), this may take a moment..." % ref)
	var args := [
		"clone", "--recurse-submodules", "-b", ref,
		"https://github.com/godotengine/godot-cpp",
		ProjectSettings.globalize_path(target_dir)
	]
	var output := []
	var exit_code := OS.execute("git", args, output, true)
	if exit_code != 0:
		push_error(Debug.plugin_log_prefix + ": git clone failed. Output: " + String("\n").join(output))
	return exit_code == 0

func _write_module_metadata(module_root: String, pascal: String, snake: String, godot_cpp_ref: String, target_version: String) -> bool:
	var data := {
		"name": pascal,
		"snake_name": snake,
		"godot_cpp_ref": godot_cpp_ref,
		"target_godot_version": target_version,
		"classes": []
	}
	return ModuleRegistry.save_module_data(pascal, data)

func create_module(raw_name: String) -> Error:
	var pascal := raw_name.to_pascal_case()
	var snake := raw_name.to_snake_case()
	var module_root := "res://modules/%s" % pascal

	if DirAccess.dir_exists_absolute(module_root):
		push_error(Debug.plugin_log_prefix + ": module '%s' already exists." % pascal)
		return ERR_ALREADY_EXISTS

	var info := Engine.get_version_info()
	var target_version := "%d.%d" % [info.major, info.minor]
	var ref := _get_godot_cpp_ref(target_version)

	if not _ensure_godot_cpp_available(ref):
		return ERR_CANT_CREATE

	DirAccess.make_dir_recursive_absolute(module_root + "/src")

	if not TemplateUtils.write_file(module_root + "/.gdignore", ""):
		return ERR_CANT_CREATE

	if not _write_module_metadata(module_root, pascal, snake, ref, target_version):
		return ERR_CANT_CREATE
	if not _write_sconstruct(module_root, snake, ref):
		return ERR_CANT_CREATE
	if not TemplateUtils.write_register_types(module_root + "/src", snake, []):
		return ERR_CANT_CREATE
	if not _write_gdextension_file(snake):
		return ERR_CANT_CREATE

	ModuleRegistry.set_current_module(pascal)

	EditorInterface.get_resource_filesystem().scan()
	Debug.log("Module '%s' created." % pascal)
	return OK

func _write_gdextension_file(snake_name: String) -> bool:
	DirAccess.make_dir_recursive_absolute("res://bin")
	var ctx := {
		"snake": snake_name,
	}
	var content := TemplateUtils.apply_template(TemplateUtils.load_template("gdextension.txt"), ctx)
	return TemplateUtils.write_file("res://bin/%s.gdextension" % snake_name, content)

func _get_godot_cpp_ref(target_version: String) -> String:
	var output := []
	var exit_code := OS.execute("git", [
		"ls-remote", "--exit-code", "--heads",
		"https://github.com/godotengine/godot-cpp", target_version
	], output, true)

	if exit_code == 0:
		return target_version

	Debug.log("No godot-cpp branch '%s' upstream, falling back to master." % target_version)
	return "master"

func recompile_module(module_name: String) -> Error:
	var data: Dictionary = ModuleRegistry.load_module_data(module_name)
	if data.is_empty():
		push_error(Debug.plugin_log_prefix + ": no metadata for module '%s'." % module_name)
		return ERR_DOES_NOT_EXIST

	var module_root_abs := ProjectSettings.globalize_path("res://modules/%s" % module_name)
	var scons_args := ["-C", module_root_abs]
	if data.get("godot_cpp_ref", "") == "master":
		scons_args.append("api_version=%s" % data["target_godot_version"])

	var output := []
	var exit_code := -1

	if OS.get_name() == "Windows":
		var cmd_args := ["/C", "py", "-m", "SCons"] + scons_args
		exit_code = OS.execute("cmd", cmd_args, output, true)
	else:
		exit_code = OS.execute("scons", scons_args, output, true)

	Debug.log("scons output:\n" + String("\n").join(output))

	if exit_code != 0:
		push_error(Debug.plugin_log_prefix + ": recompile failed for '%s' (exit code %d)." % [module_name, exit_code])
		return ERR_CANT_CREATE

	EditorInterface.get_resource_filesystem().scan()
	return OK
