extends CharacterBody2D


@export var player_sprite: AnimatedSprite2D

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600

@onready var initial_sprite_scale = player_sprite.scale

func _physics_process(delta: float) -> void:
	# .get_action_strength returns 1 or 0 on keyboard, but guages degree player 
	# has the stick for a float between 0 and 1. Positive values move right
	# negative values move left.
	var horizontal_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	
	# Actually moves character when move_and_slide is called
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity
	
	# Checks if the player is falling but detecting if the velocity is going in
	# a positive Y direction (which, in Godot, means down) and is not touching
	# the floor of the level
	var is_falling = velocity.y > 0 and not is_on_floor()
	# Same as above more or less. Checks if the jump button is pressed and if 
	# the player is on the floor.
	var is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	# Checks for if the player has released the jump button and is also
	# on an upward trajectory to end the jump early.
	var is_jump_cancelled = Input.is_action_just_released("jump") and velocity.y < 0
	# Checks for if the player is on the floor and the value of the x-axis 
	# velocity is 0.
	var is_idle = is_on_floor() and is_zero_approx(velocity.x)
	# Checks that the player is on the floor and has a movement trajectory 
	var is_walking = is_on_floor() and not is_zero_approx(velocity.x)
	
	# Checks if the jump button has been pressed and confirms player is on the 
	# floor, then pushes character into the air by the jump_strength amount.
	# Has to be negative because, in Godot, +Y values go down.
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = -jump_strength
	
	# Default function required for moving character
	move_and_slide()
	
	# Used to manage animations by verifying the values in the above declared
	# variables and playing the corresponding animations.
	if is_jumping:
		player_sprite.play("jump_start")
	elif is_walking:
		player_sprite.play("walk")
	elif is_falling:
		player_sprite.play("fall")
	elif is_idle:
		player_sprite.play("idle")
	
	# Only runs the following code if the value is not 0. This helps to prevent 
	# the sprite from snapping to the right no matter what direction the player
	# stops the character
	if not is_zero_approx(horizontal_input):
		# Check if the movement input value is less that 0, which, on the x axis
		# means that they are moving left.
		if horizontal_input < 0:
			# Takes the sprite scale and flips it on the x axis (negative == left)
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
		else:
			# Resets scale so that when the character is moving right the sprite 
			# faces right
			player_sprite.scale = initial_sprite_scale
