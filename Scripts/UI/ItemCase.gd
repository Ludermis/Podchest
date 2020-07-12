extends TextureButton

var itemType
var character
var item

func _ready():
	pass

func _on_ItemCase_pressed():
	var node = preload("res://Prefabs/Scenes/ShopConfirmationScene.tscn").instance()
	node.item = item
	node.character = character
	node.itemType = itemType
	node.texture = texture_normal
	get_tree().root.add_child(node)
