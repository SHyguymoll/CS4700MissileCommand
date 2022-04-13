extends Timer

onready var gameLogic = $"../"

var level_start = false
var info_start = false
var round_finished = false

var speed
var waitTime

func doLevelOld(levelSet: String):
	if level_start == false:
		return
	level_start = false #how to stop weirdness with yields and _process
	round_finished = false
	var currentSet = File.new()
	if currentSet.open(levelSet, File.READ):
		push_error("level at " + levelSet + " failed to load")
	speed = float(currentSet.get_line())
	waitTime = float(currentSet.get_line())
	var currentLine
	while currentSet.get_position() != currentSet.get_len():
		start(waitTime)
		yield(self, "timeout")
		currentLine = currentSet.get_line()
		for charInd in range(5):
			var parseChar = ord(currentLine[charInd])
			if parseChar < 58: #character is number
				parseChar -= 48 #subtract 58 as digits start at 58
			else: #character is uppercase letter
				parseChar -= 55 #subtract 55 to make "A" 10
			if parseChar > 35: #character is invalid, push_error and stop
				push_error("character fell out of valid number range")
				break
			match charInd:
				0:
					for _number in range(parseChar):
						gameLogic.fireEnemy(speed)
				1:
					for _number in range(parseChar):
						gameLogic.fireEnemy(speed, int(rand_range(175,275)))
				2:
					for _number in range(parseChar):
						gameLogic.fireBomb(speed)
				3:
					for _number in range(parseChar):
						gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 0)
				4:
					for _number in range(parseChar):
						gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 0)
	round_finished = true

func doLevel(speed: float = 0.1, waitTime: float = 1.0, levelNum: int = 1, normal: int = 0, split: int = 0, smart: int = 0, plane: int = 0, satellite: int = 0):
	if level_start == false:
		return
	level_start = false #how to stop weirdness with yields and _process
	round_finished = false
	while normal > 0 and split > 0 and smart > 0 and plane > 0 and satellite > 0:
		start(waitTime)
		yield(self, "timeout")
		if normal > 0:
			for repeat in range(levelNum):
				gameLogic.fireEnemy(speed)
				gameLogic.fireEnemy(speed)
				gameLogic.fireEnemy(speed)
		if split > 0:
			for repeat in range(levelNum):
				gameLogic.fireEnemy(speed, int(rand_range(175,275)))
		if smart > 0:
			for repeat in range(levelNum - 5): #smart bombs start showing at level 6
				gameLogic.fireBomb(speed)
		if plane > 0:
			for repeat in range(levelNum - 1):
				gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 0)
		if satellite > 0:
			for repeat in range(levelNum - 2):
				gameLogic.fireBomber(speed, int(rand_range(50,150)), 1 if rand_range(0,1) > 0.5 else -1, 0)
	round_finished = true

func doInfo():
	if info_start == false:
		return
	info_start = false
	gameLogic.HUD.get_node("InfoLabel/InfoLabelData").text = (
		"        1" +
		"\n\n\n" +
		str(round(float(gameLogic.levelNum)/2)) +
		"         "
	)
	gameLogic.HUD.get_node("InfoLabel").show()
	gameLogic.HUD.get_node("CoinLabel").hide()
	gameLogic.HUD.get_node("AlphaLabel").show()
	gameLogic.HUD.get_node("DeltaLabel").show()
	gameLogic.HUD.get_node("OmegaLabel").show()
	gameLogic.Silos.ammo = [10,10,10]
	start(1.5)
	yield(self, "timeout")
	gameLogic.HUD.get_node("InfoLabel").hide()
	gameLogic.gameMode = "Play"
