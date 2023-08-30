extends Control

signal start_game

var life_icon = preload("res://scenes/life_ui_element.tscn")

enum states {BASE_TITLE, IN_GAME, RESPAWNING, GAME_OVER}
@export var current_state: int = 0

func change_state(state: int):
	if state > states.GAME_OVER:
		assert(false)
	else:
		match state:
			states.BASE_TITLE:
				current_state = states.BASE_TITLE
				reset_game()
			states.IN_GAME:
				current_state = states.IN_GAME
				game_start()
			states.RESPAWNING:
				current_state = states.RESPAWNING
				respawn_text()
			states.GAME_OVER:
				current_state = states.GAME_OVER
				game_over()

func game_over():
	$MessageTitleLabel.text = "Game over :("
	$MessageTitleLabel.show()
	$Button.show()
	

func respawn_text():
	$MessageTitleLabel.text = "You're back in a sec..."
	$MessageTitleLabel.show()
	await get_tree().create_timer(4).timeout
	$MessageTitleLabel.text = ""
	$MessageTitleLabel.hide()
	

func reset_game():
	$MessageTitleLabel.text = "Test King V3!"
	$MessageTitleLabel.show()
	$Button.show()

func game_start():
	$Button.hide()
	$MessageTitleLabel.text = "Ready?"
	await get_tree().create_timer(3).timeout
	$MessageTitleLabel.text = ""
	$MessageTitleLabel.hide()

func update_lives(lives: int):
	for i in $LivesContainer.get_children():
		i.queue_free()
	for l in lives:
		var icon = life_icon.instantiate()
		$LivesContainer.add_child(icon)
		

func update_score(score: int):
	$ScoreLabel.text = "Score: " + str(score)
	
func update_high_score(score: int):
	$HighScoreLabel.text = "High Score: " + str(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(states.BASE_TITLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	start_game.emit()
