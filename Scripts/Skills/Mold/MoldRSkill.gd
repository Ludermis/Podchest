extends "res://Scripts/Base/Skill.gd"

var casting = false
var castTime = 1.0
var cooldown = 30
var cooldownRemaining = 0
var castRemaining = castTime
var characterNode : int
var activeTime = 15
var activeTimeRemaining = activeTime
var clonesToSummon = 15

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
	data["clonesToSummon"] = clonesToSummon
	return data

func findRandomEnemyPlayer():
	var rtn = characterNode
	var idArray = []
	for i in Vars.objects:
		if Vars.objects[i].is_in_group("Player") && Vars.objects[i].team != Vars.objects[characterNode].team:
			idArray.append(i)
	if idArray.size() > 0:
		rtn = idArray[randi() % idArray.size()]
	return rtn

func cast ():
	if findRandomEnemyPlayer() == characterNode:
		return
	if Client.selfPeerID == characterNode && cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting():
		Vars.objects[characterNode].animation = "cast"
		casting = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue
		Vars.objects[characterNode].addImpact("RootImpact", {"timeRemaining": castTime, "animStart": "cast", "animEnd": "downIdle"}, -1)
		castRemaining = castTime
		activeTimeRemaining = activeTime
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])

func castEnd(castAlready):
	if Client.selfPeerID == Vars.roomMaster && !castAlready:
		casting = false
		cooldownRemaining = cooldown
		castRemaining = 9999
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"skillCalled",[id,"castEnd",[true]])
		var foundEnemy = findRandomEnemyPlayer()
		if foundEnemy == characterNode:
			return
		Vars.objects[characterNode].disguised = foundEnemy
		Vars.objects[characterNode].foundEnemy = foundEnemy
		Vars.objects[characterNode].remainingClonesToSummon = clonesToSummon
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode,{"disguised": foundEnemy, "foundEnemy": foundEnemy, "remainingClonesToSummon": clonesToSummon})
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
		if Vars.objects[characterNode].disguised != characterNode:
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
		if Vars.objects[characterNode].disguised != characterNode && activeTimeRemaining <= 0:
			Vars.objects[characterNode].disguised = characterNode
			Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode,{"disguised": characterNode})
			for i in Vars.objects[characterNode].fakeDirts:
				var dirtID = Vars.objects[characterNode].fakeDirts[i]
				if Vars.objects.has(dirtID):
					Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,dirtID)
					Vars.objects[dirtID].queue_free()
