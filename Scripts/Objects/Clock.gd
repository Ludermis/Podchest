extends KinematicBody2D

var whoSummoned
var speed = 128 * 1.5
var id
var dir = Vector2(0,0)

func _ready():
	dir = Vector2(rand_range(-1,1),rand_range(-1,1))
	dir = dir.normalized()
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	if Client.selfPeerID == Vars.roomMaster:
		move_and_slide(speed * dir,Vector2.UP)
		if get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision != null:
				dir = dir.bounce(collision.normal)
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"position": position})

func dirtToPos (pos):
	if !Vars.dirts.has(pos):
		Vars.tryPlaceDirt(Client.selfPeerID,pos,Vars.objects[whoSummoned]["team"])
	elif Vars.dirts[pos].team != Vars.objects[whoSummoned]["team"]:
		Vars.tryChangeDirt(Client.selfPeerID,pos,Vars.objects[whoSummoned]["team"])


func _on_PaintTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64))


func _on_ChangeDirectionTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		dir = Vector2(rand_range(-1,1),rand_range(-1,1))
		dir = dir.normalized()
