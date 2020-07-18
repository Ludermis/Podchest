extends Node2D

var itemType
var character
var item
var texture
var APEnabled = false
var goldEnabled = false
var gold = 0
var AP = 0

func _ready():
	$Panel/Label.text = item
	$Panel/TextureRect.texture = texture
	$Panel/APButton/HBoxContainer/Label.text = str(AP)
	$Panel/GoldButton/HBoxContainer/Label.text = str(gold)
	if Vars.accountInfo["gold"] < gold:
		$Panel/GoldButton.disabled = true
	if Vars.accountInfo["AP"] < AP:
		$Panel/APButton.disabled = true
	if !APEnabled:
		$Panel/APButton.visible = false
	if !goldEnabled:
		$Panel/GoldButton.visible = false

func _on_CloseButton_pressed():
	queue_free()

func _on_APButton_pressed():
	get_tree().root.get_node("Main").rpc_id(1,"buyFromStore",Client.selfPeerID,{"type": itemType, "item": item, "character": character, "currency": "AP"})
	queue_free()


func _on_GoldButton_pressed():
	get_tree().root.get_node("Main").rpc_id(1,"buyFromStore",Client.selfPeerID,{"type": itemType, "item": item, "character": character, "currency": "gold"})
	queue_free()
