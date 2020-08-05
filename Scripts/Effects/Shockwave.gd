extends Sprite

var id

func _ready():
	$AnimationPlayer.play('blow')

func _on_AnimationPlayer_animation_finished(anim_name):
	visible = false
