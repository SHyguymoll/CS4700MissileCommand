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
const REDUCE_SEIZURES = 0.3

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
			set_modulate(Color(1, 1, 1, 1))
			position.y += 0.6
			if position.y > 34:
				state = "Idle"
				gameLogic = $"../"
		"Idle":
			move()
			if shoot_timer > 0:
				shoot_timer -= 1
		"Hit_0":
			position.y = lerp(position.y, 10, 0.3)
			set_modulate(Color(rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES),rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES),rand_range(0+REDUCE_SEIZURES,1-REDUCE_SEIZURES), 1))
			if position.y < 12:
				state = "Hit_1"
		"Hit_1":
			position.y = lerp(position.y, 35, 0.2)
			set_modulate(Color(rand_range(2*(0+REDUCE_SEIZURES),(1-REDUCE_SEIZURES)/2), rand_range(2*(0+REDUCE_SEIZURES),(1-REDUCE_SEIZURES)/2), rand_range(2*(0+REDUCE_SEIZURES),(1-REDUCE_SEIZURES)/2), 1))
			if position.y > 34:
				state = "Idle"


func _on_Area2D_area_entered(area):
	if state != "Idle":
		return
	if area.get_node("../").is_in_group("Player"):
		health -= 1
		state = "Hit_0"
	if health < 1:
		ready_to_boom = true
