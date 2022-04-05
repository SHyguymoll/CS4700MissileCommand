extends Node2D

var gameMode = "Menu"
var level = 0
var highscoreTable := {}
var score = 0
var cities = [false,false,false,false,false,false]
var bases = [0,0,0]
var incomMissCount = 0

onready var HUD := $HUDAndTitleScreen
onready var Player := $PlayerCrosshair
onready var Earth := $EarthHolder

func readHighScoreTable():
	var table = File.new()
	if table.file_exists("user://data/highscore.csv"):
		table.open("user://data/highscore.csv", File.READ)
		var currentline
		while table.get_position != table.get_len():
			currentline = table.get_csv_line()
			highscoreTable[currentline[1]] = int(currentline[2])
	else:
		highscoreTable["SOL"] = 100

func doInfoScreen(): #fluff, finish later
	HUD.get_node("CoinLabel").hide()
	HUD.get_node("AlphaLabel").show()
	HUD.get_node("DeltaLabel").show()
	HUD.get_node("OmegaLabel").show()
	cities = [1,1,1,1,1,1]
	bases = [10,10,10]
	gameMode = "Play"

func checkForLife() -> bool:
	return cities[0] or cities[1] or cities[2] or cities[3] or cities[4] or cities[5]

func checkForAmmo() -> bool:
	return bases[0] > 0 or bases[1] > 0 or bases[2] > 0

func doGame():
	$PlayerCrosshair.show()
	if checkForLife():
		if Input.is_action_just_pressed("fire_alpha") and bases[0] > 0:
			bases[0] -= 1
		if Input.is_action_just_pressed("fire_delta") and bases[1] > 0:
			bases[1] -= 1
		if Input.is_action_just_pressed("fire_omega") and bases[2] > 0:
			bases[2] -= 1

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
