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
				if Vars.store["skins"][i][j].has("gold"):
					node.goldEnabled = true
					node.gold = Vars.store["skins"][i][j]["gold"]
				if Vars.store["skins"][i][j].has("AP"):
					node.APEnabled = true
					node.AP = Vars.store["skins"][i][j]["AP"]
				node.texture_normal = load("res://Sprites/UI/Characters/" + j + ".png")
				$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)
	elif which == "characters":
		for i in Vars.store["characters"]:
			if Vars.accountInfo["ownedCharacters"].has(i):
				continue
			var node = preload("res://Prefabs/UI/ItemCase.tscn").instance()
			node.itemType = "character"
			node.character = i
			node.item = i
			node.texture_normal = load("res://Sprites/UI/Characters/" + i + ".png")
			if Vars.store["characters"][i].has("gold"):
					node.goldEnabled = true
					node.gold = Vars.store["characters"][i]["gold"]
			if Vars.store["characters"][i].has("AP"):
					node.APEnabled = true
					node.AP = Vars.store["characters"][i]["AP"]
			$"Panel/ScrollContainer/VBoxContainer/HBoxContainer".add_child(node)

remote func updateStore (store):
	Vars.store = store
	refreshStore(whichScreen)
