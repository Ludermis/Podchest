extends KinematicBody2D

var velocity = Vector2.ZERO
var jumpHeight = 1024
var acceleration = 64
var maxSpeed = 384
var peerID

func _ready():
	pass

func setup (id, pos, color):
	peerID = id
	position = pos
	set_physics_process(true)
	Vars.players[peerID] = self
	modulate = color

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
