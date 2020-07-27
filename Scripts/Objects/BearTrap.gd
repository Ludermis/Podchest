extends Node2D

var endPosition
var whoSummoned
var speed = 512
var planted = false
var id
var trappedPlayer = -1
var trapTimeRemaining = 0

var animationPlayed = false setget setAnimationPlayed

func setAnimationPlayed (v):
	animationPlayed = v
	if animationPlayed:
		$AnimatedSprite.play("default")

func tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func _ready():
	connect("tree_exited", self, "tree_exited")
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	if Vars.roomMaster == Client.selfPeerID:
		var dict = {}
		if !Vars.objects.has(whoSummoned):
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()
			return
		if !planted:
			position = position.move_toward(endPosition,delta * speed)
			dict["position"] = position
		if planted == false && position.distance_to(endPosition) < 0.1:
			planted = true
			dict["planted"] = planted
		if planted && trappedPlayer == -1:
			var arr = $Area2D.get_overlapping_bodies()
			for i in arr:
				_on_Area2D_body_entered(i)
		if planted && trappedPlayer != -1:
			trapTimeRemaining -= delta
			dict["trapTimeRemaining"] = trapTimeRemaining
			if trapTimeRemaining < 0:
				get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
				queue_free()
				return
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,dict)
		

func _on_Area2D_body_entered(body):
	if Vars.roomMaster == Client.selfPeerID:
		if !planted || trappedPlayer != -1:
			return
		if body.is_in_group("Player") && Vars.objects[body.id]["team"] != Vars.objects[whoSummoned]["team"]:
			trapTimeRemaining = 2
			$AnimatedSprite.play("default")
			trappedPlayer = body.id
			body.addImpact("RootImpact", {"timeRemaining": trapTimeRemaining, "animStart": "rooted", "animEnd": "rootedEnd"}, -1)
			get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"animationPlayed": true, "trappedPlayer": trappedPlayer})
