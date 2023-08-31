@icon("res://img/asteroid_mid.png")
class_name Asteroid extends CharacterBody2D

signal explode(asteroid: Asteroid)
@export var speed: float = 250.0

func damage():
	explode.emit(self)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = deg_to_rad(randf_range(0.0, 360.0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var collision = get_last_slide_collision()
	if collision is KinematicCollision2D:
			var object = collision.get_collider()
			if object is Ship:
				object.die()
				damage()
			
	var movement = Vector2(randf(), randf())
	velocity += movement.rotated(rotation) * 5
	velocity = velocity.limit_length(speed)
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
