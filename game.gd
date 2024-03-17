extends Node2D

enum GameState { PLAYING, WON, DEAD, PAUSED, REVIVING }

@export var current_step_duration: float = 1
@export var step_duration_decrease: float = 0.05
@export var going_right: bool = false
@export var screen_width: float = 400
@export var screen_height: float = 700
@export var distance_before_bouncing: float = 16
@export var current_level: int = 0

@export_group("Objects")
@export var player: Player
@export var magic_ship: MagicShip

@onready var move_sound: AudioStreamPlayer = $MoveSoundPlayer

var game_state: GameState = GameState.PLAYING
var can_shoot: bool = true
var chance_of_shooting_magic_number: int = 30

var current_step_progress: float = 0

var aliens: Array[Alien] = []

var top_left_alien: Alien = null
var bottom_right_alien: Alien = null


func can_game_process() -> bool:
	return game_state == GameState.PLAYING


func _find_leftmost_alien(current_min: Alien, alien: Alien):
	if alien.position.x < current_min.position.x and not alien.dead:
		return alien
	return current_min


func _find_rightmost_alien(current_max: Alien, alien: Alien):
	if alien.position.x > current_max.position.x and not alien.dead:
		return alien
	return current_max


func _find_lowest_alien(current_max: Alien, alien: Alien):
	if alien.position.y > current_max.position.y:
		return alien
	return current_max


func _find_live_aliens() -> Array[Alien]:
	return aliens.filter(func(alien): return not alien.dead)


func lowest_alien() -> Vector2:
	return _find_live_aliens().reduce(_find_lowest_alien).position


func _ready():
	for node in get_tree().get_nodes_in_group("Alien"):
		if node is Alien:
			aliens.append(node)
			node.connect("died", _on_alien_died)
	update_alien_anchors()


func update_alien_anchors():
	if aliens.all(func(alien): return alien.dead):
		return
	top_left_alien = _find_live_aliens().reduce(_find_leftmost_alien)
	bottom_right_alien = aliens.reduce(_find_rightmost_alien)


func step():
	if not can_game_process():
		return

	$DebugInfoLabel.text = "Left: %s . Right: %s" % [top_left_alien.name, bottom_right_alien.name]
	move_sound.play()
	for alien in aliens:
		alien.step(going_right)
	if lowest_alien().y >= player.position.y:
		loose_game()
		return
	if can_shoot and randi_range(0, chance_of_shooting_magic_number) > 50:
		_find_live_aliens().pick_random().shoot()
		can_shoot = false
		$GameObjects/EnemyFireResumeTimer.start()

	if (
		top_left_alien.position.x <= distance_before_bouncing
		or bottom_right_alien.position.x >= screen_width - distance_before_bouncing
	):
		going_right = not going_right
		for alien in aliens:
			alien.move_down()
	if bottom_right_alien.position.y > screen_height:
		loose_game()


func loose_game():
	game_state = GameState.DEAD
	$CanvasLayer/GameLost.visible = true
	game_state = GameState.DEAD
	$GameLostMusic.play()


func revive_player():
	$GameLostMusic.play()
	game_state = GameState.REVIVING
	player.position.x = screen_width / 2
	$AnimationPlayer.play("revive")


func win_game():
	player.dead = true
	game_state = GameState.WON
	$CanvasLayer/GameWon.visible = true
	game_state = GameState.WON
	$GameWonMusic.play()


func pause_game():
	$CanvasLayer/GamePaused.visible = true
	game_state = GameState.PAUSED
	get_tree().paused = true
	$PauseMusicPlayer.play()


func upause_game():
	$CanvasLayer/GamePaused.visible = false
	get_tree().paused = false
	game_state = GameState.PLAYING


func _on_alien_died():
	if aliens.all(func(alien): return alien.dead):
		win_game()
		return
	update_alien_anchors()
	if current_step_duration > 0.1:
		current_step_duration -= step_duration_decrease
		if chance_of_shooting_magic_number < 90:
			chance_of_shooting_magic_number += 2
	else:
		current_step_duration = 0.1


func _process(delta):
	if not can_game_process():
		return
	current_step_progress += delta
	if current_step_progress >= current_step_duration:
		current_step_progress = 0
		step()


func advance_game():
	reset()
	current_step_duration = max(1 - (step_duration_decrease * current_level), 0.1)
	chance_of_shooting_magic_number = min(30 + current_level * 10, 90)


func reset():
	$CanvasLayer/GameWon.visible = false
	$CanvasLayer/GameLost.visible = false
	for alien in aliens:
		alien.reset()
	player.position.x = screen_width / 2
	game_state = GameState.PLAYING
	player.dead = false
	game_state = GameState.PLAYING
	update_alien_anchors()
	current_step_duration = max(1 - (step_duration_decrease * current_level), 0.1)
	for bunker in get_tree().get_nodes_in_group("Bunker"):
		bunker.reset()


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if game_state == GameState.PLAYING:
			pause_game()
		elif game_state == GameState.PAUSED:
			upause_game()
	if Input.is_action_just_pressed("fire"):
		match game_state:
			GameState.PAUSED:
				upause_game()
			GameState.WON:
				advance_game()
				player.lives += 1
			GameState.DEAD:
				current_level = 0
				player.reset()
				reset()


func _on_enemy_fire_resume_timer_timeout():
	can_shoot = true


func _on_player_died():
	if player == null:
		return
	if player.lives > 1:
		player.lives -= 1
		revive_player()
	else:
		player.lives = 0
		loose_game()


func _on_animation_player_animation_finished(_anim_name: StringName):
	player.dead = false
	game_state = GameState.PLAYING


func _on_ship_summon_timer_timeout():
	if randi_range(0, 12) % 3 == 0 and not magic_ship.moving:
		magic_ship.moving = true
