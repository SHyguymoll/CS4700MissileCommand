extends Sprite

var flash_on_frame = false

func _process(_delta):
	modulate.r = rand_range(0,1)
	modulate.g = rand_range(0,1)
	modulate.b = rand_range(0,1)
