extends Control


@export var ip_line_edit: LineEdit
@export var status_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

# Called when the host presses the Host button
func _on_host_button_pressed() -> void:
	Lobby.create_game()

func _on_join_button_pressed() -> void:
	Lobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."

func _on_start_button_pressed() -> void:
	pass # Replace with function body.

func _on_connection_failed():
	status_label.text = "Failed to connect..."

func _on_connected_to_server():
	status_label.text = "Connected!"
