extends Timer

onready var gameLogic = $"../"

var round_finished = false
var speed = 0.0

const MISSILE = 6
const SPLIT = 2
const SPEED_CRUNCH = 10
const START_TIME_SHIFT = 4
const BOMB_LEVEL_DELAY = 5
const PLANE_LEVEL_DELAY = 1
const SAT_LEVEL_DELAY = 2

func _process(_delta):
	if gameLogic.gameMode == "PlayStartLevel":
		doLevel( #fix this asap
			float(gameLogic.levelNum)/SPEED_CRUNCH, #speed
			max(0.1, START_TIME_SHIFT-log(gameLogic.levelNum)), #time between volleys
			int(round(log(gameLogic.levelNum))) + MISSILE, #normal missiles
			int(round(log(gameLogic.levelNum))) + SPLIT, #splitting missiles
			int(round(log(gameLogic.levelNum - BOMB_LEVEL_DELAY))) if gameLogic.levelNum > BOMB_LEVEL_DELAY else 0, #smart bombs (start at level 6)
			int(round(log(gameLogic.levelNum - PLANE_LEVEL_DELAY))) if gameLogic.levelNum > PLANE_LEVEL_DELAY else 0, #bombers (start at level 2)
			int(round(log(gameLogic.levelNum - SAT_LEVEL_DELAY))) if gameLogic.levelNum > SAT_LEVEL_DELAY else 0 #satellites (start at level 3)
		)
		gameLogic.gameMode = "PlayPersist"

func doLevel(newSpeed: float = 0.1, waitTime: float = 1.0, normal: int = 0, split: int = 0, smart: int = 0, plane: int = 0, satellite: int = 0):
	print([newSpeed, waitTime, normal, split, smart, plane, satellite])
	round_finished = false
	speed = newSpeed
	while normal > 0 or split > 0 or smart > 0 or plane > 0 or satellite > 0:
		start(waitTime)
		yield(self, "timeout")
		if normal > 0:
			gameLogic.fireEnemy(speed)
			gameLogic.fireEnemy(speed)
			gameLogic.fireEnemy(speed)
			normal -= 3
		if split > 0:
			gameLogic.fireEnemy(speed, int(rand_range(175,275)))
			split -= 1
		if smart > 0:
			gameLogic.fireSmartBomb(speed)
			smart -= 1
		if plane > 0:
			gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 0)
			plane -= 1
		if satellite > 0:
			gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 1)
			satellite -= 1
	round_finished = true

func doInfo():
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = (
		"        1" +
		"\n\n\n" +
		str(round(float(gameLogic.levelNum)/2)) +
		"         "
	)
	gameLogic.HUD.get_node("InfoLabel").show()
	gameLogic.HUD.get_node("CoinLabel").hide()
	gameLogic.HUD.get_node("AlphaLabel").show()
	gameLogic.HUD.get_node("AlphaLabel").text = ""
	gameLogic.HUD.get_node("DeltaLabel").show()
	gameLogic.HUD.get_node("DeltaLabel").text = ""
	gameLogic.HUD.get_node("OmegaLabel").show()
	gameLogic.HUD.get_node("OmegaLabel").text = ""
	gameLogic.HUD.get_node("PlayerScore").show()
	gameLogic.HUD.get_node("HighScore").hide()
	gameLogic.HUD.get_node("TitleText").hide()
	gameLogic.Silos.ammo = [10,10,10]
	start(1.5)
	yield(self, "timeout")
	gameLogic.HUD.get_node("InfoLabel").hide()
	gameLogic.gameMode = "PlayStart"

func levelEnd():
	for silo in gameLogic.Silos.ammo:
		gameLogic.score += 5 * round(float(gameLogic.levelNum)/2) * silo
	for city in gameLogic.Cities.cities:
		gameLogic.score += 50 * round(float(gameLogic.levelNum)/2) * int(city)
	gameLogic.scoreTotal += gameLogic.score
	while gameLogic.score > 0:
		if gameLogic.score - 10000 > 0:
			gameLogic.stored_cities += 1
		gameLogic.score -= 10000
	gameLogic.levelNum += 1
	gameLogic.score = 0
	for city in gameLogic.Cities.cities:
		if !city:
			if gameLogic.stored_cities > 0:
				gameLogic.Cities.cities[city] = true #restore city
				gameLogic.stored_cities -= 1
	doInfo()
