extends Node

@export var min_time: float = 0.1
@export var max_time: float = 1.5
@export var efeito_ativo: bool = true  # Permite ativar/desativar no editor

func _ready():
	randomize()
	if efeito_ativo:
		for luz in get_children():
			_toggle_luz(luz)

func _toggle_luz(luz):
	if efeito_ativo:
		luz.visible = !luz.visible
		await get_tree().create_timer(randf_range(min_time, max_time)).timeout
		_toggle_luz(luz)
