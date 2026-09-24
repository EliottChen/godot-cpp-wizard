@tool
class_name ClassRemoverDialog
extends RefCounted

var dialog: ConfirmationDialog
var module_select: OptionButton
var class_select: OptionButton
var service: ClassService

func _init() -> void:
	service = ClassService.new()
	_setup_dialog()

func _setup_dialog() -> void:
	dialog = ConfirmationDialog.new()
	dialog.title = "Remove a Godot class"
	dialog.min_size = Vector2i(400, 140)
	dialog.ok_button_text = "Remove"

	var vbox = VBoxContainer.new()

	var module_label = Label.new()
	module_label.text = "Module:"
	vbox.add_child(module_label)

	module_select = OptionButton.new()
	module_select.item_selected.connect(_on_module_selected)
	vbox.add_child(module_select)

	var class_label = Label.new()
	class_label.text = "Class:"
	vbox.add_child(class_label)

	class_select = OptionButton.new()
	vbox.add_child(class_select)

	dialog.add_child(vbox)
	dialog.confirmed.connect(_on_remove_class_confirmed)

	EditorInterface.get_base_control().add_child(dialog)

func open_dialog() -> void:
	module_select.clear()
	class_select.clear()

	var modules := ModuleRegistry.list_modules()
	if modules.is_empty():
		push_error(Debug.plugin_log_prefix + ": no modules found. Create one first.")
		return

	var current_module := ModuleRegistry.get_current_module()
	var current_idx := 0
	for i in modules.size():
		module_select.add_item(modules[i])
		if modules[i] == current_module:
			current_idx = i
	module_select.select(current_idx)

	_populate_classes(module_select.get_item_text(current_idx))
	dialog.popup_centered()

func _on_module_selected(_index: int) -> void:
	var module_name := module_select.get_item_text(module_select.selected)
	_populate_classes(module_name)

func _populate_classes(module_name: String) -> void:
	class_select.clear()
	var data := ModuleRegistry.load_module_data(module_name)
	var classes: Array = data.get("classes", [])
	for c in classes:
		class_select.add_item(c.get("name", c.get("snake", "")))

func cleanup() -> void:
	if is_instance_valid(dialog):
		dialog.queue_free()

func _on_remove_class_confirmed() -> void:
	if class_select.item_count == 0:
		push_error(Debug.plugin_log_prefix + ": no class selected.")
		return

	var module_name := module_select.get_item_text(module_select.selected)
	var class_name_selected := class_select.get_item_text(class_select.selected)

	var err := service.remove_class(module_name, class_name_selected)
	if err != OK:
		push_error(Debug.plugin_log_prefix + ": remove class failed with error %d." % err)
