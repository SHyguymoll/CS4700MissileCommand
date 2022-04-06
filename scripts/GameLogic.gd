extends Node2D


onready var HUD := $HUDAndTitleScreen
onready var Player := $PlayerCrosshair
onready var Earth := $EarthHolder

var gameMode = "Menu"
var level = 0
var highscoreTable := {}
var score = 0
var cities = {}
var bases = [0,0,0]
var targetArray = []
var missileDict = {}
var incomMissCount = 0
var incomingMissileSet = []

const SCREEN_WIDTH = 256


onready var playerMissile := preload("res://scenes/PlayerMissile.tscn")
onready var enemyMissile := preload("res://scenes/EnemyMissile.tscn")
onready var targetPointer := preload("res://scenes/TargetGraphic.tscn")
onready var missileTrail := preload("res://scenes/MissileTrail.tscn")
onready var explosion := preload("res://scenes/Explosion.tscn")
var levelSet



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
		highscoreTable["SOL"] = 100
	table.close()

func doInfoScreen(): #fluff, finish later
	HUD.get_node("CoinLabel").hide()
	HUD.get_node("AlphaLabel").show()
	HUD.get_node("DeltaLabel").show()
	HUD.get_node("OmegaLabel").show()
	cities = {$EarthHolder/CityHolder/L3: true,$EarthHolder/CityHolder/L2: true,$EarthHolder/CityHolder/L1: true,$EarthHolder/CityHolder/R1: true,$EarthHolder/CityHolder/R2: true,$EarthHolder/CityHolder/R3: true}
	bases = [10,10,10]
	gameMode = "Play"

func doTrail():
	for missile in missileDict:
		missileDict[missile][0].set_point_position(1, missile.global_position)

func checkForCollision():
	var mutateDict = missileDict.duplicate(true)
	for missile in missileDict:
		if missile.ready_to_boom:
			var newExplosion = explosion.instance()
			add_child(newExplosion)
			newExplosion.position = missile.global_position
			mutateDict.erase(missile)
			missileDict[missile][0].queue_free()
			if missileDict[missile].size() == 2:
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
			newMissile.global_position = Vector2(20,206)
		1:
			newMissile.global_position = Vector2(124,206)
			newMissile.fast = true
		2:
			newMissile.global_position = Vector2(240,206)
	var newTrail = missileTrail.instance()
	add_child(newTrail)
	newTrail.add_point(newMissile.global_position)
	newTrail.add_point(newMissile.global_position)
	newMissile.angle = newMissile.get_angle_to(Player.global_position)
	newMissile.target = Player.global_position
	newMissile.ready = true
	missileDict[newMissile] = [newTrail, newTarget]

func fireEnemy(start_location: Vector2 = Vector2(-1,-1)):
	var newMissile = enemyMissile.instance()
	add_child(newMissile)
	newMissile.global_position = Vector2(rand_range(0.3,0.7)*SCREEN_WIDTH, 0) #make sure that missiles don't go off screen
	if start_location != Vector2(-1,-1):
		newMissile.global_position = start_location
	
	var newTrail = missileTrail.instance()
	add_child(newTrail)
	newTrail.add_point(newMissile.global_position)
	newTrail.add_point(newMissile.global_position)
	newMissile.angle = newMissile.get_angle_to(targetArray[int(rand_range(0,9))] + Vector2(rand_range(0,10-level),rand_range(0,10-level)))
	newMissile.ready = true
	missileDict[newMissile] = [newTrail]

func checkForLife() -> bool:
	return cities.values()[0] or cities.values()[1] or cities.values()[2] or cities.values()[3] or cities.values()[4] or cities.values()[5]

func checkForAmmo() -> bool:
	return bases[0] > 0 or bases[1] > 0 or bases[2] > 0

func checkHealth() -> void:
	for city in cities:
		if !cities[city]:
			city.hide()

func doGame():
	$PlayerCrosshair.show()
	if checkForLife():
		if Input.is_action_just_pressed("fire_alpha") and bases[0] > 0:
			bases[0] -= 1
			$EarthHolder/SiloHolder/SiloAlpha.frame = 10 - bases[0]
			if bases[0] < 4:
				$HUDAndTitleScreen/AlphaLabel.text = "LOW"
			if bases[0] == 0:
				$HUDAndTitleScreen/AlphaLabel.text = "OUT"
			fire(0)
		if Input.is_action_just_pressed("fire_delta") and bases[1] > 0:
			bases[1] -= 1
			$EarthHolder/SiloHolder/SiloDelta.frame = 10 - bases[1]
			if bases[1] < 4:
				$HUDAndTitleScreen/DeltaLabel.text = "LOW"
			if bases[1] == 0:
				$HUDAndTitleScreen/DeltaLabel.text = "OUT"
			fire(1)
		if Input.is_action_just_pressed("fire_omega") and bases[2] > 0:
			bases[2] -= 1
			$EarthHolder/SiloHolder/SiloOmega.frame = 10 - bases[2]
			if bases[2] < 4:
				$HUDAndTitleScreen/DeltaLabel.text = "LOW"
			if bases[2] == 0:
				$HUDAndTitleScreen/DeltaLabel.text = "OUT"
			fire(2)
	if Input.is_action_just_pressed("debug_fireenemy"):
		fireEnemy()
	doTrail()
	checkForCollision()
	checkHealth()

func _ready():
	readHighScoreTable()
	targetArray = [$EarthHolder/CityHolder/L1.position,$EarthHolder/CityHolder/L2.position,$EarthHolder/CityHolder/L3.position,$EarthHolder/CityHolder/R1.position,$EarthHolder/CityHolder/R2.position,$EarthHolder/CityHolder/R3.position,$EarthHolder/SiloHolder/SiloAlpha.position,$EarthHolder/SiloHolder/SiloDelta.position,$EarthHolder/SiloHolder/SiloOmega.position]
	cities = {$EarthHolder/CityHolder/L3: false,$EarthHolder/CityHolder/L2: false,$EarthHolder/CityHolder/L1: false,$EarthHolder/CityHolder/R1: false,$EarthHolder/CityHolder/R2: false,$EarthHolder/CityHolder/R3: false}
	HUD.get_node("HighScore").text = String(highscoreTable[highscoreTable.keys()[0]])
	HUD.get_node("PlayerScore").text = String(score)
	HUD.get_node("AlphaLabel").text = ""
	HUD.get_node("DeltaLabel").text = ""
	HUD.get_node("OmegaLabel").text = ""
	HUD.get_node("CoinLabel").show()
	HUD.get_node("AlphaLabel").hide()
	HUD.get_node("DeltaLabel").hide()
	HUD.get_node("OmegaLabel").hide()

func _process(_delta):
	if gameMode == "Menu":
		if Input.is_action_pressed("start"):
			gameMode = "InfoScreen"
	if gameMode == "InfoScreen":
		doInfoScreen()
	if gameMode == "Play":
		doGame()


func L3_collision(area):
	cities[$EarthHolder/CityHolder/L3] = false


func L2_collision(area):
	cities[$EarthHolder/CityHolder/L2] = false


func L1_collision(area):
	cities[$EarthHolder/CityHolder/L1] = false


func R1_collision(area):
	cities[$EarthHolder/CityHolder/R1] = false


func R2_collision(area):
	cities[$EarthHolder/CityHolder/R2] = false


func R3_collision(area):
	cities[$EarthHolder/CityHolder/R3] = false
