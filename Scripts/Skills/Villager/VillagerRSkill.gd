extends "res://Scripts/Base/Skill.gd"

var casting = false
var castTime = 1.0
var cooldown = 25
var cooldownRemaining = 0
var castRemaining = castTime
var characterNode : int
var activeTime = 10
var activeTimeRemaining = activeTime

func _ready():
	pass

func _init():
	type = "cast"

func use ():
	if Client.selfPeerID == characterNode:
		cast()

func getSharedData ():
	var data = {}
	data["casting"] = casting
	data["castTime"] = castTime
	data["cooldown"] = cooldown
	data["cooldownRemaining"] = cooldownRemaining
	data["castRemaining"] = castRemaining
	data["activeTimeRemaining"] = activeTimeRemaining
	return data

func cast ():
	if Client.selfPeerID == characterNode && cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting():
		Vars.objects[characterNode].animation = "cast"
		casting = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue
		Vars.objects[characterNode].canMove = false
		castRemaining = castTime
		activeTimeRemaining = activeTime
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])

func castEnd(castAlready):
	if Client.selfPeerID == Vars.roomMaster && !castAlready:
		Vars.objects[characterNode].canMove = true
		Vars.objects[characterNode].animation = "downIdle"
		casting = false
		cooldownRemaining = cooldown
		castRemaining = 9999
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"skillCalled",[id,"castEnd",[true]])
		Vars.objects[characterNode].setScytheActive(true)
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode,{"canMove": true, "scytheActive": true})
	if Client.selfPeerID == characterNode:
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false

func update(delta):
	if Client.selfPeerID == characterNode:
		if !casting:
			if cooldownRemaining > 0:
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",((cooldown - cooldownRemaining) / cooldown) * 100)
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.red
			else:
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",101)
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.lime
		if casting:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (castTime - castRemaining) / castTime * 100
	if Client.selfPeerID == Vars.roomMaster:
		var dict = {}
		if Vars.objects[characterNode].scytheActive:
			activeTimeRemaining -= delta
			dict["activeTimeRemaining"] = activeTimeRemaining
		if casting:
			castRemaining -= delta
			dict["castRemaining"] = castRemaining
			if castRemaining <= 0:
				castEnd(false)
		elif cooldownRemaining > 0:
			cooldownRemaining -= delta
			dict["cooldownRemaining"] = cooldownRemaining
		if !dict.empty():
			Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,dict])
		if Vars.objects[characterNode].scytheActive && activeTimeRemaining <= 0:
			Vars.objects[characterNode].setScytheActive(false)
			Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode,{"scytheActive": false})
