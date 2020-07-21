extends KinematicBody2D

var whoSummoned
var speed = 128 * 1.5
var id
var dir = Vector2(0,0)
var lifeRemaining = 15.0
var returnMode = false setget setReturnMode
var animation = "default" setget setAnimation

func setReturnMode (rtnMode):
	if returnMode == false && rtnMode == true:
		returnMode = rtnMode
		$PaintTimer.wait_time = 0.05

func setAnimation (anim):
	animation = anim
	$AnimatedSprite.play(anim)

func _ready():
	dir = Vector2(rand_range(-1,1),rand_range(-1,1))
	dir = dir.normalized()
	Vars.objects[whoSummoned].clocks.append(id)
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	if Client.selfPeerID == Vars.roomMaster:
		if returnMode == false:
			lifeRemaining -= delta
			move_and_slide(speed * dir,Vector2.UP)
			if get_slide_count() > 0:
				var collision = get_slide_collision(0)
				if collision != null:
					dir = dir.bounce(collision.normal)
			if lifeRemaining <= 0:
				get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Effects/ClockDestroyEffect.tscn",{"position": position, "modulate": modulate})
				get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
				queue_free()
				return
		else:
			move_and_slide(speed * 5 * (Vars.objects[whoSummoned].position - position).normalized(),Vector2.UP)
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,{"position": position, "lifeRemaining": lifeRemaining, "returnMode": returnMode})

func dirtToPos (pos):
	if !Vars.dirts.has(pos):
		Vars.tryPlaceDirt(Client.selfPeerID,Vars.objects[whoSummoned]["id"],pos,Vars.objects[whoSummoned]["team"])
	elif Vars.dirts[pos].team != Vars.objects[whoSummoned]["team"]:
		Vars.tryChangeDirt(Client.selfPeerID,pos,Vars.objects[whoSummoned]["id"],Vars.objects[whoSummoned]["team"])

func _on_PaintTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		dirtToPos(Vars.optimizeVector(position + Vector2(32,32),64))


func _on_ChangeDirectionTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		dir = Vector2(rand_range(-1,1),rand_range(-1,1))
		dir = dir.normalized()


func _on_Area2D_body_entered(body):
	pass


func _on_Clock_tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)


func _on_Area2D_area_entered(area):
	if Client.selfPeerID == Vars.roomMaster:
		if area.get_node("..").is_in_group("Player"):
			var body = area.get_node("..")
			if returnMode == false:
				if body.is_in_group("Player") && Vars.objects[body.id]["team"] != Vars.objects[whoSummoned]["team"]:
					get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Effects/ClockDestroyEffect.tscn",{"position": position, "modulate": modulate})
					get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
					queue_free()
			else:
				if body.is_in_group("Player") && body.id == whoSummoned:
					body.reduceQCooldown = 4
					get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,body.id,{"reduceQCooldown": 4})
					get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Effects/ClockDestroyEffect.tscn",{"position": position, "modulate": modulate})
					get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
					queue_free()
