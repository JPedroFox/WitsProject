extends Node

const CONFIG_PATH = "user://settings.cfg"

var music_volume := 80.0
var effects_volume := 100.0
var resolution_index := 8
var display_mode_index := 1
var show_fps := false
var fps_max := 60

func _ready():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		music_volume = config.get_value("audio", "music_volume", music_volume)
		effects_volume = config.get_value("audio", "effects_volume", effects_volume)
		resolution_index = config.get_value("video", "resolution_index", resolution_index)
		display_mode_index = config.get_value("video", "display_mode_index", display_mode_index)
		show_fps = config.get_value("video", "show_fps", show_fps)
		fps_max = config.get_value("video", "FPS_Max", fps_max)
		if has_node("/root/Game/Camera2D"):
			var camera = get_node("/root/Game/Camera2D")
			if camera:
				Global.adjust_camera_zoom(camera)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "effects_volume", effects_volume)
	config.set_value("video", "resolution_index", resolution_index)
	config.set_value("video", "display_mode_index", display_mode_index)
	config.set_value("video", "show_fps", show_fps)
	config.set_value("video", "FPS_Max", fps_max)
	config.save(CONFIG_PATH)
	if has_node("/root/Game/Camera2D"):
		var camera = get_node("/root/Game/Camera2D")
		if camera:
			Global.adjust_camera_zoom(camera)
