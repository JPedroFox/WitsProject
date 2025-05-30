extends Node2D

signal wave_spawned

@export var zombie_scene = preload("res://cenas/Enemy.tscn")
var difficulty: String # "easy", "medium", "hard"

@onready var zones = [$Zone1, $Zone2, $Zone3]
@onready var blocks = [$Block1, $Block2]
@onready var ocluzion = [get_node("/root/Game/visibilityMask/block1"), get_node("/root/Game/visibilityMask/block2")]
var current_zone_index := 0
var spawn_area : Area2D

var max_enemies := {
	"easy": 15,
	"medium": 25,
	"hard": 45
}

var current_enemies = []

func _ready():
	Global.get_difficulty(self)
	spawn_area = zones[current_zone_index]
	spawn_wave()

func _process(_delta):
	# Remove zumbis mortos da lista
	current_enemies = current_enemies.filter(func(z): return z and z.is_inside_tree())

	# Se não tem mais zumbis vivos, muda de zona (se possível)
	if current_enemies.size() == 0 and current_zone_index < zones.size() - 1:
		current_zone_index += 1
		spawn_area = zones[current_zone_index]
		spawn_wave()

func spawn_wave():
	var enemy_count = max_enemies.get(difficulty, 0)
	for i in range(enemy_count*((current_zone_index+2)*0.5)):
		spawn_zombie()
	emit_signal("wave_spawned")

func get_random_point_in_area() -> Vector2:
	var polygon = spawn_area.get_node("CollisionPolygon2D").polygon
	var tries = 30
	for i in range(tries):
		var min_x = polygon[0].x
		var max_x = polygon[0].x
		var min_y = polygon[0].y
		var max_y = polygon[0].y

		for point in polygon:
			min_x = min(min_x, point.x)
			max_x = max(max_x, point.x)
			min_y = min(min_y, point.y)
			max_y = max(max_y, point.y)

		var rand_x = randf_range(min_x, max_x)
		var rand_y = randf_range(min_y, max_y)
		var test_point = Vector2(rand_x, rand_y)

		if Geometry2D.is_point_in_polygon(test_point, polygon):
			return spawn_area.global_position + test_point

	return spawn_area.global_position

func spawn_zombie():
	var spawn_pos = get_random_point_in_area()
	var zombie = zombie_scene.instantiate()
	zombie.global_position = spawn_pos
	call_deferred("add_child", zombie)
	zombie.get_node("IA_Zombi").call_deferred("setup", zombie)
	
	# Conecta o sinal "dead_true"
	zombie.connect("dead_true", Callable(self, "_on_zombie_dead"))
	
	current_enemies.append(zombie)

func _on_zombie_dead(zombie):
	current_enemies.erase(zombie)

	if current_enemies.is_empty() and current_zone_index < zones.size() - 1:
		blocks[current_zone_index].queue_free()
		ocluzion[current_zone_index].queue_free()
		current_zone_index += 1
		
		spawn_area = zones[current_zone_index]
		spawn_wave()
