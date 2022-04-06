extends Sprite

var fast = false
var ready = false
var angle = 0
var target = Vector2(0,0)
var ready_to_boom = false

const ERROR_ROOM = 3

func position_valid() -> bool:
	return position.y < (target.y + ERROR_ROOM) and position.y > (target.y - ERROR_ROOM) and position.x < (target.x + ERROR_ROOM) and position.x > (target.x - ERROR_ROOM)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		position.x += cos(angle) + int(fast) * cos(angle)
		position.y += sin(angle) + int(fast) * sin(angle)
		if position_valid():
			ready_to_boom = true
