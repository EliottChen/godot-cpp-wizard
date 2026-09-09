class_name Debug

const plugin_log_prefix : String = "[GDExtension]"

func _init() -> void:
	self.log("helper class initialized")
	pass

static func log(message : String) -> void:
	print_rich("[color=green]", plugin_log_prefix, " ", message, "[/color]")

static func check_log() ->void:
	if FileAccess.file_exists("user://pending_log.txt"):
		var file = FileAccess.open("user://pending_log.txt", FileAccess.READ)
		if file:
			var saved_message = file.get_as_text()
			file.close()
			
			# Affiche le message
			print_rich("[color=green][GDExtension] ", saved_message, "[/color]")
			
			# Supprime le fichier pour ne pas réafficher au prochain lancement
			DirAccess.remove_absolute("user://pending_log.txt")

static func restart_and_log(message: String):
	var file = FileAccess.open("user://pending_log.txt", FileAccess.WRITE)
	if file:
		file.store_string(message)
		file.close()
	
	EditorInterface.restart_editor()
