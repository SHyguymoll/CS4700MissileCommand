extends AnimatedSprite

var ready = false
var direction = -1
var ready_to_boom = false
var state = "null"
var shoot_timer = 100
var health = 0
var gameLogic

const SCREEN_SIZE = 256
const MAX_DISTANCE = 30
const EXPLOSION_SIZE = 20
const SPEED = 0.3

func _ready():
	gameLogic = $"../"

func move():
	#slow guy
	if position.x > SCREEN_SIZE-10:
		direction = -1
	if position.x < 10:
		direction = 1
	position.x += SPEED * direction
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		"Intro":
			position.y = lerp(position.y, 35, 0.1)
			if position.y > 34:
				state = "Idle"
				gameLogic = $"../"
		"Idle":
			move()
			if shoot_timer > 0:
				shoot_timer -= 1
		"Hit_0":
			position.y = lerp(position.y, 10, 0.3)
			if position.y < 12:
				state = "Hit_1"
		"Hit_1":
			position.y = lerp(position.y, 35, 0.2)
			if position.y > 34:
				state = "Idle"


func _on_Area2D_area_entered(area):
	if state != "Idle":
		return
	if area.get_node("../").is_in_group("Player"):
		health -= 1
		state = "Hit_0"
	if health == 0:
		ready_to_boom = true
