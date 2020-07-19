extends Node2D


func _ready():
	rpc_id(1,"demandAdminInfo",Client.selfPeerID)

func _on_CancelButton_pressed():
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")

remote func gotAdminInfo (dict):
	Vars.adminInfo = dict
	for i in Vars.adminInfo["logs"]:
		$LogsList.add_item(i)
	$LogsList.select(0)
	_on_LogsList_item_selected(0)


func _on_LogsList_item_selected(index):
	$RichTextLabel.bbcode_text = Vars.logBBCode(Vars.adminInfo["logs"][$LogsList.get_item_text(index)])
