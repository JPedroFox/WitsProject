extends Label

# Current difficulty: can be "easy", "medium", or "hard"
var difficulty := "easy"

func _ready():
	Global.get_difficulty(self)

func get_parameters_by_difficulty():
	match difficulty:
		"easy":
			return {
				"health_recovery": 2,
				"drop_chance": 70,
				"health_drop_chance": 50,
				"enemy_damage": 5,
				"field_of_view": 15,
				"zombie_total": 67
			}
		"medium":
			return {
				"health_recovery": 1,
				"drop_chance": 40,
				"health_drop_chance": 40,
				"enemy_damage": 5,
				"field_of_view": 10,
				"zombie_total": 112
			}
		"hard":
			return {
				"health_recovery": 0.5,
				"drop_chance": 30,
				"health_drop_chance": 30,
				"enemy_damage": 4,
				"field_of_view": 5,
				"zombie_total": 202
			}
	return {}

func update_difficulty_label():
	Global.get_difficulty(self)
	var p = get_parameters_by_difficulty()

	var label_text := """
Difficulty: %s
- Health recovery per drop: %.1f%% hit
- Chance to drop something: %d%%
- Chance it's health instead of ammo: %d%%
- Enemy damage: %d hits until death
- Field of view: %dm
- Total zombies: %d
""" % [
		difficulty.capitalize(),
		p.health_recovery,
		p.drop_chance,
		p.health_drop_chance,
		p.enemy_damage,
		p.field_of_view,
		p.zombie_total
	]

	self.text = label_text.strip_edges()
