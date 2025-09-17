extends Container

class_name SettingsMenu

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var open_ai_key_input: LineEdit = %OpenAIKey
@onready var serper_key_input: LineEdit = %SerperKey
@onready var model_input: OptionButton = %Model
@onready var color_input: OptionButton = %Color


func fade_in() -> void:
	open_ai_key_input.text = Config.openai_api_key
	serper_key_input.text = Config.serper_api_key
	var success = select_by_value(model_input, Config.openai_model)
	if not success:
		model_input.selected = 0
	success = select_by_value(color_input, Config.color_scheme)
	if not success:
		color_input.selected = 0
	animation_player.play("fade_in")
	await animation_player.animation_finished
	# modulate = Color("#e1f9b0") if Config.color_scheme == "spring forest" else Color("#FCDBCC")


func fade_out() -> void:
	animation_player.play_backwards("fade_in")
	await animation_player.animation_finished


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
	Config.save()
	Events.hide_settings.emit()


func _on_cancel_button_pressed() -> void:
	Events.hide_settings.emit()
