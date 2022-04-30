extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game = $"../../"
var speed = 1
var mode = 0

func _process(_delta):
	if game.gameMode == "PlayPersist":
		show()
		if mode == 0:
			if Input.is_action_pressed("ui_right"):
				position.x += speed
			if Input.is_action_pressed("ui_left"):
				position.x -= speed
			if Input.is_action_pressed("ui_down"):
				position.y += speed
			if Input.is_action_pressed("ui_up"):
				position.y -= speed
		else:
			position = get_global_mouse_position()
		position.x = clamp(position.x, 0, 256)
		position.y = clamp(position.y, 0, 170)
	else:
		hide()
