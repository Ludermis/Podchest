extends Node2D

var endPosition
var whoSummoned
var speed = 512
var planted = false
var id

func _ready():
	if Vars.myTeam != Vars.players[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.players[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	if Vars.roomMaster == Client.selfPeerID:
		if !planted:
			position = position.move_toward(endPosition,delta * speed)
		if planted == false && position.distance_to(endPosition) < 0.1:
			planted = true
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"position": position,"planted": planted})
