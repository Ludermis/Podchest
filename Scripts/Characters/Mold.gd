extends "res://Scripts/Base/Character.gd"

var disguised setget setDisguised
var fakeDirts = {}
var remainingClonesToSummon = 0
var foundEnemy = -1

func setDisguised (who):
	disguised = who
	if disguised == id:
		$NameLabel.text = playerName
		$NameLabel.modulate = Vars.teams[team]["color"].blend(Color(1,1,1,0.5))
		$Skin.free()
		add_child(load("res://Prefabs/Skins/" + characterName + ".tscn").instance())
	elif disguised != id:
		$NameLabel.text = Vars.objects[disguised].playerName
		$NameLabel.modulate = Vars.teams[Vars.objects[disguised]["team"]]["color"].blend(Color(1,1,1,0.5))
		$Skin.free()
		add_child(load("res://Prefabs/Skins/" + Vars.objects[disguised]["characterName"] + ".tscn").instance())

func tree_exited():
	.tree_exited()
	if Client.selfPeerID == Vars.roomMaster:
		for i in fakeDirts:
			var dirtID = fakeDirts[i]
			if Vars.objects.has(dirtID):
				get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,dirtID)
				Vars.objects[dirtID].queue_free()

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill3'):
		useSkill(3)
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[3])

func _init():
	characterName = "Mold"

func readyCustom():
	disguised = id
	var skill1 = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
	skill1.id = 1
	skill1.characterNode = id
	
	var skill2 = preload("res://Scripts/Skills/Villager/VillagerESkill.gd").new()
	skill2.id = 2
	skill2.characterNode = id
	
	var skill3 = preload("res://Scripts/Skills/Mold/MoldRSkill.gd").new()
	skill3.id = 3
	skill3.characterNode = id
	
	skills[1] = skill1
	skills[2] = skill2
	skills[3] = skill3

func _on_DirtTimer_timeout():
	._on_DirtTimer_timeout()
	if Client.selfPeerID == Vars.roomMaster && disguised != id:
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !fakeDirts.has(vec) && (!Vars.dirts.has(vec) || Vars.dirts[vec]["team"] == team):
			fakeDirts[vec] = -1
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/FakeDirt.tscn",{"whoSummoned": id, "position": vec, "realColor": Vars.teams[Vars.objects[disguised]["team"]]["color"]})

func _physics_process(delta):
	animationHandler()
	skillSystem(delta)
	if Client.selfPeerID == Vars.roomMaster && remainingClonesToSummon > 0:
		get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/FakePlayer.tscn",{"whoSummoned": id, "position": position, "disguised": foundEnemy})
		remainingClonesToSummon -= 1
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"remainingClonesToSummon": remainingClonesToSummon})
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
