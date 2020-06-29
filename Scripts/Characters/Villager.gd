extends KinematicBody2D

var velocity = Vector2.ZERO
var jumpHeight = 1024
var acceleration = 64
var maxSpeed = 384
var id
var team = -1
var canMove = true
var arrowEffect : Node2D

var animation = "" setget setAnimation
var animationPlaying = false setget setAnimationPlaying
var scytheActive = false setget setScytheActive
var scytheRotation = 0 setget setScytheRotation
var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var characterName = "Villager"

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
	if skin != "":
		$Sprite.frames = load("res://SavedResources/SpriteFrames/" + skin + ".tres")
	else:
		$Sprite.frames = load("res://SavedResources/SpriteFrames/" + characterName + ".tres")

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func setAnimation (anim):
	animation = anim
	$Sprite.animation = anim

func setAnimationPlaying (playing):
	animationPlaying = playing
	$Sprite.playing = playing
	if playing == false:
		$Sprite.frame = 5

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

func anySkillCasting ():
	return (skills[1]["casting"] || skills[2]["casting"] || skills[3]["casting"])

func anySkillIndicating ():
	return (skills[1]["indicating"] || skills[2]["indicating"])

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
			$Sprite.play("cast")
			skills[1]["castStarted"] = Vars.time
			skills[1]["effect"].queue_free()
			arrowEffect.queue_free()
	
	# CASTING UPDATE
	if skills[1]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[1]["castStarted"]) / skills[1]["castTime"] * 100
		if skills[1]["castStarted"] + skills[1]["castTime"] <= Vars.time:
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/Seed.tscn",{"whoSummoned": Client.selfPeerID, "position": position, "endPosition": skills[1]["castLocation"], "area": skills[1]["area"]})
			canMove = true
			$Sprite.stop()
			$Sprite.animation = "down"
			$Sprite.frame = 5
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
			$Sprite.play("cast")
			skills[2]["castStarted"] = Vars.time
			skills[2]["effect"].queue_free()
			arrowEffect.queue_free()
	
	# CASTING UPDATE
	if skills[2]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[2]["castStarted"]) / skills[2]["castTime"] * 100
		if skills[2]["castStarted"] + skills[2]["castTime"] <= Vars.time:
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/BearTrap.tscn",{"whoSummoned": Client.selfPeerID, "position": position, "endPosition": skills[2]["castLocation"]})
			canMove = true
			$Sprite.stop()
			$Sprite.animation = "down"
			$Sprite.frame = 5
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
		$Sprite.play("cast")
		skills[3]["castStarted"] = Vars.time
	
	# CASTING UPDATE
	if skills[3]["casting"]:
		get_tree().root.get_node("Main/CanvasLayer/ProgressBar").value = (Vars.time - skills[3]["castStarted"]) / skills[3]["castTime"] * 100
		if skills[3]["castStarted"] + skills[3]["castTime"] <= Vars.time:
			setScytheActive(true)
			get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"scytheActive": true})
			canMove = true
			$Sprite.stop()
			$Sprite.animation = "down"
			$Sprite.frame = 5
			get_tree().root.get_node("Main/CanvasLayer/ProgressBar").visible = false
			skills[3]["casting"] = false
			skills[3]["lastCasted"] = Vars.time
	if Vars.time - skills[3]["lastCasted"] >= skills[3]["activeTime"]:
		setScytheActive(false)
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"scytheActive": false})

func _physics_process(delta):
	if id != Client.selfPeerID:
		return
	# Skill System
	
	skillSystem()
	
	if canMove:
		if Input.is_action_pressed('up'):
			if !$Sprite.playing || $Sprite.animation != "up":
				$Sprite.play("up")
		elif Input.is_action_pressed('down'):
			if !$Sprite.playing || $Sprite.animation != "down":
				$Sprite.play("down")
		elif Input.is_action_pressed('right'):
			if !$Sprite.playing || $Sprite.animation != "right":
				$Sprite.play("right")
		elif Input.is_action_pressed('left'):
			if !$Sprite.playing || $Sprite.animation != "left":
				$Sprite.play("left")
		else:
			if $Sprite.playing:
				$Sprite.stop()
				$Sprite.frame = 5
	
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
	var sendingDict = {"position": position, "animation": $Sprite.animation, "animationPlaying": $Sprite.playing}
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
