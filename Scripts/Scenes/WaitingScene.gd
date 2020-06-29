extends Node2D

var startedTime

func _ready():
	startedTime = Vars.time

func _process (delta):
	$Time.text = Vars.timeToString(int(Vars.time - startedTime))

remote func selectionStarted ():
	get_tree().change_scene("res://Prefabs/Scenes/CharacterSelectionScene.tscn")

remote func playerCountUpdated (count, mx):
	$Players.text = str(count) + " / " + str(mx)

remote func gameStarted ():
	get_tree().change_scene("res://Prefabs/Scenes/GameScene.tscn")

func _on_CancelButton_pressed():
	rpc_id(1,"leaveRoom",Client.selfPeerID)
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")
