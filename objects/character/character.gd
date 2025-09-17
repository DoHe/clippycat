extends Node2D

class_name Character

@onready var animated_sprite: AnimatedSprite2D = %LemurSprite
@onready var idle_action_timer: Timer = %IdleActionTimer
@onready var hover_timer: Timer = %HoverTimer
@onready var settings_button: TextureButton = %SettingsButton
@onready var settings_animation_player: AnimationPlayer = %SettingsAnimationPlayer

@export var idle_action_interval_min: float = 5.0
@export var idle_action_interval_max: float = 10.0

var is_under_mouse: bool = false


const IDLE_LIKELIHOODS: Dictionary[String, float] = {
	"idle1": 1,
	"idle2": 1,
}

const IDLE_ACTION_LIKELIHOODS: Dictionary[String, float] = {
	"jumping": 1,
}


const CLICK_ACTION_LIKELIHOODS: Dictionary[String, float] = {
	"dancing": 1,
	"jumping": 2,
}

var talking: bool = false


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	idle_action_timer.start(randf_range(idle_action_interval_min, idle_action_interval_max))
	Events.character_action_triggered.connect(_on_character_action_triggered)
	Events.text_sent.connect(_on_text_sent)
	Events.message_generated.connect(_on_message_generated)


func _process(_delta: float) -> void:
	if is_under_mouse and not settings_button.visible and hover_timer.is_stopped():
		hover_timer.start()
	if not is_under_mouse and settings_button.visible and not settings_animation_player.is_playing():
		hover_timer.stop()
		settings_animation_player.play_backwards("fade_in")
		await settings_animation_player.animation_finished
		settings_button.visible = false
		settings_button.disabled = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action_alt"):
		var idx := Random.RNG.rand_weighted(CLICK_ACTION_LIKELIHOODS.values())
		var click_animation = CLICK_ACTION_LIKELIHOODS.keys()[idx]
		animated_sprite.play(click_animation)


func _on_animation_finished() -> void:
	var idx := Random.RNG.rand_weighted(IDLE_LIKELIHOODS.values())
	var idle_animation = IDLE_LIKELIHOODS.keys()[idx]
	animated_sprite.play(idle_animation)


func _on_idle_action_timer_timeout() -> void:
	if talking:
		return
	var idx := Random.RNG.rand_weighted(IDLE_ACTION_LIKELIHOODS.values())
	var idle_action_animation = IDLE_ACTION_LIKELIHOODS.keys()[idx]
	animated_sprite.play(idle_action_animation)
	idle_action_timer.start(randf_range(idle_action_interval_min, idle_action_interval_max))


func _on_character_action_triggered(action: String) -> void:
	match action:
		"dance":
			talking = false
			animated_sprite.play("dancing")
		"jump":
			talking = false
			animated_sprite.play("jumping")
		_:
			push_error("Unknown character action: %s" % action)


func _on_text_sent(_text: String) -> void:
	talking = true
	animated_sprite.play("talking")


func _on_message_generated(_message: String) -> void:
	if not talking:
		return
	talking = false
	animated_sprite.play("idle1")


func _on_hover_area_mouse_entered() -> void:
	is_under_mouse = true


func _on_hover_area_mouse_exited() -> void:
	is_under_mouse = false


func _on_hover_timer_timeout() -> void:
	settings_button.disabled = false
	settings_button.visible = true
	settings_animation_player.play("fade_in")


func _on_settings_button_mouse_entered() -> void:
	is_under_mouse = true


func _on_settings_button_mouse_exited() -> void:
	is_under_mouse = false


func _on_settings_button_pressed() -> void:
	Events.show_settings.emit()
