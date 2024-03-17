extends Area2D
class_name Alien

signal died

enum AlienType { PINECONE, BRAIN, SKULL }

@onready var sprite: Sprite2D = $Sprite2D
@export var step_size: float = 16
@export var points: int = 100
@export var bullet_prefab: PackedScene
@export var sprite_type : AlienType = AlienType.PINECONE
@export var explosion_prefab : PackedScene


var start_location : Vector2

var dead = false

var _current_frame_state: bool

var current_frame_state: bool = false:
	get:
		return _current_frame_state
	set(value):
		_current_frame_state = value
		sprite.region_rect.position.x = 0 if not value else 16

func _ready():
	start_location = position
	match sprite_type:
		AlienType.PINECONE: 
			sprite.region_rect.position.y = 0
		AlienType.BRAIN: 
			sprite.region_rect.position.y = 16
		AlienType.SKULL: 
			sprite.region_rect.position.y = 32

	 

func step(going_right: bool):
	current_frame_state = not current_frame_state
	position.x = position.x + ((-step_size) if not going_right else step_size)


func reset():
	position = start_location
	dead = false
	visible = true


func move_down():
	position.y += step_size


func shoot():
	if bullet_prefab == null:
		printerr("%s can't  fire because because it's missing ammo" % name)
		return
	var bullet = bullet_prefab.instantiate() as BulletEnemy
	get_tree().root.add_child(bullet)
	bullet.position = position


func die():
	visible = false
	dead = true
	if explosion_prefab != null:
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_tree().root.add_child(explosion)
	died.emit()