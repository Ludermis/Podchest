extends Sprite

var startPos
var endPos
var whoSummoned
var speed = 512
var planted = false
var area
var summonedTime
var timeToExplode = 5

func _ready():
	position = startPos

func _process(delta):
	position = position.move_toward(endPos,delta * speed)
	$Particles2D.process_material.scale += delta
	if planted == false && position.distance_to(endPos) < 0.1:
		planted = true
		summonedTime = Vars.time
	if planted && Vars.time - summonedTime >= timeToExplode:
		if Client.selfPeerID == whoSummoned:
			for x in range(1,area / 2 + 2):
				for y in range (-area / 2 + (x - 1),area / 2 + 1 - (x - 1)):
					dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64) + Vector2(y * 64, (x - 1) * 64))
			for x in range(1,area / 2 + 1):
				for y in range (-area / 2 + x,area / 2 + 1 - x):
					dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64) + Vector2(y * 64, -x * 64))
		queue_free()

func dirtToPos (pos):
	if !Vars.dirts.has(pos):
		get_tree().root.get_node("Main").rpc_id(1,"dirtCreated",Client.selfPeerID,pos,Vars.teams[Vars.myTeam]["color"])
	elif Vars.dirts[pos].team != Vars.myTeam:
		get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",Client.selfPeerID,pos,Vars.teams[Vars.myTeam]["color"])
