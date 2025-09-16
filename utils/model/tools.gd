class_name Tools

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

const TOOLS = [
	ANIMATION_TOOL,
	WEBSEARCH_TOOL,
]


static func play_animation(animation_name: String) -> String:
	Events.character_action_triggered.emit(animation_name)
	return "success"


static func do_web_search(query: String) -> String:
	return (
		"""{
        "query": "%s",
        "results": [
            {
            "title": "First results",
            "description": "This is the first result"
            }
        ]
        }"""
		% query
	)
