extends Node2D

var ammo = [10,10,10]
var ammoReloadTimer = [0,0,0]
var baseState = ["Ready","Ready","Ready"]

func _process(_delta):
	$SiloAlpha.set_frame(10-ammo[0])
	$SiloDelta.set_frame(10-ammo[1])
	$SiloOmega.set_frame(10-ammo[2])
	$SiloAlpha/ProgressBar.set_value(ammoReloadTimer[0])
	$SiloDelta/ProgressBar.set_value(ammoReloadTimer[1])
	$SiloOmega/ProgressBar.set_value(ammoReloadTimer[2])
	$SiloAlpha/ProgressBar.hide()
	$SiloDelta/ProgressBar.hide()
	$SiloOmega/ProgressBar.hide()
	if baseState[0] == "Reloading":
		$SiloAlpha/ProgressBar.show()
	if baseState[1] == "Reloading":
		$SiloDelta/ProgressBar.show()
	if baseState[2] == "Reloading":
		$SiloOmega/ProgressBar.show()

func reload(base: int):
	baseState[base] = "Reloading"
	if ammo[base] == 10:
		return
	ammoReloadTimer[base] += 1
	if ammoReloadTimer[base] > 99:
		ammo[base] += 1
		ammoReloadTimer[base] = 0

func Alpha_breached(_area):
	ammo[0] = 0


func Delta_breached(_area):
	ammo[1] = 0


func Omega_breached(_area):
	ammo[2] = 0
