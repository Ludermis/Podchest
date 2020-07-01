extends Node2D

var itemType
var character
var item
var texture

func _ready():
	$Panel/Label.text = item
	$Panel/TextureRect.texture = texture

func _on_YesButton_pressed():
	get_tree().root.get_node("Main").rpc_id(1,"buyFromStore",Client.selfPeerID,{"type": itemType, "item": item, "character": character})
	queue_free()


func _on_NoButton_pressed():
	queue_free()


func _on_CloseButton_pressed():
	queue_free()
