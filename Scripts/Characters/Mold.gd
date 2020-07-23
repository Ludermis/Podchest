extends "res://Scripts/Base/Character.gd"

var disguised setget setDisguised

func setDisguised (who):
	disguised = who
	if disguised == id:
		$NameLabel.text = playerName
		$NameLabel.modulate = Vars.teams[team]["color"]
	elif disguised != id:
		$NameLabel.text = Vars.objects[disguised].playerName
		$NameLabel.modulate = Vars.teams[Vars.objects[disguised]["team"]]["color"]

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

func _physics_process(delta):
	animationHandler()
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		skillSystem()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
