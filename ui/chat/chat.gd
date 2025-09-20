class_name Chat

extends Container

@onready var input: TextEdit = %Input
@onready var output: RichTextLabel = %Output
@onready var waiting_timer: Timer = %WaitingTimer
@onready var commit_button: TextureButton = %CommitButton
@onready var fader: Fader = %Fader
@onready var speech_bubble: NinePatchRect = %SpeechBubble

var is_waiting: bool = false
var num_waiting_dots: int = 0


func _ready() -> void:
	input.text = ""
	output.text = ""
	Events.message_generated.connect(_on_message_generated)
	Events.tool_call_received.connect(_on_tool_call_received)


func fade_in() -> void:
	speech_bubble.modulate = Color("#e1f9b0") if Config.color_scheme == "spring forest" else Color("#FCDBCC")
	await fader.fade_in()


func fade_out() -> void:
	await fader.fade_out()
	History.message_history.clear()
	output.text = ""
	input.text = ""


func _on_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("commit"):
		_commit()
		get_viewport().set_input_as_handled()


func _commit() -> void:
	output.append_text("\n")
	input.editable = false
	commit_button.disabled = true
	num_waiting_dots = 0
	waiting_timer.start()
	is_waiting = true
	send_text(input.text)


func send_text(text: String) -> void:
	output.append_text("\n[color=#C25419][b]You said:[/b][/color] [i]%s[/i]\n\n" % text)
	input.text = ""
	Events.text_sent.emit(text)
	if text == "dance":
		Events.character_action_triggered.emit("dance")


func _on_message_generated(message: String) -> void:
	is_waiting = false
	_remove_waiting_dots()
	input.editable = true
	commit_button.disabled = false
	output.append_text(message)


func _on_tool_call_received(tool_call: Dictionary) -> void:
	var tool_name = tool_call.get("function", {}).get("name", "")
	var waiting_sentence = Tools.TOOL_WAITING_SENTENCE.get(tool_name, "Give me a sec.")
	_remove_waiting_dots()
	output.append_text("[i]%s[/i]\n\n" % [waiting_sentence])


func _remove_waiting_dots():
	var last_line = output.get_parsed_text().split("\n")[-1]
	if last_line in [".", "..", "..."]:
		output.remove_paragraph(output.get_paragraph_count() - 1)


func _on_waiting_timer_timeout() -> void:
	if not is_waiting:
		return

	var last_line = output.get_parsed_text().split("\n")[-1]
	var dots = ""
	if last_line in [".", "..", "..."]:
		output.remove_paragraph(output.get_paragraph_count() - 1)
		dots += "\n"
	for _i in range(num_waiting_dots):
		dots += "."
	output.append_text(dots)
	num_waiting_dots += 1
	if num_waiting_dots > 3:
		num_waiting_dots = 0


func _on_commit_button_pressed() -> void:
	_commit()
