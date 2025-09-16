extends Node

@warning_ignore_start("UNUSED_SIGNAL")
signal character_action_triggered(action: String)
signal message_generated(message: String)
signal text_sent(text: String)
signal tool_call_received(tool_call: Dictionary)