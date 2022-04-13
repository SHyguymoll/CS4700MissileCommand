extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game = $".."
var speed = 1

func _process(_delta):
	if game.gameMode == "PlayPersist":
		show()
		if Input.is_action_pressed("ui_right"):
			position.x += speed
		if Input.is_action_pressed("ui_left"):
			position.x -= speed
		position.x = clamp(position.x, 0, 256)
		if Input.is_action_pressed("ui_down"):
			position.y += speed
		if Input.is_action_pressed("ui_up"):
			position.y -= speed
		position.y = clamp(position.y, 0, 170)
	else:
		hide()
