extends Sprite

var speed = 0.3
var ready = false
var target = Vector2(0,0)
var ready_to_boom = false
var clear_me = false
var explosionPositions := {}

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
	var simplePositions = []
	for explosion in explosionPositions:
		simplePositions.append(explosionPositions[explosion]) #adds posiiton (Vec2) to array
	for simpPosition in simplePositions:
		if position.x < simpPosition.x - MAX_DISTANCE or \
			position.x > simpPosition.x + MAX_DISTANCE or \
			position.y < simpPosition.y - MAX_DISTANCE or \
			position.y > simpPosition.y + MAX_DISTANCE: #distance check
			continue
		if position.x > simpPosition.x - EXPLOSION_SIZE:
			position.x -= 2*speed
		if position.x < simpPosition.x + EXPLOSION_SIZE:
			position.x += 2*speed
		if position.y > simpPosition.y - EXPLOSION_SIZE:
			position.y += 2*speed
		if position.y < simpPosition.y + EXPLOSION_SIZE:
			position.y -= 2*speed
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ready:
		move_smartly()
	if position.x < 0 or position.x > SCREEN_SIZE:
		clear_me = true


func _on_Area2D_area_entered(_area):
	ready_to_boom = true
