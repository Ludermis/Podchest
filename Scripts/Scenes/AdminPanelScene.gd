extends Node2D


func _ready():
	rpc_id(1,"demandAdminInfo",Client.selfPeerID,{"type": "main"})

func _on_CancelButton_pressed():
	get_tree().change_scene("res://Prefabs/Scenes/MainScene.tscn")

remote func gotAdminInfo (demand, dict):
	if demand["type"] == "main":
		Vars.adminInfo = dict
		for i in Vars.adminInfo["logs"]:
			$LogsList.add_item(i)
		$LogsList.select(0)
		_on_LogsList_item_selected(0)
	elif demand["type"] == "getLog":
		$RichTextLabel.bbcode_text = Vars.logBBCode(dict["log"])


func _on_LogsList_item_selected(index):
	rpc_id(1,"demandAdminInfo",Client.selfPeerID,{"type": "getLog", "which": $LogsList.get_item_text(index)})
