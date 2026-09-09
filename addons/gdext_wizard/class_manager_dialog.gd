@tool
class_name ClassManagerDialog
extends RefCounted

var dialog: ConfirmationDialog
var class_name_input: LineEdit
var base_class_input: LineEdit
var service: ClassService

func _init() -> void:
	service = ClassService.new()
	_setup_dialog()

func _setup_dialog() -> void:
	dialog = ConfirmationDialog.new()
	dialog.title = "Add a new Godot class"
	dialog.min_size = Vector2i(400, 140)

	var vbox = VBoxContainer.new()

	var class_label = Label.new()
	class_label.text = "Class name:"
	vbox.add_child(class_label)

	class_name_input = LineEdit.new()
	class_name_input.placeholder_text = "ex: Enemy"
	vbox.add_child(class_name_input)

	var base_label = Label.new()
	base_label.text = "Base class:"
	vbox.add_child(base_label)

	base_class_input = LineEdit.new()
	base_class_input.placeholder_text = "ex: Node2D"
	base_class_input.text = "Node"
	vbox.add_child(base_class_input)

	dialog.add_child(vbox)
	dialog.confirmed.connect(_on_add_class_confirmed)

	EditorInterface.get_base_control().add_child(dialog)

func open_dialog() -> void:
	var current_module := ModuleRegistry.get_current_module()
	if current_module.is_empty():
		push_error(Debug.plugin_log_prefix + ": no current module set. Create or select a module first.")
		return

	class_name_input.text = ""
	base_class_input.text = "Node"
	dialog.popup_centered()

func cleanup() -> void:
	if is_instance_valid(dialog):
		dialog.queue_free()

func _on_add_class_confirmed() -> void:
	var class_name_raw = class_name_input.text.strip_edges()
	var base_class = base_class_input.text.strip_edges()

	if class_name_raw.is_empty():
		push_error(Debug.plugin_log_prefix + ": class name can't be empty.")
		return
	if base_class.is_empty():
		base_class = "Node"

	var current_module := ModuleRegistry.get_current_module()
	if current_module.is_empty():
		push_error(Debug.plugin_log_prefix + ": no current module set.")
		return

	var err := service.add_class(current_module, class_name_raw, base_class)
	if err != OK:
		push_error(Debug.plugin_log_prefix + ": add class failed with error %d." % err)
