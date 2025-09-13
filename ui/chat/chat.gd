extends Container

class_name Chat

@onready var input: TextEdit = %Input
@onready var output: RichTextLabel = %Output


func _ready() -> void:
	input.text = ""
	output.text = ""


func _on_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("commit"):
		send_text(input.text)
		get_viewport().set_input_as_handled()


func send_text(text: String) -> void:
	output.append_text("\n[b]You said:[/b] [i]%s[/i]\n\n" % text)
	input.text = ""
	if text == "dance":
		output.append_text("here you go\n")
		Events.character_action_triggered.emit("dance")
	else:
		output.append_text("right now the only thing I know how to is dance\n")
