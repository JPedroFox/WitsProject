extends Node2D

@onready var camera = $Camera2D
@onready var hud = $Hud/hud
@onready var pause = false

func _ready():
	Global.kills = 0
	Global.start = false
	Global.adjust_camera_zoom(camera)
	if !AudioGlobal.playing:
		AudioGlobal.play_music()
	camera.process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta):
	if Input.is_action_just_released("ui_cancel") and !pause:
		var esc_scene = preload("res://cenas/EscMenu.tscn").instantiate()
		esc_scene.process_mode = Node.PROCESS_MODE_ALWAYS
		hud.set_visible(false)
		camera.add_child(esc_scene)
		get_tree().paused = true
		pause = true
	if get_tree().paused == false and pause:
		hud.set_visible(true)
		pause = false
