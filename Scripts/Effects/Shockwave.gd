extends Sprite

var id

func _ready():
	$AnimationPlayer.play('blow')

func _on_AnimationPlayer_animation_finished(anim_name):
	if Vars.roomMaster == Client.selfPeerID:
		get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
		Vars.objects.erase(id)
		queue_free()
