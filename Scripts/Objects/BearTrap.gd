extends Node2D

var endPosition
var whoSummoned
var speed = 512
var planted = false
var id
var trappedPlayer = -1
var trapTimeRemaining = 0

func _ready():
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	if trappedPlayer == Client.selfPeerID:
		Vars.objects[Client.selfPeerID].canMove = false
		Vars.objects[Client.selfPeerID].animationPlaying = false
	if Vars.roomMaster == Client.selfPeerID:
		if !planted:
			position = position.move_toward(endPosition,delta * speed)
		if planted == false && position.distance_to(endPosition) < 0.1:
			planted = true
		if planted && trappedPlayer != -1:
			trapTimeRemaining -= delta
			if trapTimeRemaining < 0:
				get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
				queue_free()
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"position": position,"planted": planted, "trapTimeRemaining": trapTimeRemaining, "trappedPlayer": trappedPlayer})
		

func _on_Area2D_body_entered(body):
	if Vars.roomMaster == Client.selfPeerID:
		if !planted:
			return
		print(str(body))
		if body.is_in_group("Player") && Vars.objects[body.id]["team"] != Vars.objects[whoSummoned]["team"]:
			trapTimeRemaining = 2
			trappedPlayer = body.id

func _on_BearTrap_tree_exited():
	if trappedPlayer == Client.selfPeerID:
		Vars.objects[Client.selfPeerID].canMove = true
