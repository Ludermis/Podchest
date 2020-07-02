extends KinematicBody2D

var velocity = Vector2.ZERO
var jumpHeight = 1024
var acceleration = 64
var maxSpeed = 384
var id
var team = -1
var canMove = true
var arrowEffect : Node2D
var limbs = {"hand1": {},"hand2": {},"leg1": {},"leg2": {},"head": {},"body": {}}

var animation = "idle" setget setAnimation
var desiredDirection = "down"
var direction = "down" setget setDirection
var scytheActive = false setget setScytheActive
var scytheRotation = 0 setget setScytheRotation
var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "Villager"
var directionsInt = {1: "down", 2: "downright", 3: "right", 4: "upright", 5: "up", 6: "upleft", 7: "left", 8: "downleft"}
var directionsString = {"down": 1,"downright": 2,"right": 3,"upright": 4,"up": 5,"upleft": 6,"left": 7,"downleft": 8}

var skills = 	{1:
					{
						"effect": null, "casting": false, "lastCasted": -1000,
						"indicating": false, "maxRange": 1000, "area": 9, 
						"castTime": 0.5, "castStarted": -1000, "cooldown": 5, "castLocation": Vector2.ZERO
					},
				2:
					{
						"effect": null, "casting": false, "lastCasted": -1000,
						"indicating": false, "maxRange": 200, "castTime": 0.5, 
						"castStarted": -1000, "cooldown": 7, "castLocation": Vector2.ZERO
					},
				3:
					{
						"casting": false, "lastCasted": -1000, "activeTime": 10,
						"castTime": 1, "castStarted": -1000, "cooldown": 25
					}
				}

func setSkin (newSkin):
	skin = newSkin

func setDirection (dir):
	direction = dir

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func setAnimation (anim):
	animation = anim

func setScytheActive (isActive):
	scytheActive = isActive
	if isActive:
		$DirtTimerScythe.start()
		$Schyte.visible = true
	else:
		$DirtTimerScythe.stop()
		$Schyte.visible = false

func setScytheRotation (rot):
	scytheRotation = rot
	if id != Client.selfPeerID:
		$Schyte.rotation = rot

func _ready():
	set_physics_process(true)
	$DirtTimer.start()
	
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

func anySkillCasting ():
	return (skills[1]["casting"] || skills[2]["casting"] || skills[3]["casting"])

func anySkillIndicating ():
	return (skills[1]["indicating"] || skills[2]["indicating"])

func findNextDirection ():
	if desiredDirection == direction:
		return
	if directionsString[direction] < directionsString[desiredDirection]:
		direction = directionsInt[directionsString[direction] + 1]
	else:
		direction = directionsInt[directionsString[direction] - 1]

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
	
