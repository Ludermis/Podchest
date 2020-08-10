extends "res://Scripts/Base/Character.gd"

var disguised = -1 setget setDisguised

func setDisguised (who):
	if (who != -1 && !Vars.objects.has(who)) || disguised == who:
		return
	disguised = who
	#print(str(id, " ", disguised))
	if disguised == -1:
		$NameLabel.text = playerName
		$NameLabel.modulate = Vars.teams[team]["color"].blend(Color(1,1,1,0.5))
		$Skin.free()
		add_child(load("res://Prefabs/Skins/" + characterName + ".tscn").instance())
	else:
		$NameLabel.text = Vars.objects[disguised].playerName
		$NameLabel.modulate = Vars.teams[Vars.objects[disguised]["team"]]["color"].blend(Color(1,1,1,0.5))
		$Skin.free()
		add_child(load("res://Prefabs/Skins/" + Vars.objects[disguised]["characterName"] + ".tscn").instance())
	
	if !animationsNeedRotation.has(animation):
		$Skin.rotation = 0
	if $Skin/AnimationPlayer.assigned_animation != animation:
		$Skin/AnimationPlayer.play(animation)

func _init():
	characterName = "Mold"

func readyCustom():
	if id == Client.selfPeerID:
#		skills[1] = preload("res://Scripts/Skills/Xedarin/XedarinQSkill.gd").new()
#		skills[1].id = 1
#		skills[1].characterNode = id
#		skills[1].init()
#
#		skills[2] = preload("res://Scripts/Skills/Xedarin/XedarinESkill.gd").new()
#		skills[2].id = 2
#		skills[2].characterNode = id
#		skills[2].init()
		
		skills[3] = preload("res://Scripts/Skills/Mold/MoldRSkill.gd").new()
		skills[3].id = 3
		skills[3].characterNode = id
		skills[3].init()

func _physics_process(delta):
	if id == Client.selfPeerID:
		pressed = {"left": Input.is_action_pressed('left'), "right": Input.is_action_pressed('right'), "up": Input.is_action_pressed('up'), "down": Input.is_action_pressed('down')}
		skillSystem(delta)
		inputHandler()
		var dict = {}
		dict["pressed"] = pressed
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,dict)
