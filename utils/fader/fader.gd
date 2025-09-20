extends Node

class_name Fader

@export var target: CanvasItem
@export var duration: float = 0.5

var fading: bool = false


func fade_in() -> void:
	fading = true
	target.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 1.0, duration)
	await tween.finished
	fading = false


func fade_out() -> void:
	fading = true
	target.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 0.0, duration)
	await tween.finished
	fading = false