class_name Debug

const plugin_log_prefix : String = "GDExtension"

func _init() -> void:
	self.log("helper class initialized")
	pass

static func log(message : String) -> void:
	print_rich("[color=green]", plugin_log_prefix, ": ", message, "[/color]")
