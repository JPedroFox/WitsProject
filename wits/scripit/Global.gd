extends Node

@warning_ignore("unused_signal")
signal animation_signal

var control = false
var start = false
var difficulty : String = "medium"
var time
var kills = 0

func _ready():
	Global.connect("animation_signal", Callable(self, "_on_animation_signal"))

func adjust_camera_zoom(camera: Camera2D):
	var screen_height = get_viewport().get_visible_rect().size.y
	var scale = screen_height / 1080.0
	camera.zoom = Vector2(scale, scale)

func set_difficulty(opition : String):
	difficulty = opition

func get_difficulty(nodo):
	nodo.difficulty = difficulty

func _on_animation_signal():
	start = true
