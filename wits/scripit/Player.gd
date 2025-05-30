class_name Player
extends CharacterBody2D

signal player_health_changed

@export var speed : float = 2  # Velocidade normal
@export var sprint_speed : float = 3  # Velocidade de corrida
@export var camera_smooth_speed = 10  # Ajuste da suavidade da câmera
@export var Linked_position_node: Node2D
@export var MouseTracker: Node2D

@onready var player = self  # Referência ao jogador
@onready var gui = get_node("/root/Game/Hud/hud")
@onready var shotgun = preload("res://cenas/Shotgun.tscn")
@onready var handgun = preload("res://cenas/Handgun.tscn")
@onready var rifle = preload("res://cenas/Rifle.tscn")
@onready var camera = get_node("/root/Game/Camera2D")
@onready var health_node = $Health  # Referência ao nó de saúde do jogador
@onready var shoot_point = $ShootPoint  # Referência ao nó de disparo no jogador
@onready var storage_bullet = $StorageBullet

# Constante para suavidade da rotação
const ROTATION_LERP_SPEED = 15.0

var current_weapon = 1  # Mantém o controle da arma atual
var weapon  # Arma atual do jogador
var use_mouse = true  # Inicialmente o mouse é usado
var last_aim_position = Vector2.ZERO  # Para armazenar a última posição do controle/direcional
var last_mouse_position = Vector2.ZERO  # Para detectar movimento do mouse
var mouse_threshold = 100  # Distância mínima para considerar que o mouse se moveu

func _ready():
	change_weapon(current_weapon)
	
	gui.set_player(player)
	print("ShootPoint encontrado no jogador:", shoot_point)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Troca de armas com atalhos do teclado
	if Input.is_action_just_pressed("armar1") and current_weapon != 1:
		change_weapon(1)
	if Input.is_action_just_pressed("armar2") and current_weapon != 2:
		change_weapon(2)
	if Input.is_action_just_pressed("armar3") and current_weapon != 3:
		change_weapon(3)
	if Input.is_action_just_pressed("ui_change_weapon_up"):
		switch_weapon(1)
	if Input.is_action_just_pressed("ui_change_weapon_down"):
		switch_weapon(-1)
	
	if Linked_position_node != null:
		Linked_position_node.position = self.position
		Linked_position_node.rotation_degrees = self.rotation_degrees
		
	# Calcula a direção do movimento detectando as teclas
	if Global.start:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		# Verifica se o jogador está pressionando a tecla de correr (Shift)
		var current_speed = speed * 100
		if Input.is_action_pressed("ui_shift"):
			current_speed = sprint_speed * 100
		# Aplica a movimentação normalizada e a velocidade
		velocity = direction.normalized() * current_speed
		move_and_slide()
	
	if weapon and weapon.has_node("AnimationPlayer"):
		var anim_player = weapon.get_node("AnimationPlayer")
		if not weapon.is_shooting and not weapon.is_reloading:
			if velocity.length() > 0:
				if not anim_player.is_playing() or anim_player.current_animation != "Move":
					anim_player.play("Move")
			else:
				if not anim_player.is_playing() or anim_player.current_animation != "Idle":
					anim_player.play("Idle")

	# Lógica de rotação entre mouse e controle
	rotate_player(delta)
	
	# Lerp da posição da câmera (suavização) para seguir o nó vazio
	camera.position = camera.position.lerp(self.position, camera_smooth_speed * delta)

func handle_hit(damage: int):
	if health_node:
		gui.flash_red()
		health_node.set_health(health_node.health - damage)  # Atualiza a saúde
		emit_signal("player_health_changed", health_node.health)
		if health_node.health <= 0:
			# Lógica de Game Over
			print("Game Over!")
			game_over()

