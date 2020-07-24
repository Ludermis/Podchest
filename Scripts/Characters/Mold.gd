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

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill1'):
		skills[0].use()
	if Input.is_action_just_pressed('skill2'):
		skills[1].use()
	if Input.is_action_just_pressed('skill3'):
		skills[2].use()

func _init():
	disguised = id
	characterName = "Mold"
	var skill1 = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
	skill1.characterNode = self
	skills.append(skill1)
	
	var skill2 = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
	skill2.characterNode = self
	skills.append(skill2)
	
	var skill3 = preload("res://Scripts/Skills/Mold/MoldRSkill.gd").new()
	skill3.characterNode = self
	skills.append(skill3)

func _on_DirtTimer_timeout():
	._on_DirtTimer_timeout()
	if Client.selfPeerID == Vars.roomMaster && disguised != null && disguised != id:
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !fakeDirts.has(vec) && (!Vars.dirts.has(vec) || Vars.dirts[vec]["team"] == team):
			fakeDirts[vec] = -1
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/FakeDirt.tscn",{"whoSummoned": id, "position": vec, "realColor": Vars.teams[Vars.objects[disguised]["team"]]["color"]})

func _physics_process(delta):
	animationHandler()
	if id == Client.selfPeerID:
		if remainingClonesToSummon > 0:
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/FakePlayer.tscn",{"whoSummoned": id, "position": position, "disguised": foundEnemy})
			remainingClonesToSummon -= 1
		inputHandler()
		movementHandler()
		skillSystem()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		if disguised != id:
			sendingDict["remainingClonesToSummon"] = remainingClonesToSummon
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
