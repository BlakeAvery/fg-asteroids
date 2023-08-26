@icon("res://img/ship.png")
class_name Ship extends CharacterBody2D

signal shoot(position: Vector2, rotation)
signal death
@export var controllable: bool = false
@export var acceleration: float = 7.0
@export var deceleration: float = 7.0
@export var max_speed: float = 200.0
@export var rotation_speed: float = 150.0

var laser = preload("res://scenes/bullet.tscn")

func die():
	death.emit()
	queue_free()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if !controllable:
		rotation = randf_range(0.0, 360.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# I'm going to put the shooting input check in here. Don't say nothing
	if controllable:
		if Input.is_action_pressed("shoot"):
			var bullet = laser.instantiate()
			var parent_path = get_tree()
			parent_path.connect("node_added", bullet.spawn())
			bullet.position = $GunPoint.position
			shoot.emit()

func _physics_process(delta):
	# Ngl let us try to do a collision check first :)
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision is KinematicCollision2D:
		var what_did_we_hit = collision.get_collider()
		if what_did_we_hit is Ship:
			what_did_we_hit.die()
			die()
		#if what_did_we_hit is Asteroid:
		#	die()
		if what_did_we_hit is Bullet:
			die()
			what_did_we_hit.destroy()
	# Collision block complete. This handles our movement input
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
	# Now wrap this nigga around
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
