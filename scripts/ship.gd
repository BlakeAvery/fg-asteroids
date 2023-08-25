@icon("res://img/ship.png")
class_name Ship extends CharacterBody2D

signal shoot
signal death
@export var controllable: bool = false
@export var acceleration: float = 7.0
@export var deceleration: float = 7.0
@export var max_speed: float = 200.0
@export var rotation_speed: float = 150.0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if !controllable:
		rotation = randf_range(0.0, 360.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if !controllable: # NPC condition
		var attack_vector = Vector2(0.0, randf_range(0.6, 1.0)) # This represents NPC moving
		velocity += attack_vector.rotated(rotation) * acceleration # Set velocity vector to the attack vector rotated by the ships rotation times our acceleration
		velocity = velocity.limit_length(max_speed)
	else:
		print(velocity)
		var input_vector = Vector2(0.0, Input.get_action_strength("accel"))
		velocity += input_vector.rotated(rotation) * acceleration
		velocity = velocity.limit_length(max_speed)
		if Input.is_action_pressed("left"):
			rotate(deg_to_rad(-rotation_speed * delta))
		if Input.is_action_pressed("right"):
			rotate(deg_to_rad(rotation_speed * delta))
		if input_vector.y == 0:
			velocity = velocity.move_toward(Vector2.ZERO, deceleration)
	move_and_slide()
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
