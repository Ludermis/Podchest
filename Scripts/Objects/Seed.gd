extends Sprite

var endPosition
var whoSummoned
var speed = 512
var planted = false
var area
var id
var materialScale = 1.0
var timeToExplode = 5

func _ready():
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	$Particles2D.process_material.scale = materialScale
	if Client.selfPeerID == Vars.roomMaster:
		if planted:
			timeToExplode -= delta
		else:
			position = position.move_toward(endPosition,delta * speed)
		materialScale += delta
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"position": position, "materialScale": materialScale, "planted": planted, "timeToExplode": timeToExplode})
		if planted == false && position.distance_to(endPosition) < 0.1:
			planted = true
		if timeToExplode < 0:
			for x in range(1,area / 2 + 2):
				for y in range (-area / 2 + (x - 1),area / 2 + 1 - (x - 1)):
					dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64) + Vector2(y * 64, (x - 1) * 64))
			for x in range(1,area / 2 + 1):
				for y in range (-area / 2 + x,area / 2 + 1 - x):
					dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64) + Vector2(y * 64, -x * 64))
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()

func dirtToPos (pos):
	if !Vars.dirts.has(pos):
		get_tree().root.get_node("Main").rpc_id(1,"dirtCreated",Client.selfPeerID,pos,Vars.objects[whoSummoned]["team"])
	elif Vars.dirts[pos].team != Vars.objects[whoSummoned]["team"]:
		get_tree().root.get_node("Main").rpc_id(1,"dirtChanged",Client.selfPeerID,pos,Vars.objects[whoSummoned]["team"])
