extends Node

var client
var url
var selfPeerID

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
