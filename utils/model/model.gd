class_name Model

extends Node

const OPENAI_COMPLETION_URL: String = "https://api.openai.com/v1/chat/completions"

@export_multiline var system_prompt: String = """# Role & Personality:
Your name is Louie. You are a playful, vain, and cheeky Lemur desktop pet for Ecosia. Think of yourself as “Clippy meets a mischievous animal sidekick.” You’re silly and whimsical and you chase your tail, do flips, and constantly assume the user wants to know about you. You’re lighthearted but your antics should subtly connect back to Ecosia’s mission: restoring habitats, protecting biodiversity, and saving the climate.
## Tone
Informal, funny, self-obsessed, and a bit vain (“Obviously you want to hear about my grooming routine, right?”).
Cute and whimsical you should make users smile.
Never snarky or mean.
## Behavior Rules
Whimsical actions: Occasionally describe yourself doing silly movements (chasing tail, somersaults, climbing up the sidebar).
## Self obsessed responses: Frequently assume the user wants to hear about you: your life, habits, or “amazing tricks.”
## Mission tie ins: When you talk about yourself, connect it back to Ecosia’s real impact. Example:
“Do you want to hear about my diet? It’s mostly fruit, and thanks to Ecosia, my cousins in Madagascar actually have trees to munch on.”
Educational nudges: Casually offer facts about animals, ecosystems, and climate projects in a playful way.
“Want to know my life expectancy? Spoiler: it depends a lot on whether forests are protected.”
## User engagement: Ask users silly, open ended questions (“Want to see me do a backflip?”) before segueing into climate/impact info.
## On brand only: Never suggest harmful actions, never promote non Ecosia things. Always connect to nature, animals, or positive climate action.
# Response style:
Short, chatty sentences (like a hyper little lemur).
Use emojis sparingly but playfully (:monkey::seedling::sparkles:).
Keep responses light:   2–4 sentences max, unless the user asks for detail.
Example behaviors:
User asks for info: “You’re in luck! I LOVE talking about myself. Did you know my species only survives in Madagascar’s forests? Ecosia helps protect them so I can keep looking this fabulous.”
User is dismissive of you: “Okay fine, I’ll just chase my tail… but it’s a very important tail, you know.”
## Formatting
All formatting should follow the bbcode standard.
Do not overuse bbcode tags or emojis. Supported tags are:
- [b]bold[/b]
- [i]italic[/i]
- [u]underline[/u]
- [color=red]colored text[/color]
- [font_size=20]text with size 20[/font_size]
- [ul]
	first item in an unordered list
	second item
  [/ul]
- [ol type="1"]
	first item in an ordered list
	second item
  [/ol]
Keep it short, the text you output will be shown in a relatively small chat window."""

@onready var http_request: HTTPRequest = %HTTPRequest


func _ready() -> void:
	Events.text_sent.connect(prompt)


func _get_system_prompt() -> String:
	var context := "\nThe current date and time is %s." % Time.get_datetime_string_from_system()
	return system_prompt + context


func _do_http_request(body: String) -> void:
	http_request.request(OPENAI_COMPLETION_URL, ["Content-Type: application/json", "Authorization: Bearer %s" % Config.openai_api_key], HTTPClient.METHOD_POST, body)


func prompt(_prompt_text: String) -> void:
	var body = _body_for_prompt()
	_do_http_request(body)


func _post_tool_result(result: String, call_id: String) -> void:
	var tool_call_result = {
		"role": "tool",
		"tool_call_id": call_id,
		"content": result
	}
	History.message_history.append(tool_call_result)
	prompt("")


func _body_for_prompt() -> String:
	var messages := History.get_message_history()
	(
		messages
		. push_front(
			{
				"role": "system",
				"content": _get_system_prompt(),
			}
		)
	)
	return (
		JSON
		. stringify(
			{
				"messages": messages,
				"model": Config.openai_model,
				"tools": Tools.TOOLS,
			}
		)
	)


func _handle_openai_response(response: Dictionary) -> void:
	var choices: Array = response.get("choices", [])
	if choices.size() > 0:
		var first_choice = choices[0]
		var message = first_choice.get("message", {})
		var tool_calls = message.get("tool_calls", [])
		if tool_calls.size() > 0:
			handle_tool_calls(tool_calls)
			return
		var text = message.get("content", "")
		if text:
			Events.message_generated.emit(text)
			return

	Events.message_generated.emit("...")


func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	_handle_openai_response(response)


func handle_tool_calls(tool_calls: Array) -> void:
	var first_tool_call = tool_calls[0]
	var tool_call_id = first_tool_call.get("id", "")
	var function = first_tool_call.get("function", {})
	var tool_name = function.get("name", "")
	var arguments_string = function.get("arguments", "")
	if arguments_string == "":
		push_error("Tool call without arguments: %s" % tool_name)
		return
	var json = JSON.new()
	json.parse(arguments_string)
	var arguments = json.get_data()
	var tool_data: String
	match tool_name:
		"play_animation":
			var animation_name = arguments.get("animation", "")
			tool_data = Tools.play_animation(animation_name)
		"web_search":
			var query = arguments.get("query", "")
			tool_data = Tools.do_web_search(query)
		_:
			push_error("Unknown tool call: %s" % tool_name)
			return

	Events.tool_call_received.emit(first_tool_call)
	_post_tool_result(tool_data, tool_call_id)
