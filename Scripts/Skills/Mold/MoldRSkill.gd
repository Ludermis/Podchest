extends "res://Scripts/Base/Skill.gd"

var casting
var castTime
var castRemaining
var cooldown
var cooldownRemaining
var characterNode : int
var gotInfo = false

func _ready():
	pass

func init ():
	type = "cast"
	Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"getSkillInfo",[characterNode,id])

func use ():
	if cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting():
		Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"useSkill",[id,{}])

func cast (data):
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.blue

func castEnd(data):
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false

func update(delta):
	if !gotInfo:
		return
	if !casting:
		if cooldownRemaining > 0:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",((cooldown - cooldownRemaining) / cooldown) * 100)
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.red
		else:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").get_material().set_shader_param("value",101)
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill3/Progress").modulate = Color.lime
	else:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (castTime - castRemaining) / castTime * 100
