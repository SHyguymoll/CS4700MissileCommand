extends Node2D


onready var HUD := $HUDAndTitleScreen
onready var Player := $PlayerCrosshair
onready var Cities := $EarthHolder/CityHolder
onready var Silos := $EarthHolder/SiloHolder
onready var TimedVars := $GeneralTimer

var gameMode = "Menu"
var level = 0
var highscoreTable := {}
var score = 0
var targetArray = []
var missileDict = {}
var smartBombDict = {}
var explosionDict = {}
var bomberDict = {}
var incomMissCount = 0
var incomingMissileSet = []
var internal_clock = 100
var stored_cities = 0


const SCREEN_WIDTH = 256
const SPLIT_DIFFERENCE = 0.3

onready var playerMissile := preload("res://scenes/PlayerMissile.tscn")
onready var enemyMissile := preload("res://scenes/EnemyMissile.tscn")
onready var smartBomb := preload("res://scenes/SmartBomb.tscn")
onready var enemyBomber := preload("res://scenes/Bomber.tscn")
onready var targetPointer := preload("res://scenes/TargetGraphic.tscn")
onready var missileTrail := preload("res://scenes/MissileTrail.tscn")
onready var explosionScene := preload("res://scenes/Explosion.tscn")
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
		table.store_csv_line(["SOL", "7500"])
		highscoreTable["SOL"] = 7500
	table.close()

func doInfoScreen(): #fluff, finish later
	HUD.get_node("CoinLabel").hide()
	HUD.get_node("AlphaLabel").show()
	HUD.get_node("DeltaLabel").show()
	HUD.get_node("OmegaLabel").show()
	Silos.ammo = [10,10,10]
	
	gameMode = "Play"

func doTrail():
	for missile in missileDict:
		missileDict[missile][0].set_point_position(1, missile.global_position)

func checkMissileState():
	var newMissileDict = missileDict.duplicate(true)
	for missile in missileDict:
		if missile.ready_to_boom or missile.clear_me:
			if missile.ready_to_boom:
				var newExplosion = explosionScene.instance()
				add_child(newExplosion)
				newExplosion.position = missile.global_position
				explosionDict[newExplosion] = newExplosion.position
			newMissileDict.erase(missile)
			missileDict[missile][0].queue_free()
			if missileDict[missile].size() == 2 and typeof(missileDict[missile][1]) != TYPE_INT:
				missileDict[missile][1].queue_free()
			missile.queue_free()
		if missile.split_timer == 0:
			fireEnemy(missile.position, -1, newMissileDict)
			fireEnemy(missile.position, -1, newMissileDict)
	missileDict = newMissileDict.duplicate(true)

func checkSmartBombState():
	var newSmartBombDict = smartBombDict.duplicate()
	for bomb in smartBombDict:
		if bomb.ready_to_boom or bomb.clear_me:
			if bomb.ready_to_boom:
				var newExplosion = explosionScene.instance()
				add_child(newExplosion)
				newExplosion.position = bomb.global_position
				explosionDict[newExplosion] = newExplosion.position
			newSmartBombDict.erase(bomb)
			bomb.queue_free()
		else:
			bomb.explosionPositions = explosionDict
			newSmartBombDict[bomb] = bomb.position
	smartBombDict = newSmartBombDict.duplicate()

func checkBomberState():
	var newBomberDict = bomberDict.duplicate()
	for bomber in bomberDict:
		if bomber.ready_to_boom or bomber.clear_me:
			if bomber.ready_to_boom:
				var newExplosion = explosionScene.instance()
				add_child(newExplosion)
				newExplosion.position = bomber.global_position
				explosionDict[newExplosion] = newExplosion.position
			newBomberDict.erase(bomber)
			bomber.queue_free()
		if bomber.deploy_timer == 0:
			fireEnemy(bomber.position, -1, missileDict)
			bomber.deploy_timer = -1
	bomberDict = newBomberDict.duplicate()

func checkExplosionState() -> bool:
	var newExplosionDict = explosionDict.duplicate(true)
	for explosion in explosionDict:
		if explosion.finished:
			newExplosionDict.erase(explosion)
			explosion.queue_free()
	explosionDict = newExplosionDict.duplicate(true)
	if explosionDict.size() == 0:
		return false
	return true

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
	newTrail.default_color = Color("df0022ff")
	newTrail.add_point(newMissile.global_position)
	newTrail.add_point(newMissile.global_position)
	newMissile.angle = newMissile.get_angle_to(Player.global_position)
	newMissile.target = Player.global_position
	newMissile.ready = true
	missileDict[newMissile] = [newTrail, newTarget]

func pickRandomTarget():
	var target_picked = targetArray[int(rand_range(0,9))]
	return Vector2(target_picked.x + rand_range(-10+level,10-level), target_picked.y)

