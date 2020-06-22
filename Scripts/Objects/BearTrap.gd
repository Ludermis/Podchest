extends Node2D

var startPos
var endPos
var whoSummoned
var speed = 512
var planted = false
var summonedTime

func _ready():
	position = startPos
	if Vars.myTeam != Vars.players[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.players[whoSummoned]["team"]]["color"].darkened(0.5)

func _process(delta):
	if !planted:
		position = position.move_toward(endPos,delta * speed)
	if planted == false && position.distance_to(endPos) < 0.1:
		planted = true
