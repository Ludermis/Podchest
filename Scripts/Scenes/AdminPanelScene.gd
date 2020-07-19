extends Node2D


func _ready():
	rpc_id(1,"demandAdminInfo",Client.selfPeerID)

func _on_CancelButton_pressed():
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")

remote func gotAdminInfo (dict):
	Vars.adminInfo = dict
	$RichTextLabel.bbcode_text = dict["currentLog"]
