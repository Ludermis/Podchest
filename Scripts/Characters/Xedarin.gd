extends "res://Scripts/Base/Character.gd"

func inputHandler():
	if Input.is_action_just_pressed('skill1'):
		skills[1].use()
	if Input.is_action_just_pressed('skill2'):
		skills[2].use()
	if Input.is_action_just_pressed('skill3'):
		skills[3].use()
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,4)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)

func _init():
	characterName = "Xedarin"

func readyCustom():
	if id == Client.selfPeerID:
		skills[1] = preload("res://Scripts/Skills/Xedarin/XedarinQSkill.gd").new()
		skills[1].id = 1
		skills[1].characterNode = id
		skills[1].init()
		
		skills[2] = preload("res://Scripts/Skills/Xedarin/XedarinESkill.gd").new()
		skills[2].id = 2
		skills[2].characterNode = id
		skills[2].init()
		
		skills[3] = preload("res://Scripts/Skills/Xedarin/XedarinRSkill.gd").new()
		skills[3].id = 3
		skills[3].characterNode = id
		skills[3].init()

func _physics_process(delta):
	if id == Client.selfPeerID:
		pressed = {"left": Input.is_action_pressed('left'), "right": Input.is_action_pressed('right'), "up": Input.is_action_pressed('up'), "down": Input.is_action_pressed('down')}
		skillSystem(delta)
		inputHandler()
		var dict = {}
		dict["pressed"] = pressed
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,dict)
