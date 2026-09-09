@tool
class_name ClassService
extends RefCounted

func add_class(module_name: String, class_name_raw: String, base_class: String = "Node") -> Error:
	var module_root := "res://modules/%s" % module_name
	if not DirAccess.dir_exists_absolute(module_root):
		push_error(Debug.plugin_log_prefix + ": module '%s' does not exist." % module_name)
		return ERR_DOES_NOT_EXIST

	var data := ModuleRegistry.load_module_data(module_name)
	if data.is_empty():
		push_error(Debug.plugin_log_prefix + ": no metadata for module '%s'." % module_name)
		return ERR_DOES_NOT_EXIST

	var pascal := class_name_raw.to_pascal_case()
	var snake := class_name_raw.to_snake_case()

	var classes: Array = data.get("classes", [])
	for c in classes:
		if c.get("snake", "") == snake:
			push_error(Debug.plugin_log_prefix + ": class '%s' already exists in module '%s'." % [pascal, module_name])
			return ERR_ALREADY_EXISTS
	
	var ctx := {
	"name": pascal,
	"upper": snake.to_upper(),
	"snake": snake,
	"base": base_class,
	"base_include": base_class.to_snake_case().replace("_2d", "2d").replace("_3d", "3d"),
	}
	
	var header := TemplateUtils.apply_template(TemplateUtils.load_template("class.h.txt"), ctx)
	var cpp := TemplateUtils.apply_template(TemplateUtils.load_template("class.cpp.txt"), ctx)

	if not TemplateUtils.write_file(module_root + "/src/%s.h" % snake, header):
		return ERR_CANT_CREATE
	if not TemplateUtils.write_file(module_root + "/src/%s.cpp" % snake, cpp):
		return ERR_CANT_CREATE

	classes.append({"name": pascal, "snake": snake, "base": base_class})
	data["classes"] = classes

	if not ModuleRegistry.save_module_data(module_name, data):
		return ERR_CANT_CREATE

	var snake_module: String = data.get("snake_name", module_name.to_snake_case())
	if not TemplateUtils.write_register_types(module_root + "/src", snake_module, classes):
		return ERR_CANT_CREATE

	Debug.log("Class '%s' (%s) added to module '%s'." % [pascal, base_class, module_name])
	return OK
