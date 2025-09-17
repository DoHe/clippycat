extends Node

var openai_api_key: String = ""
var openai_model: String = "gpt-4.1"
var serper_api_key: String = ""
var color_scheme: String = "spring forest"

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err != OK:
		push_error("Failed to load config file: %s" % err)
		return

	openai_api_key = config.get_value("openai", "api_key")
	if openai_api_key == null:
		push_error("No openai api key found in config file.")

	openai_model = config.get_value("openai", "model", openai_model)

	serper_api_key = config.get_value("serper", "api_key")
	if serper_api_key == null:
		push_error("No serper api key found in config file.")


	color_scheme = config.get_value("ui", "color_scheme", color_scheme)


func save() -> void:
	var config = ConfigFile.new()
	config.set_value("openai", "api_key", openai_api_key)
	config.set_value("openai", "model", openai_model)
	config.set_value("serper", "api_key", serper_api_key)
	config.set_value("ui", "color_scheme", color_scheme)
	var err = config.save("user://config.cfg")
	if err != OK:
		push_error("Failed to save config file: %s" % err)
