extends Node

class_name Main

const character_position_small: Vector2i = Vector2i(32, 32)
const small_window_size: Vector2i = Vector2i(64, 64)
const character_position_large: Vector2i = Vector2i(32, 368)
const large_window_size: Vector2i = Vector2i(400, 400)

var is_dragging: bool = false
var dragging_origin: Vector2 = Vector2.ZERO

@onready var chat: Chat = %Chat
@onready var character: Character = %Character


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("option"):
		is_dragging = true
		dragging_origin = event.position

	if event.is_action_released("option"):
		is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		get_window().position += Vector2i(event.position - dragging_origin)

	
	if event.is_action_pressed("action"):
		if chat.visible:
			get_window().size = small_window_size
			get_window().position.y += large_window_size.y - small_window_size.y
			chat.hide()
			character.position = character_position_small
		else:
			get_window().size = large_window_size
			get_window().position.y -= large_window_size.y - small_window_size.y
			character.position = character_position_large
			chat.show()
			chat.grab_focus()
			chat.input.grab_focus()