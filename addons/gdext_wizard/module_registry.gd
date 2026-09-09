class_name ModuleRegistry
extends RefCounted

const STATE_PATH := "res://addons/gdext_wizard/wizard_state.cfg"

static func list_modules() -> Array[String]:
	var modules: Array[String] = []
	var dir := DirAccess.open("res://modules")
	if dir == null:
		return modules
	dir.list_dir_begin()
	var folder := dir.get_next()
	while folder != "":
		if dir.current_is_dir() and FileAccess.file_exists("res://modules/%s/module.json" % folder):
			modules.append(folder)
		folder = dir.get_next()
	dir.list_dir_end()
	return modules

static func get_current_module() -> String:
	var cfg := ConfigFile.new()
	if cfg.load(STATE_PATH) != OK:
		return ""
	return cfg.get_value("state", "current_module", "")

static func set_current_module(module_name: String) -> void:
	var cfg := ConfigFile.new()
	cfg.load(STATE_PATH)
	cfg.set_value("state", "current_module", module_name)
	cfg.save(STATE_PATH)

static func load_module_data(module_name: String) -> Dictionary:
	var path := "res://modules/%s/module.json" % module_name
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

static func save_module_data(module_name: String, data: Dictionary) -> bool:
	var path := "res://modules/%s/module.json" % module_name
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ModuleRegistry: couldn't write module.json for '%s' (error %d)." % [module_name, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true
