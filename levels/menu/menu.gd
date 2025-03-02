extends Control


@export var ip_line_edit: LineEdit
@export var status_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connects callbacks to these particular events
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

func _on_host_button_pressed() -> void:
	# Runs the create_game function located in the Lobby script
	Lobby.create_game()

func _on_join_button_pressed() -> void:
	# Runs the join_game function with the ip address taken from the LineEdit 
	# field in the menu
	Lobby.join_game(ip_line_edit.text)
	# Updates the text field in the status_label to reflect the current status
	status_label.text = "Connecting..."
	
func _on_start_button_pressed() -> void:
	pass # Replace with function body.
	
func _on_connection_failed():
	# Updates label text to inform user that they were unable to connect
	status_label.text = "Failed to connect..."
	
func _on_connected_to_server():
	# Updates label text to inform user they have successfully connected
	status_label.text = "Connected!"
