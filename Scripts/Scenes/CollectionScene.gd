extends Node2D


func _ready():
	for i in Vars.accountInfo["ownedCharacters"]:
		var node = preload("res://Prefabs/UI/CharacterRect.tscn").instance()
		node.name = i
		node.texture = load("res://Sprites/UI/Characters/" + i + ".png")
		node.get_node("Label").text = i
		$"TabContainer/Characters/ItemList".add_child(node)
