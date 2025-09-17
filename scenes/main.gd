extends Node

class_name Main

const character_position_small: Vector2i = Vector2i(120, 32)
const small_window_size: Vector2i = Vector2i(184, 64)
const character_position_large: Vector2i = Vector2i(120, 388)
const large_window_size: Vector2i = Vector2i(400, 420)

var is_dragging: bool = false
var dragging_origin: Vector2 = Vector2.ZERO

@onready var chat: Chat = %Chat
@onready var character: Character = %Character
@onready var settings_menu: SettingsMenu = %SettingsMenu


func _ready() -> void:
	Events.show_settings.connect(_on_show_settings)
	Events.hide_settings.connect(_on_hide_settings)


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
			_hide_chat()
		else:
			if settings_menu.visible:
				await _hide_settings()
			_show_chat()


func _show_chat() -> void:
	_enlarge_window()
	chat.show()
	await chat.fade_in()
	chat.grab_focus()
	chat.input.grab_focus()


func _hide_chat() -> void:
	await chat.fade_out()
	chat.hide()
	_shrink_window()
	character.position = character_position_small


func _enlarge_window() -> void:
	get_window().size = large_window_size
	get_window().position.y -= large_window_size.y - small_window_size.y
	character.position = character_position_large


func _shrink_window() -> void:
	get_window().size = small_window_size
	get_window().position.y += large_window_size.y - small_window_size.y
	character.position = character_position_small


func _show_settings() -> void:
	_enlarge_window()
	settings_menu.visible = true
	settings_menu.fade_in()


func _hide_settings() -> void:
	await settings_menu.fade_out()
	settings_menu.visible = false
	_shrink_window()


func _on_show_settings() -> void:
	if chat.visible:
		await _hide_chat()
	_show_settings()


func _on_hide_settings() -> void:
	_hide_settings()