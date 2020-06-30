extends TextureButton

var itemType
var character
var item

func _ready():
	pass

func _on_ItemCase_pressed():
	get_tree().root.get_node("Main").rpc_id(1,"buyFromStore",Client.selfPeerID,{"type": itemType, "item": item, "character": character})
