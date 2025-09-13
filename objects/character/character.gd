extends Node2D

class_name Character

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D2
@onready var idle_action_timer: Timer = %IdleActionTimer

@export var idle_action_interval_min: float = 5.0
@export var idle_action_interval_max: float = 10.0

const IDLE_LIKELIHOODS: Dictionary[String, float] = {
	"idle1": 1,
	"idle2": 1,
	"sleeping": 2
}

const IDLE_ACTION_LIKELIHOODS: Dictionary[String, float] = {
	"lick1": 1,
	"lick2": 1,
	"arching": 1
}


const CLICK_ACTION_LIKELIHOODS: Dictionary[String, float] = {
	"tap": 1,
	"pounce": 1
}


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	idle_action_timer.start(randf_range(idle_action_interval_min, idle_action_interval_max))
	Events.character_action_triggered.connect(_on_character_action_triggered)


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
	var idx := Random.RNG.rand_weighted(IDLE_ACTION_LIKELIHOODS.values())
	var idle_action_animation = IDLE_ACTION_LIKELIHOODS.keys()[idx]
	animated_sprite.play(idle_action_animation)
	idle_action_timer.start(randf_range(idle_action_interval_min, idle_action_interval_max))


func _on_character_action_triggered(action: String) -> void:
	if action == "dance":
		animated_sprite.play("jumping2")