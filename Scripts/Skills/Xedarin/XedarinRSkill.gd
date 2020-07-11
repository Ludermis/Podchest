extends "res://Scripts/Base/Skill.gd"

var casting = false
var lastCasted = -1000
var castTime = 1.0
var castStarted = -1000
var cooldown = 20
var characterNode : Node2D
var area = 21

func _ready():
	pass

func _init():
	type = "cast"

func use ():
	cast()

func cast ():
	if lastCasted + cooldown <= Vars.time && !characterNode.anySkillCasting():
		characterNode.animation = "cast"
		characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		casting = true
		characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue
		characterNode.canMove = false
		castStarted = Vars.time

func castEnd():
	characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Effects/Shockwave.tscn",{"position": characterNode.position})
	for x in range(1,area / 2 + 2):
		for y in range (-area / 2 + (x - 1),area / 2 + 1 - (x - 1)):
			var pos = Vars.optimizeVector(characterNode.position + Vector2(32,32),64) + Vector2(y * 64, (x - 1) * 64)
			if Vars.dirts.has(pos) && Vars.dirts[pos].team == 1:
				Vars.tryChangeDirt(Client.selfPeerID,pos,2)
			elif Vars.dirts.has(pos):
				Vars.tryChangeDirt(Client.selfPeerID,pos,1)
	for x in range(1,area / 2 + 1):
		for y in range (-area / 2 + x,area / 2 + 1 - x):
			var pos = Vars.optimizeVector(characterNode.position + Vector2(32,32),64) + Vector2(y * 64, -x * 64)
			if Vars.dirts.has(pos) && Vars.dirts[pos].team == 1:
				Vars.tryChangeDirt(Client.selfPeerID,pos,2)
			elif Vars.dirts.has(pos):
				Vars.tryChangeDirt(Client.selfPeerID,pos,1)
	
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
