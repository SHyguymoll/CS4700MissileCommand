extends Node2D

var gameMode = "Menu"
var level = 0
var highscoreTable := {}
var score = 0
var cities = [false,false,false,false,false,false]
var bases = [0,0,0]
var missileDict = {}
var incomMissCount = 0

onready var playerMissile := preload("res://scenes/PlayerMissile.tscn")
onready var targetPointer := preload("res://scenes/TargetGraphic.tscn")
onready var missileTrail := preload("res://scenes/MissileTrail.tscn")
onready var explosion := preload("res://scenes/Explosion.tscn")

onready var HUD := $HUDAndTitleScreen
onready var Player := $PlayerCrosshair
onready var Earth := $EarthHolder

func readHighScoreTable():
	var table = File.new()
	var currentline
	if table.file_exists("user://highscore.csv"):
		table.open("user://highscore.csv", File.READ)
		while table.get_position() != table.get_len():
			currentline = table.get_csv_line()
			highscoreTable[currentline[0]] = int(currentline[1])
	else:
		table.open("user://highscore.csv", File.WRITE)
		table.store_csv_line(["SOL", "100"])
		table.seek(0)
		while table.get_position() != table.get_len():
			currentline = table.get_csv_line()
			highscoreTable[currentline[0]] = int(currentline[1])
	table.close()

func doInfoScreen(): #fluff, finish later
	HUD.get_node("CoinLabel").hide()
	HUD.get_node("AlphaLabel").show()
	HUD.get_node("DeltaLabel").show()
	HUD.get_node("OmegaLabel").show()
	cities = [true,true,true,true,true,true]
	bases = [10,10,10]
	gameMode = "Play"

func doTrail():
	for missile in missileDict:
		missileDict[missile][1].set_point_position(1, missile.global_position)

func checkForCollision():
	var mutateDict = missileDict.duplicate(true)
	for missile in missileDict:
		if missile.ready_to_boom:
			var newExplosion = explosion.instance()
			add_child(newExplosion)
			newExplosion.position = missile.global_position
			mutateDict.erase(missile)
			missileDict[missile][0].queue_free()
			missileDict[missile][1].queue_free()
			missile.queue_free()
			
	missileDict = mutateDict.duplicate(true)

func fire(baseID: int):
	var newTarget = targetPointer.instance()
	add_child(newTarget)
	newTarget.position = Player.global_position
	var newMissile = playerMissile.instance()
	add_child(newMissile)
	match baseID:
		0:
			newMissile.global_position = Vector2(20,207)
		1:
			newMissile.global_position = Vector2(124,207)
			newMissile.fast = true
		2:
			newMissile.global_position = Vector2(230,207)
	var newTrail = missileTrail.instance()
	add_child(newTrail)
	newTrail.add_point(newMissile.global_position)
	newTrail.add_point(newMissile.global_position)
	newMissile.angle = newMissile.get_angle_to(Player.global_position)
	newMissile.target = Player.global_position
	newMissile.ready = true
	missileDict[newMissile] = [newTarget, newTrail]

func checkForLife() -> bool:
	return cities[0] or cities[1] or cities[2] or cities[3] or cities[4] or cities[5]

func checkForAmmo() -> bool:
	return bases[0] > 0 or bases[1] > 0 or bases[2] > 0

func doGame():
	$PlayerCrosshair.show()
	if checkForLife():
		if Input.is_action_just_pressed("fire_alpha") and bases[0] > 0:
			#bases[0] -= 1
			print("Firing Alpha")
			fire(0)
		if Input.is_action_just_pressed("fire_delta") and bases[1] > 0:
			#bases[1] -= 1
			print("Firing Delta")
			fire(1)
		if Input.is_action_just_pressed("fire_omega") and bases[2] > 0:
			#bases[2] -= 1
			print("Firing Omega")
			fire(2)
	doTrail()
	checkForCollision()

func _ready():
	readHighScoreTable()
	HUD.get_node("HighScore").text = String(highscoreTable[highscoreTable.keys()[0]])
	HUD.get_node("PlayerScore").text = String(score)
	HUD.get_node("AlphaLabel").text = ""
	HUD.get_node("DeltaLabel").text = ""
	HUD.get_node("OmegaLabel").text = ""
	HUD.get_node("CoinLabel").show()
	HUD.get_node("AlphaLabel").hide()
	HUD.get_node("DeltaLabel").hide()
	HUD.get_node("OmegaLabel").hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gameMode == "Menu":
		if Input.is_action_pressed("start"):
			gameMode = "InfoScreen"
	if gameMode == "InfoScreen":
		doInfoScreen()
	if gameMode == "Play":
		doGame()