func fireEnemy(start_location: Vector2 = Vector2(-1,-1), split: int = -1, dictionary: Dictionary = missileDict, speed: float = 0.3):
	var newMissile = enemyMissile.instance()
	add_child(newMissile)
	newMissile.global_position = Vector2(rand_range(0,1)*SCREEN_WIDTH, 0)
	newMissile.split_timer = split
	newMissile.speed = speed
	newMissile.angle = newMissile.get_angle_to(pickRandomTarget())
	if start_location != Vector2(-1,-1):
		newMissile.global_position = start_location
		newMissile.angle += rand_range(-SPLIT_DIFFERENCE, SPLIT_DIFFERENCE)
	var newTrail = missileTrail.instance()
	add_child(newTrail)
	newTrail.default_color = Color("dfff0000")
	newTrail.add_point(newMissile.global_position)
	newTrail.add_point(newMissile.global_position)
	
	newMissile.ready = true
	dictionary[newMissile] = [newTrail, split]

func fireSmartBomb(speed: float = 0.3):
	var newBomb = smartBomb.instance()
	add_child(newBomb)
	newBomb.global_position = Vector2(rand_range(0,1)*SCREEN_WIDTH, 0)
	newBomb.speed = speed
	newBomb.target = pickRandomTarget()
	newBomb.ready = true
	smartBombDict[newBomb] = newBomb.position

func fireBomber(speed: float = 0.3, fire_timer: int = 66, facing: int = 1, type: int = 1):
	var newBomber = enemyBomber.instance()
	add_child(newBomber)
	newBomber.speed = speed
	newBomber.deploy_timer = fire_timer
	newBomber.facing = facing
	newBomber.type = type
	newBomber.global_position = Vector2(SCREEN_WIDTH, int(rand_range(90,110))) if facing == -1 else Vector2(0, int(rand_range(90,110)))
	newBomber.scale.x = facing
	bomberDict[newBomber] = newBomber.position
	newBomber.ready = true

func checkForLife() -> bool:
	return Cities.cities[0] or Cities.cities[1] or Cities.cities[2] or Cities.cities[3] or Cities.cities[4] or Cities.cities[5]

func checkForAmmo() -> bool:
	return Silos.ammo[0] > 0 or Silos.ammo[1] > 0 or Silos.ammo[2] > 0

func doResultsScreen():
	pass

func doGame():
	Player.show()
	HUD.get_node("DefendText").hide()
	if checkForLife():
		if Input.is_action_just_pressed("fire_alpha") and Silos.ammo[0] > 0:
			Silos.ammo[0] -= 1
			Silos.get_node("SiloAlpha").frame = 10 - Silos.ammo[0]
			if Silos.ammo[0] < 4:
				HUD.get_node("AlphaLabel").text = "LOW"
			if Silos.ammo[0] == 0:
				HUD.get_node("AlphaLabel").text = "OUT"
			fire(0)
		if Input.is_action_just_pressed("fire_delta") and Silos.ammo[1] > 0:
			Silos.ammo[1] -= 1
			Silos.get_node("SiloDelta").frame = 10 - Silos.ammo[1]
			if Silos.ammo[1] < 4:
				HUD.get_node("DeltaLabel").text = "LOW"
			if Silos.ammo[1] == 0:
				HUD.get_node("DeltaLabel").text = "OUT"
			fire(1)
		if Input.is_action_just_pressed("fire_omega") and Silos.ammo[2] > 0:
			Silos.ammo[2] -= 1
			Silos.get_node("SiloOmega").frame = 10 - Silos.ammo[2]
			if Silos.ammo[2] < 4:
				HUD.get_node("OmegaLabel").text = "LOW"
			if Silos.ammo[2] == 0:
				HUD.get_node("OmegaLabel").text = "OUT"
			fire(2)
	if Input.is_action_just_pressed("debug_fireenemy"):
		fireEnemy()
	if Input.is_action_just_pressed("debug_firesplit"):
		fireEnemy(Vector2(-1,-1),200)
	if Input.is_action_just_pressed("debug_firebomb"):
		fireSmartBomb()
	if Input.is_action_just_pressed("debug_firebomber"):
		fireBomber(0.5, 1000,1 if rand_range(0,1) > 0.5 else -1, 1 if rand_range(0,1) > 0.5 else 0)
	doTrail()
	checkMissileState()
	checkSmartBombState()
	checkBomberState()
	if !checkExplosionState():
		doResultsScreen()

func _ready():
	readHighScoreTable()
	targetArray = [
		Cities.get_node("L1").global_position,
		Cities.get_node("L1").global_position,
		Cities.get_node("L1").global_position,
		Cities.get_node("L1").global_position,
		Cities.get_node("L1").global_position,
		Cities.get_node("L1").global_position,
		Silos.get_node("SiloAlpha").global_position,
		Silos.get_node("SiloDelta").global_position,
		Silos.get_node("SiloOmega").global_position
	]
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

func Report_Omega(_area):
	HUD.get_node("OmegaLabel").text = "OUT"
	Silos.get_node("SiloOmega").frame = 10


func Report_Delta(_area):
	HUD.get_node("DeltaLabel").text = "OUT"
	Silos.get_node("SiloDelta").frame = 10


func Report_Alpha(_area):
	HUD.get_node("AlphaLabel").text = "OUT"
	Silos.get_node("SiloAlpha").frame = 10
