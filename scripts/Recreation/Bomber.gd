extends Sprite

var speed = 1
var ready = false
var facing = 1
var ready_to_boom = false
var clear_me = false
var deploy_timer = 66

const SCREEN_SIZE = 256

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ready:
		show()
		position += Vector2(speed*facing,0)
		if deploy_timer != -1:
			if deploy_timer > 0:
				deploy_timer -= 1
		if position.x > SCREEN_SIZE and facing == 1 or position.x < 0 and facing == -1:
			clear_me = true
	else:
		hide()
		scale.x = facing


func Bomber_Hit(_area):
	ready_to_boom = true