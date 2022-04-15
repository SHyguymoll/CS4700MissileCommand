extends Sprite

var speed = 0.3
var ready = false
var target = Vector2(0,0)
var ready_to_boom = false
var reason = "Contact"
var clear_me = false
var explosions := {}

const SCREEN_SIZE = 256
const MAX_DISTANCE = 30
const EXPLOSION_SIZE = 20

func move_smartly():
	#normal movement
	if position.x > target.x:
		position.x -= speed
	if position.x < target.x:
		position.x += speed
	if position.y > target.y:
		position.y -= speed
	if position.y < target.y:
		position.y += speed
	#dodge movement
	for explosion in explosions:
		if position.x < explosions[explosion][0].x - MAX_DISTANCE or \
			position.x > explosions[explosion][0].x + MAX_DISTANCE or \
			position.y < explosions[explosion][0].y - MAX_DISTANCE or \
			position.y > explosions[explosion][0].y + MAX_DISTANCE: #distance check
			continue
		if position.x > explosions[explosion][0].x - explosions[explosion][1].x*EXPLOSION_SIZE:
			position.x += 1.5*speed
		if position.x < explosions[explosion][0].x + explosions[explosion][1].x*EXPLOSION_SIZE:
			position.x -= 1.5*speed
		if position.y < explosions[explosion][0].y + explosions[explosion][1].y*EXPLOSION_SIZE:
			position.y -= 0.8*speed
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		move_smartly()
	if position.x < 0 or position.x > SCREEN_SIZE:
		clear_me = true


func _on_Area2D_area_entered(area):
	ready_to_boom = true
	if area.get_node("../").is_in_group("Player"):
		reason = "Player"
