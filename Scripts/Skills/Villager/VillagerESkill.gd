extends "res://Scripts/Base/Skill.gd"

var arrowEffect : Node2D
var effect : Node2D
var casting = false
var lastCasted = -1000
var indicating = false
var maxRange = 200
var castTime = 0.5
var castStarted = -1000
var cooldown = 7
var castLocation = Vector2.ZERO
var characterNode : Node2D

func _ready():
	pass

func _init():
	type = "skillshot"

func use ():
	indicate()

func indicate ():
	if indicating:
		indicating = false
		effect.queue_free()
		arrowEffect.queue_free()
		return
	if lastCasted + cooldown <= Vars.time && !characterNode.anySkillCasting() && !indicating:
		for i in characterNode.skills:
			if "indicating" in i && i.indicating == true:
				i.indicating = false
				i.effect.queue_free()
				i.arrowEffect.queue_free()
		indicating = true
		effect = preload("res://Prefabs/Effects/BearTrapEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		characterNode.get_tree().root.get_node("Main").add_child(effect)
		characterNode.get_tree().root.get_node("Main").add_child(arrowEffect)

func cast ():
	characterNode.animation = "cast"
	characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
	indicating = false
	casting = true
	characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.blue
	castLocation = characterNode.get_global_mouse_position()
	characterNode.canMove = false
	castStarted = Vars.time
	effect.queue_free()
	arrowEffect.queue_free()

func castEnd():
	characterNode.get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/BearTrap.tscn",{"whoSummoned": characterNode.id, "position": characterNode.position, "endPosition": castLocation})
	characterNode.canMove = true
	characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
	casting = false
	lastCasted = Vars.time

func update():
	if !casting:
		if lastCasted + cooldown > Vars.time:
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",(Vars.time - lastCasted) / cooldown * 100)
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.red
		else:
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").get_material().set_shader_param("value",101)
			characterNode.get_tree().root.get_node("Main/CanvasLayer/Skills/Skill2/Progress").modulate = Color.lime
	if indicating:
		effect.position = characterNode.get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([characterNode.position,characterNode.get_global_mouse_position()])
		var canCast = characterNode.position.distance_to(characterNode.get_global_mouse_position()) <= maxRange
		if !canCast:
			arrowEffect.default_color = Color.red
		else:
			arrowEffect.default_color = Color.cyan
		if Input.is_action_just_pressed("leftclick") && canCast:
			cast()
	if casting:
		characterNode.get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - castStarted) / castTime * 100
		if castStarted + castTime <= Vars.time:
			castEnd()
