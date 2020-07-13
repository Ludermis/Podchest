extends Node2D


func _ready():
	rpc_id(1,"demandStore",Client.selfPeerID)

func characters ():
	$AllLabel.text = "All Characters\n" + str(Vars.store["characters"].keys().size() + 1)
	$YourLabel.text = "Your Characters\n" + str(Vars.accountInfo["ownedCharacters"].size())
	for child in $"Panel/ScrollContainer/VBoxContainer/HBoxContainer".get_children():
		child.queue_free()
	for i in Vars.accountInfo["ownedCharacters"]:
		var node = preload("res://Prefabs/UI/CharacterRect.tscn").instance()
		node.name = i
		node.texture = load("res://Sprites/UI/Characters/" + i + ".png")
		node.get_node("Label").text = i
		$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)

func skins ():
	var totalSkinCount = 0
	var mySkinCount = 0
	for i in Vars.store["skins"]:
		totalSkinCount += Vars.store["skins"][i].keys().size()
	for i in Vars.accountInfo["ownedSkins"]:
		mySkinCount += Vars.accountInfo["ownedSkins"][i].size()
	$AllLabel.text = "All Skins\n" + str(totalSkinCount)
	$YourLabel.text = "Your Skins\n" + str(mySkinCount)
	for child in $"Panel/ScrollContainer/VBoxContainer/HBoxContainer".get_children():
		child.queue_free()
	for i in Vars.accountInfo["ownedCharacters"]:
		if Vars.accountInfo["ownedSkins"].has(i):
			for j in Vars.accountInfo["ownedSkins"][i]:
				var node = preload("res://Prefabs/UI/CharacterRect.tscn").instance()
				node.name = j
				node.texture = load("res://Sprites/UI/Characters/" + j + ".png")
				node.get_node("Label").text = j
				$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)

remote func updateStore (store):
	Vars.store = store
	characters()
