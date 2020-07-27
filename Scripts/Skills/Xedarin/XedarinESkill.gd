extends "res://Scripts/Base/Skill.gd"

var casting = false
var castTime = 1.0
var cooldown = 5
var cooldownRemaining = 0
var castRemaining = castTime
var characterNode : int

func _ready():
	pass

func _init():
	type = "cast"

func getSharedData ():
	var data = {}
	data["casting"] = casting
	data["castTime"] = castTime
	data["cooldown"] = cooldown
	data["cooldownRemaining"] = cooldownRemaining
	data["castRemaining"] = castRemaining
	return data

func use ():
	if Client.selfPeerID == characterNode:
		cast()

func cast ():
	if Client.selfPeerID == characterNode && cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting():
		Vars.objects[characterNode].animation = "cast"
		casting = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.blue
		Vars.objects[characterNode].addImpact("RootImpact", {"timeRemaining": castTime, "animStart": "cast", "animEnd": "downIdle"}, -1)
		castRemaining = castTime
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])

func castEnd(castAlready):
	if Client.selfPeerID == Vars.roomMaster && !castAlready:
		for i in Vars.objects[characterNode].clocks:
			if Vars.objects.has(i):
				Vars.objects[i].returnMode = true
				Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,i,{"returnMode": true})
		casting = false
		cooldownRemaining = cooldown
		castRemaining = 9999
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"skillCalled",[id,"castEnd",[true]])
	if Client.selfPeerID == characterNode:
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false

func update(delta):
	if Client.selfPeerID == characterNode:
		if !casting:
			if cooldownRemaining > 0:
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",((cooldown - cooldownRemaining) / cooldown) * 100)
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.red
			else:
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",101)
				Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.lime
		if casting:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (castTime - castRemaining) / castTime * 100
	if Client.selfPeerID == Vars.roomMaster:
		var dict = {}
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
