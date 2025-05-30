extends Control

@onready var player = get_parent().get_node("AnimationMenu")
@onready var music = $MenuMusic
@onready var ui_Button = get_parent().get_node("uiButton")
@onready var ui_Swipe= get_parent().get_node("uiSwipe")

var statics = false
var play = false
var playplay = false
var game = false
var settings = false
var quit = false
var retur = false

@export var fade_time := 2.0 # segundos para fade-in e fade-out
var is_fading_in := false
var is_fading_out := false
var fade_timer := 0.0

func _ready():
	$DifficultyLabel.update_difficulty_label()
	Settings.load_settings()
	player.play("intro")
	$PlayButton.connect("pressed", Callable(self, "_on_play_pressed"))
	$SettingsButton.connect("pressed", Callable(self, "_on_settings_pressed"))
	$QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))
	$ReturnButton.connect("pressed", Callable(self, "_on_return_button_pressed"))
	$OptionButton.connect("item_selected", Callable(self, "_on_option_button_item_selected"))
	$Statistics.connect("pressed", Callable(self, "_on_stastics_pressed"))
	player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	play_music()

func _physics_process(delta):
	if is_fading_in:
		fade_timer += delta
		var t = clamp(fade_timer / fade_time, 0, 1)
		music.volume_db = lerp(-80.0, linear_to_db(Settings.music_volume/100)-7, t)
		if t >= 1.0:
			is_fading_in = false

	elif is_fading_out:
		fade_timer += delta
		var t = clamp(fade_timer / fade_time, 0, 1)
		music.volume_db = lerp(linear_to_db((Settings.music_volume+7)/100)-7, -80.0, t)
		if t >= 1.0:
			is_fading_out = false
			music.stop()

func play_music():
	if not music.playing:
		music.play()
	music.volume_db = -80
	fade_timer = 0.0
	is_fading_in = true
	is_fading_out = false

func stop_music():
	if music.playing:
		fade_timer = 0.0
		is_fading_out = true
		is_fading_in = false

func _on_play_pressed():
	if !player.is_playing():
		ui_Button.play()
		statics = false
		if playplay:
			game = true
			stop_music()
			player.play("play")
		else:
			play = true
			player.play("PlaySetings")
		

func _on_settings_pressed():
	if !player.is_playing():
		ui_Button.play()
		statics = false
		settings = true
		player.speed_scale = 3
		player.play_backwards("intro")

func _on_stastics_pressed():
	if !player.is_playing():
		ui_Button.play()
		if statics:
			statics = false
			player.play_backwards("dados")
		else:
			statics = true
			player.play("dados")

func _on_quit_pressed():
	if !player.is_playing():
		ui_Button.play()
		statics = false
		stop_music()
		quit = true
		player.speed_scale = 3
		player.play_backwards("intro")

func _on_return_button_pressed():
	if !player.is_playing():
		ui_Button.play()
		retur = true
		play = false
		playplay = false
		player.speed_scale = 3
		player.play_backwards("PlaySetings")
		

# Função chamada quando a animação termina
func _on_animation_finished(_anim_name):
	if settings:
		player.speed_scale = 1
		player.play("settings")
		settings = false
	elif quit:
		get_tree().quit()
	elif play:
		playplay = true
		play = false
	elif game:
		get_tree().change_scene_to_file("res://cenas/Game.tscn")
		playplay = false
		play = false
		game = false
	elif retur:
		player.speed_scale = 1
		retur = false

func _on_option_button_item_selected(index):
	ui_Button.play()
	if index == 0:
		Global.set_difficulty("easy")
	elif index == 1:
		Global.set_difficulty("medium")
	elif index == 2:
		Global.set_difficulty("hard")
	$DifficultyLabel.update_difficulty_label()