func change_weapon(new_weapon_name: int):
	if weapon:
		player.remove_child(weapon)  # Remove a arma anterior
	
	# Atualiza o nome da arma atual
	current_weapon = new_weapon_name
	
	# Instancia e equipa a nova arma
	if new_weapon_name == 1:
		weapon = handgun.instantiate()
	elif new_weapon_name == 2:
		weapon = shotgun.instantiate()
	elif new_weapon_name == 3:
		weapon = rifle.instantiate()
	
	player.add_child(weapon)
	
	# Recupera a munição do armazenamento e aplica à nova arma
	var ammo_data = storage_bullet.get_ammo(current_weapon)
	weapon.set_ammo(ammo_data["current_ammo"])  # Define a munição atual da nova arma

func switch_weapon(direction: int):
	var max_weapons = 3  # Quantidade total de armas disponíveis
	current_weapon += direction
	
	if current_weapon > max_weapons:
		current_weapon = 1  # Volta para a primeira arma
	elif current_weapon < 1:
		current_weapon = max_weapons  # Vai para a última arma
	
	change_weapon(current_weapon)

func rotate_player(delta):
	# Obtém a posição atual do mouse
	var mouse_position = MouseTracker.position
	
	# Verifica o input do controle (direcional direito)
	
	var aim_direction = Vector2(
		Input.get_action_strength("ui_look_right") - Input.get_action_strength("ui_look_left"),
		Input.get_action_strength("ui_look_down") - Input.get_action_strength("ui_look_up")
	)
	
	# Se o direcional do controle estiver sendo pressionado, ativa o controle e desativa o mouse
	if aim_direction.length() > 0.:  # Se o controle foi usado
		use_mouse = false
		Global.control = true
		last_aim_position = global_position + aim_direction.normalized() * 100000
	
	# Se o controle não estiver sendo usado, verifica se o mouse foi movido
	elif not use_mouse:
		# Verifica se o mouse se moveu mais do que o threshold
		if mouse_position.distance_to(last_mouse_position) > mouse_threshold:  # Se a posição do mouse mudou significativamente
			use_mouse = true
			Global.control = false
			last_aim_position = mouse_position
	
	# Atualiza a posição do mouse
	last_mouse_position = mouse_position
	
	# Decide a rotação com base no dispositivo ativo
	var target_angle = (mouse_position - global_position).angle() if use_mouse else (last_aim_position - global_position).angle()
	if use_mouse:
		rotation = target_angle
	else:
		rotation = lerp_angle(rotation, target_angle, ROTATION_LERP_SPEED * delta)

func game_over():
	var game_over_scene = preload("res://cenas/GameOver.tscn").instantiate()
	game_over_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	Global.start = false
	gui.game_over()
	# Adiciona diretamente ao root (interface global)
	camera.add_child(game_over_scene)
	# Pausa o jogo
	get_tree().paused = true

func pick_up_ammo(ammo_instance):
	var ammo_type = ammo_instance.weapon_id  # O tipo da arma (1 = Handgun, 2 = Shotgun, 3 = Rifle)
	var ammo_quantity = ammo_instance.ammo_amount  # A quantidade de munição que o inimigo droppou
	
	# Atualiza a munição do jogador de acordo com o tipo de arma
	match ammo_type:
		1: 
			storage_bullet.add_ammo(1, ammo_quantity)  # Atualiza munição da Handgun
			print("Pegou munição da arma 1! Novo total:", storage_bullet.get_ammo(1)["storage_ammo"])
		2: 
			storage_bullet.add_ammo(2, ammo_quantity)  # Atualiza munição da Shotgun
			print("Pegou munição da arma 2! Novo total:", storage_bullet.get_ammo(2)["storage_ammo"])
		3: 
			storage_bullet.add_ammo(3, ammo_quantity)  # Atualiza munição do Rifle
			print("Pegou munição da arma 3! Novo total:", storage_bullet.get_ammo(3)["storage_ammo"])
	
	# Agora que a munição foi pega, remove o item de munição da cena
	gui.update_weapon_ammo(weapon)
	ammo_instance.queue_free()

func pick_up_life(life_instance):
	var life_quantity = life_instance.life_amount  # A quantidade de vida que o inimigo droppou
	health_node.set_health(health_node.health + life_quantity)
	# Agora que a munição foi pega, remove o item de munição da cena
	emit_signal("player_health_changed", health_node.health)
	life_instance.queue_free()
