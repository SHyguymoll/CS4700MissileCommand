extends Timer

onready var gameLogic = $"../"

var level_start = false
var info_start = false
var round_finished = false

var speed
var waitTime

func doLevel(levelSet: String):
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

func doInfo():
	if info_start == false:
		return
	info_start = false
	gameLogic.HUD.get_node("CoinLabel").hide()
	gameLogic.HUD.get_node("AlphaLabel").show()
	gameLogic.HUD.get_node("DeltaLabel").show()
	gameLogic.HUD.get_node("OmegaLabel").show()
	gameLogic.Silos.ammo = [10,10,10]
	start(1.5)
	yield(self, "timeout")
	gameLogic.gameMode = "Play"
