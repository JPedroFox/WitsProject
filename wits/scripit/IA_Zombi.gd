extends Node2D #IA_zombi.gd

enum State {
	FREEZ,
	PATROL,
	ENGAGE
}

@export var patrol_speed = 80  # Velocidade do patrulhamento
@export var patrol_area_range = 200  # Distância de patrulha ao redor do inimigo
@export var num_patrol_points = 5  # Quantidade de pontos de patrulha a serem gerados

@onready var range_detection = $RangeDetection
@onready var enemy = get_parent()  # Referência ao inimigo (que é o pai deste nó)
@onready var Freez_Timer = $FreezTimer  # Referência ao timer de pausa entre patrulhas
@onready var Engage_Timer = $EngageTimer  # Referência ao timer de pausa entre patrulhas
@onready var Patrol_Timer = $PatrolTimer# Referência ao timer de pausa entre patrulhas
@export var speed = 200  # Velocidade do inimigo

@onready var animation = $"../AnimationPlayer"

var patrol_points = []  # Lista de pontos de patrulha
var current_state = State.PATROL
var player = null
var current_patrol_index = 0  # Índice do ponto de patrulha atual
var move = true
var dead = false

func setup(enemy_node):
	if not is_inside_tree():
		await ready  # Espera o nó entrar na árvore
	enemy = enemy_node
	player = get_tree().root.get_node("/root/Game/visibility/Player")
	enemy.connect("engage_triggered", Callable(self, "_on_engage_triggered"))
	enemy.connect("dead_true", Callable(self, "_dead_true"))
	Global.connect("animation_signal", Callable(self, "_on_animation_signal"))
	generate_patrol_points(num_patrol_points, patrol_area_range)
	set_state(State.PATROL)


# Função para o estado de patrulha
func _physics_process(delta):
	player = get_tree().root.get_node("/root/Game/visibility/Player")
	
	if not player or dead:
		return
	
	match current_state:
		State.PATROL:
			_move_towards_patrol_point(delta)  # Move o inimigo para o próximo ponto de patrulha
			
		State.ENGAGE:
			if player != null:
				_move_towards_player(player.global_position)  # segue o player
			else:
				print("ERRO: Jogador não encontrado!")
		State.FREEZ:
			pass  # Não faz nada (ficar parado)
	if current_state == State.PATROL and !move:
		set_state(State.FREEZ)

func set_state(new_state: State):  # Defina o tipo de new_state como State
	if new_state == current_state:
		return
	
	if new_state == State.PATROL:
		# Inicia a patrulha após o timer de FREEZ
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()  # Próximo ponto de patrulha
		Freez_Timer.stop()  # Garante que o timer está parado quando no estado PATROL
		Patrol_Timer.start()
		animation.stop()
		animation.speed_scale = 1
		animation.play("Move")
	elif new_state == State.ENGAGE:
		# Lógica para o estado de ENGAGE (movimento em direção ao jogador)
		Freez_Timer.stop()  # Garante que o timer está parado quando no estado ENGAGE
		animation.stop()
		animation.speed_scale = 2
		animation.play("Move")
	elif new_state == State.FREEZ :
		# O inimigo fica parado durante o tempo do timer
		Patrol_Timer.stop()
		animation.stop()
		animation.speed_scale = 1
		animation.play("Idle")
		wait()  # Chama a função de espera ao entrar no estado FREEZ

	current_state = new_state

# Função para gerar pontos aleatórios dentro de uma área
func generate_patrol_points(count: int, range_max: int):
	patrol_points.clear()  # Limpa os pontos de patrulha anteriores
	for i in range(count):
		var random_point = global_position + Vector2(randi_range(-range_max, range_max)+50, randi_range(-range_max, range_max)+50)
		patrol_points.append(random_point)

# Função para mover o inimigo para o próximo ponto de patrulha
func _move_towards_patrol_point(_delta):
	if patrol_points.size() == 0:
		return  # Evita movimento se não houver pontos de patrulha
	
	var target_point = patrol_points[current_patrol_index]  # Ponto de patrulha atual
	var direction = (target_point - enemy.global_position).normalized()  # Direção até o ponto
	
	# Calcula o ângulo entre a posição atual e o ponto de patrulha
	var target_angle = direction.angle()
	
	# Suaviza a rotação com lerp_angle, para garantir uma rotação mais fluida
	var current_angle = enemy.rotation
	var new_angle = lerp_angle(current_angle, target_angle, 0.01)  # 0.1 controla a suavização da rotação
	enemy.rotation = new_angle  # Aplica a rotação suavizada
	
	# Movimento contínuo
	if Global.start:
		enemy.velocity = direction * patrol_speed
		enemy.move_and_slide()
	
	# Se o inimigo chegar perto do ponto de patrulha, entra no estado FREEZ e inicia o timer
	if enemy.global_position.distance_to(target_point) < 5 or Patrol_Timer.get_time_left() == 0:
		set_state(State.FREEZ)  # Muda para FREEZ ao chegar no ponto

# Função para movimentar o inimigo em direção ao jogador
func _move_towards_player(player_position):
	if player:
		# Calcula a direção para o player
		var target_rotation = enemy.global_position.direction_to(player_position).angle()
		
		# Suaviza a rotação com Lerp (interpola entre o ângulo atual e o alvo)
		enemy.rotation = lerp_angle(enemy.rotation, target_rotation, 0.05)  # 0.1 é a suavidade (ajuste conforme necessário)
		
		# Calcula a direção do movimento com base na rotação suavizada
		var movement_direction = Vector2(1, 0).rotated(enemy.rotation)
		
		# Aplica o movimento suave, ajustando a velocidade com base na desaceleração
		enemy.velocity = movement_direction * speed
	
		# Move o inimigo com a velocidade ajustada
		if Global.start:
			enemy.move_and_slide()

# Função que faz o inimigo esperar no ponto de patrulha
func wait():
	Freez_Timer.start()  # Inicia o timer de freez

# Função para manipular o timer do freez
func _on_freez_timer_timeout():
	set_state(State.PATROL)  # Após o tempo de congelamento, volta ao estado PATROL

# Detecção do jogador entrando na área de alcance
func _on_range_detection_body_entered(body):
	if body.is_in_group("player"):
		set_state(State.ENGAGE)  # Muda para o estado ENGAGE quando o jogador entra no alcance
		player = body
		Engage_Timer.stop()

# Detecção do jogador saindo da área de alcance
func _on_range_detection_body_exited(body):
	if !dead:
		if player and body == player: 
			Engage_Timer.start()

func _on_engage_timer_timeout():
	set_state(State.FREEZ)
	
# Função que ativa o estado ENGAGE
func _on_engage_triggered():
	if _on_range_detection_body_entered(player):
		set_state(State.ENGAGE)
		Engage_Timer.start()

func _on_animation_signal():
	move = true

@warning_ignore("unused_parameter")
func _dead_true(emiter):
	dead = true
