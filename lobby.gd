extends Node


signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const MAX_CONNECTIONS = 2

var players = {}

var player_info = {"name": "Name"}


func _ready() -> void:
	# This has the player connect to the event that was emitted below. When the
	# built in multiplayer notices someone connects to the server, it will 
	# perform this command
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game():
	# This represents the player that is hosting.
	var peer = ENetMultiplayerPeer.new()
	# This creates the server, and if an error is thrown, it will return the 
	# contents of that error, maybe to be displayed in main menu
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	# Store the host player into this variable, required for server to stay 
	# running
	multiplayer.multiplayer_peer = peer
	
	# Stores the hosts data, must be done manually because the script will not 
	# run before the host starts it
	players[1] = player_info
	# Fires the signal to anyone connected to this server that this player has 
	# connected.
	player_connected.emit(1, player_info)

func _on_player_connected(id):
	pass

func _on_player_disconnected(id):
	pass
	
func _on_connected_to_server():
	pass

func _on_connection_failed():
	pass
	
func _on_server_disconnected():
	pass
