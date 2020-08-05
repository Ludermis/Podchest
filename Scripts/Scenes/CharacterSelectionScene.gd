extends Node2D

var buttonGroup
var characterSelected = false
var selectedCharacter = ""

func _ready():
	buttonGroup = ButtonGroup.new()
	
	var node = preload("res://Prefabs/UI/CharacterButton.tscn").instance()
	var defaultCharacter = "Villager"
	node.name = defaultCharacter
	node.pressed = true
	node.get_node("TextureRect").texture = load("res://Sprites/UI/Characters/" + defaultCharacter + ".png")
	node.get_node("Label").text = defaultCharacter
	node.group = buttonGroup
	$"Panel/HBoxContainer".add_child(node)
	
	if Vars.loggedIn:
		for i in Vars.accountInfo["ownedCharacters"]:
			if i != defaultCharacter:
				node = preload("res://Prefabs/UI/CharacterButton.tscn").instance()
				node.name = i
				node.get_node("TextureRect").texture = load("res://Sprites/UI/Characters/" + i + ".png")
				node.get_node("Label").text = i
				node.group = buttonGroup
				$"Panel/HBoxContainer".add_child(node)

remote func gotGameTime (time, ping, upload):
	$"Time".text = Vars.timeToString(time)

remote func gameStarted ():
	get_tree().change_scene("res://Prefabs/Scenes/GameScene.tscn")

func _on_FPSTimer_timeout():
	rpc_id(1,"demandGameTime",Client.selfPeerID,OS.get_ticks_msec())
