extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_host_button_pressed() -> void:
	# Runs the creat_game function located in the Lobby script
	Lobby.create_game()


func _on_join_button_pressed() -> void:
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	pass # Replace with function body.
