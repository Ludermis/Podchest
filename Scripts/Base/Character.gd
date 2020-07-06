extends KinematicBody2D

var velocity = Vector2.ZERO
var acceleration = 64
var maxSpeed = 384
var id
var team = -1
var canMove = true
var limbs = {"hand1": {},"hand2": {},"leg1": {},"leg2": {},"head": {},"body": {}}
var animation = "idle" setget setAnimation
var desiredDirection = "down" setget setDesiredDirection
var direction = "down"
var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "DefaultCharacterName"
var directionsInt = {1: "down", 2: "downright", 3: "right", 4: "upright", 5: "up", 6: "upleft", 7: "left", 8: "downleft"}
var directionsString = {"down": 1,"downright": 2,"right": 3,"upright": 4,"up": 5,"upleft": 6,"left": 7,"downleft": 8}
var skills = []

func setSkin (newSkin):
	skin = newSkin
	if skin != "":
		$Body.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Head.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Leg1.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Leg2.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Hand1.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Hand2.texture.atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")

func setDesiredDirection (dir):
	desiredDirection = dir

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func setAnimation (anim):
	animation = anim

func skillSystem ():
	for i in skills:
		i.update()

func anySkillCasting ():
	for i in skills:
		if "casting" in i && i.casting == true:
			return true
	return false

func anySkillIndicating ():
	for i in skills:
		if "indicating" in i && i.indicating == true:
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
			desiredDirection = "upright"
		elif Input.is_action_pressed('left') && Input.is_action_pressed('up'):
			animation = "walk"
			desiredDirection = "upleft"
		elif Input.is_action_pressed('right') && Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "downright"
		elif Input.is_action_pressed('left') && Input.is_action_pressed('down'):
			animation = "walk"
			desiredDirection = "downleft"
		else:
			animation = "idle"
	
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,4)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)

