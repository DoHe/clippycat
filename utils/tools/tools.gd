class_name Tools

extends Node

const ANIMATION_TOOL := {
	"type": "function",
	"function":
	{
		"name": "play_animation",
		"description":
		"""Instruct the cat avatar to do one of the supported animations:
					- dance
					- jump""",
		"parameters":
		{
			"type": "object",
			"properties":
			{
				"animation":
				{
					"type": "string",
					"description": "The name of the animation to play. One of: dance, jump",
				},
			},
			"required": ["animation"],
		},
	}
}

const WEBSEARCH_TOOL := {
	"type": "function",
	"function":
	{
		"name": "web_search",
		"description":
		"""Search the web for recent information.
		Use this tool to answer questions about current events
		or to find specific information online.
		The query should be a concise description of what you want to search for.""",
		"parameters":
		{
			"type": "object",
			"properties":
			{
				"query":
				{
					"type": "string",
					"description": "The search query.",
				},
			},
			"required": ["query"],
		},
	}
}

const TOOL_WAITING_SENTENCE := {
	"web_search": "I'll go check the web for that...",
	"play_animation": "Look at me! See what I can do!",
}

signal serper_results_received(results: String)

@onready var http_request: HTTPRequest = %HTTPRequest


func play_animation(animation_name: String) -> String:
	Events.character_action_triggered.emit(animation_name)
	return "success"


func do_web_search(query: String) -> String:
	http_request.request(
		"https://google.serper.dev/search",
		[
			'X-API-KEY: %s' % Config.serper_api_key,
			'Content-Type: application/json',
		],
		HTTPClient.METHOD_POST,
		'{"q": "%s"}' % query
	)
	var serper_results = await serper_results_received
	return serper_results


func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	serper_results_received.emit(body.get_string_from_utf8())


func get_active_tools() -> Array:
	var active_tools: Array = [ANIMATION_TOOL]
	if Config.serper_api_key != "":
		active_tools.append(WEBSEARCH_TOOL)
	return active_tools