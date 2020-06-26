extends Node

var friction = 0.2
var serverIP = "176.41.149.112"
var serverPort = 27015
var dirtCount = 0
var dirts = {}
var teams = {}
var myTeam = -1
var scores = {1: 0, 2: 0}
var endGameStats
var loggedIn = false
var username = ""
var accountInfo
var time : float = 0 setget ,getTime
var objects = {}
var roomMaster = -1
var ping = 9999
var build = "3"
var newBuildIfMineWrong

var mapSizeX = 50
var mapSizeY = 50
var selectedGamemode = "quick1v1"

func clearVars():
	roomMaster = -1
	objects = {}
	dirtCount = 0
	dirts = {}
	teams = {}
	ping = 9999
	myTeam = -1
	scores = {1: 0, 2: 0}

func getTime() -> float:
	return OS.get_ticks_msec() / 1000.0

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

func tryPlaceDirt (id, pos, team):
	if pos.x < 0 || pos.y < -(mapSizeY - 1) * 64 || pos.x > (mapSizeX - 1) * 64 || pos.y > 0:
		return
	get_tree().root.get_node("Main").rpc_id(1,"dirtCreated",id,pos,team)

func tryChangeDirt (id, pos, team):
	if pos.x < 0 || pos.y < -(mapSizeY - 1) * 64 || pos.x > (mapSizeX - 1) * 64 || pos.y > 0:
		return
	get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",id,pos,team)

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
