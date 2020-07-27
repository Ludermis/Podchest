extends "res://Scripts/Base/Skill.gd"

var arrowEffect : Node2D
var effect : Node2D
var casting = false
var indicating = false
var maxRange = 200
var castTime = 0.5
var cooldown = 7
var cooldownRemaining = 0
var castRemaining = castTime
var castLocation = Vector2.ZERO
var characterNode : int

func _ready():
	pass

func _init():
	type = "skillshot"

func getSharedData ():
	var data = {}
	data["casting"] = casting
	data["indicating"] = indicating
	data["maxRange"] = maxRange
	data["castTime"] = castTime
	data["cooldown"] = cooldown
	data["cooldownRemaining"] = cooldownRemaining
	data["castRemaining"] = castRemaining
	data["castLocation"] = castLocation
	return data

func use ():
	if Client.selfPeerID == characterNode:
		indicate()

func indicate ():
	if indicating:
		indicating = false
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,{"indicating": false}])
		effect.queue_free()
		arrowEffect.queue_free()
		return
	if cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting() && !indicating:
		for x in Vars.objects[characterNode].skills:
			var i = Vars.objects[characterNode].skills[x]
			if "indicating" in i && i.indicating == true:
				i.indicating = false
				Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[i,{"indicating": false}])
				i.effect.queue_free()
				i.arrowEffect.queue_free()
		indicating = true
		effect = preload("res://Prefabs/Effects/BearTrapEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		effect.position = Vars.objects[characterNode].get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([Vars.objects[characterNode].position,Vars.objects[characterNode].get_global_mouse_position()])
		Vars.objects[characterNode].get_tree().root.get_node("Main").add_child(effect)
		Vars.objects[characterNode].get_tree().root.get_node("Main").add_child(arrowEffect)

func cast ():
	if Client.selfPeerID == characterNode:
		Vars.objects[characterNode].animation = "cast"
		indicating = false
		casting = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.blue
		castLocation = Vars.objects[characterNode].get_global_mouse_position()
		Vars.objects[characterNode].addImpact("RootImpact", {"timeRemaining": castTime, "animStart": "cast", "animEnd": "downIdle"}, -1)
		castRemaining = castTime
		effect.queue_free()
		arrowEffect.queue_free()
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"updateSkillInfo",[id,getSharedData()])

func castEnd(castAlready):
	if Client.selfPeerID == Vars.roomMaster && !castAlready:
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/BearTrap.tscn",{"whoSummoned": characterNode, "position": Vars.objects[characterNode].position, "endPosition": castLocation})
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
		if indicating:
			effect.position = Vars.objects[characterNode].get_global_mouse_position()
			arrowEffect.points = PoolVector2Array([Vars.objects[characterNode].position,Vars.objects[characterNode].get_global_mouse_position()])
			var canCast = Vars.objects[characterNode].position.distance_to(Vars.objects[characterNode].get_global_mouse_position()) <= maxRange
			if !canCast:
				arrowEffect.default_color = Color.red
			else:
				arrowEffect.default_color = Color.cyan
			if Input.is_action_just_pressed("leftclick") && canCast:
				cast()
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
