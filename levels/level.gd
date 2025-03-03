extends Node2D


@export var player_spawner: MultiplayerSpawner
@export var players_container: Node2D
@export var player_scenes: Array[PackedScene]
@export var spawn_points: Array[Node2D]

var next_spawn_point_index = 0
var next_character_index = 0


func _ready() -> void:
	# Checks to make sure that only the server host runs the code that follows
	if not multiplayer.is_server():
		return
		
	# In the event of a person disconnecting from the server, run the MultiplayerAPI
	# function that is called and also run the delete_player function
	multiplayer.peer_disconnected.connect(delete_player)
	
	# ----- NOT RELEVANT FOR THIS PROJECT -----
	# Connects the add_player function to the peer_connected event so that if
	# someone joins late, when this event is called, it will run add_player
	# for them
	#multiplayer.peer_connected.connect(add_player)
	# -----------------------------------------
		
	# Iterates through all the players retrieved by the get_peers function and 
	# uses their id to run the add_player function. This does not include the host
	for id in multiplayer.get_peers():
		add_player(id)
	
	# Manually run add_player on the host, which always has the id of 1
	add_player(1)
	
func _enter_tree() -> void:
	# Sets the method to be used each time a player is spawned
	player_spawner.spawn_function = spawn_player
	
# Built-in function called when this node is removed from the tree
func _exit_tree() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	# Checks that the player is the host and ends the function if they are not
	if not multiplayer.is_server():
		return
	
	# Removes the delete_player function as a callback from the peer_disconnected
	# method
	multiplayer.peer_disconnected.disconnect(delete_player)

func add_player(id):
	# Uses the PlayerSpawner spawn function to create the new player
	player_spawner.spawn(id)

func spawn_player(id):
	# Instantiates a new player scene
	var player_instance = player_scenes[next_character_index].instantiate()
	next_character_index += 1
	if next_character_index >= len(player_scenes):
		next_character_index = 0
	# Set the position of the spawned in player
	player_instance.position = get_spawn_point()
	# Changes the name of the player_instance node in the explorer
	player_instance.name = str(id)
	# Returns the created instance of the player
	return player_instance
# Called when a player leaves the game to clean up any data associated with them

func delete_player(id):
	# Checks for the id of the player that is needing to be deleted, ends the 
	# function if they are not found
	if not players_container.has_node(str(id)):
		return
		
	# Retrieves the specific player from the players_container so that their 
	# data can be removed completely
	players_container.get_node(str(id)).queue_free()
	
func get_spawn_point():
	# Take the position property of the spawn point node at the current index,
	# which the value is stored in the variable next_spawn_point_index
	var spawn_point = spawn_points[next_spawn_point_index].position
	# Increment the value of the next_spawn_point_index
	next_spawn_point_index += 1
	# Compare the value of that variable with what would be its index location in the
	# array, and if it does not exist, set it's value back to 0
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	
	return spawn_point


	