func skillSystem ():
	# SKILL 1
	if !skills[1]["casting"]:
		if skills[1]["lastCasted"] + skills[1]["cooldown"] > Vars.time:
			get_tree().root.get_node("Main/CanvasLayer/Skill1/Progress").get_material().set_shader_param("value",(Vars.time - skills[1]["lastCasted"]) / skills[1]["cooldown"] * 100)
			get_tree().root.get_node("Main/CanvasLayer/Skill1/Progress").modulate = Color.red
		else:
			get_tree().root.get_node("Main/CanvasLayer/Skill1/Progress").get_material().set_shader_param("value",101)
			get_tree().root.get_node("Main/CanvasLayer/Skill1/Progress").modulate = Color.lime
	
	# INDICATING START
	if Input.is_action_just_pressed('skill1') && skills[1]["lastCasted"] + skills[1]["cooldown"] <= Vars.time && !anySkillCasting() && !skills[1]["indicating"]:
		if skills[2]["indicating"]:
			skills[2]["indicating"] = false
			skills[2]["effect"].queue_free()
			arrowEffect.queue_free()
		skills[1]["indicating"] = true
		skills[1]["effect"] = preload("res://Prefabs/Effects/SeedEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		skills[1]["effect"].drawArea = true
		skills[1]["effect"].areaOfEffect = skills[1]["area"]
		get_tree().root.get_node("Main").add_child(skills[1]["effect"])
		get_tree().root.get_node("Main").add_child(arrowEffect)
	elif Input.is_action_just_pressed('skill1') && skills[1]["indicating"] == true:
		skills[1]["indicating"] = false
		skills[1]["effect"].queue_free()
		arrowEffect.queue_free()
	
	# INDICATING UPDATE
	if skills[1]["indicating"]:
		skills[1]["effect"].position = get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([position,get_global_mouse_position()])
		var canCast = position.distance_to(get_global_mouse_position()) <= skills[1]["maxRange"]
		if !canCast:
			arrowEffect.default_color = Color.red
		else:
			arrowEffect.default_color = Color.cyan
		if Input.is_action_just_pressed("leftclick") && canCast:
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
			skills[1]["indicating"] = false
			skills[1]["casting"] = true
			get_tree().root.get_node("Main/CanvasLayer/Skill1/Progress").modulate = Color.blue
			skills[1]["castLocation"] = get_global_mouse_position()
			canMove = false
			skills[1]["castStarted"] = Vars.time
			skills[1]["effect"].queue_free()
			arrowEffect.queue_free()
	
	# CASTING UPDATE
	if skills[1]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[1]["castStarted"]) / skills[1]["castTime"] * 100
		if skills[1]["castStarted"] + skills[1]["castTime"] <= Vars.time:
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/Seed.tscn",{"whoSummoned": Client.selfPeerID, "position": position, "endPosition": skills[1]["castLocation"], "area": skills[1]["area"]})
			canMove = true
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
			skills[1]["casting"] = false
			skills[1]["lastCasted"] = Vars.time
	
	# SKILL 2
	
	if !skills[2]["casting"]:
		if skills[2]["lastCasted"] + skills[2]["cooldown"] > Vars.time:
			get_tree().root.get_node("Main/CanvasLayer/Skill2/Progress").get_material().set_shader_param("value",(Vars.time - skills[2]["lastCasted"]) / skills[2]["cooldown"] * 100)
			get_tree().root.get_node("Main/CanvasLayer/Skill2/Progress").modulate = Color.red
		else:
			get_tree().root.get_node("Main/CanvasLayer/Skill2/Progress").get_material().set_shader_param("value",101)
			get_tree().root.get_node("Main/CanvasLayer/Skill2/Progress").modulate = Color.lime
	
	# INDICATING START
	if Input.is_action_just_pressed('skill2') && skills[2]["lastCasted"] + skills[2]["cooldown"] <= Vars.time && !anySkillCasting() && !skills[2]["indicating"]:
		if skills[1]["indicating"]:
			skills[1]["indicating"] = false
			skills[1]["effect"].queue_free()
			arrowEffect.queue_free()
		skills[2]["indicating"] = true
		skills[2]["effect"] = preload("res://Prefabs/Effects/BearTrapEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		get_tree().root.get_node("Main").add_child(skills[2]["effect"])
		get_tree().root.get_node("Main").add_child(arrowEffect)
	elif Input.is_action_just_pressed('skill2') && skills[2]["indicating"] == true:
		skills[2]["indicating"] = false
		skills[2]["effect"].queue_free()
		arrowEffect.queue_free()
	
	# INDICATING UPDATE
	if skills[2]["indicating"]:
		skills[2]["effect"].position = get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([position,get_global_mouse_position()])
		var canCast = position.distance_to(get_global_mouse_position()) <= skills[2]["maxRange"]
		if !canCast:
			arrowEffect.default_color = Color.red
		else:
			arrowEffect.default_color = Color.cyan
		if Input.is_action_just_pressed("leftclick") && canCast:
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
			skills[2]["indicating"] = false
			skills[2]["casting"] = true
			get_tree().root.get_node("Main/CanvasLayer/Skill2/Progress").modulate = Color.blue
			skills[2]["castLocation"] = get_global_mouse_position()
			canMove = false
			skills[2]["castStarted"] = Vars.time
			skills[2]["effect"].queue_free()
			arrowEffect.queue_free()
	
	# CASTING UPDATE
	if skills[2]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[2]["castStarted"]) / skills[2]["castTime"] * 100
		if skills[2]["castStarted"] + skills[2]["castTime"] <= Vars.time:
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/BearTrap.tscn",{"whoSummoned": Client.selfPeerID, "position": position, "endPosition": skills[2]["castLocation"]})
			canMove = true
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
			skills[2]["casting"] = false
			skills[2]["lastCasted"] = Vars.time
	
	# SKILL 3
	
	if !skills[3]["casting"]:
		if skills[3]["lastCasted"] + skills[3]["cooldown"] > Vars.time:
			get_tree().root.get_node("Main/CanvasLayer/Skill3/Progress").get_material().set_shader_param("value",(Vars.time - skills[3]["lastCasted"]) / skills[3]["cooldown"] * 100.0)
			get_tree().root.get_node("Main/CanvasLayer/Skill3/Progress").modulate = Color.red
		else:
			get_tree().root.get_node("Main/CanvasLayer/Skill3/Progress").get_material().set_shader_param("value",101.0)
			get_tree().root.get_node("Main/CanvasLayer/Skill3/Progress").modulate = Color.lime
	
	# INDICATING START
	if Input.is_action_just_pressed('skill3') && skills[3]["lastCasted"] + skills[3]["cooldown"] <= Vars.time && !anySkillCasting():
		if skills[1]["indicating"]:
			skills[1]["indicating"] = false
			skills[1]["effect"].queue_free()
			arrowEffect.queue_free()
		if skills[2]["indicating"]:
			skills[2]["indicating"] = false
			skills[2]["effect"].queue_free()
			arrowEffect.queue_free()
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = true
		skills[3]["casting"] = true
		get_tree().root.get_node("Main/CanvasLayer/Skill3/Progress").modulate = Color.blue
		canMove = false
		skills[3]["castStarted"] = Vars.time
	
	# CASTING UPDATE
	if skills[3]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[3]["castStarted"]) / skills[3]["castTime"] * 100
		if skills[3]["castStarted"] + skills[3]["castTime"] <= Vars.time:
			setScytheActive(true)
			get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"scytheActive": true})
			canMove = true
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
			skills[3]["casting"] = false
			skills[3]["lastCasted"] = Vars.time
	if Vars.time - skills[3]["lastCasted"] >= skills[3]["activeTime"]:
		setScytheActive(false)
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"scytheActive": false})

func _physics_process(delta):
	animationHandler()
	
	if id != Client.selfPeerID:
		return
	# Skill System
	
	skillSystem()
	
	# Animation
	
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
	var sendingDict = {"position": position, "animation": animation, "direction": direction}
	if scytheActive:
		sendingDict["scytheRotation"] = $Schyte.rotation
	get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)

func _on_DirtTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !Vars.dirts.has(vec):
			Vars.tryPlaceDirt(Client.selfPeerID,vec,team)
		elif Vars.dirts[vec].team != team:
			Vars.tryChangeDirt(Client.selfPeerID,vec,team)


func _on_DirectionTimer_timeout():
	findNextDirection()
