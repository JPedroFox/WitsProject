extends Node2D

@export var health: int = 100
@export var max_health: int = 100  # Adiciona uma variável para o valor máximo de saúde

func set_health(new_health: int):
	health = clamp(new_health, 0, max_health)  # Agora o valor máximo é a variável max_health
