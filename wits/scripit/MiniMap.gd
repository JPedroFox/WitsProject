extends MarginContainer
class_name Minimap

@export var player: Player
@export var zoom = 1.5: set = set_zoom

@onready var grid = $MarginContainer/Grid
@onready var player_marker = $MarginContainer/Grid/PlayerM
@onready var mob_marker = $MarginContainer/Grid/EnemyM
@onready var icons = {
	"mob": mob_marker,
}

var grid_scale
var markers = {}

func _ready():
	# Acessa o nó "Game" e o nó "Player"
	var game_node = get_parent().get_parent().get_parent()
	player = game_node.get_node("visibility/Player")
	
	var spawner_path = "/root/Game/visibility/EnemySpawner"
	var spawner = get_tree().root.get_node(spawner_path) if get_tree().root.has_node(spawner_path) else null
	if spawner:
		spawner.connect("wave_spawned", Callable(self, "_on_wave_spawned"))

	await get_tree().process_frame
	player_marker.position = grid.size / 2
	_update_zoom()
	update_minimap_enemies()  # carrega os da primeira zona

func _physics_process(_delta):
	if not player:
		return
	player_marker.rotation = player.rotation + PI / 2
	
	var to_remove = []
	for item in markers:
		if not is_instance_valid(item):
			to_remove.append(item)
			continue
		
		var obj_pos = (item.position - player.position) * grid_scale + grid.size / 2
		if grid.get_rect().has_point(obj_pos + grid.position):
			markers[item].scale = Vector2(0.1, 0.1)
		else:
			markers[item].scale = Vector2(0.075, 0.075)
		obj_pos = obj_pos.clamp(Vector2.ZERO, grid.size)
		markers[item].position = obj_pos
	
	for item in to_remove:
		_on_object_removed(item)

func _on_object_removed(emitter):
	if emitter in markers:
		markers[emitter].queue_free()
		markers.erase(emitter)

# Função que atualiza o zoom e recalcula o grid_scale
func set_zoom(value):
	zoom = clamp(value, 0.5, 5)
	_update_zoom()

func _update_zoom():
	# Recalcula o grid_scale com base no tamanho do grid, do viewport e do zoom atual
	grid_scale = grid.size / (get_viewport_rect().size * zoom)
	print("Novo grid_scale:", grid_scale)

# Captura os inputs globais para atualizar o zoom
func _input(event):
	# Se for um evento de tecla pressionada...
	if event is InputEventKey and event.pressed:
		if Input.is_action_pressed("ui_zoom_in"):
			# Diminuir o zoom (aproximação) – note que zoom menor aproxima
			zoom = clamp(zoom - 0.1, 0.5, 5)
			_update_zoom()
			print("Zoom in: ", zoom)
		elif Input.is_action_pressed("ui_zoom_out"):
			# Aumentar o zoom (afastamento)
			zoom = clamp(zoom + 0.1, 0.5, 5)
			_update_zoom()
			print("Zoom out: ", zoom)

func _on_wave_spawned():
	await get_tree().process_frame
	update_minimap_enemies()

func update_minimap_enemies():
	var map_objects = get_tree().get_nodes_in_group("enemies")
	for item in map_objects:
		if item not in markers:
			var new_marker = icons[item.minimap_icon].duplicate()
			grid.add_child(new_marker)
			new_marker.show()
			markers[item] = new_marker
			item.connect("dead_true", Callable(self, "_on_object_removed"))
