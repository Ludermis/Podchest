extends Node

var friction = 0.2
var serverIP = "localhost"
var serverPort = 27015
var dirtCount = 0
var dirts = {}
var teams = {}
var myTeam = -1
var scores = {1: 0, 2: 0}
var endGameStats
var loggedIn = false
var username = ""
var accountInfo = {}
var adminInfo = {}
var time : float = 0 setget ,getTime
var objects = {}
var roomMaster = -1
var ping = 9999
var build = "26"
var buildConfirmed = false
var newBuildIfMineWrong

var mapSizeX = 50
var mapSizeY = 50
var selectedGamemode = "quick1v1"
var store

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
	randomize()

func logBBCode (txt):
	txt = txt.replace("[ERROR]","[color=red][ERROR][/color]")
	txt = txt.replace("[INFO]","[color=blue][INFO][/color]")
	txt = txt.replace("Lynext","[wave amp=25 freq=2] [color=#5D00FF]L[/color][color=#6B00FF]y[/color][color=#7A01FF]n[/color][color=#8802FF]e[/color][color=#9703FF]x[/color][color=#A504FF]t[/color] [/wave]")
	txt = txt.replace("Flycoder","[wave amp=25 freq=2] [color=#0AB6FF]F[/color][color=#15A7FF]l[/color][color=#2199FF]y[/color][color=#2D8AFF]c[/color][color=#397CFF]o[/color][color=#446DFF]d[/color][color=#505FFF]e[/color][color=#5C50FF]r[/color] [/wave]")
	txt = txt.replace("Regnatif","[wave amp=25 freq=2] [color=#0DBEFF]R[/color][color=#09CED8]e[/color][color=#06DEB2]g[/color][color=#03EE8C]n[/color][color=#00FF66]a[/color][color=#0AFF4C]t[/color][color=#15FF33]i[/color][color=#20FF19]f[/color] [/wave]")
	return txt

func rotatePoint(point,center,angle) -> Vector2:
	var newX = cos(angle) * (point.x - center.x) - sin(angle) * (point.y - center.y) + center.x
	var newY = sin(angle) * (point.x - center.x) + cos(angle) * (point.y - center.y) + center.y
	return Vector2(newX,newY)

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

func tryPlaceDirt (id, painter, pos, team):
	if pos.x < 0 || pos.y < -(mapSizeY - 1) * 64 || pos.x > (mapSizeX - 1) * 64 || pos.y > 0:
		return
	get_tree().root.get_node("Main").rpc_id(1,"dirtCreated", id, painter, pos, team)

func tryChangeDirt (id, painter, pos, team):
	if pos.x < 0 || pos.y < -(mapSizeY - 1) * 64 || pos.x > (mapSizeX - 1) * 64 || pos.y > 0:
		return
	get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",id, painter, pos, team)

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
