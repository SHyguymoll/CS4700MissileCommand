extends Node2D

var ammo = [10,10,10]

func _process(_delta):
	$SiloAlpha.set_frame(10-ammo[0])
	$SiloDelta.set_frame(10-ammo[1])
	$SiloOmega.set_frame(10-ammo[2])

func Alpha_breached(_area):
	ammo[0] = 0


func Delta_breached(_area):
	ammo[1] = 0


func Omega_breached(_area):
	ammo[2] = 0
