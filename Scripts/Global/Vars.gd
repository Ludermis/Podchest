extends Node

var friction = 0.2
var serverIP = "176.41.149.112"
var serverPort = 27015
var players = {}
var dirtCount = 0
var dirts = {}
var teams = {}
var myTeam = -1
var scores = {1: 0, 2: 0}
var endGameStats

func clearVars():
	players = {}
	dirtCount = 0
	dirts = {}
	teams = {}
	myTeam = -1
	scores = {1: 0, 2: 0}

func _ready():
	pass

func timeToString (t):
	var rtn = ""
	var minutes = int(t / 60)
	if minutes < 10:
		rtn += "0"
	rtn += str(minutes)
	rtn += ":"
	var seconds = int(t) % 60
	if seconds < 10:
		rtn += "0"
	rtn += str(seconds)
	return rtn

func optimizeVector(pos, opt):
	var newv = Vector2.ZERO;
	var nx = fmod(pos.x,opt);
	var ny = fmod(pos.y,opt);
	if (nx < 0):
		nx += opt;
	if (ny < 0):
		ny += opt;
	newv.x = pos.x - nx
	newv.y = pos.y - ny;
	return newv;
