class_name Chat

extends Container

@onready var input: TextEdit = %Input
@onready var output: RichTextLabel = %Output


func _ready() -> void:
	input.text = ""
	output.text = ""
	Events.message_generated.connect(_on_message_generated)


func _on_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("commit"):
		input.editable = false
		send_text(input.text)
		get_viewport().set_input_as_handled()


func send_text(text: String) -> void:
	output.append_text("\n[b]You said:[/b] [i]%s[/i]\n\n" % text)
	input.text = ""
	Events.text_sent.emit(text)
	if text == "dance":
		Events.character_action_triggered.emit("dance")


func _on_message_generated(message: String) -> void:
	input.editable = true
	output.append_text(message)
