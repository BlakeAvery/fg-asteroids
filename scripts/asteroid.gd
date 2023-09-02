@icon("res://img/asteroid_mid.png")
class_name Asteroid extends CharacterBody2D

signal explode(asteroid: Asteroid)
enum sizes {SMALL, MID, BIG}
@export var speed: float = 250.0
var size: int
var big = preload("res://scenes/asteroid_large_shape.tscn")
var mid = preload("res://scenes/asteroid_mid_shape.tscn")
var lil = preload("res://scenes/asteroid_small_shape.tscn")
var exist_timer: Timer = Timer.new()

func damage():
	explode.emit(self)

func kaboom(): #They should introduce the private keyword in GDScript before I start using C# :)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	exist_timer.wait_time = 20.0
	exist_timer.connect("timeout", kaboom)
	add_child(exist_timer)
	exist_timer.start()
	match size:
		sizes.SMALL:
			$Sprite2D.texture = preload("res://img/asteroid_small.png")
			var polygon = lil.instantiate()
			call_deferred("add_child", polygon)
			speed = 300.0
		sizes.MID:
			$Sprite2D.texture = preload("res://img/asteroid_mid.png")
			var polygon = mid.instantiate()
			call_deferred("add_child", polygon)
			speed = 250.0
		sizes.BIG:
			$Sprite2D.texture = preload("res://img/asteroid_big.png")
			var polygon = big.instantiate()
			call_deferred("add_child", polygon)
			speed = 200.0
		_:
			assert(false)
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
			if object is Asteroid:
				object.velocity = object.velocity * -1
				object.rotation = object.rotation * -1
				velocity = velocity * -1
				rotation = rotation * -1
			
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
