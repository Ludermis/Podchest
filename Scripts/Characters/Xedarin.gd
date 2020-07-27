extends "res://Scripts/Base/Character.gd"

var clocks = []

func reduceQCooldown(rdc):
	skills[1].cooldownRemaining -= rdc

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
	characterName = "Xedarin"

func readyCustom():
	var skill1 = preload("res://Scripts/Skills/Xedarin/XedarinQSkill.gd").new()
	skill1.id = 1
	skill1.characterNode = id
	
	var skill2 = preload("res://Scripts/Skills/Xedarin/XedarinESkill.gd").new()
	skill2.id = 2
	skill2.characterNode = id
	
	var skill3 = preload("res://Scripts/Skills/Xedarin/XedarinRSkill.gd").new()
	skill3.id = 3
	skill3.characterNode = id
	
	skills[1] = skill1
	skills[2] = skill2
	skills[3] = skill3

func _physics_process(delta):
	animationHandler()
	skillSystem(delta)
	impactSystem(delta)
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
