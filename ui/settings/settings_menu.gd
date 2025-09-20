extends Container

class_name SettingsMenu

@onready var open_ai_key_input: LineEdit = %OpenAIKey
@onready var serper_key_input: LineEdit = %SerperKey
@onready var model_input: OptionButton = %Model
@onready var color_input: OptionButton = %Color
@onready var name_input: LineEdit = %Name
@onready var location_input: LineEdit = %Location
@onready var fader: Fader = %Fader


func fade_in() -> void:
	modulate = Color("#e1f9b0") if Config.color_scheme == "spring forest" else Color("#FCDBCC")
	open_ai_key_input.text = Config.openai_api_key
	serper_key_input.text = Config.serper_api_key
	name_input.text = Config.user_name
	location_input.text = Config.user_location
	var success = select_by_value(model_input, Config.openai_model)
	if not success:
		model_input.selected = 0
	success = select_by_value(color_input, Config.color_scheme)
	if not success:
		color_input.selected = 0
	await fader.fade_in()


func fade_out() -> void:
	await fader.fade_out()


func select_by_value(option_button: OptionButton, value: String) -> bool:
	for i in option_button.get_item_count():
		if option_button.get_item_text(i) == value:
			option_button.selected = i
			return true
	return false


func _on_save_button_pressed() -> void:
	Config.openai_api_key = open_ai_key_input.text
	Config.serper_api_key = serper_key_input.text
	Config.openai_model = model_input.get_item_text(model_input.selected)
	Config.color_scheme = color_input.get_item_text(color_input.selected)
	Config.user_name = name_input.text
	Config.user_location = location_input.text
	Config.save()
	Events.hide_settings.emit()


func _on_cancel_button_pressed() -> void:
	Events.hide_settings.emit()
