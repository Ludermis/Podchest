extends "res://Scripts/Base/Skill.gd"

var arrowEffect : Node2D
var effect : Node2D
var casting
var indicating = false
var maxRange
var area
var castTime
var cooldown
var cooldownRemaining
var castRemaining
var castLocation = Vector2.ZERO
var characterNode : int
var gotInfo = false

func _ready():
	pass

func init ():
	type = "skillshot"
	Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"getSkillInfo",[characterNode,id])

func use ():
	indicate()

func cast (data):
	castLocation = data["castLocation"]
	indicating = false
	effect.queue_free()
	arrowEffect.queue_free()
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.blue

func castEnd(data):
	Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false

func indicate ():
	if indicating:
		indicating = false
		effect.queue_free()
		arrowEffect.queue_free()
		return
	if cooldownRemaining <= 0 && !Vars.objects[characterNode].anySkillCasting() && !indicating:
		for x in Vars.objects[characterNode].skills:
			var i = Vars.objects[characterNode].skills[x]
			if "indicating" in i && i.indicating == true:
				i.indicating = false
				i.effect.queue_free()
				i.arrowEffect.queue_free()
		indicating = true
		effect = preload("res://Prefabs/Effects/BearTrapEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		effect.position = Vars.objects[characterNode].get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([Vars.objects[characterNode].position,Vars.objects[characterNode].get_global_mouse_position()])
		Vars.objects[characterNode].get_tree().root.get_node("Main").add_child(effect)
		Vars.objects[characterNode].get_tree().root.get_node("Main").add_child(arrowEffect)

func update(delta):
	if !gotInfo:
		return
	if !casting:
		if cooldownRemaining > 0:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",((cooldown - cooldownRemaining) / cooldown) * 100)
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.red
		else:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",101)
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.lime
	else:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (castTime - castRemaining) / castTime * 100
	if indicating:
		effect.position = Vars.objects[characterNode].get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([Vars.objects[characterNode].position,Vars.objects[characterNode].get_global_mouse_position()])
		var canCast = Vars.objects[characterNode].position.distance_to(Vars.objects[characterNode].get_global_mouse_position()) <= maxRange
		if !canCast:
			arrowEffect.default_color = Color.red
		else:
			arrowEffect.default_color = Color.cyan
		if Input.is_action_just_pressed("leftclick") && canCast:
			castLocation = Vars.objects[characterNode].get_global_mouse_position()
			Vars.objects[characterNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,characterNode,"useSkill",[id,{"castLocation": castLocation}])
		if casting:
			Vars.objects[characterNode].get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (castTime - castRemaining) / castTime * 100
