extends "res://Scripts/Base/Character.gd"

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill1'):
		skills[0].cast()

func _init():
	characterName = "Xedarin"
	var skill1 = preload("res://Scripts/Skills/Xedarin/XedarinQSkill.gd").new()
	skill1.characterNode = self
	skills.append(skill1)

func _physics_process(delta):
	animationHandler()
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		skillSystem()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
