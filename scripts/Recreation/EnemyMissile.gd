extends Sprite

var speed = 0.3
var ready = false
var angle = 0
var ready_to_boom = false
var reason = "Contact"
var clear_me = false
var split_timer = -1

const SCREEN_SIZE = 256

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		position.x += speed*cos(angle)
		position.y += speed*sin(angle)
		if split_timer != -1:
			split_timer -= 1
	if position.x < 0 or position.x > SCREEN_SIZE:
		clear_me = true


func _on_Area2D_area_entered(area):
	ready_to_boom = true
	if area.get_node("../").is_in_group("Player"):
		reason = "Player"
