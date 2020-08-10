extends "res://Scripts/Base/Character.gd"

var scytheActive = false setget setScytheActive
var scytheRotation = 0 setget setScytheRotation

func setScytheActive (isActive):
	if scytheActive == isActive:
		return
	scytheActive = isActive
	if isActive:
		$Schyte.visible = true
	else:
		$Schyte.visible = false

func setScytheRotation (rot):
	if id != Client.selfPeerID:
		scytheRotation = rot
		$Schyte.rotation = rot

func _init():
	characterName = "Villager"

func readyCustom():
	if id == Client.selfPeerID:
		skills[1] = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
		skills[1].id = 1
		skills[1].characterNode = id
		skills[1].init()
		
		skills[2] = preload("res://Scripts/Skills/Villager/VillagerESkill.gd").new()
		skills[2].id = 2
		skills[2].characterNode = id
		skills[2].init()
		
		skills[3] = preload("res://Scripts/Skills/Villager/VillagerRSkill.gd").new()
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
		if scytheActive:
			dict["scytheRotation"] = $Schyte.rotation
			dict["mousePos"] = get_global_mouse_position()
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,dict)
