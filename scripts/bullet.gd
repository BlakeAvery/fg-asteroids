@icon("res://img/bullet.png")
class_name Bullet extends Area2D
@export var color: Color

func _init(location: Vector2, direction: float, bullet_color: Color = color):
	color = bullet_color
	rotation = direction
	position = location
	
func destroy(object: Node2D):
	# First off! Check for Ship or Asteroid!
	if object is Ship:
		object.die()
#	if object is Asteroid:
#		pass
#
	# Now destroy the laser
	queue_free()

func spawn():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var attack_vector = Vector2(0.0, randf_range(0.6, 1.0)) # This represents NPC moving
	position += attack_vector.rotated(rotation) * 10 # Set velocity vector to the attack vector rotated by the ships rotation times our acceleration

