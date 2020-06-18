extends Node

var friction = 0.2
var serverIP = ""
var serverPort = 27015
var players = {}
var dirtCount = 0
var dirts = {}
var teams = {}
var teamsByColors = {}
var myTeam = -1
var scores = {1: 0, 2: 0}

func _ready():
	pass

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
