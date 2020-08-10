extends Node2D

var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "DefaultCharacterName"
var team = -1
var animation setget setAnimation
var id
var skills = {}
var animationsNeedRotation = ["rooted", "rootedEnd"]
var pressed = {"right": false, "left": false, "up": false, "down": false}

func setSkin (newSkin):
	if skin == newSkin:
		return
	skin = newSkin
	var toLoad = skin
	if toLoad == "":
		toLoad = characterName
	var atlas = load("res://Sprites/Characters/" + toLoad.to_lower() + ".png")
	$Skin/Body.texture.atlas = atlas
	$Skin/Head.texture.atlas = atlas
	$Skin/Leg1.texture.atlas = atlas
	$Skin/Leg2.texture.atlas = atlas
	$Skin/Hand1.texture.atlas = atlas
	$Skin/Hand2.texture.atlas = atlas

func setAnimation (anim):
	if animation == anim:
		return
	animation = anim
	if !animationsNeedRotation.has(animation):
		$Skin.rotation = 0
	if $Skin/AnimationPlayer.assigned_animation != anim:
		$Skin/AnimationPlayer.play(animation)

func setPlayerName (pName):
	if playerName == pName:
		return
	playerName = pName
	$NameLabel.text = playerName

func readyCustom():
	pass

func inputHandler():
	if Input.is_action_just_pressed('skill1'):
		skills[1].use()
	if Input.is_action_just_pressed('skill2'):
		skills[2].use()
	if Input.is_action_just_pressed('skill3'):
		skills[3].use()
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,4)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)

func skillSystem (delta):
	for i in skills:
		skills[i].update(delta)

func updateSkillInfo (which, info):
	for i in info:
		skills[which][i] = info[i]

func skillCalled (which, called, data):
	skills[which].callv(called, data)

func anySkillCasting ():
	for i in skills:
		if "casting" in skills[i] && skills[i].casting == true:
			return true
	return false

func _ready():
	$NameLabel.modulate = Vars.teams[team]["color"].blend(Color(1,1,1,0.5))
	if id == Client.selfPeerID:
		get_tree().root.get_node("Main/CanvasLayer").add_child(load("res://Prefabs/UI/CharacterSkills/" + characterName + ".tscn").instance())
	readyCustom()
