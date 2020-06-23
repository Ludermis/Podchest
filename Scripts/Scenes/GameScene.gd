extends Node2D

func _ready():
	rpc_id(1,"readyToGetObjects",Client.selfPeerID)

func _process(delta):
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		rpc_id(1,"playerFocused",Client.selfPeerID)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		rpc_id(1,"playerUnfocused",Client.selfPeerID)

remote func playerJoined (who, obj, data):
	print(str("New user instanced ", who))
	var node = load(obj).instance()
	for i in data.keys():
		node.set(i,data[i])
	if node.id == Client.selfPeerID:
		print("Camera working.")
		Vars.myTeam = data["team"]
		node.add_child(preload("res://Prefabs/Misc/PlayerCamera.tscn").instance())
	Vars.objects[data["id"]] = node
	add_child(node)

remote func playerDisconnected (who):
	print(str("A user disconnected ", who))
	Vars.objects[who].queue_free()

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

remote func roomMasterChanged(newMaster):
	Vars.roomMaster = newMaster
	if Vars.roomMaster == Client.selfPeerID:
		$CanvasLayer/RoomMaster.visible = true
	else:
		$CanvasLayer/RoomMaster.visible = false

remote func objectCreated (who, obj, data):
	var node = load(obj).instance()
	for i in data.keys():
		node.set(i,data[i])
	Vars.objects[data["id"]] = node
	add_child(node)

remote func objectUpdated (who, obj, data):
	if !Vars.objects.has(obj):
		return
	var node = Vars.objects[obj]
	for i in data.keys():
		node.set(i,data[i])

remote func objectRemoved (who, obj):
	if !Vars.objects.has(obj):
		return
	Vars.objects[obj].queue_free()
	Vars.objects.erase(obj)

remote func updateTeams (d):
	Vars.teams = d
	$"CanvasLayer/Score1".modulate = Vars.teams[1]["color"]
	$"CanvasLayer/Score2".modulate = Vars.teams[2]["color"]

remote func gameEnded (d):
	Vars.endGameStats = d
	$FPSTimer.stop()
	$"CanvasLayer/Time".text = "Game Ended"
	$EndTimer.start()
	get_tree().paused = true

remote func gotGameTime (time, ping):
	Vars.ping = OS.get_ticks_msec() - ping
	$"CanvasLayer/Ping".text = str(Vars.ping) + " ms"
	$"CanvasLayer/Time".text = Vars.timeToString(time)

func _on_FPSTimer_timeout():
	$"CanvasLayer/FPS".set_text(str(Engine.get_frames_per_second()))
	rpc_id(1,"demandGameTime",Client.selfPeerID,OS.get_ticks_msec(),Vars.ping)

func _on_EndTimer_timeout():
	get_tree().paused = false
	get_tree().change_scene("res://Prefabs/Scenes/GameOverScene.tscn")
