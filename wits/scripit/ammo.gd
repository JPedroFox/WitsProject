extends Area2D

@export var ammo_amount = 0
@export var weapon_id = 0# 1 = Handgun, 2 = Shotgun, 3 = Rifle
var collected = false  # <- trava

func _on_body_entered(body):
	if collected:
		return  # Já foi pega, ignora
	if body.is_in_group("player"):
		body.pick_up_ammo(self)
		queue_free()
