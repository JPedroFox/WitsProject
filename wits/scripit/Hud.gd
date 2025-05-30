extends CanvasLayer  # hud.gd

@warning_ignore("unused_signal")
signal animation_signal
@onready var contro = $Control
@onready var minimap = $MiniMap
@onready var health_bar = $Control/ProgressHealth
@onready var current_ammo_label = $Control/ammo_gun
@onready var max_ammo_label = $Control/ammo_magazin
@onready var icon_weapon = $Control/IconWeapon
@onready var cronometro = $Cronometro
@onready var fps_label = $FPS
@onready var animation_player = $AnimationTimer
@onready var storage_bullet = get_node("/root/Game/visibility/Player/StorageBullet")  # Atualize o caminho conforme necessário
@onready var dano = $dano

var total_milliseconds: int
var elapsed_time = 0  # Tempo decorrido em segundos
var player
var current_weapon
var play = false
var weapon_textures = {
	1: preload("res://sprites/Survivor Spine/Survivor Spine/images/Pistol icon.png"),
	2: preload("res://sprites/Survivor Spine/Survivor Spine/images/Shotgun icon.png"),
	3: preload("res://sprites/Survivor Spine/Survivor Spine/images/Rifle icon.png"),
}

func _ready():
	dano.set_visible(true)
	fps_label.visible = Settings.show_fps
	animation_player.play("playTimer")

func _physics_process(delta):
	if play:
		# Verifica se ainda há inimigos
		if are_enemies_alive():
			# Incrementa o tempo se houver inimigos
			elapsed_time += delta
			update_cronometro()
		else:
			stop_timer()  # Para o cronômetro quando não houver inimigos
			Win()

# Renomeie o parâmetro para evitar o conflito de nome
func set_player(new_player):
	self.player = new_player
	
	# Atualiza a barra de saúde e a munição, com a arma atual do jogador
	set_new_health_value(new_player.health_node.health)  # Acesse a saúde do nó Health
	update_weapon_ammo(new_player.weapon)
	
	# Conecta sinais para atualizar a UI quando a saúde ou a arma mudar
	new_player.connect("player_health_changed", Callable(self, "set_new_health_value"))

func set_new_health_value(new_health):
	health_bar.value = new_health  # Atualiza a barra de saúde

func update_weapon_ammo(weapon):
	if weapon:
		var ammo = storage_bullet.get_ammo(weapon.weapon_name)
		current_ammo_label.text = str(ammo["current_ammo"])
		max_ammo_label.text = str(ammo["storage_ammo"])
		
		 # Atualizar ícone da arma
		if weapon.weapon_name in weapon_textures:
			icon_weapon.texture = weapon_textures[weapon.weapon_name]

# Inicia o cronômetro
func start_timer():
	elapsed_time = 0  # Reseta o tempo
	set_process(true)  # Ativa o processamento

# Para o cronômetro
func stop_timer():
	set_process(false)  # Desativa o processamento

# Atualiza a Label do cronômetro
func update_cronometro():
	total_milliseconds = int(elapsed_time * 1000)  # Tempo em milissegundos
	@warning_ignore("integer_division")
	var minutes = total_milliseconds / 60000
	@warning_ignore("integer_division")
	var seconds = (total_milliseconds / 1000) % 60
	var milliseconds = total_milliseconds % 1000
	cronometro.text = "%02d:%02d:%03d" % [int(minutes), int(seconds), int(milliseconds)]

# Função para verificar se ainda há inimigos no grupo "enemies"
func are_enemies_alive() -> bool:
	var enemies = get_tree().get_nodes_in_group("enemies")
	return enemies.size() > 0

func _emit_signal():
	Global.emit_signal("animation_signal")
	play = true

func flash_red():
	var tween = create_tween()
	dano.modulate = Color(1, 0.5, 0.5, 0)
	tween.tween_property(dano, "modulate", Color(1, 0.5, 0.5, 0.5), 0.05)
	tween.tween_property(dano, "modulate", Color(1, 1, 1, 0), 0.2)

func game_over():
	self.set_visible(false)
	Global.time = total_milliseconds

func Win():
	var win_scene = preload("res://cenas/win.tscn").instantiate()
	win_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	Global.start = false
	get_node("/root/Game/Hud/hud").game_over()
	# Adiciona diretamente ao root (interface global)
	get_node("/root/Game/Camera2D").add_child(win_scene)
	# Pausa o jogo
	get_tree().paused = true
