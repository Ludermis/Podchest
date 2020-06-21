extends Node2D

func _ready():
	rpc_id(1,"readyToGetObjects",Client.selfPeerID)

func _process(delta):
	pass

remote func positionUpdated (who, newPosition):
	if Vars.players.has(who):
		Vars.players[who].position = newPosition

remote func animationUpdated (who, anim):
	if Vars.players.has(who):
		if anim != "stop":
			Vars.players[who].get_node("Sprite").play(anim)
		else:
			Vars.players[who].get_node("Sprite").stop()
			Vars.players[who].get_node("Sprite").frame = 0

remote func playerJoined (who, d):
	print(str("New user instanced ", who))
	var newPlayer = preload("res://Prefabs/Characters/Villager.tscn").instance()
	newPlayer.setup(who,d["position"],d["color"],d["team"])
	if newPlayer.peerID == Client.selfPeerID:
		print("Camera working.")
		Vars.myTeam = d["team"]
		newPlayer.add_child(preload("res://Prefabs/Misc/PlayerCamera.tscn").instance())
	add_child(newPlayer)

remote func playerDisconnected (who):
	print(str("A user disconnected ", who))
	Vars.players[who].queue_free()

remote func dirtCreated (d):
	Vars.dirtCount += 1
	var node = preload("res://Prefabs/Objects/Dirt.tscn").instance()
	#print("Dirt created " + str(Vars.dirtCount))
	node.position = d["position"]
	Vars.dirts[node.position] = node
	node.realColor = d["color"]
	node.team = d["team"]
	Vars.scores[node.team] += 1
	add_child(node)
	$"CanvasLayer/Score1".text = str(Vars.scores[1])
	$"CanvasLayer/Score2".text = str(Vars.scores[2])

remote func dirtChanged (d):
	Vars.scores[Vars.dirts[d["position"]].team] -= 1
	Vars.dirts[d["position"]].realColor = d["color"]
	Vars.dirts[d["position"]].team = d["team"]
	Vars.scores[Vars.dirts[d["position"]].team] += 1
	Vars.dirts[d["position"]].set_process(true)
	$"CanvasLayer/Score1".text = str(Vars.scores[1])
	$"CanvasLayer/Score2".text = str(Vars.scores[2])

remote func skillCast(who, data):
	if data["skill"] == "villager_skill_1":
		var node = preload("res://Prefabs/Objects/Seed.tscn").instance()
		node.startPos = data["startPosition"]
		node.endPos = data["endPosition"]
		node.area = data["area"]
		node.whoSummoned = who
		add_child(node)

remote func updateTeams (d):
	Vars.teams = d
	$"CanvasLayer/Score1".modulate = Vars.teams[1]["color"]
	$"CanvasLayer/Score2".modulate = Vars.teams[2]["color"]

remote func gameEnded (d):
	Vars.endGameStats = d
	$FPSTimer.stop()
	get_tree().change_scene("res://Prefabs/Scenes/GameOverScene.tscn")

remote func gotGameTime (time):
	$"CanvasLayer/Time".text = Vars.timeToString(time)

func _on_FPSTimer_timeout():
	$"CanvasLayer/FPS".set_text(str(Engine.get_frames_per_second()))
	rpc_id(1,"demandGameTime",Client.selfPeerID)
