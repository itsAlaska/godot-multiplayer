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

func join_game(address):
	# For when a player is connecting to a hosted game, so this is the client
	# player, not the host player
	var peer = ENetMultiplayerPeer.new()
	# Creates the client version of the game being host at this address/port. 
	# And as in the function, if an error is thrown it will return an error,
	# stored in this variable
	var error = peer.create_client(address, PORT)
	if error:
		return error
		
	# Also like above, sets this multiplayer_peer to be the current player, 
	# the player client joining a hosted game
	multiplayer.multiplayer_peer = peer
	
	
# This function is intended to be called when a player connects to the server 
# that isn't currently connected 
func _on_player_connected(id):
	# id = the id of the person that has just connected. player_info is the info
	# from another player already connected to the server, NOT the newly connected
	# player
	_register_player.rpc_id(id, player_info)
	
# This is a function intended to be called when a new player connects to the 
# server, that updates everyone's 'players' dictionary with that data.
# RPC = Remote Procedure Call. any_peer = any player can call it. reliable = 
# if a sent message fails it will continue to attempt to send it
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	# stores the ID of the player that sent this RPC
	var new_player_id = multiplayer.get_remote_sender_id()
	# Stores the player_info to the key, who's index is chosen by the above variable
	players[new_player_id] = new_player_info
	# Sends out the signal with this players ID and info to every client that 
	# is listening for it
	player_connected.emit(new_player_id, new_player_info)
	
func _on_player_disconnected(id):
	# Removes any stored data about this player (id)
	players.erase(id)
	# Triggers the signal that informs all peers connected to this signal about
	# the event and passes on the players id that disconnected
	player_disconnected.emit(id)
	
func _on_connected_to_server():
	# Sets a unique id to the player that has connected to the server, when they
	# connect
	var peer_id = multiplayer.get_unique_id()
	# Adds this player to the 'players' dictionary by their unique ID and 
	# attachs the data in player_info to it
	players[peer_id] = player_info
	# Triggers this signal for any other clients that are supposed to be hearing 
	# it, and passes on the id and player_info of the just connected player to
	# them
	player_connected.emit(peer_id, player_info)
	
func _on_connection_failed():
	# Makes sure to remove any data that was put in here during an unsuccessful
	# connection attempt so that it is empty for the next attempt
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	# Similar to above, removes the data stored in multiplayer_peer
	multiplayer.multiplayer_peer = null
	# Clears all data held in the 'players' dictionary
	players.clear()
	# Lets all the connected clients know that the server has disconnected
	server_disconnected.emit()
