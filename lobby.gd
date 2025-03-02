extends Node


signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const 	MAX_CONNECTIONS = 2

var players = {}
var player_info = {"name": "Player Name"}


func _ready() -> void:
	# This adds a callback to the various functions built into the multiplayer API 
	# that fires when one of these functions is used
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game():
	# Represents host player
	var peer = ENetMultiplayerPeer.new()
	# Performs the built in function of creating a server. Typically this will 
	# return nothing, but if there is an error it will return the error
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	# Requirement to set the host to this as the server is created to make sure 
	# that the server stays active
	multiplayer.multiplayer_peer = peer
	
	# The host of the server always has an ID of 1. This sets the player_info of
	# the host in their local version of the players dictionary
	players[1] = player_info
	# Sends this players id and player_info to connected players' "players" 
	# dictionary
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
