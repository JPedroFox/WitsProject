extends Control

@onready var nome_input = $CanvasLayer/NomeInput
@onready var salvar_button = $CanvasLayer/save
@onready var restart_button = $CanvasLayer/RestartButton
@onready var quit_button = $CanvasLayer/QuitButton
@onready var cronometro = $CanvasLayer/Cronometro
@onready var kills = $CanvasLayer/Kills
var saveOnread = false

# Chame isso com os dados do fim do jogo
var tipo_fim: String = "dead" 

func _ready():
	update_statitics()
	restart_button.connect("pressed", Callable(self, "_on_play_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	salvar_button.connect("pressed", Callable(self, "_on_salvar_pressed"))

func _on_play_pressed():
	# Troca para a cena do jogo
	Global.kills = 0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/Game.tscn")

func _on_quit_pressed():
	# Sai do jogo
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/MainMenu.tscn")

func update_statitics():
	var total_milliseconds = Global.time  # Tempo em milissegundos
	print(total_milliseconds)
	@warning_ignore("integer_division")
	var minutes = total_milliseconds / 60000
	@warning_ignore("integer_division")
	var seconds = (total_milliseconds / 1000) % 60
	var milliseconds = total_milliseconds % 1000
	cronometro.text = "%02d:%02d:%03d" % [int(minutes), int(seconds), int(milliseconds)]
	
	kills.text = "%d Kills" % Global.kills

func _on_salvar_pressed():
	var nome = nome_input.text.strip_edges()
	if nome == "":
		print("⚠️ Nome vazio. Nenhum dado salvo.")
		return
	DadosCripto.salvar_estatistica(tipo_fim, nome, Global.time, Global.kills, Global.difficulty)
	salvar_button.disabled = true
	nome_input.editable = false
	print("✅ Estatística salva com nome:", nome)
