extends Node2D


func _ready():
	pass

remote func loginCompleted (info):
	Vars.username = $Username.text
	Vars.accountInfo = info
	Vars.loggedIn = true
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")

remote func loginFailed ():
	$Message.modulate = Color.red
	$Message.text = "Login failed."
	$Message.visible = true
