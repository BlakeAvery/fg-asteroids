@icon("res://img/asteroid_mid.png")
class_name NewAsteroid extends Area2D

signal explode(asteroid: NewAsteroid)
enum sizes {SMALL, MID, BIG}
var speed: float
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
			speed = 350.0
		sizes.MID:
			$Sprite2D.texture = preload("res://img/asteroid_mid.png")
			var polygon = mid.instantiate()
			call_deferred("add_child", polygon)
			speed = 250.0
		sizes.BIG:
			$Sprite2D.texture = preload("res://img/asteroid_big.png")
			var polygon = big.instantiate()
			call_deferred("add_child", polygon)
			speed = 210.0
		_:
			assert(false)
	rotation = deg_to_rad(randf_range(0.0, 360.0))

func _physics_process(delta):
	var movement = Vector2(0.0, -1.0)
	global_position += movement.rotated(rotation) * speed * delta
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0


func _on_body_entered(body: Node2D):
	explode.emit(self)
	if body is Ship:
		body.die()

func _on_area_entered(area: Area2D):
	if area is NewAsteroid:
		rotation *= -1
	else:
		damage()
