extends CharacterBody2D  # Enemy.gd

# Força do empurrão
@export var knockback_strength : float = 1000
# Tempo para aplicar o empurrão
@export var knockback_duration : float = 0.5  # Tempo em segundos para o empurrão durar

# Variáveis internas para controle do empurrão
var knockback_velocity : Vector2 = Vector2()  # A direção e força do empurrão
var knockback_timer : float = 0  # Timer para suavizar o empurrão

# Sinal para informar à IA que deve ativar o estado ENGAGE
signal engage_triggered
signal dead_true

# Referência ao nó de Health e Position2D
@onready var health = $HealthEnemy
@onready var damage_area = $DamageArea  # Referência à área de dano
@onready var damage_timer = $DamageTimer  # Timer para dano periódico
@onready var player = get_tree().get_first_node_in_group("player")

var player_in_area = false  # Flag para verificar se o jogador está na área

@export var minimap_icon: String = "mob"  # "mob" é a chave no dicionário `icons` do Minimap

@onready var ammo_scene = preload("res://cenas/Ammo.tscn")
@onready var life_scene = preload("res://cenas/life.tscn")

var difficulty: String # "easy", "medium", "hard"

var max_Life := {
	"easy": 40,
	"medium": 20,
	"hard": 12.5
}

var max_drop := {
	"easy": 0.7,
	"medium": 0.5,
	"hard": 0.3
}

var max_damage := {
	"easy": 20,
	"medium": 20,
	"hard": 25
}

func _ready():
	Global.get_difficulty(self)
	add_to_group("enemies")

# Função chamada quando o inimigo recebe dano
func handle_hit(damage: int):
	flash_red()
	emit_signal("engage_triggered")
	if health:
		health.set_health(health.health - damage)
		if health.health <= 0 and !health.dead:
			health.dead = true
			emit_signal("dead_true", self)
			var drop_chance = max_drop.get(difficulty, 0)
			if ammo_scene and randf() <= drop_chance:
				if randf() >= min(0.5, drop_chance):
					var ammo_instance = ammo_scene.instantiate()
					ammo_instance.global_position = global_position
					call_deferred("_drop_ammo", ammo_instance)
				else:
					var life_instance = life_scene.instantiate()
					life_instance.global_position = global_position
					call_deferred("_drop_life", life_instance)
			Global.kills += 1
			call_deferred("queue_free")

# Função separada para adicionar a munição sem quebrar o motor
func _drop_ammo(ammo_instance):
	# Escolhe arma aleatória (1, 2 ou 3)
	var weapon_id = randi_range(1, 3)
	ammo_instance.weapon_id = weapon_id

	# Quantidade aleatória baseada na arma
	match weapon_id:
		1: ammo_instance.ammo_amount = randi_range(10, 15)  # Handgun
		2: ammo_instance.ammo_amount = randi_range(6, 12)   # Shotgun
		3: ammo_instance.ammo_amount = randi_range(30, 60) # Rifle

	# Definindo a posição global da munição
	ammo_instance.global_position = global_position
	
	# Adiciona o item de munição na cena do inimigo (sem duplicar)
	get_parent().add_child(ammo_instance)  # Só adiciona uma vez!

func _drop_life(life_instance):
	life_instance.life_amount = max_Life.get(difficulty, 0)
	# Definindo a posição global da life
	life_instance.global_position = global_position
	
	# Adiciona o item de life na cena do inimigo (sem duplicar)
	get_parent().add_child(life_instance)  # Só adiciona uma vez!

func flash_red():
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

# Função para corrigir a rotação da barra de saúde
func _physics_process(delta):
	if health:
		health.rotation = -rotation  # Inverte a rotação da barra de saúde
	
	if knockback_timer > 0:  # Aplica a força de empurrão suavemente ao jogador, diminuindo o tempo do timer
		if player:
			# Move o jogador suavemente de acordo com o tempo
			player.global_position += knockback_velocity * delta
			self.global_position -= (knockback_velocity/2) * delta
			# Reduz a força do empurrão ao longo do tempo para suavizar
			knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 1 - (knockback_timer / knockback_duration))
			# Reduz o timer
			knockback_timer -= delta

# Detecta o jogador entrando na área de dano
func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("Attack")
		player_in_area = true
		damage_timer.start()  # Inicia o timer para causar dano repetido

# Detecta o jogador saindo da área de dano
func _on_damage_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		damage_timer.stop()  # Para o timer de dano

# Aplica dano ao jogador a cada vez que o timer expira
func _on_damage_timer_timeout():
	if player_in_area:
		apply_damage_to_player()

# Função chamada quando o inimigo aplica dano ao jogador
func apply_damage_to_player():
	if player and player.has_method("handle_hit"):
		# Aplica dano ao jogador
		player.handle_hit(max_damage.get(difficulty, 0))

		# Calcular a direção do empurrão (direção oposta ao inimigo)
		var direction_to_enemy = player.global_position - global_position  # Direção do inimigo para o jogador
		direction_to_enemy = direction_to_enemy.normalized()  # Normaliza a direção para garantir uma direção constante
		
		# Aplica o empurrão ao jogador
		knockback_velocity = direction_to_enemy * knockback_strength  # Define a força do empurrão
		knockback_timer = knockback_duration  # Reseta o tempo de empurrão para começar a aplicar
