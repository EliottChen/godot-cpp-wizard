@tool
class_name TemplateUtils
extends RefCounted

const TEMPLATE_DIR := "res://addons/gdext_wizard/templates/"

static func apply_template(template: String, ctx: Dictionary) -> String:
	var result := template
	for key in ctx.keys():
		result = result.replace("@@%s@@" % String(key).to_upper(), str(ctx[key]))
	return result

static func load_template(template_name: String) -> String:
	var file := FileAccess.open(TEMPLATE_DIR + template_name, FileAccess.READ)
	if file == null:
		push_error(Debug.plugin_log_prefix + ": missing template '%s' (error %d)." % [template_name, FileAccess.get_open_error()])
		return ""
	return file.get_as_text()

static func write_file(path: String, content: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error(Debug.plugin_log_prefix + ": couldn't write file '%s' (error %d)." % [path, FileAccess.get_open_error()])
		return false
	file.store_string(content)
	file.close()
	return true

static func write_register_types(src_dir: String, snake_name: String, classes: Array) -> bool:
	var includes := ""
	var registrations := ""
	for c in classes:
		includes += "#include \"%s.h\"\n" % c["snake"]
		registrations += "\tGDREGISTER_CLASS(%s);\n" % c["name"]

	var ctx := {
		"upper": snake_name.to_upper(),
		"snake": snake_name,
		"includes": includes,
		"registrations": registrations,
	}

	var header := apply_template(load_template("register_types.h.txt"), ctx)
	var cpp := apply_template(load_template("register_types.cpp.txt"), ctx)

	var ok_h := write_file(src_dir + "/register_types.h", header)
	var ok_cpp := write_file(src_dir + "/register_types.cpp", cpp)
	return ok_h and ok_cpp
