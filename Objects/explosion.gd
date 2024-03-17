extends Sprite2D

func _on_timer_timeout():
	queue_free()

func _ready():
	$AudioStreamPlayer2D.play()