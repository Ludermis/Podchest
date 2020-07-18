extends TextureButton

var itemType
var character
var item
var APEnabled = false
var goldEnabled = false
var gold = 0
var AP = 0

func _ready():
	$Label.text = item
	$HBoxContainer/APContainer/Label.text = str(AP)
	$HBoxContainer/GoldContainer/Label.text = str(gold)
	if !APEnabled:
		$HBoxContainer/APContainer.visible = false
	if !goldEnabled:
		$HBoxContainer/GoldContainer.visible = false

func _on_ItemCase_pressed():
	var node = preload("res://Prefabs/Scenes/ShopConfirmationScene.tscn").instance()
	node.item = item
	node.character = character
	node.itemType = itemType
	node.APEnabled = APEnabled
	node.goldEnabled = goldEnabled
	node.gold = gold
	node.AP = AP
	node.texture = texture_normal
	get_tree().root.add_child(node)
