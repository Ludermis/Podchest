extends "res://Scripts/Base/Character.gd"

var scytheActive = false setget setScytheActive
var scytheRotation = 0 setget setScytheRotation

func setScytheActive (isActive):
	scytheActive = isActive
	if isActive:
		$DirtTimerScythe.start()
		$Schyte.visible = true
	else:
		$DirtTimerScythe.stop()
		$Schyte.visible = false

func setScytheRotation (rot):
	scytheRotation = rot
	$Schyte.rotation = rot

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill1'):
		useSkill(1)
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[1])
	if Input.is_action_just_pressed('skill2'):
		useSkill(2)
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[2])
	if Input.is_action_just_pressed('skill3'):
		useSkill(3)
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[3])

func _init():
	characterName = "Villager"

func readyCustom():
	var skill1 = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
	skill1.id = 1
	skill1.characterNode = id
	
	var skill2 = preload("res://Scripts/Skills/Villager/VillagerESkill.gd").new()
	skill2.id = 2
	skill2.characterNode = id
	
	var skill3 = preload("res://Scripts/Skills/Villager/VillagerRSkill.gd").new()
	skill3.id = 3
	skill3.characterNode = id
	
	skills[1] = skill1
	skills[2] = skill2
	skills[3] = skill3

func _physics_process(delta):
	animationHandler()
	skillSystem(delta)
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		if scytheActive:
			sendingDict["scytheRotation"] = $Schyte.rotation
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
