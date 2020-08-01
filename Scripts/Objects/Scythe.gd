extends Sprite


func _ready():
	pass

func _process(delta):
	if visible && Client.selfPeerID == $"..".id:
		look_at(get_global_mouse_position())
		rotation = rotation + deg2rad(27)
