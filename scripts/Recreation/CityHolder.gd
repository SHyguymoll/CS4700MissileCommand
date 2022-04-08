extends Node2D

export var cities = [true, true, true, true, true, true]

func L3_breached(_area):
	cities[0] = false
	$L3.hide()


func L2_breached(_area):
	cities[1] = false
	$L2.hide()


func L1_breached(_area):
	cities[2] = false
	$L1.hide()


func R1_breached(_area):
	cities[3] = false
	$R1.hide()


func R2_breached(_area):
	cities[4] = false
	$R2.hide()


func R3_breached(_area):
	cities[5] = false
	$R3.hide()
