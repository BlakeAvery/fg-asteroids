extends Node2D

var laser = preload("res://scenes/bullet.tscn")
var ship = preload("res://scenes/ship.tscn")
var asteroid = preload("res://scenes/asteroid.tscn")

var frame_timer: int = 0
var game_active: bool = false # This will later be controlled by UI. Go away
enum ui_states {BASE_TITLE, IN_GAME, RESPAWNING, GAME_OVER}

@export var max_lives: int = 4
var lives: int = max_lives
var score: int = 0
var high_score: int = 0

func spawn_ship():
	var s = ship.instantiate()
	s.controllable = false
	$ShipSpawnPath/ShipSpawnPoint.progress_ratio = randf()
	s.position = $ShipSpawnPath/ShipSpawnPoint.position
	s.connect("shoot", _on_ship_shoot)
	add_child(s)
	
func spawn_asteroid():
	var a = asteroid.instantiate()
	$AsteroidSpawnPath/AsteroidSpawnPoint.progress_ratio = randf()
	a.position = $AsteroidSpawnPath/AsteroidSpawnPoint.position
	a.connect("explode", _on_asteroid_explode)
	add_child(a)
	
func game_over():
	game_active = false
	if score > high_score:
		high_score = score
		$UI.update_high_score(score)
	$UI.change_state(ui_states.GAME_OVER)
	$EnemyShipSpawnTimer.stop()
	$AsteroidSpawnTimer.stop()
	$RespawnTimer.stop()
	

func update_score(points: int):
	if game_active:
		score = score + points
		$UI.update_score(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass
	

func _on_ship_shoot(laser):
	print("Laser shot at " + str(laser))
	laser.connect("add_score", update_score)
	add_child(laser)
	

func _on_player_death():
	game_active = false
	lives -= 1
	$UI.update_lives(lives)
	if lives > 0:
		$RespawnTimer.start()
		$UI.change_state(ui_states.RESPAWNING)
#		lives = lives - 1 # Why doesn't -= work?
		await $RespawnTimer.timeout
		$Player.alive = true
		$Player/CollisionPolygon2D.disabled = false
		$Player.show()
		game_active = true
	else:
		game_over()
	

func _on_asteroid_explode(rock: Asteroid):
	# First take down the position and rotation of the dying asteroid.
	# Then kill the dying asteroid, spawn two new at asteroid position
	# Unless at smallest size. Then just kill the asteroid
	pass


func _on_ui_start():
	game_active = true
	score = 0
	lives = max_lives
	$UI.update_score(score)
	$UI.update_lives(lives)
	$UI.change_state(ui_states.IN_GAME)
	$EnemyShipSpawnTimer.start()
	$AsteroidSpawnTimer.start()
	$Player.show()
	$Player.alive = true
	$Player/CollisionPolygon2D.disabled = false
	
