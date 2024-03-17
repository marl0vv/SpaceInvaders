extends Area2D
class_name Bunker

@export var default_hit_points : int = 3
@onready var sprite : Sprite2D = $Sprite2D

var _health : int = 3
var _destroyed : bool 

var health : int = 3 :
	get:
		return _health
	set(value):
		_health = value
		if _health < 0:
			destroyed = true
		else:
			destroyed = false
			sprite.region_rect.position.x = (default_hit_points - _health) * 32

var destroyed : bool = false :
	get: 
		return _destroyed
	set(value):
		_destroyed = value
		visible = not value

func reset():
	health = default_hit_points