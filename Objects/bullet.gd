extends Area2D
class_name Bullet
@export var speed: float = 500

var player: Player


func _physics_process(delta):
	position.y -= speed * delta
	if position.y < 0:
		queue_free()


func _on_area_entered(area: Area2D):
	if area is Alien and not area.dead:
		player.points += area.points
		area.die()
		queue_free()
		return
	if area is MagicShip:
		player.points += area.points
		area.die()
		queue_free()
		return
	if area is Bunker and not area.destroyed:
		area.health -= 1
		queue_free()
		return

