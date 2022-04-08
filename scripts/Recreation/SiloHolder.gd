extends Node2D

var ammo = [10,10,10]

func Alpha_breached(_area):
	ammo[0] = 0


func Delta_breached(_area):
	ammo[1] = 0


func Omega_breached(_area):
	ammo[2] = 0
