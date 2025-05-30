extends Node2D #Handgun.gd

@onready var animation_player = $AnimationPlayer
@onready var gui = get_node("/root/Game/Hud/hud")  # Referência ao HUD

@onready var shoot_sound = $ShootSound # Substitua pelo caminho correto do nó
@onready var reload_sound = $ReloadSound

var is_reloading = false  # Flag para verificar se o jogador está recarregando

@onready var storage_bullet = get_node("../StorageBullet")  # Referência ao StorageBullet
var weapon_name = 1 #"handgun"   Nome da arma atual
var is_shooting = false

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

func _physics_process(_delta):
	gui.update_weapon_ammo(self)
	var ammo_data = storage_bullet.get_ammo(weapon_name)
	
	# Se a munição acabar, inicia a recarga
	if Input.is_action_just_pressed("shoot") and ammo_data["storage_ammo"] != 0 and ammo_data["current_ammo"] == 0 and not is_reloading:
		start_reload()
	
	# Verifica se o jogador apertou a tecla de recarga
	if Input.is_action_just_pressed("reload") and ammo_data["storage_ammo"] != 0 and not is_reloading and ammo_data["current_ammo"] != ammo_data["max_capacity"]:
		start_reload()
	
	# Detecta o clique do mouse para atirar, mas só se não estiver recarregando
	if Input.is_action_just_pressed("shoot") and animation_player.current_animation != "shot" and not is_reloading and Global.start:
		shoot()

func shoot():
	var ammo_data = storage_bullet.get_ammo(weapon_name)

	if ammo_data["current_ammo"] > 0:
		const bullet_scene = preload("res://cenas/Bullet.tscn")
		var new_bullet = bullet_scene.instantiate()

		# Encontra o jogador (pai) e verifica o ShootPoint
		var player = get_parent()
		if player and player.has_node("ShootPoint"):
			var shoot_point = player.get_node("ShootPoint")

			new_bullet.global_position = shoot_point.global_position
			new_bullet.global_rotation = shoot_point.global_rotation
			new_bullet.direction = Vector2.RIGHT.rotated(shoot_point.global_rotation)

			# Passa o dano da arma para a bala
			var weapon_damage = storage_bullet.get_weapon_damage(weapon_name)
			new_bullet.init(weapon_damage)  # Passa o dano para a bala

			player.get_parent().add_child(new_bullet)

			is_shooting = true
			animation_player.play("shot")

			await animation_player.animation_finished
			is_shooting = false

			shoot_sound.pitch_scale = randf_range(0.9, 1.1) # Som aleatório entre tons similares
			shoot_sound.play()

			# Atualiza a munição após o disparo
			storage_bullet.update_current_ammo(weapon_name, ammo_data["current_ammo"] - 1)
			gui.update_weapon_ammo(self)  # Atualiza o HUD

func start_reload():
	if not is_reloading:
		reload_sound.play()
		is_reloading = true
		animation_player.play("reload")

func stop_reload():
	await animation_player.animation_finished
	storage_bullet.reload_weapon(weapon_name)
	gui.update_weapon_ammo(self)
	is_reloading = false
