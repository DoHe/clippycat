extends Node


var message_history: Array[Dictionary] = []


func _ready() -> void:
	Events.text_sent.connect(_on_text_sent)
	Events.message_generated.connect(_on_message_generated)
	Events.tool_call_received.connect(_on_tool_call_received)


func _on_message_generated(message: String) -> void:
	message_history.append({
		"content": message,
		"role": "assistant",
	})


func _on_text_sent(text: String) -> void:
	message_history.append({
		"content": text,
		"role": "user",
	})


func _on_tool_call_received(tool_call: Dictionary) -> void:
	message_history.append({
		"role": "assistant",
		"tool_calls": [tool_call],
	})


func get_message_history(limit: int = -1) -> Array:
	var history: Array[Dictionary] = message_history.duplicate()
	if limit > 0:
		history = history.slice(-limit)
	return history