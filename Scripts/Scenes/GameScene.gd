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
	newPlayer.setup(who,d["position"],d["color"])
	if newPlayer.peerID == Client.selfPeerID:
		print("Camera working.")
		newPlayer.add_child(preload("res://Prefabs/Misc/PlayerCamera.tscn").instance())
	add_child(newPlayer)
