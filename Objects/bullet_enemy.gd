extends Area2D
class_name BulletEnemy
@export var speed: float = 300
@export var screen_height: float = 700

func _physics_process(delta):
	position.y += speed * delta
	if position.y > screen_height:
		queue_free()


func _on_area_entered(area: Area2D):
	if area is Player:
		area.die()
		queue_free()
		return
	if area is Bunker and not area.destroyed:
		area.health -= 1
		queue_free()
		return
