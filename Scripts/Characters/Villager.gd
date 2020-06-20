extends KinematicBody2D

var velocity = Vector2.ZERO
var jumpHeight = 1024
var acceleration = 64
var maxSpeed = 384
var peerID
var team = -1

var castingSkill1 = false
var arrowEffect : Node2D
var skill1Effect : Node2D

func _ready():
	if peerID == Client.selfPeerID:
		print("Timer started")
		$DirtTimer.start()

func setup (id, pos, color, t):
	peerID = id
	position = pos
	set_physics_process(true)
	Vars.players[peerID] = self
	modulate = color
	team = t

func _physics_process(delta):
	if peerID != Client.selfPeerID:
		return
	
	# Skill System
	
	if Input.is_action_just_pressed('skill1') && castingSkill1 == false:
		castingSkill1 = true
		skill1Effect = preload("res://Prefabs/Effects/SeedEffect.tscn").instance()
		arrowEffect = preload("res://Prefabs/Effects/ArrowEffect.tscn").instance()
		get_tree().root.get_node("Main").add_child(skill1Effect)
		get_tree().root.get_node("Main").add_child(arrowEffect)
	elif Input.is_action_just_pressed('skill1') && castingSkill1 == true:
		castingSkill1 = false
		skill1Effect.queue_free()
		arrowEffect.queue_free()
	
	if castingSkill1:
		skill1Effect.position = get_global_mouse_position()
		arrowEffect.points = PoolVector2Array([position,get_global_mouse_position()])
	
	if Input.is_action_pressed('up'):
		if !$Sprite.playing || $Sprite.animation != "up":
			$Sprite.play("up")
			get_tree().root.get_node("Main").rpc_id(1,"updateAnimation",Client.selfPeerID,$Sprite.animation)
	elif Input.is_action_pressed('down'):
		if !$Sprite.playing || $Sprite.animation != "down":
			$Sprite.play("down")
			get_tree().root.get_node("Main").rpc_id(1,"updateAnimation",Client.selfPeerID,$Sprite.animation)
	elif Input.is_action_pressed('right'):
		if !$Sprite.playing || $Sprite.animation != "right":
			$Sprite.play("right")
			get_tree().root.get_node("Main").rpc_id(1,"updateAnimation",Client.selfPeerID,$Sprite.animation)
	elif Input.is_action_pressed('left'):
		if !$Sprite.playing || $Sprite.animation != "left":
			$Sprite.play("left")
			get_tree().root.get_node("Main").rpc_id(1,"updateAnimation",Client.selfPeerID,$Sprite.animation)
	else:
		if $Sprite.playing:
			$Sprite.stop()
			$Sprite.frame = 0
			get_tree().root.get_node("Main").rpc_id(1,"updateAnimation",Client.selfPeerID,"stop")
	
	if Input.is_action_just_released('wheeldown'):
		$Camera2D.zoomLevel = min($Camera2D.zoomLevel + 1,12)
	if Input.is_action_just_released('wheelup'):
		$Camera2D.zoomLevel = max($Camera2D.zoomLevel - 1,1)
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
	velocity = move_and_slide(velocity,Vector2.UP)
	get_tree().root.get_node("Main").rpc_unreliable_id(1,"updatePosition",Client.selfPeerID,position)

func _on_DirtTimer_timeout():
	var vec = Vars.optimizeVector(position + Vector2(32,32),64)
	if !Vars.dirts.has(vec):
		get_tree().root.get_node("Main").rpc_id(1,"dirtCreated",Client.selfPeerID,vec,modulate)
	elif Vars.dirts[vec].team != Vars.myTeam:
		get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",Client.selfPeerID,vec,modulate)
