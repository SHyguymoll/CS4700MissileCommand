extends Timer

onready var gameLogic = $"../"

var round_finished = false
var boss_finished = true
var firing_finished = false
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
		round_finished = false
		speed = float(gameLogic.levelNum)/SPEED_CRUNCH
		if gameLogic.variantMode:
			gameLogic.fireMAD()
			
			boss_finished = false
			round_finished = true
		else:
			doLevel(
				max(0.1, START_TIME_SHIFT - log(gameLogic.levelNum)), #time between volleys
				int(round(log(gameLogic.levelNum))) + MISSILE, #normal missiles
				int(round(log(gameLogic.levelNum))) + SPLIT, #splitting missiles
				int(round(log(gameLogic.levelNum - BOMB_LEVEL_DELAY))) if gameLogic.levelNum > BOMB_LEVEL_DELAY else 0, #smart bombs (start at level 6)
				int(round(log(gameLogic.levelNum - PLANE_LEVEL_DELAY))) if gameLogic.levelNum > PLANE_LEVEL_DELAY else 0, #bombers (start at level 2)
				int(round(log(gameLogic.levelNum - SAT_LEVEL_DELAY))) if gameLogic.levelNum > SAT_LEVEL_DELAY else 0 #satellites (start at level 3)
			)
		gameLogic.gameMode = "PlayPersist"
	if gameLogic.gameMode == "PlayPersist":
		if boss_finished and firing_finished and gameLogic.explosionDict.size() == 0:
			round_finished = true

func doLevel(waitTime: float = 1.0, normal: int = 0, split: int = 0, smart: int = 0, plane: int = 0, satellite: int = 0):
	firing_finished = false
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
			gameLogic.fireBomber(speed, int(rand_range(100,200)), 1 if rand_range(0,1) > 0.5 else -1, 0)
			plane -= 1
		if satellite > 0:
			gameLogic.fireBomber(speed, int(rand_range(150,250)), 1 if rand_range(0,1) > 0.5 else -1, 1)
			satellite -= 1
	firing_finished = true

func doInfo():
	gameLogic.HUD.get_node("InfoLabel").text = (
		"CURSOR: ARROW KEYS\n" +
		"CAN'T FIRE AT YOURSELF\n" +
		"SOME MISSILES SPLIT\n" +
		"HARDER EVERY LEVEL\n" +
		"GOOD LUCK"
	)
	if gameLogic.variantMode:
		gameLogic.HUD.get_node("InfoLabel").text = (
			"CURSOR: ARROW KEYS\n" +
			"CAN'T FIRE AT YOURSELF\n" +
			"ONLY ONE TARGET\n" +
			"HARDER EVERY LEVEL\n" +
			"RELOAD WITH SECOND KEY"
		)
	gameLogic.HUD.get_node("InfoLabel").show()
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").hide()
	gameLogic.HUD.get_node("CoinLabel").hide()
	
	gameLogic.HUD.get_node("AlphaLabel").text = "A"
	gameLogic.HUD.get_node("DeltaLabel").text = "S"
	gameLogic.HUD.get_node("OmegaLabel").text = "D"
	if gameLogic.variantMode:
		gameLogic.HUD.get_node("AlphaLabel").text = "A, Q"
		gameLogic.HUD.get_node("DeltaLabel").text = "S, W"
		gameLogic.HUD.get_node("OmegaLabel").text = "D, E"
	
	gameLogic.HUD.get_node("AlphaLabel").show()
	gameLogic.HUD.get_node("DeltaLabel").show()
	gameLogic.HUD.get_node("OmegaLabel").show()
	gameLogic.HUD.get_node("PlayerScore").show()
	gameLogic.HUD.get_node("HighScore").hide()
	gameLogic.HUD.get_node("TitleText").hide()
	gameLogic.HUD.get_node("VariantSwitch").hide()
	start(3)
	yield(self, "timeout")
	gameLogic.gameMode = "InfoStart"

func doRoundStart():
	gameLogic.HUD.get_node("InfoLabel").text = " PLAYER  \n\n\n  X POINTS"
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = (
		"        1\n\n\n" +
		str(round(float(gameLogic.levelNum)/2)) +
		"         "
	)
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").show()
	gameLogic.HUD.get_node("InfoLabel").show()
	gameLogic.HUD.get_node("AlphaLabel").text = ""
	gameLogic.HUD.get_node("DeltaLabel").text = ""
	gameLogic.HUD.get_node("OmegaLabel").text = ""
	if !gameLogic.variantMode:
		gameLogic.Silos.ammo = [10,10,10]
	if gameLogic.variantMode:
		if fmod(gameLogic.levelNum, 3) == 0:
			gameLogic.HUD.get_node("VariantBonus").show()
	start(1.5)
	yield(self, "timeout")
	gameLogic.HUD.get_node("VariantBonus").hide()
	gameLogic.HUD.get_node("InfoLabel").hide()
	gameLogic.HUD.get_node("DefendText").hide()
	gameLogic.gameMode = "PlayStart"

func gameEnd():
	start(3)
	yield(self, "timeout")
	gameLogic.gameMode = "Reset"

func levelEnd():
	gameLogic.HUD.get_node("InfoLabel").text = "SCORE:"
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = "\n\n" + str(gameLogic.scoreTotal)
	gameLogic.HUD.get_node("InfoLabel").show()
	gameLogic.HUD.get_node("PlayerScore").hide()
	var current_thing = 0
	if !gameLogic.variantMode:
		for silo in gameLogic.Silos.ammo:
			for _ammo in range(silo):
				gameLogic.score += 5 * round(float(gameLogic.levelNum)/2)
				gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = "\n\n" + str(gameLogic.scoreTotal + gameLogic.score)
				var newLabel = gameLogic.popupLabel.instance()
				gameLogic.add_child(newLabel)
				newLabel.value = 5 * round(float(gameLogic.levelNum)/2)
				newLabel.given_pos = gameLogic.targetArray[current_thing + 6]
				newLabel.state = "start"
				start(0.1)
				yield(self, "timeout")
			current_thing += 1
		current_thing = 0
	for city in gameLogic.Cities.cities:
		gameLogic.score += 50 * round(float(gameLogic.levelNum)/2) * int(city)
		gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = "\n\n" + str(gameLogic.scoreTotal + gameLogic.score)
		if city:
			var newLabel = gameLogic.popupLabel.instance()
			gameLogic.add_child(newLabel)
			newLabel.value = 50 * round(float(gameLogic.levelNum)/2)
			newLabel.given_pos = gameLogic.targetArray[current_thing]
			newLabel.state = "start"
		start(0.2)
		yield(self, "timeout")
		current_thing += 1
	gameLogic.scoreTotal += gameLogic.score
	gameLogic.score = 0
	if gameLogic.variantMode:
		if fmod(gameLogic.levelNum, 3) == 0:
			gameLogic.stored_cities += 1
	else:
		while gameLogic.scoreTotal > gameLogic.bonus_minimum:
			gameLogic.stored_cities += 1
			gameLogic.bonus_minimum += 5000
	gameLogic.levelNum += 1
	for city in len(gameLogic.Cities.cities):
		if !gameLogic.Cities.cities[city]:
			if gameLogic.stored_cities > 0:
				gameLogic.Cities.cities[city] = true #restore city
				gameLogic.stored_cities -= 1
				gameLogic.HUD.get_node("InfoLabel").text = "SCORE:\n\n\n\nBONUS CITY"
	start(1.0)
	yield(self, "timeout")
	doRoundStart()
