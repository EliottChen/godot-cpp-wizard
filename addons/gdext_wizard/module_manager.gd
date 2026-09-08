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
	
	# Attacher le dialogue à l'interface de l'éditeur
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
		push_error(Debug.plugin_log_prefix ,": modulename can't be empty.")
		return
		
	Debug.log("Starting creation of C++ module of name: " + module_name)
