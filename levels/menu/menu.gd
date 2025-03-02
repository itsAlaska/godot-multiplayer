extends Node


@export var ui: Control
@export var level_container: Node
@export var level_scene: PackedScene
@export var ip_line_edit: LineEdit
@export var status_label: Label
@export var not_connected_hbox: HBoxContainer
@export var host_hbox: HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connects callbacks to these particular events
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

func _on_host_button_pressed() -> void:
	# Hides the not_connected_hbox so that it can make way for the host_hbox
	not_connected_hbox.hide()
	# Reveals the hosts hbox
	host_hbox.show()
	# Runs the create_game function located in the Lobby script
	Lobby.create_game()
	# Let's the host know that they are indeed hosting
	status_label.text = "Hosting!"

func _on_join_button_pressed() -> void:
	# Hide the not connected hbox for the player that is joining a hosted game
	# as there is nothing else they need to do with the buttons
	not_connected_hbox.hide()
	# Runs the join_game function with the ip address taken from the LineEdit 
	# field in the menu
	Lobby.join_game(ip_line_edit.text)
	# Updates the text field in the status_label to reflect the current status
	status_label.text = "Connecting..."
	
func _on_start_button_pressed() -> void:
	# The .rpc suffix means that it is called on every client. So, this is telling
	# every client to hide the menu scene
	hide_menu.rpc()
	# Uses the change_level function the the call_deferred method added on, this
	# is to ensure that it loads at the correct time
	change_level.call_deferred(level_scene)
	
func change_level(scene):
	# Iterate through all children in the level_container node
	for child in level_container.get_children():
		# Removes the child from the level_container
		level_container.remove_child(child)
		# Deletes the child entirely
		child.queue_free()
	# Creates the level scene that is meant to be the current level and makes 
	# it a child of the level_container
	level_container.add_child(scene.instantiate())
	
func _on_connection_failed():
	# Updates label text to inform user that they were unable to connect
	status_label.text = "Failed to connect..."
	# Reveals the not connected hbox in the event that a connection was not made
	not_connected_hbox.show()
	
func _on_connected_to_server():
	# Updates label text to inform user they have successfully connected
	status_label.text = "Connected!"

# call_local clarifies that this function needs to be called by everyone, 
# including the host. 
# authority asserts that this function can only be run by the host 
@rpc("call_local", "authority", "reliable")
func hide_menu():
	# Simply hides the entire UI so that it does not cover the game screen
	ui.hide()
