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

func join_game(address):
	# This represents a player that is joining a hosted game.
	var peer = ENetMultiplayerPeer.new()
	# Like above, will return an error message if there was an error
	var error = peer.create_client(address, PORT)
	if error:
		return error
	# Store the player if everything was successful
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	# id is the id of the person that is the recipient of the data (the person
	# that just connected) and then the connected person receives the info
	# in the second argument
	_register_player.rpc_id(id, player_info)
	
# any_peer means every player, not just the host, can run this function. 
# Reliable means that it will continue to attempt sending the information
# packets until it is confirmed to be sent through.
# RPC = Remote Procedure Calls
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	# This will store the ID of the player that sent this rpc. This function is
	# being run on every other player's client, not the person who triggered
	# the function.
	var new_player_id = multiplayer.get_remote_sender_id()
	# Updates this players data, ie. their info
	players[new_player_id] = new_player_info
	# This player signals to everyone their id and info 
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	# Removes the player from the Players list
	players.erase(id)
	# Emits the signal to all other players to update that this player has left
	player_disconnected.emit(id)
	
func _on_connected_to_server():
	# Every player gets a unique ID when they connect to the server
	var peer_id = multiplayer.get_unique_id()
	# Will take whatever is in the player_info variable and store it with the
	# player's ID in the players dictionary
	players[peer_id] = player_info
	# Updates all players that this player has connected and shared their ID and
	# info with them.
	player_connected.emit(peer_id, player_info)

func _on_connection_failed():
	# Simply sets the player object to null in case there was an issue 
	# connecting. Keeps it clear for the following attempts.
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	# Similar to above, except it is when you are already connected to the 
	# server and then disconnect.
	multiplayer.multiplayer_peer = null
	# Clears the players dictionary so that it will be blank for future connects
	players.clear()
	# Updates all the other players that this player has disconnected.
	server_disconnected.emit()
