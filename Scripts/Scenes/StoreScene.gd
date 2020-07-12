extends Node2D

var whichScreen = "characters"

func _ready():
	rpc_id(1,"demandStore",Client.selfPeerID)

remote func buySuccessful():
	refreshStore(whichScreen)

remote func accountInfoRefreshed (info):
	Vars.accountInfo = info

func refreshStore (which):
	whichScreen = which
	for child in $"Panel/ScrollContainer/VBoxContainer/HBoxContainer".get_children():
		child.queue_free()
	$CoinLabel.text = str(Vars.accountInfo["gold"])
	$APLabel.text = str(Vars.accountInfo["AP"])
	if which == "skins":
		for i in Vars.store["skins"]:
			for j in Vars.store["skins"][i]:
				if Vars.accountInfo["ownedSkins"].has(i) && Vars.accountInfo["ownedSkins"][i].has(j):
					continue
				var node = preload("res://Prefabs/UI/ItemCase.tscn").instance()
				node.itemType = "skin"
				node.character = i
				node.item = j
				node.get_node("Label").text = j
				node.texture_normal = load("res://Sprites/UI/Characters/" + j + ".png")
				node.get_node("MoneyLabel").text = str(Vars.store["skins"][i][j]["price"])
				if Vars.accountInfo[Vars.store["skins"][i][j]["priceType"]] < Vars.store["skins"][i][j]["price"]:
					node.disabled = true
					node.self_modulate = Color.gray
				if Vars.store["skins"][i][j]["priceType"] == "AP":
					node.get_node("CoinSprite").play("AP")
					node.get_node("CoinSprite").scale = Vector2(0.4,0.4)
				$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)
	elif which == "characters":
		for i in Vars.store["characters"]:
			if Vars.accountInfo["ownedCharacters"].has(i):
				continue
			var node = preload("res://Prefabs/UI/ItemCase.tscn").instance()
			node.itemType = "character"
			node.character = i
			node.item = i
			node.get_node("Label").text = i
			node.texture_normal = load("res://Sprites/UI/Characters/" + i + ".png")
			node.get_node("MoneyLabel").text = str(Vars.store["characters"][i]["priceGold"])
			if Vars.accountInfo["gold"] < Vars.store["characters"][i]["priceGold"]:
				node.disabled = true
				node.self_modulate = Color.gray
			$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)

remote func updateStore (store):
	Vars.store = store
	refreshStore(whichScreen)
