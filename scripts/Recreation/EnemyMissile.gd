extends Sprite

var speed = 1
var ready = false
var angle = 0
var ready_to_boom = false

const ERROR_ROOM = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		position.x += speed*cos(angle)
		position.y += speed*sin(angle)


func _on_Area2D_area_entered(_area):
	ready_to_boom = true
