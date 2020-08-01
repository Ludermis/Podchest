extends "res://Scripts/Base/Character.gd"

var scytheActive = false setget setScytheActive
var scytheRotation = 0 setget setScytheRotation

func setScytheActive (isActive):
	scytheActive = isActive
	if isActive:
		$Schyte.visible = true
	else:
		$Schyte.visible = false

func setScytheRotation (rot):
	scytheRotation = rot
	$Schyte.rotation = rot

func inputHandler():
	if Input.is_action_just_pressed('skill1'):
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[1])
	if Input.is_action_just_pressed('skill2'):
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[2])
	if Input.is_action_just_pressed('skill3'):
		get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,id,"useSkill",[3])
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,4)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)

func _init():
	characterName = "Villager"

func readyCustom():
	pass

func _physics_process(delta):
	if id == Client.selfPeerID:
		inputHandler()
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"pressed": {"left": Input.is_action_pressed('left'), "right": Input.is_action_pressed('right'), "up": Input.is_action_pressed('up'), "down": Input.is_action_pressed('down')}})
