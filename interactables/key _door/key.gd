extends Node2D


@export var follow_offset: Vector2
@export var lerp_speed = .5

var following_body 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if multiplayer.is_server():
		if following_body != null:
			global_position = lerp(
				following_body.global_position + follow_offset,
				global_position,
				pow(.5, delta * lerp_speed))


func _on_area_2d_body_entered(body: Node2D) -> void:
	following_body = body
