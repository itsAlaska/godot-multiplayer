extends CharacterBody2D


@export var player_camera: PackedScene
@export var camera_height = 316

@export var player_sprite: AnimatedSprite2D
@export var player_finder: Node2D

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600
@export var max_jumps = 3
@export var push_force = 10

@onready var initial_sprite_scale = player_sprite.scale

var owner_id = 1
var jump_count = 0
var camera_instance
var state = PlayerState.IDLE
var current_interactable

enum PlayerState {
	IDLE,
	WALKING,
	JUMP_STARTED,
	JUMPING,
	DOUBLE_JUMPING,
	FALLING
}

func _enter_tree():
	# Sets the owner id to be an integer converted version of the players name
	owner_id = name.to_int()
	
	# Makes sure that this instantiated player node can only be controlled by the
	# player, identified by their id
	set_multiplayer_authority(owner_id)
	
	# Performs a check that the person running the this code segment is in fact
	# the owner of this node, and ends the function if it is not. Essentially ensuring
	# that the camera spawned in goes only to the player
	if owner_id != multiplayer.get_unique_id():
		return
	
	# Refer to function at the bottom of the script for notes.
	set_up_camera()

func _process(_delta):
	if multiplayer.multiplayer_peer == null:
		return
	# Makes sure that the code in this function is only run by the owner of this 
	# scene
	if owner_id != multiplayer.get_unique_id():
		return
		
	# Refer to function at the bottom of the script for notes.
	update_camera_pos()

func _physics_process(_delta: float) -> void:
	# Makes sure that the code in this function is only run by the owner of this 
	# scene
	if owner_id != multiplayer.get_unique_id():
		return
		
	
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
	
	if Input.is_action_just_pressed("interact"):
		if current_interactable != null:
			current_interactable.interact.rpc_id(1)
	
	#Refer to function at bottom of script for notes.
	handle_movement_state()
		
	# Default function required for moving character
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var pushable = collision.get_collider() as PushableObject
		if pushable == null:
			continue
		var point = collision.get_position() - pushable.global_position
		pushable.push(-collision.get_normal() * push_force, point)
	
	# Refer to function at bottom of script for notes.
	face_movement_direction(horizontal_input)


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == PlayerState.JUMPING:
		player_sprite.play("jump")
	
func set_up_camera():
	# When the script first loads up, the player's camera is created and stored 
	# in a variable.
	camera_instance = player_camera.instantiate()
	# Accesses the camera's global position and moves it on the y-axis to the 
	#value stored in the camera_height variable.
	camera_instance.global_position.y = camera_height
	# Accesses the current scene and adds the camera as a child of the current 
	# scene.
	get_tree().current_scene.add_child.call_deferred(camera_instance)

func update_camera_pos():
	# This makes sure the the camera's x-axis is the same as the players so that
	# it follows the player around.
	camera_instance.global_position.x = global_position.x

func face_movement_direction(horizontal_input):
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

func handle_movement_state():
	# Decide State
	# Checks if the jump button is pressed and if the player is on the floor.
	# Updates state to reflect as such
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMP_STARTED
	# Checks for if the player is on the floor and the value of the x-axis 
	# velocity is 0.
	elif is_on_floor() and is_zero_approx(velocity.x):
		state = PlayerState.IDLE
	# Checks that the player is on the floor and has a movement trajectory 
	elif is_on_floor() and not is_zero_approx(velocity.x):
		state = PlayerState.WALKING
	else:
		state = PlayerState.JUMPING
	
	if velocity.y > 0 and not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			state = PlayerState.DOUBLE_JUMPING
		else:
			state = PlayerState.FALLING
	
	# Process State
	match state:
		PlayerState.IDLE: 
			player_sprite.play("idle")
			jump_count = 0
		PlayerState.WALKING:
			player_sprite.play("walk")
			jump_count = 0
		PlayerState.JUMP_STARTED:
			player_sprite.play("jump_start")
			jump_count += 1
			velocity.y = -jump_strength
		PlayerState.DOUBLE_JUMPING:
			player_sprite.play("double_jump_start")
			jump_count += 1
			if jump_count <= max_jumps:
				velocity.y = -jump_strength
		PlayerState.FALLING:
			player_sprite.play("fall")
		
	# Jump cancelling
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 0


func _on_interaction_handler_area_entered(area: Area2D) -> void:
	current_interactable = area


func _on_interaction_handler_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	player_finder.visible = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	player_finder.visible = true
