extends Sprite

var ready = false
var direction = -1
var ready_to_boom = false
var reason = "Contact"
var clear_me = false
var explosions := {}

const SCREEN_SIZE = 256
const MAX_DISTANCE = 30
const EXPLOSION_SIZE = 20

func move_smartly(speed: float = 0.3):
	#normal movement
	if position.x > SCREEN_SIZE-10:
		direction = -1
	if position.x < 10:
		direction = 1
	
	position.x += speed * direction
	#dodge movement
	for explosion in explosions:
		if position.x < explosions[explosion][0].x - MAX_DISTANCE or \
			position.x > explosions[explosion][0].x + MAX_DISTANCE or \
			position.y < explosions[explosion][0].y - MAX_DISTANCE or \
			position.y > explosions[explosion][0].y + MAX_DISTANCE: #distance check
			continue
		if position.x > explosions[explosion][0].x - explosions[explosion][1].x*EXPLOSION_SIZE:
			position.x += 2*speed
		if position.x < explosions[explosion][0].x + explosions[explosion][1].x*EXPLOSION_SIZE:
			position.x -= 2*speed
		if position.y < explosions[explosion][0].y + explosions[explosion][1].y*EXPLOSION_SIZE:
			position.y -= speed
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		move_smartly()


func _on_Area2D_area_entered(area):
	ready_to_boom = true
	if area.get_node("../").is_in_group("Player"):
		reason = "Player"
