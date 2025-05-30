extends Control

@onready var player = get_parent().get_node("AnimationMenu")

# Referências aos elementos da interface
@onready var music_slider = $Music
@onready var effects_slider = $Effects
@onready var resolution_option = $Resolution
@onready var display_mode_option = $DisplayMode
@onready var controls_button = $Controls
@onready var back_button = $Back
@onready var FPS_Show_button = $ShowFPS
@onready var FPS_slider = $FPS
@onready var FPS_text = $FPSText
@onready var ui_Button = get_parent().get_node("uiButton")
@onready var ui_Swipe= get_parent().get_node("uiSwipe")


var back = false
var control = false
var resolutions = [
	Vector2i(1920, 1200), 
	Vector2i(1920, 1080), 
	Vector2i(1680, 1050),
	Vector2i(1600, 900), 
	Vector2i(1280, 1024), 
	Vector2i(1440, 900),
	Vector2i(1366, 768), 
	Vector2i(1280, 800), 
	Vector2i(1280, 720),
	Vector2i(1024, 768), 
	Vector2i(1024, 600), 
	Vector2i(1024, 576),
	Vector2i(854, 480)
]

func _ready():
	# Conectando sinais
	music_slider.connect("value_changed", Callable(self, "_on_music_slider_changed"))
	effects_slider.connect("value_changed", Callable(self, "_on_effects_slider_changed"))
	resolution_option.connect("item_selected", Callable(self, "_on_resolution_selected"))
	display_mode_option.connect("item_selected", Callable(self, "_on_display_mode_selected"))
	FPS_slider.connect("value_changed", Callable(self, "_on_FPS_slider_changed"))
	controls_button.connect("pressed", Callable(self, "_on_controls_button_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	player.connect("animation_finished", Callable(self, "_on_animation_finished"))

	# Carregar configurações ao iniciar
	load_from_settings()

func _physics_process(_delta):
	# Fechar o menu com o botão de cancelamento
	if Input.is_action_just_released("ui_cancel"):
		if !player.is_playing():
			Settings.save_settings()
			player.speed_scale = 3
			back = true
			player.play_backwards("settings")

# Slider de volume da música
func _on_music_slider_changed(value: int):
	if value%5 == 0:
		ui_Swipe.play()
	Settings.music_volume = min(50.0, value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Settings.music_volume/100))
	Settings.save_settings()

func _on_effects_slider_changed(value: int):
	if value%5 == 0:
		ui_Swipe.play()
	Settings.effects_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(Settings.effects_volume/100))
	Settings.save_settings()

func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0  # Silêncio total
	return 20.0 * log(value) / log(10.0)

# Mudança de resolução
func _on_resolution_selected(index):
	ui_Button.play()
	# Ajusta a resolução interna da tela
	Settings.resolution_index = index
	DisplayServer.window_set_size(resolutions[index])
	get_tree().root.content_scale_size = resolutions[index]
	_center()
	Settings.save_settings()

func _on_display_mode_selected(index):
	ui_Button.play()
	Settings.display_mode_index = index
	match index:
		0: 
			resolution_option.disabled = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_tree().root.content_scale_size = resolutions[resolution_option.selected]
			_center()
		1: 
			resolution_option.disabled = true
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			get_tree().root.content_scale_size = DisplayServer.window_get_size()
		2: 
			resolution_option.disabled = true
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			get_tree().root.content_scale_size = DisplayServer.window_get_size()
	
	Settings.save_settings()
	# Ajusta a resolução antes de mudar o modo de exibição

# Função para centralizar a janela
func _center():
	await get_tree().process_frame  # Espera 1 frame para garantir que a janela já está configurada
	var screen_size = DisplayServer.screen_get_size()  # Pega o tamanho real da tela
	var window_size = get_window().size  # Pega o tamanho da janela
	var new_position = (screen_size - window_size) / 2  # Calcula a posição central
	get_window().position = new_position  # Move a janela para o centro

func _on_FPS_slider_changed(value: int):
	if value%5 == 0:
		ui_Swipe.play()
	Settings.fps_max = int(value)
	if Settings.fps_max == 121.0:
		Engine.max_fps = 0
		FPS_text.text = "illimited"
	else:
		Engine.max_fps = Settings.fps_max
		FPS_text.text = str(Settings.fps_max)
	Settings.save_settings()

# Função chamada quando o botão de FPS é pressionado/trocado
func _on_FPS_Show_button_toggled(button_pressed):
	ui_Button.play()
	Settings.show_fps = button_pressed
	Settings.save_settings()

# Botão de controles (abre a tela de controles)
func _on_controls_button_pressed():
	ui_Button.play()
	if !player.is_playing():
		control = true
		print("Configurações ainda não implementadas!")

# Botão de voltar para o menu principal
func _on_back_button_pressed():
	ui_Button.play()
	if !player.is_playing():
		Settings.save_settings()
		player.speed_scale = 3
		back = true
		player.play_backwards("settings")

func _on_animation_finished(anim_name):
	if anim_name == "settings":
		if back:
			player.speed_scale = 1
			player.play("intro")
			back = false
		elif controls_button:
			control = false

# Carregar configurações ao iniciar
func load_from_settings():
	# Carregar sliders de volume
	music_slider.value = Settings.music_volume
	effects_slider.value = Settings.effects_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(effects_slider.value / 100.0))

	# Resolução e modo de exibição
	resolution_option.select(Settings.resolution_index)
	display_mode_option.select(Settings.display_mode_index)
	_on_display_mode_selected(Settings.display_mode_index)

	# Mostrar FPS
	FPS_Show_button.button_pressed = Settings.show_fps
	FPS_slider.value = Settings.fps_max
	if int(FPS_slider.value) == 121:
		FPS_text.text = "illimited"
	else:
		FPS_text.text = str(FPS_slider.value)
