extends Node2D

var connectedFully = false

func _ready():
	pass

func _process(delta):
	if (Client.client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED && connectedFully == false):
		Client.selfPeerID = get_tree().get_network_unique_id()
		print(str("PeerID : ", Client.selfPeerID))
		rpc_id(1,"playerJoined",Client.selfPeerID)
		connectedFully = true

remote func positionUpdated (who, newPosition):
	if Vars.players.has(who):
		Vars.players[who].position = newPosition

remote func playerJoined (who, d):
	print(str("New user instanced ", who))
	var newPlayer = preload("res://Prefabs/Characters/Player.tscn").instance()
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
	var node = preload("res://Prefabs/Effects/Dirt.tscn").instance()
	print("Dirt created " + str(Vars.dirtCount))
	node.id = d["id"]
	Vars.dirts[node.id] = node
	node.position = d["position"]
	node.realColor = d["color"]
	Vars.scores[Vars.teamsByColors[node.realColor]] += 1
	get_tree().root.get_node("Main").add_child(node)
	if Vars.teamsByColors[Vars.dirts[d["id"]].realColor] != Vars.myTeam:
		Vars.dirts[d["id"]].z_index = -1
	$"CanvasLayer/Score1".text = str(Vars.scores[1])
	$"CanvasLayer/Score2".text = str(Vars.scores[2])

remote func dirtChanged (d):
	Vars.scores[Vars.teamsByColors[Vars.dirts[d["id"]].realColor]] -= 1
	Vars.dirts[d["id"]].realColor = d["color"]
	Vars.scores[Vars.teamsByColors[Vars.dirts[d["id"]].realColor]] += 1
	if Vars.teamsByColors[Vars.dirts[d["id"]].realColor] != Vars.myTeam:
		Vars.dirts[d["id"]].z_index = -1
	$"CanvasLayer/Score1".text = str(Vars.scores[1])
	$"CanvasLayer/Score2".text = str(Vars.scores[2])

remote func updateTeams (d):
	Vars.teams = d
	for i in Vars.teams:
		Vars.teamsByColors[Vars.teams[i]["color"]] = i
	$"CanvasLayer/Score1".modulate = Vars.teams[1]["color"]
	$"CanvasLayer/Score2".modulate = Vars.teams[2]["color"]
