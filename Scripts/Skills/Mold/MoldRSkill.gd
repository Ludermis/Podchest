extends "res://Scripts/Base/Skill.gd"

var casting = false
var lastCasted = -1000
var castTime = 1.0
var castStarted = -1000
var cooldown = 4
var characterNode : Node2D
var activeTime = 10

func _ready():
	pass

func _init():
	type = "cast"

func use ():
	cast()

func findRandomEnemyPlayer():
	var rtn = characterNode.id
	for i in Vars.objects:
		if Vars.objects[i].is_in_group("Player") && Vars.objects[i].team != characterNode.team:
			rtn = Vars.objects[i].id
			break
	return rtn

func cast ():
	if findRandomEnemyPlayer() == characterNode.id:
		return
	if lastCasted + cooldown <= Vars.time && !characterNode.anySkillCasting():
		characterNode.animation = "cast"
		characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		casting = true
		characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue
		characterNode.canMove = false
		castStarted = Vars.time

func castEnd():
	characterNode.canMove = true
	characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
	casting = false
	lastCasted = Vars.time
	var foundEnemy = findRandomEnemyPlayer()
	if foundEnemy == characterNode.id:
		return
	characterNode.disguised = foundEnemy
	characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode.id,{"disguised": foundEnemy})

func update():
	if !casting:
		if lastCasted + cooldown > Vars.time:
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",(Vars.time - lastCasted) / cooldown * 100)
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.red
		else:
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",101)
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.lime
	if casting:
		characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - castStarted) / castTime * 100
		if castStarted + castTime <= Vars.time:
			castEnd()
	if characterNode.disguised != characterNode.id && Vars.time - lastCasted >= activeTime:
		print("sa")
		characterNode.disguised = characterNode.id
		characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode.id,{"disguised": characterNode.id})
