extends "res://Scripts/Base/Character.gd"

var clocks = []

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill1'):
		skills[0].use()
	if Input.is_action_just_pressed('skill2'):
		skills[1].use()
	if Input.is_action_just_pressed('skill3'):
		skills[2].use()

func _init():
	characterName = "Xedarin"
	var skill1 = preload("res://Scripts/Skills/Xedarin/XedarinQSkill.gd").new()
	skill1.characterNode = self
	skills.append(skill1)
	
	var skill2 = preload("res://Scripts/Skills/Xedarin/XedarinESkill.gd").new()
	skill2.characterNode = self
	skills.append(skill2)
	
	var skill3 = preload("res://Scripts/Skills/Xedarin/XedarinRSkill.gd").new()
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
