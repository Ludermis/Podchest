extends Node2D

var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "DefaultCharacterName"
var team = -1
var animation setget setAnimation
var id
var skills = {}
var animationsNeedRotation = ["rooted", "rootedEnd"]

func setSkin (newSkin):
	skin = newSkin
	if skin != "":
		var atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Skin/Body.texture.atlas = atlas
		$Skin/Head.texture.atlas = atlas
		$Skin/Leg1.texture.atlas = atlas
		$Skin/Leg2.texture.atlas = atlas
		$Skin/Hand1.texture.atlas = atlas
		$Skin/Hand2.texture.atlas = atlas

func setAnimation (anim):
	animation = anim
	if !animationsNeedRotation.has(animation):
		$Skin.rotation = 0
	if $Skin/AnimationPlayer.assigned_animation != anim:
		$Skin/AnimationPlayer.play(animation)

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func readyCustom():
	pass

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
