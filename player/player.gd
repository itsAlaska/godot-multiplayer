extends CharacterBody2D

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600

func _physics_process(delta: float) -> void:
	# .get_action_strength returns 1 or 0 on keyboard, but guages degree player 
	# has the stick for a float between 0 and 1
	var horizontal_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	
	# Actually moves character when move_and_slide is called
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity
	
	# Checks if the jump button has been pressed and confirms player is on the 
	# floor, then pushes character into the air by the jump_strength amount.
	# Has to be negative because, in Godot, +Y values go down.
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = -jump_strength
	
	# Default function required for moving character
	move_and_slide()
