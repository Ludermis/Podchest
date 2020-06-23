extends Node2D


func _ready():
	pass

remote func loginCompleted (info):
	Vars.username = $Container/Username.text
	Vars.accountInfo = info
	Vars.loggedIn = true
	var save = File.new()
	save.open("user://account.txt",File.WRITE)
	save.store_string(JSON.print({"loggedin": true, "username": Vars.username, "info": info}, " "))
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")

remote func loginFailed ():
	$Message.modulate = Color.red
	$Message.text = "Login failed."
	$Message.visible = true
