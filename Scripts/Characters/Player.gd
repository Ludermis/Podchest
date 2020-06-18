extends KinematicBody2D

var velocity = Vector2.ZERO
var jumpHeight = 1024
var acceleration = 64
var maxSpeed = 384
var peerID
var team = -1

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
	elif Vars.dirts[vec].realColor != modulate:
		get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",Client.selfPeerID,vec,modulate)
