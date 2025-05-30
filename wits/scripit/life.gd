extends Area2D

@export var life_amount = 0
var collected = false  # <- trava

func _on_body_entered(body):
	if collected:
		return  # Já foi pega, ignora
	if body.is_in_group("player"):
		body.pick_up_life(self)
		queue_free()
