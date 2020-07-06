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
	if id != Client.selfPeerID:
		$Schyte.rotation = rot

func inputHandler():
	.inputHandler()
	if Input.is_action_just_pressed('skill1'):
		skills[0].indicate()
	if Input.is_action_just_pressed('skill2'):
		skills[1].indicate()
	if Input.is_action_just_pressed('skill3'):
		skills[2].cast()

func _init():
	characterName = "Villager"
	var skill1 = preload("res://Scripts/Skills/Villager/VillagerQSkill.gd").new()
	skill1.characterNode = self
	
	var skill2 = preload("res://Scripts/Skills/Villager/VillagerESkill.gd").new()
	skill2.characterNode = self
	
	var skill3 = preload("res://Scripts/Skills/Villager/VillagerRSkill.gd").new()
	skill3.characterNode = self
	
	skills.append(skill1)
	skills.append(skill2)
	skills.append(skill3)

func _physics_process(delta):
	animationHandler()
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		skillSystem()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		if scytheActive:
			sendingDict["scytheRotation"] = $Schyte.rotation
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)
