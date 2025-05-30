extends Node2D

@export var health: int = 100
@onready var dead = false
@onready var progress_bar = $ProgressHealth  # Confirme o caminho

func _ready():
	update_health_bar()  # Atualiza a barra ao iniciar
	progress_bar.max_value = health

func set_health(new_health: int):
	health = clamp(new_health, 0, health)
	update_health_bar()  # Atualiza a barra sempre que a saúde mudar

func update_health_bar():
	if progress_bar:
		progress_bar.value = health
