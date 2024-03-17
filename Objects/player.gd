extends Area2D
class_name Player
signal died

@export var speed: float = 100
@export var screen_size: float = 600
@export var fire_cooldown: float = 0.5
@export var bullet_prefab: PackedScene

@export_group("UI")
@export var score_label: Label
@export var lives_label: Label
@export var highscore_label: Label

var current_firecooldown_progress: float = 0
var can_fire: bool = true
var dead : bool = false
var _lives: int = 3
var _points: int

var points: int = 0:
	get:
		return _points
	set(value):
		_points = value
		if score_label != null:
			score_label.text = str(value)

var lives: int = 3:
	get:
		return _lives
	set(value):
		_lives = value
		if lives_label != null:
			lives_label.text = str(value)


func fire_bullet():
	if bullet_prefab == null or not can_fire:
		return
	can_fire = false
	$ShootSoundPlayer.play()
	var bullet = bullet_prefab.instantiate() as Bullet
	get_tree().root.add_child(bullet)
	bullet.position = position
	bullet.player = self


func _physics_process(delta):
	if dead:
		return
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x = speed
	if Input.is_action_pressed("move_left"):
		direction.x = -speed
	if Input.is_action_just_pressed("fire"):
		fire_bullet()

	position += direction * delta
	if position.x < 16:
		position.x = 17
	if position.x > screen_size - 16:
		position.x = screen_size - 16


func _process(delta):
	current_firecooldown_progress += delta
	if current_firecooldown_progress > fire_cooldown:
		can_fire = true
		current_firecooldown_progress = 0


func die():
	if not dead:
		died.emit()
		dead = true

func reset():
	lives = 3