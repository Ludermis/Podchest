extends KinematicBody2D

var velocity = Vector2.ZERO
var acceleration = 64
var maxSpeed = 384
var id
var team = -1
var canMove = true
var animation = "idle" setget setAnimation
var desiredDirection = "down" setget setDesiredDirection
var direction = "down"
var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "DefaultCharacterName"
var directionsInt = {1: "down", 2: "downRight", 3: "right", 4: "upRight", 5: "up", 6: "upLeft", 7: "left", 8: "downLeft"}
var directionsString = {"down": 1,"downRight": 2,"right": 3,"upRight": 4,"up": 5,"upLeft": 6,"left": 7,"downLeft": 8}
var skills = {}

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

func setDesiredDirection (dir):
	desiredDirection = dir

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func setAnimation (anim):
	animation = anim

func skillSystem (delta):
	for i in skills:
		skills[i].update(delta)

func useSkill (which):
	skills[which].use()

func updateSkillInfo (which, data):
	for i in data:
		skills[which].set(i,data[i])

func skillCalled (which, funcName, data):
	skills[which].callv(funcName,data)

func anySkillCasting ():
	for i in skills:
		if "casting" in skills[i] && skills[i].casting == true:
			return true
	return false

func anySkillIndicating ():
	for i in skills:
		if "indicating" in skills[i] && skills[i].indicating == true:
			return true
	return false

func movementHandler ():
	if canMove:
		if Input.is_action_pressed('right'):
			velocity.x = min(velocity.x + acceleration, maxSpeed)
		elif Input.is_action_pressed('left'):
			velocity.x = max(velocity.x - acceleration, -maxSpeed)
		else:
			velocity.x = lerp(velocity.x,0,Vars.friction)
		if Input.is_action_pressed('down'):
			velocity.y = min(velocity.y + acceleration, maxSpeed)
		elif Input.is_action_pressed('up'):
			velocity.y = max(velocity.y - acceleration, -maxSpeed)
		else:
			velocity.y = lerp(velocity.y,0,Vars.friction)
	else:
		velocity.y = lerp(velocity.y,0,Vars.friction)
		velocity.x = lerp(velocity.x,0,Vars.friction)
	velocity = move_and_slide(velocity,Vector2.UP)

func inputHandler ():
	if canMove:
		if Input.is_action_pressed('down') && !Input.is_action_pressed('right') && !Input.is_action_pressed('left'):
			animation = "walk"
			desiredDirection = "down"
		elif Input.is_action_pressed('up') && !Input.is_action_pressed('right') && !Input.is_action_pressed('left'):
			animation = "walk"
			desiredDirection = "up"
		elif Input.is_action_pressed('right') && !Input.is_action_pressed('up') && !Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "right"
		elif Input.is_action_pressed('left') && !Input.is_action_pressed('up') && !Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "left"
		elif Input.is_action_pressed('right') && Input.is_action_pressed('up'):
			animation = "walk"
			desiredDirection = "upRight"
		elif Input.is_action_pressed('left') && Input.is_action_pressed('up'):
			animation = "walk"
			desiredDirection = "upLeft"
		elif Input.is_action_pressed('right') && Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "downRight"
		elif Input.is_action_pressed('left') && Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "downLeft"
		else:
			animation = "idle"
	
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,4)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)

func animationHandler ():
	if animation == "idle":
		if $Skin/AnimationPlayer.assigned_animation != direction + "Idle":
			$Skin/AnimationPlayer.play(direction + "Idle")
	elif animation == "walk":
		if $Skin/AnimationPlayer.assigned_animation != direction + "Walk":
			$Skin/AnimationPlayer.play(direction + "Walk")
	else:
		if $Skin/AnimationPlayer.assigned_animation != animation:
			$Skin/AnimationPlayer.play(animation)

func findNextDirection ():
	if desiredDirection == direction:
		return
	var dir = 1
	if directionsString[direction] < directionsString[desiredDirection]:
		dir = 1
		if abs(directionsString[direction] - directionsString[desiredDirection]) > 4:
			dir = -1
	else:
		dir = -1
		if abs(directionsString[direction] - directionsString[desiredDirection]) > 4:
			dir = 1
	var next = directionsString[direction] + dir
	if next == 9:
		next = 1
	elif next == 0:
		next = 8
	direction = directionsInt[next]

func _on_DirtTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !Vars.dirts.has(vec):
			Vars.tryPlaceDirt(Client.selfPeerID,id,vec,team)
		elif Vars.dirts[vec].team != team:
			Vars.tryChangeDirt(Client.selfPeerID,id,vec,team)

func _on_DirectionTimer_timeout():
	if animation == "walk" || animation == "idle":
		findNextDirection()

func tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func readyCustom():
	pass

func _ready():
	connect("tree_exiting", self, "tree_exited")
	set_physics_process(true)
	$NameLabel.modulate = Vars.teams[team]["color"].blend(Color(1,1,1,0.5))
	$DirtTimer.start()
	if id == Client.selfPeerID:
		get_tree().root.get_node("Main/CanvasLayer").add_child(load("res://Prefabs/UI/CharacterSkills/" + characterName + ".tscn").instance())
	readyCustom()

func _physics_process(delta):
	pass
