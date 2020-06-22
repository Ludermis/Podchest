extends Node2D

var startedTime

func _ready():
	startedTime = Vars.time

func _process (delta):
	$Time.text = Vars.timeToString(int(Vars.time - startedTime))

remote func gameStarted ():
	get_tree().change_scene("res://Prefabs/Scenes/GameScene.tscn")

remote func playerCountUpdated (count, mx):
	$Players.text = str(count) + " / " + str(mx)
