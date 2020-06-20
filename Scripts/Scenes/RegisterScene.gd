extends Node2D


func _ready():
	pass

remote func registerCompleted ():
	$Message.modulate = Color.lime
	$Message.text = "Registration completed! You can go back and login now."
	$Message.visible = true
	$Username.visible = false
	$Password.visible = false
	$RegisterButton.visible = false

remote func registerFailed (msg):
	$Message.modulate = Color.red
	$Message.text = msg
	$Message.visible = true