func animationHandler ():
	if animation == "idle":
		if direction == "down":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["origin"]
			$Leg2.position = limbs["leg2"]["origin"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 0
			$Body.texture.region.position.y = 0
			
			$Hand1.z_index = 0
			$Hand2.z_index = 0
		if direction == "up":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["origin"]
			$Leg2.position = limbs["leg2"]["origin"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64
			$Body.texture.region.position.y = 64
			
			$Hand1.z_index = -1
			$Hand2.z_index = -1
		if direction == "right":
			$Hand1.position = limbs["hand1"]["originRight"]
			$Leg1.position = limbs["leg1"]["originRight"]
			$Leg2.position = limbs["leg2"]["originRight"]
			
			$Hand1.visible = true
			$Hand2.visible = false
			
			$Head.texture.region.position.y = 128
			$Body.texture.region.position.y = 128
			
			$Hand1.z_index = 0
			$Leg2.z_index = -1
		if direction == "left":
			$Hand1.position = limbs["hand1"]["originLeft"]
			$Leg1.position = limbs["leg1"]["originLeft"]
			$Leg2.position = limbs["leg2"]["originLeft"]
			
			$Hand1.visible = true
			$Hand2.visible = false
			
			$Head.texture.region.position.y = 192
			$Body.texture.region.position.y = 192
			
			$Hand1.z_index = 0
			$Leg2.z_index = 0
		if direction == "upright":
			$Hand1.position = limbs["hand1"]["originUpRight"]
			$Hand2.position = limbs["hand2"]["originUpRight"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 5
			$Body.texture.region.position.y = 64 * 5
			
			$Hand1.z_index = -1
			$Hand2.z_index = 0
		if direction == "upleft":
			$Hand1.position = limbs["hand1"]["originUpRight"]
			$Hand2.position = limbs["hand2"]["originUpRight"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 6
			$Body.texture.region.position.y = 64 * 6
			
			$Hand1.z_index = 0
			$Hand2.z_index = -1
		if direction == "downright":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 4
			$Body.texture.region.position.y = 64 * 4
			
			$Hand1.z_index = 0
			$Hand2.z_index = -1
		if direction == "downleft":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 7
			$Body.texture.region.position.y = 64 * 7
			
			$Hand1.z_index = -1
			$Hand2.z_index = 0
	elif animation == "walk":
		if direction == "down":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["origin"]
			$Leg2.position = limbs["leg2"]["origin"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 0
			$Body.texture.region.position.y = 0
			
			$Hand1.z_index = 0
			$Hand2.z_index = 0
			
			$Hand1.position.y = limbs["hand1"]["origin"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["origin"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["origin"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["origin"].y - sin(Vars.time * 20)
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "up":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["origin"]
			$Leg2.position = limbs["leg2"]["origin"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64
			$Body.texture.region.position.y = 64
			
			$Hand1.z_index = -1
			$Hand2.z_index = -1
			
			$Hand1.position.y = limbs["hand1"]["origin"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["origin"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["origin"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["origin"].y - sin(Vars.time * 20)
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "right":
			$Hand1.position = limbs["hand1"]["originRight"]
			$Leg1.position = limbs["leg1"]["originRight"]
			$Leg2.position = limbs["leg2"]["originRight"]
			
			$Hand1.visible = true
			$Hand2.visible = false
			
			$Head.texture.region.position.y = 128
			$Body.texture.region.position.y = 128
			
			$Hand1.z_index = 0
			$Leg2.z_index = -1
			
			$Hand1.position.x = limbs["hand1"]["originRight"].x + sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originRight"].y - sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originRight"].y + sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originLeft"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originLeft"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "left":
			$Hand1.position = limbs["hand1"]["originLeft"]
			$Leg1.position = limbs["leg1"]["originLeft"]
			$Leg2.position = limbs["leg2"]["originLeft"]
			
			$Hand1.visible = true
			$Hand2.visible = false
			
			$Head.texture.region.position.y = 192
			$Body.texture.region.position.y = 192
			
			$Hand1.z_index = 0
			$Leg2.z_index = 0
			
			$Hand1.position.x = limbs["hand1"]["originLeft"].x - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originLeft"].y - sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originLeft"].y + sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originLeft"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originLeft"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "upright":
			$Hand1.position = limbs["hand1"]["originUpRight"]
			$Hand2.position = limbs["hand2"]["originUpRight"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 5
			$Body.texture.region.position.y = 64 * 5
			
			$Hand1.z_index = -1
			$Hand2.z_index = 0
			
			$Hand1.position.y = limbs["hand1"]["originUpRight"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originUpRight"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originUpRight"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originUpRight"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "upleft":
			$Hand1.position = limbs["hand1"]["originUpRight"]
			$Hand2.position = limbs["hand2"]["originUpRight"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 6
			$Body.texture.region.position.y = 64 * 6
			
			$Hand1.z_index = 0
			$Hand2.z_index = -1
			
			$Hand1.position.y = limbs["hand1"]["originUpRight"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originUpRight"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originUpRight"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originUpRight"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "downright":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 4
			$Body.texture.region.position.y = 64 * 4
			
			$Hand1.z_index = 0
			$Hand2.z_index = -1
			
			$Hand1.position.y = limbs["hand1"]["origin"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["origin"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originUpRight"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originUpRight"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originUpRight"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0
		if direction == "downleft":
			$Hand1.position = limbs["hand1"]["origin"]
			$Hand2.position = limbs["hand2"]["origin"]
			$Leg1.position = limbs["leg1"]["originUpRight"]
			$Leg2.position = limbs["leg2"]["originUpRight"]
			
			$Hand1.visible = true
			$Hand2.visible = true
			
			$Head.texture.region.position.y = 64 * 7
			$Body.texture.region.position.y = 64 * 7
			
			$Hand1.z_index = -1
			$Hand2.z_index = 0
			
			$Hand1.position.y = limbs["hand1"]["origin"].y + sin(Vars.time * 20)
			$Hand2.position.y = limbs["hand2"]["origin"].y - sin(Vars.time * 20)
			$Leg1.position.y = limbs["leg1"]["originUpRight"].y + sin(Vars.time * 20)
			$Leg2.position.y = limbs["leg2"]["originUpRight"].y - sin(Vars.time * 20)
			$Leg1.position.x = limbs["leg1"]["originUpRight"].x - sin(Vars.time * 20) / 4
			$Leg2.position.x = limbs["leg2"]["originUpRight"].x + sin(Vars.time * 20) / 4
			$Head.position.y = limbs["head"]["origin"].y + sin(Vars.time * 10) / 6.0

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

func initLimbPositions ():
	limbs["hand1"]["origin"] = $Hand1.position
	limbs["hand1"]["originRight"] = $Hand1.position + Vector2(4,0)
	limbs["hand1"]["originLeft"] = $Hand1.position + Vector2(8,0)
	limbs["hand1"]["originUpRight"] = $Hand1.position + Vector2(1,0)
	
	limbs["hand2"]["origin"] = $Hand2.position
	limbs["hand2"]["originUpRight"] = $Hand2.position - Vector2(1,0)
	
	limbs["leg1"]["origin"] = $Leg1.position
	limbs["leg1"]["originRight"] = $Leg1.position + Vector2(1.5,0)
	limbs["leg1"]["originLeft"] = $Leg1.position + Vector2(1.5,0)
	limbs["leg1"]["originUpRight"] = $Leg1.position + Vector2(1,0)
	
	limbs["leg2"]["origin"] = $Leg2.position
	limbs["leg2"]["originRight"] = $Leg2.position - Vector2(1.5,0)
	limbs["leg2"]["originLeft"] = $Leg2.position - Vector2(1.5,0)
	limbs["leg2"]["originUpRight"] = $Leg2.position - Vector2(1,0)
	
	limbs["body"]["origin"] = $Body.position
	limbs["head"]["origin"] = $Head.position

func _on_DirtTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !Vars.dirts.has(vec):
			Vars.tryPlaceDirt(Client.selfPeerID,vec,team)
		elif Vars.dirts[vec].team != team:
			Vars.tryChangeDirt(Client.selfPeerID,vec,team)

func _on_DirectionTimer_timeout():
	findNextDirection()

func _ready():
	set_physics_process(true)
	$DirtTimer.start()
	if id == Client.selfPeerID:
		get_tree().root.get_node("Main/CanvasLayer").add_child(load("res://Prefabs/UI/CharacterSkills/" + characterName + ".tscn").instance())
	initLimbPositions()

func _physics_process(delta):
	pass
