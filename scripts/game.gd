extends Node2D

var laser = preload("res://scenes/bullet.tscn")
var ship = preload("res://scenes/ship.tscn")

var frame_timer: int = 0
@export var ship_spawn_interval = 2 # Change this to modify how often enemy ships spawn. In seconds
var game_active: bool = true # This will later be controlled by UI. Go away
enum ui_states {BASE_TITLE, IN_GAME, RESPAWNING, GAME_OVER}

@export var lives: int = 3
var score: int = 0
var high_score: int = 0

func spawn_ship():
	var s = ship.instantiate()
	s.controllable = false
	$ShipSpawnPath/ShipSpawnPoint.progress_ratio = randf()
	s.position = $ShipSpawnPath/ShipSpawnPoint.position
	s.connect("shoot", _on_ship_shoot)
	add_child(s)
	
func game_over():
	if score > high_score:
		high_score = score
		$UI.update_high_score(score)
	$UI.change_state(ui_states.GAME_OVER)
	

func update_score(points: int):
	score = score + points
	$UI.update_score(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	frame_timer += 1
	# Its messed up, right? I just wanted to see how this would perform really
	if frame_timer / Engine.physics_ticks_per_second == ship_spawn_interval:
		spawn_ship()
		frame_timer = 0
	

func _on_ship_shoot(laser):
	print("Laser shot at " + str(laser))
	laser.connect("add_score", update_score)
	add_child(laser)


func _on_player_death():
	if lives > 0:
		$RespawnTimer.start()
		$UI.change_state(ui_states.RESPAWNING)
		lives = lives - 1 # Why doesn't -= work?
		$UI.update_lives(lives)
		await $RespawnTimer.timeout
		$Player.alive = true
		$Player/CollisionPolygon2D.disabled = false
		$Player.show()
	else:
		game_over()
	


func _on_ui_start():
	score = 0
	$UI.update_score(score)
	$UI.update_lives(lives)
	$UI.change_state(ui_states.IN_GAME)
	
	
