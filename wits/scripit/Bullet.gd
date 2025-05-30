extends Area2D

@export var speed = 4000  # Velocidade da bala
var direction = Vector2(1, 0)  # Direção da bala
@export var max_range = 1500  # Distância máxima que a bala pode percorrer
var travelled_distance = 0  # Distância percorrida

var weapon_damage: int  # Armazena o dano da arma que disparou a bala

# A cada frame, move a bala e verifica a distância percorrida
func _physics_process(delta):
	position += direction * speed * delta  # Move a bala na direção definida
	
	travelled_distance += speed * delta
	if travelled_distance > max_range:  # Se a bala percorrer a distância máxima
		queue_free()  # Destrói a bala

# Função chamada quando a bala é instanciada
func init(damage) -> void:
	weapon_damage = damage  # Configura o dano da arma

# Detecta colisão com o inimigo
func _on_body_entered(body):
	if body.has_method("handle_hit") and body.is_in_group("enemies"):
		body.handle_hit(weapon_damage)  # Passa o dano para o inimigo
	if !body.is_in_group("player"):
		queue_free()  # Destrói a bala após a colisão
