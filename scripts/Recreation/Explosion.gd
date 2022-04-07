extends Sprite

var finished = false
var delta_timer = 0

const REDUCE_SEIZURES = 0.3

func _process(delta):
	modulate.r = rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES)
	modulate.g = rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES)
	modulate.b = rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES)
	if !finished:
		delta_timer += delta
	scale = Vector2(sin(delta_timer*2),sin(delta_timer*2))
	if delta_timer > PI/2:
		finished = true
		#queue_free()
