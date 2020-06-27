extends Node

var client
var url
var selfPeerID = 0
var maxTries = 10
var tries = 0

signal connection_ok
signal connection_failed

func _ready():
	pass

func connectToServer ():
	print("Client starting...")
	client = WebSocketClient.new();
	url = str("ws://",Vars.serverIP,":",Vars.serverPort)
	client.connect_to_url(url, PoolStringArray(), true);
	get_tree().set_network_peer(client);

func _process(delta):
	if client == null:
		return
	if (client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();
		if selfPeerID == 0:
			selfPeerID = get_tree().get_network_unique_id()
			if selfPeerID != 0:
				emit_signal("connection_ok")
			tries += 1
			if tries == maxTries:
				emit_signal("connection_failed")
