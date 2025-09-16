extends Node

var openai_api_key: String = ""
var openai_model: String = "gpt-5-nano"


func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://config.cfg")
	if err != OK:
		push_error("Failed to load config file: %s" % err)
		return

	openai_api_key = config.get_value("openai", "api_key")
	if openai_api_key == null:
		push_error("No openai api key found in config file.")

	openai_model = config.get_value("openai", "model", openai_model)
