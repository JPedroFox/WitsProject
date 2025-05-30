extends Control

@onready var player = get_parent().get_node("AnimationMenu")
@onready var fundo = get_parent().get_node("fundo")
@onready var ui_Button = get_parent().get_node("uiButton")
@onready var ui_Swipe= get_parent().get_node("uiSwipe")

var play = false
var settings = false
var quit = false

func _ready():
	$DifficultyLabel.update_difficulty_label()
	fundo.play("fundo")
	player.play("intro")
	$PlayButton.connect("pressed", Callable(self, "_on_play_pressed"))
	$SettingsButton.connect("pressed", Callable(self, "_on_settings_pressed"))
	$QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))
	player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(_delta):
	if Global.control:
		$Tastiera.set_visible(false)
		$Controles.set_visible(true)
	else: 
		$Controles.set_visible(false)
		$Tastiera.set_visible(true)
	if Input.is_action_just_released("ui_cancel"):
		if !player.is_playing():
			play = true
			player.play("play")

func _on_play_pressed():
	if !player.is_playing():
		ui_Button.play()
		play = true
		player.play("play")

func _on_settings_pressed():
	if !player.is_playing():
		ui_Button.play()
		settings = true
		player.speed_scale = 3
		player.play_backwards("intro")

func _on_quit_pressed():
	AudioGlobal.stop_music()
	if !player.is_playing():
		ui_Button.play()
		AudioGlobal.stop_music()
		quit = true
		player.speed_scale = 3
		player.play_backwards("intro")

# Função chamada quando a animação termina
func _on_animation_finished(_anim_name):
	if settings:
		player.speed_scale = 1
		player.play("settings")
		settings = false
	elif quit:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://cenas/MainMenu.tscn")
	elif play:
		play = false
		get_tree().paused = false
		get_parent().get_parent().queue_free()
