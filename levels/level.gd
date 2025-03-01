extends Node2D


@export var player_scene: PackedScene
@export var players_container: Node2D
@export var spawn_points: Array[Node2D]

var next_spawn_point_index = 0


func _ready():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_disconnected.connect(delete_player)
	
	# The line below apparently helps with late joiners. It is not relevant for
	# this lecture project, but still seemed useful to know about.
	# multiplayer.peer_connected.connect(add_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	# Host always has id of 1
	add_player(1)
	
func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_disconnected.disconnect(delete_player)

func add_player(id):
	var player_instance = player_scene.instantiate()
	player_instance.position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

func delete_player(id):
	if not players_container.has_node(str(id)):
		return
		
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].position
	next_spawn_point_index += 1
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	return spawn_point
