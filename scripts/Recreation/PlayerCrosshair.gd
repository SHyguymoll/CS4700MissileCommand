extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game = $".."
var speed = 1

func _process(_delta):
	if game.gameMode == "Play":
		show()
		if Input.is_action_pressed("ui_right"):
			position.x += speed
		if Input.is_action_pressed("ui_left"):
			position.x -= speed
		if Input.is_action_pressed("ui_down"):
			position.y += speed
		if Input.is_action_pressed("ui_up"):
			position.y -= speed
		if position.x < 0:
			position.x = 0
		if position.x > 256:
			position.x = 256
		if position.y < 0:
			position.y = 0
		if position.y > 170:
			position.y = 170
	else:
		hide()
