extends Node2D

var cities = [true, true, true, true, true, true]

func _process(_delta):
	if cities[0] == false:
		$L3.hide()
	else:
		$L3.show()
	if cities[1] == false:
		$L2.hide()
	else:
		$L2.show()
	if cities[2] == false:
		$L1.hide()
	else:
		$L1.show()
	if cities[3] == false:
		$R1.hide()
	else:
		$R1.show()
	if cities[4] == false:
		$R2.hide()
	else:
		$R2.show()
	if cities[5] == false:
		$R3.hide()
	else:
		$R3.show()

func L3_breached(_area):
	cities[0] = false


func L2_breached(_area):
	cities[1] = false


func L1_breached(_area):
	cities[2] = false


func R1_breached(_area):
	cities[3] = false


func R2_breached(_area):
	cities[4] = false


func R3_breached(_area):
	cities[5] = false
