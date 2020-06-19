extends Node2D


func _ready():
	pass

remote func gameStarted ():
	get_tree().change_scene("res://Prefabs/Scenes/GameScene.tscn")
