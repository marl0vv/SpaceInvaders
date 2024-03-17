extends Area2D
class_name MagicShip

@export var start_position : Node2D 
@export var end_position : Node2D
@export var speed : float = 300

@export var points : int = 100
@export var moving : bool = false

var paused = false

func _process(delta):
	if not moving or paused:
		return
	position.x -= speed * delta
	if position.x < end_position.position.x:
		position.x = start_position.position.x
		moving = false

func die():
	position.x = start_position.position.x
	moving = false
