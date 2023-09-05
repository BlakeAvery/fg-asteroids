extends Node2D

var laser = preload("res://scenes/bullet.tscn")
var ship = preload("res://scenes/ship.tscn")
var asteroid = preload("res://scenes/asteroid.tscn")

var frame_timer: int = 0
var game_active: bool = false # This will later be controlled by UI. Go away
enum ui_states {BASE_TITLE, IN_GAME, RESPAWNING, GAME_OVER}
enum rock_states {SMALL, MID, BIG}

@export var max_lives: int = 5
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
	a.size = rock_states.BIG
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

func _on_ship_shoot(laser):
	laser.connect("add_score", update_score)
	add_child(laser)
	

func _on_player_death(): # Player respawn code is in here. Needs to be refactored to Ship object
	game_active = false
	lives -= 1
	$UI.update_lives(lives)
	if lives > 0:
		$RespawnTimer.start()
		$UI.change_state(ui_states.RESPAWNING)
		await $RespawnTimer.timeout
		$Player.alive = true
		$Player.show()
		$Player/InvincibleTimer.start()
		$Player/Sprite2D.modulate = Color($Player/Sprite2D.modulate, 0.5)
		game_active = true
	else:
		game_over()
	

func _on_asteroid_explode(rock: Asteroid):
	# First check size of asteroid. If already small kill it.
	# If its not too small we can make a new one. Take down position
	# data, spawn two new ones that are smaller, and send them flying
	# in different directions. Make sure to kill the original rock
	match rock.size:
		rock_states.SMALL:
			rock.kaboom()
		rock_states.MID, rock_states.BIG:
			var spawn_pos = rock.position
			var spawn_dir = rock.rotation
			var prev_size = rock.size
			rock.kaboom()
			var one_rock = asteroid.instantiate()
			var two_rock = asteroid.instantiate()
			one_rock.global_position = spawn_pos
			two_rock.global_position = spawn_pos
			one_rock.rotation = spawn_dir - .5
			two_rock.rotation = spawn_dir + .5
			match prev_size:
				rock_states.BIG:
					one_rock.size = rock_states.MID
					two_rock.size = rock_states.MID
				rock_states.MID:
					one_rock.size = rock_states.SMALL
					two_rock.size = rock_states.SMALL
			one_rock.connect("explode", _on_asteroid_explode)
			two_rock.connect("explode", _on_asteroid_explode)
			add_child(one_rock)
			add_child(two_rock)


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
	
