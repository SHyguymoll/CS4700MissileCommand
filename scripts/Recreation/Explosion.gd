extends Sprite


# Declare member variables here. Examples:
var delta_timer = 0

func _process(delta):
	delta_timer += delta
	scale = Vector2(sin(delta_timer*2),sin(delta_timer*2))
	if delta_timer > PI/2:
		queue_free()
