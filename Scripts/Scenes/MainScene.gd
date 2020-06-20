extends Node2D


func _ready():
	if Client.selfPeerID == 0:
		Client.connectToServer()
		Client.connect("connection_ok",self,"connection_ok")
		Client.connect("connection_failed",self,"connection_failed")
	else:
		readyConnected()

func logged():
	$AccountPanel/AccountName.text = Vars.username
	$AccountPanel/LoginButton.visible = false
	$AccountPanel/RegisterButton.visible = false
	$AccountPanel/LogoutButton.visible = true

remote func loginCompleted (info):
	logged()

remote func loginFailed ():
	pass

func readyConnected ():
	rpc_id(1,"demandOnline",Client.selfPeerID)
	if !Vars.loggedIn:
		var save = File.new()
		if save.file_exists("user://account.txt"):
			save.open("user://account.txt", File.READ)
			var data = JSON.parse(save.get_as_text()).result
			save.close()
			print(str(data))
			Vars.username = data["username"]
			Vars.accountInfo = data["info"]
			if data["loggedin"]:
				get_tree().root.get_node("Main").rpc_id(1,"loginAccount",Client.selfPeerID,Vars.username,Vars.accountInfo["password"])
	else:
		logged()
func _process (delta):
	pass

func connection_ok ():
	print(str("PeerID : ", Client.selfPeerID))
	readyConnected()

func connection_failed ():
	get_tree().change_scene_to(preload("res://Prefabs/Scenes/ConnectionFailedScene.tscn"))

remote func updateStats (d):
	$LabelRooms.text = "Rooms : " + str(d["rooms"])
	$LabelOnline.text = "Online : " + str(d["playerCount"])

func _on_DemandStatsTimer_timeout():
	rpc_id(1,"demandOnline",Client.selfPeerID)
