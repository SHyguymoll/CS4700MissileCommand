extends Sprite

var fast = false
var ready = false
var angle = 0
var target = Vector2(0,0)
var ready_to_boom = false #kept for parity with EnemyMissile.gd
var reason = "Player" #ditto
var clear_me = false #ditto
var split_timer = -1

const ERROR_ROOM = 3

func position_valid() -> bool:
	return position.y < (target.y + ERROR_ROOM) and position.y > (target.y - ERROR_ROOM) and position.x < (target.x + ERROR_ROOM) and position.x > (target.x - ERROR_ROOM)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		position.x += 2.5*(cos(angle) + int(fast) * cos(angle))
		position.y += 2.5*(sin(angle) + int(fast) * sin(angle))
		if position_valid():
			ready_to_boom = true
