extends "res://Scripts/Base/Skill.gd"

var casting = false
var lastCasted = -1000
var castTime = 1.0
var castStarted = -1000
var cooldown = 25
var characterNode : Node2D
var activeTime = 10

func _ready():
	pass

func _init():
	type = "cast"

func cast ():
	if lastCasted + cooldown <= Vars.time && !characterNode.anySkillCasting():
		characterNode.animation = "cast"
		characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		casting = true
		characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue
		characterNode.canMove = false
		castStarted = Vars.time

func castEnd():
	characterNode.setScytheActive(true)
	characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode.id,{"scytheActive": true})
	characterNode.canMove = true
	characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
	casting = false
	lastCasted = Vars.time

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
	if characterNode.scytheActive && Vars.time - lastCasted >= activeTime:
		characterNode.setScytheActive(false)
		characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,characterNode.id,{"scytheActive": false})
