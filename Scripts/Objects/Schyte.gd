extends Sprite


func _ready():
	pass

#func _draw():
#	if Client.selfPeerID == $"..".id:
#		var optimizedPos = Vars.optimizeVector($"..".position + Vector2(32,32),64)
#		var vec = (get_global_mouse_position() - optimizedPos).normalized()
#		vec = Vars.optimizeVector(optimizedPos + vec * 64 + Vector2(32,32), 64)
#		draw_line(to_local(optimizedPos), to_local(vec), Color(255, 0, 0), 3)

func _process(delta):
	if visible && Client.selfPeerID == $"..".id:
		look_at(get_global_mouse_position())
		rotation = rotation + deg2rad(27)

func dirtToPos (pos):
	if !Vars.dirts.has(pos):
		Vars.tryPlaceDirt(Client.selfPeerID,pos,$"..".team)
	elif Vars.dirts[pos].team != $"..".team:
		Vars.tryChangeDirt(Client.selfPeerID,pos,$"..".team)


func _on_DirtTimerScythe_timeout():
	if visible && Client.selfPeerID == $"..".id:
		var optimizedPos = Vars.optimizeVector($"..".position + Vector2(32,32),64)
		var vec = (get_global_mouse_position() - optimizedPos).normalized()
		vec = Vars.optimizeVector(optimizedPos + vec * 64 + Vector2(32,32), 64)
		dirtToPos(vec)
