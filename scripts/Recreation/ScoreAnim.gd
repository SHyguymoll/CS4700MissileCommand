extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var value = 0
var given_pos = Vector2(0,0)
var state = "wait"

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		"wait":
			$Score.text = ""
		"start":
			$Score.text = "+" + str(value)
			position = given_pos
			state = "process"
		"process":
			position.y -= 1
			modulate.a8 -= 20
			if modulate.a8 < 10:
				queue_free()
