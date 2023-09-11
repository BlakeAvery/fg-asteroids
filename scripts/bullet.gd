@icon("res://img/bullet.png")
class_name Bullet extends Area2D

signal add_score(points: int)
var speed: float = 800.0
var is_player: bool

#func _init(location: Vector2, direction: float, bullet_color: Color = color):
#	color = bullet_color
#	rotation = direction
#	position = location
	
func destroy(object):
	# First off! Check for Ship or Asteroid!
	if object is Ship:
		if object.controllable and is_player:
			pass
		elif !object.controllable and !is_player:
			pass
		elif object.controllable and !is_player:
			object.die()
			queue_free()
		elif !object.controllable and is_player:
			object.die()
			add_score.emit(300)
			queue_free()
	if object is NewAsteroid and is_player:
		match object.size:
			0:
				add_score.emit(200)
			1:
				add_score.emit(150)
			2:
				add_score.emit(100)
		queue_free()

func set_color(color: Color):
	$Sprite2D.set_deferred("modulate", color)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$Sprite2D.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var movement = Vector2(0.0, -1.0)
	global_position += movement.rotated(rotation) * speed * delta


func _on_fizzle_timer_timeout():
	queue_free()
