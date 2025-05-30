extends Node2D #Shotgun.gd

@onready var animation_player = $AnimationPlayer
@onready var gui = get_node("/root/Game/Hud/hud")  # Referência ao HUD

var is_reloading = false  # Flag para verificar se o jogador está recarregando

@export var num_bullets = 7  # Número de balas adicionais (além da principal)
@export var angle_variation = 20  # Variação máxima do ângulo em graus para cada bala
@export var bullet_max_range = 300  # Controle do alcance máximo da bala

@onready var storage_bullet = get_node("../StorageBullet")  # Referência ao StorageBullet
var weapon_name = 2  # Nome da arma atual
var is_shooting = false
@onready var shoot_sound = $ShootSound # Substitua pelo caminho correto do nó
@onready var reload_sound = $ReloadSound

var current_ammo: int # Quantidade inicial de munição
var max_capacity: int  # Capacidade máxima de munição

# Função para setar a munição da arma
func set_ammo(amount: int):
	var ammo_data = storage_bullet.get_ammo(weapon_name)
	current_ammo = ammo_data["current_ammo"]
	max_capacity = ammo_data["max_capacity"]
	current_ammo = clamp(amount, 0, max_capacity)  # Limita a munição entre 0 e a capacidade máxima

func _ready():
	gui.update_weapon_ammo(self)
	randomize()

func _physics_process(_delta):
	# Detecta o clique do mouse para atirar, mas só se não estiver recarregando
	if Input.is_action_just_pressed("shoot") and animation_player.current_animation != "shot" and not is_reloading and Global.start:
		shoot()
	
	var ammo_data = storage_bullet.get_ammo(weapon_name)
	
	# Se a munição acabar, inicia a recarga
	if Input.is_action_just_pressed("shoot") and ammo_data["storage_ammo"] != 0 and ammo_data["current_ammo"] == 0 and not is_reloading:
		start_reload()
	
	# Verifica se o jogador apertou a tecla de recarga
	if Input.is_action_just_pressed("reload") and ammo_data["storage_ammo"] != 0 and not is_reloading and ammo_data["current_ammo"] != ammo_data["max_capacity"]:
		start_reload()
	
func shoot():
	var ammo_data = storage_bullet.get_ammo(weapon_name)
	if ammo_data["current_ammo"] != 0:
		const bullet_scene = preload("res://cenas/Bullet.tscn")  # Referência para a cena da bala
		
		# Encontra o jogador (pai) e verifica o ShootPoint
		var player = get_parent()
		
		if player and player.has_node("ShootPoint"):
			var shoot_point = player.get_node("ShootPoint")
			for i in range(num_bullets):
				var new_bullet = bullet_scene.instantiate()  # Instancia a cena da bala
				
				# Define a posição e rotação inicial da bala
				new_bullet.global_position = shoot_point.global_position

				# Calcula uma rotação aleatória dentro do intervalo de variação
				var random_angle = randf_range(-angle_variation, angle_variation)
				var bullet_rotation = shoot_point.global_rotation + deg_to_rad(random_angle)
				new_bullet.global_rotation = bullet_rotation

				# Ajusta a direção da bala com base na rotação calculada
				new_bullet.direction = Vector2.RIGHT.rotated(bullet_rotation)

				# Define o alcance máximo diretamente na bala
				new_bullet.max_range = bullet_max_range

				# Passa o dano da arma para a bala
				var weapon_damage = storage_bullet.get_weapon_damage(weapon_name)
				new_bullet.init(weapon_damage)  # Passa o dano para a bala

				# Adiciona a bala como filho na cena
				player.get_parent().add_child(new_bullet)
		
		# Toca a animação de tiro
		is_shooting = true
		animation_player.play("shot")
		
		await animation_player.animation_finished
		is_shooting = false

		shoot_sound.pitch_scale = randf_range(0.9, 1.1) # Som aleatório entre tons similares
		shoot_sound.play()
		
		storage_bullet.update_current_ammo(weapon_name, ammo_data["current_ammo"] - 1)
		gui.update_weapon_ammo(self)  # Atualiza o HUD

func start_reload():
	if not is_reloading:
		reload_sound.play()
		animation_player.play("reload")
		is_reloading = true

func stop_reload():
	await animation_player.animation_finished
	storage_bullet.reload_weapon(weapon_name)
	gui.update_weapon_ammo(self)
	is_reloading = false
