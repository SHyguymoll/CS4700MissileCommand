extends Sprite

var finished = false
var delta_timer = 0

func _process(delta):
	if !finished:
		delta_timer += delta
	scale = Vector2(sin(delta_timer*2),sin(delta_timer*2))
	if delta_timer > PI/2:
		#finished = true
		queue_free()
	modulate.r = rand_range(0,1)
	modulate.g = rand_range(0,1)
	modulate.b = rand_range(0,1)
