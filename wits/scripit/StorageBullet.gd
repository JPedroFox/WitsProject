extends Node2D

# Dicionário para armazenar os dados de munição e dano de cada arma
var ammo_data = {
	1: {"current_ammo": 10, "storage_ammo": 50, "max_capacity": 10, "damage": 25},  # Handgun
	2: {"current_ammo": 6, "storage_ammo": 24, "max_capacity": 6, "damage": 20},   # Shotgun
	3: {"current_ammo": 30, "storage_ammo": 90, "max_capacity": 30, "damage": 20}  # Rifle
}

# Obtém os dados de munição de uma arma
func get_ammo(weapon_name: int) -> Dictionary:
	if ammo_data.has(weapon_name):
		return ammo_data[weapon_name]
	else:
		return {"current_ammo": 0, "storage_ammo": 0, "max_capacity": 0, "damage": 0}

# Obtém o dano de uma arma
func get_weapon_damage(weapon_name: int) -> int:
	if ammo_data.has(weapon_name):
		return ammo_data[weapon_name]["damage"]
	else:
		return 0

# Atualiza a munição atual de uma arma
func update_current_ammo(weapon_name: int, ammo: int) -> void:
	if ammo_data.has(weapon_name):
		ammo_data[weapon_name]["current_ammo"] = clamp(ammo, 0, ammo_data[weapon_name]["max_capacity"])

# Atualiza a munição no armazenamento
func update_storage_ammo(weapon_name: int, ammo: int) -> void:
	if ammo_data.has(weapon_name):
		ammo_data[weapon_name]["storage_ammo"] = max(ammo, 0)

# Recarrega a arma, movendo munição do armazenamento para a arma
func reload_weapon(weapon_name: int) -> void:
	if ammo_data.has(weapon_name):
		var weapon = ammo_data[weapon_name]
		var needed_ammo = weapon["max_capacity"] - weapon["current_ammo"]
		var ammo_to_reload = min(needed_ammo, weapon["storage_ammo"])
		weapon["current_ammo"] += ammo_to_reload
		weapon["storage_ammo"] -= ammo_to_reload

# Atualiza as informações de munição de uma arma específica
func update_ammo(weapon_id: int, current_ammo: int, storage_ammo: int):
	if ammo_data.has(weapon_id):
		ammo_data[weapon_id]["current_ammo"] = current_ammo
		ammo_data[weapon_id]["storage_ammo"] = storage_ammo
	else:
		print("Arma não encontrada no armazenamento.")

func add_ammo(weapon_id, ammo_quantity):
	ammo_data[weapon_id]["storage_ammo"] += ammo_quantity
